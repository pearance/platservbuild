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
aptitude install -y apache2 php5 php5-cli php5-gd php5-mysql php5-curl \
mysql-server phpmyadmin landscape-common postfix sudo rsync git-core \
update-notifier-common zip zsh drush

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



# Install Provision
cd /srv/aegir
su -s /bin/bash aegir -c 'mkdir .drush'
su -s /bin/bash aegir -c 'drush dl --destination=/srv/aegir/.drush provision-6.x'
echo -e "\n${BLD}${RED} Install Provision ${BLD}${GREEN}| Done!${RESET}\n"



# Install Hostmaster
su -s /bin/bash aegir -c 'cd /srv/aegir && drush hostmaster-install'
echo -e "\n${BLD}${RED} Install Hostmaster ${BLD}${GREEN}| Done!${RESET}\n"





# }}}
# POST AEGIR BUILD # {{{
###################################################################
# Install Modules
su -s /bin/bash aegir -c "cd ~/hostmaster*/sites/all/ && drush dl hosting_profile_roles"
su -s /bin/bash aegir -c "cd ~/hostmaster*/sites/all/ && drush dl hosting_backup_queue"
su -s /bin/bash aegir -c "cd ~/hostmaster*/sites/all/ && drush dl hosting_backup_gc"
su -s /bin/bash aegir -c "cd ~/hostmaster*/sites/all/ && drush -y en hosting_profile_roles -l $newhostname"
su -s /bin/bash aegir -c "cd ~/hostmaster*/sites/all/ && drush -y en hosting_backup_queue -l $newhostname"
su -s /bin/bash aegir -c "cd ~/hostmaster*/sites/all/ && drush -y en hosting_backup_gc -l $newhostname"
su -s /bin/bash aegir -c "cd ~/hostmaster*/sites/all/ && drush -y en hosting_alias -l $newhostname"



# Clone Install Profile
su -s /bin/bash aegir -c "mkdir -p /srv/aegir/platforms/.profiles/"
su -s /bin/bash aegir -c "git clone https://github.com/pearance/pro_101_install_profile.git pro_101"



# Establish Links to Scripts
su -s /bin/bash aegir -c "mkdir -p ~/backups/pre-platservbuild"
	# build script
ln -s ~/platforms/.profiles/pro_101/scripts/pro_101_build.sh /usr/local/bin/pro101build
	# global.inc
su -s /bin/bash aegir -c "mv ~/config/includes/global.inc ~/backups/pre-platservbuild/global.inc.bak"
su -s /bin/bash aegir -c "ln -s ~/platforms/.profiles/pro_101/scripts/global.inc ~/config/includes/global.inc"
	# install.provision.inc
su -s /bin/bash aegir -c "mv ~/.drush/provision/platform/install.provision.inc ~/backups/pre-platservbuild/install.provision.inc.bak"
su -s /bin/bash aegir -c "ln -s ~/platforms/.profiles/pro_101/scripts/install.provision.inc ~/.drush/provision/platform/install.provision.inc"



# Set Folder Permissions
find /srv/aegir/clients -type d -exec chmod 0775 {} \;
find /srv/aegir/config -type d -exec chmod 0775 {} \;
find /srv/aegir/platforms -type d -exec chmod 0775 {} \;



# Set File Permissions
find /srv/aegir/clients -type f -exec chmod 0664 {} \;
find /srv/aegir/config -type f -exec chmod 0664 {} \;
find /srv/aegir/platforms -type f -exec chmod 0664 {} \;



# Create Additional Account
echo -n -e "\Create a user account? [y/n] "
read -N 1 ADDUSER
if test "$ADDUSER" = "y" -o "$REPLY" = "Y"; then
  if [ $(id -u) -eq 0 ]; then
    echo -e "\n"
    read -p "Enter username : " username
    echo
    read -s -p "Enter password : " password
    echo -e "\n"
    read -p "Enter firstname : " firstname
    echo
    read -p "Enter lastname : " lastname
    echo
    read -p "Enter email address : " email
    egrep "^$username" /etc/passwd >/dev/null

    if [ $? -eq 0 ]; then
        echo -e "\n$username exists!"
    else
        pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
        useradd -m -p $pass -s /bin/zsh $username
        usermod -G www-data,aegir,sudo $username
        su -s /bin/bash $username -c 'cd && curl -O https://raw.github.com/shelltopia/shelltopia/master/.aux/install.sh && chmod 770 install.sh && ./install.sh'

        [ $? -eq 0 ] && echo -e "\n${BLD}${RED} Create Additional Account $username ${BLD}${GREEN}| Done!${RESET}\n" || echo -e "\nFailed to add another user!"
    fi
  else
    echo -e "\nOnly root may add a user to the system"
  fi
else
  echo -e "\nProceeding..."
fi
echo -e "\n${BLD}${RED} Post Aegir Build ${BLD}${GREEN}| Done!${RESET}\n"



# }}}
# vim:fdm=marker:
