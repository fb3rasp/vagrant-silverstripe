#!/bin/bash

echo "Provisioning virtual machine..." 2> /dev/null

sed -i 's/http:\/\/us.archive.ubuntu.com/http:\/\/ftp.citylink.co.nz/g' /etc/apt/sources.list
apt-get update

echo "Updating packages/repositories" 2> /dev/null

apt-get install python-software-properties build-essential -y 2> /dev/null
add-apt-repository ppa:ondrej/php5 -y 2> /dev/null
apt-get update 2> /dev/null

echo "Installing Git" 2> /dev/null
apt-get install git -y 2> /dev/null

echo "Installing Apache2"
apt-get install apache2 -y 2> /dev/null

echo -e "\n--- Allowing Apache override to all ---\n"
sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf

echo "Enabling Apache2 mod-rewrite"
a2enmod rewrite > /dev/null 2> /dev/null

echo "Installing PHP"
apt-get install php5 libapache2-mod-php5 -y 2> /dev/null

echo "Installing PHP extensions"
apt-get install php5-common php5-dev php5-cli php5-fpm php5-tidy -y 2> /dev/null
apt-get install curl php5-curl php5-gd php5-mcrypt php5-mysql -y 2> /dev/null
apt-get install php5-xsl -y 2> /dev/null

echo -e "\n--- Set PHP Timezone to Europe/Berlin ---\n"
sudo sed -i "s/;date.timezone =/date.timezone = Europe\/Berlin/g" /etc/php5/apache2/php.ini

echo -e "\n--- We definitly need to see the PHP errors, turning them on ---\n"
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/apache2/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/apache2/php.ini

echo "Preparing MySQL"
apt-get install debconf-utils -y 2> /dev/null

debconf-set-selections <<< "mysql-server mysql-server/root_password password root"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password root"

echo "Installing MySQL"
apt-get install mysql-server libapache2-mod-auth-mysql -y 2> /dev/null

if [ "$INSTALL_DEBUG" == "true" ]
then
    echo "Installing xDebug"
    sudo apt-get install php5-xdebug -y 2> /dev/null

    XDEBUG=`find / -name 'xdebug.so'`
    IDEKEY="$XDEBUG_IDEKEY"

    echo -e "\n--- Configure xDebug and enable remote debuggin via idekey: '$IDEKEY'"
    cat >> /etc/php5/apache2/php.ini << "EOF"
zend_extension="$XDEBUG"
xdebug.remote_enable=1
xdebug.remote_handler=dbgp
xdebug.remote_mode=req
xdebug.remote_autostart=1
xdebug.remote_connect_back=1
xdebug.remote_host=192.168.30.10
xdebug.remote_port=9000
xdebug.idekey="$IDEKEY"
EOF
fi

if [ "$DEPENDENCY_MANAGEMENET" == "true" ]
then
    #
    # Install dependencies management components (npm, bower and gulp)
    apt-get install -y npm
    apt-get install -y nodejs-legacy

    npm install -g bower
    npm install -g gulp

    echo "Install composer"
    curl -s https://getcomposer.org/installer | php
    mv composer.phar /usr/local/bin/composer

    echo "Install SSPAK"
    curl -sS https://silverstripe.github.io/sspak/install | php -- /usr/local/bin;
fi

echo "Remove default index.html"
rm -f /var/www/hml/index.html

cat >> /etc/apache2/sites-available/001-silverstripe.conf << "EOF"
<VirtualHost *:80>
	ServerAdmin webmaster@localhost
	DocumentRoot /vagrant/www/

	ErrorLog /vagrant/logs/error.log
	CustomLog /vagrant/logs/access.log combined

    <Directory /vagrant/www/>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

a2dissite 000-default.conf
a2ensite 001-silverstripe.conf

service apache2 restart 2> /dev/null