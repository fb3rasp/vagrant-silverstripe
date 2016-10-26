#!/bin/bash

echo "Drop databases..."

cd /vagrant/backup

for i in *.sql
do
	file=$i
	database=`sed "s/.sql//g" <<< $i`
	echo "Drop database $database"
	
	mysql -u root -proot -e"drop database $database;"
done