#! /bin/bash

clear

read -p "This will refresh your build/install...\n\nEnter Database Name?" db

rm -rf /srv/aegir
crontab -r -u aegir
userdel aegir --remove
userdel support --remove
userdel itaine --remove
rm /etc/apache2/conf.d/aegir.conf

echo -e "\n Removing Database"
mysql -e 'drop database $db;'

rm -r saasmaster
echo -e "\n*** Clone Repository ***"
git clone git://github.com/Pearance/saasmaster.git

