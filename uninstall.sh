#! /bin/bash

clear
rm -rf /srv/aegir
crontab -r -u aegir
userdel aegir
userdel support
rm /etc/apache2/conf.d/aegir.conf

