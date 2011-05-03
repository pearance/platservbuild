#! /bin/bash

clear
rm -rf /srv/aegir
crontab -r -u aegir
userdel aegir --force --remove
userdel support --force --remove
rm /etc/apache2/conf.d/aegir.conf

rm saasmaster.sh
curl -O https://github.com/Pearance/saasmaster/raw/master/saasmaster.sh && chmod 700 saas$

