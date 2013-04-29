#! /bin/bash

# VARIABLES # {{{
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


# }}}
# FUNCTIONS # {{{
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



# }}}
# AEGIR BUILD # {{{
###################################################################

# Get Input
clear
echo
read -p "Enter hostname: " newhostname



# Update System
aptitude update
aptitude full-upgrade -y
echo -e "\n${BLD}${RED} Update System ${BLD}${GREEN}| Done!${RESET}\n"



# Install Packages
aptitude install -y apache2 php5 php5-cli php5-gd php5-mysql php5-curl
aptitude install -y mysql-server phpmyadmin landscape-common postfix sudo rsync
aptitude install -y git-core update-notifier-common zip
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



# Create Aegir Account
adduser --system --group --home /srv/aegir aegir
adduser aegir www-data
echo -e "\n${BLD}${RED} Create Aegir Account ${BLD}${GREEN}| Done!${RESET}\n"



# Create Support Account
# if [ $(id -u) -eq 0 ]; then
#   read -s -p "Enter password for support account: " password
#   echo -e "\n"
#   egrep "^support" /etc/passwd >/dev/null
#   if [ $? -eq 0 ]; then
#       echo -e "\nPearance support account already exists!"
#   else
#     pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
#     useradd -m -p $pass -s /bin/bash support
#     usermod -G www-data,aegir,sudo support
#     cd /home/support/
#     su -s /bin/bash support -c 'cd && curl -L https://raw.github.com/pearance/shelltopia/master/.aux/install.sh | sh'
#
#     [ $? -eq 0 ] && echo -e "\n${BLD}${RED} Create Support Account ${BLD}${GREEN}| Done!${RESET}\n" || echo -e "\nFailed to add support account!"
#   fi
# else
#   echo -e "\nOnly root may add a user to the system\n"
# fi



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
su -s /bin/bash aegir -c "git clone --branch master http://git.drupal.org/project/drush.git /srv/aegir/drush/"
su -s /bin/bash aegir -c "cd ~/drush/ && git checkout 7.x-4.5"
su -s /bin/bash aegir -c "mkdir -p ~/bin/ && cd ~/bin/"
su -s /bin/bash aegir -c "ln -s /srv/aegir/drush/drush drush"
echo -e "\n${BLD}${RED} Install Drush ${BLD}${GREEN}| Done!${RESET}\n"



# Install Provision
cd /srv/aegir
su -s /bin/bash aegir -c 'mkdir .drush'
su -s /bin/bash aegir -c '/srv/aegir/drush/drush dl --destination=/srv/aegir/.drush provision-6.x'
echo -e "\n${BLD}${RED} Install Provision ${BLD}${GREEN}| Done!${RESET}\n"



# Install Hostmaster
su -s /bin/bash aegir -c 'cd /srv/aegir && /srv/aegir/drush/drush hostmaster-install'
echo -e "\n${BLD}${RED} Install Hostmaster ${BLD}${GREEN}| Done!${RESET}\n"





# }}}
# POST AEGIR BUILD # {{{
###################################################################
# Install Modules
su -s /bin/bash aegir -c "cd /srv/aegir/hostmaster*/sites/all/"
su -s /bin/bash aegir -c "drush dl hosting_profile_roles"
su -s /bin/bash aegir -c "drush dl hosting_backup_queue"
su -s /bin/bash aegir -c "drush dl hosting_backup_gc"
su -s /bin/bash aegir -c "drush -y en hosting_profile_roles -l lp-*.pearance.com"
su -s /bin/bash aegir -c "drush -y en hosting_backup_queue -l lp-*.pearance.com"
su -s /bin/bash aegir -c "drush -y en hosting_backup_gc -l lp-*.pearance.com"
su -s /bin/bash aegir -c "drush -y en hosting_alias -l lp-*.pearance.com"



# Clone Install Profile
su -s /bin/bash aegir -c "mkdir -p /srv/aegir/platforms/.profiles/"
su -s /bin/bash aegir -c "git clone https://github.com/pearance/pro_101_install_profile.git pro_101"



# Establish Links to Scripts
su -s /bin/bash aegir -c "mkdir -p ~/backups/pre-platservbuild"

	# build script
ln -s ~/platforms/.profiles/pro_101/scripts/pro_101_build.sh /usr/bin/pro101build

	# global.inc
su -s /bin/bash aegir -c "mv ~/config/includes/global.inc ~/backups/pre-platservbuild/global.inc.bak"
su -s /bin/bash aegir -c "ln -s ~/platforms/.profiles/pro_101/scripts/global.inc ~/config/includes/global.inc"

	# install.provision.inc
su -s /bin/bash aegir -c "mv ~/.drush/provision/platform/install.provision.inc ~/backups/pre-platservbuild/install.provision.inc.bak"
su -s /bin/bash aegir -c "ln -s ~/platforms/.profiles/pro_101/scripts/install.provision.inc ~/.drush/provision/platform/install.provision.inc"



# Set Folder Permissions
su -s /bin/bash aegir -c "find ~/clients/ -type -d -exec chmod 775 {} \;"
su -s /bin/bash aegir -c "find ~/config/ -type -d -exec chmod 775 {} \;"
su -s /bin/bash aegir -c "find ~/drush/ -type -d -exec chmod 775 {} \;"
su -s /bin/bash aegir -c "find ~/platforms/ -type -d -exec chmod 775 {} \;"


# Set File Permissions
su -s /bin/bash aegir -c "find ~/clients/ -type -f -exec chmod 664 {} \;"
su -s /bin/bash aegir -c "find ~/config/ -type -f -exec chmod 664 {} \;"
su -s /bin/bash aegir -c "find ~/drush/ -type -f -exec chmod 664 {} \;"
su -s /bin/bash aegir -c "find ~/platforms/ -type -f -exec chmod 664 {} \;"



# }}}
# vim:fdm=marker:
