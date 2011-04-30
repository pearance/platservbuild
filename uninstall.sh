#! /bin/bash

clear
rm -rf /srv/aegir
crontab -r -u aegir
userdel aegir
rm /etc/apache2/conf.d/aegir.conf
/etc/init.d/apache2 restart

