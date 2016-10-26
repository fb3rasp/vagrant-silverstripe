#!/bin/bash

echo "Create databases..."
cd /vagrant/backup

for i in *.sql
do
	file=$i
	database=`sed "s/.sql//g" <<< $i`
	echo "Import database $database from file $file"
	
	mysql -u root -proot -e"create database $database;"
	mysql -u root -proot $database < $file
done