#! /bin/bash

rm -rf /srv/aegir
crontab -r -u aegir
userdel aegir
cd /etc/apache2/conf.d && rm aegir.conf
/etc/init.d/apache2 restart

