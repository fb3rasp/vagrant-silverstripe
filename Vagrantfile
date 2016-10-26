# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

    config.vm.box = "primalskill/ubuntu-trusty64"

    config.vm.network "private_network", ip: "192.168.33.11"

    config.vm.provider :virtualbox do |vb|
        vb.name = "Vagrant - SilverStripe Dev Machine"
        vb.memory = 1024

        vb.customize ["modifyvm", :id, "--usb", "off"]
        vb.customize ["modifyvm", :id, "--usbehci", "off"]
    end

    config.vm.provision "shell", path:  "provision/provision.sh",
        env: {
            "INSTALL_DEBUG" => "false",
            "DEPENDENCY_MANAGEMENET" => "false",
            "XDEBUG_IDEKEY" => "phpStorm-xdebug"
        }
end
