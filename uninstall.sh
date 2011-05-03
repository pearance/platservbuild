#! /bin/bash

clear
rm -rf /srv/aegir
crontab -r -u aegir
userdel aegir --remove
userdel support --remove
userdel itaine --remove
rm /etc/apache2/conf.d/aegir.conf

rm saasmaster.sh
curl -O https://github.com/Pearance/saasmaster/raw/master/saasmaster.sh && chmod 700 saasmaster.sh && . saasmaster.sh

