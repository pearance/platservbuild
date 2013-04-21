#! /bin/bash

# DEFINE VARIABLES
###################################################################

BLD=$(tput bold)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YLW=$(tput setaf 3)
BLUE=$(tput setaf 4)
PURPLE=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
RESET=$(tput sgr0)


# SCRIPT
###################################################################

# Get input
clear
echo
read -p "Enter hostname: " newhostname



# Update System
aptitude update
aptitude full-upgrade -y
echo -e "\n${BLD}${RED} Update System ${BLD}${GREEN}| Done!${RESET}\n"



# Install Packages
aptitude install -y apache2 php5 php5-cli php5-gd php5-mysql php5-curl mysql-server
aptitude install -y phpmyadmin landscape-common postfix sudo rsync
aptitude install -y bash-completion git-core git-completion update-notifier-common
mysql_secure_installation
echo -e "\n${BLD}${RED} Install Packages ${BLD}${GREEN}| Done!${RESET}\n"



# Update Hostname
echo $newhostname > /etc/hostname
hostname -F /etc/hostname
echo -e "\n${BLD}${RED} Update Hostname ${BLD}${GREEN}| Done!${RESET}\n"



# Configure SSH
/bin/cp -n /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
/bin/cp -f /etc/ssh/sshd_config.bak /etc/ssh/sshd_config
update_sshd_config >> /etc/ssh/sshd_config
/etc/init.d/ssh restart
echo -e "\n${BLD}${RED} Configure SSH ${BLD}${GREEN}| Done!${RESET}\n"



# Configure DNS
/bin/cp -n /etc/hosts /etc/hosts.bak
/bin/cp -f /etc/hosts.bak /etc/hosts
update_hosts >> /etc/hosts
AEGIR_HOST=`uname -n`
echo -e "\n${BLD}${RED} Configure DNS ${BLD}${GREEN}| Done!${RESET}\n"



# Update mcrypt.ini
# update_mcrypt_ini > /etc/php5/cli/conf.d/mcrypt.ini
# echo -e "\n${BLD}${RED} Update mcrypt.ini ${BLD}${GREEN}| Done!${RESET}\n"



# Create Aegir Account
adduser --group --home /srv/aegir aegir
adduser aegir www-data
passwd aegir
su -s /bin/bash aegir -c 'cd && curl -O https://raw.github.com/Bashtopia/Bashtopia/master/.aux/install.sh && chmod 770 install.sh; ./install.sh'
echo -e "\n${BLD}${RED} Create Aegir Account ${BLD}${GREEN}| Done!${RESET}\n"



# Configure Apache
a2enmod rewrite
ln -s /srv/aegir/config/apache.conf /etc/apache2/conf.d/aegir.conf
echo -e "\n${BLD}${RED} Configure Apache ${BLD}${GREEN}| Done!${RESET}\n"



# Configure PHP
echo upload_max_filesize = 5M >> /etc/php5/apache2/php.ini



# Configure Sudo
/bin/cp -n /etc/sudoers /etc/sudoers.bak
/bin/cp -f /etc/sudoers.bak /etc/sudoers
update_sudoers >> /etc/sudoers
echo -e "\n${BLD}${RED} Configure Sudo ${BLD}${GREEN}| Done!${RESET}\n"



# Install Drush
cd /srv/aegir
su -s /bin/bash aegir -c 'git clone --branch master http://git.drupal.org/project/drush.git'
cd drush
su -s /bin/bash aegir -c 'git checkout 7.x-4.5'
echo -e "\n${BLD}${RED} Install Drush ${BLD}${GREEN}| Done!${RESET}\n"



# Install Provision
cd /srv/aegir
su -s /bin/bash aegir -c 'mkdir .drush'
su -s /bin/bash aegir -c '/srv/aegir/drush/drush dl --destination=/srv/aegir/.drush provision-6.x'
echo -e "\n${BLD}${RED} Install Provision ${BLD}${GREEN}| Done!${RESET}\n"



# Install Hostmaster
su -s /bin/bash aegir -c 'cd /srv/aegir && /srv/aegir/drush/drush hostmaster-install'
echo -e "\n${BLD}${RED} Install Hostmaster ${BLD}${GREEN}| Done!${RESET}\n"



# DEFINE FUNCTIONS
###################################################################

function update_hosts {
AEGIR_HOST=`uname -n`
IP=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
cat <<- _EOF_

#######################
# PEARANCE AMMENDMENT #
#######################

$IP         $AEGIR_HOST
_EOF_
}


function update_sshd_config {
cat <<- _EOF_

#######################
# PEARANCE AMMENDMENT #
#######################

ClientAliveInterval 120
_EOF_
}


function update_sudoers {
cat <<- _EOF_

#######################
# PEARANCE AMMENDMENT #
#######################

aegir ALL=NOPASSWD: /usr/sbin/apache2ctl
_EOF_
}



function update_mcrypt_ini {
cat <<- _EOF_
;#######################
;# PEARANCE AMMENDMENT #
;#######################

; configuration for php MCrypt module
extension=mcrypt.so
_EOF_
}

