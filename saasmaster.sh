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



function update_aegir_make {
cat <<- _EOF_
;#######################
;# PEARANCE AMMENDMENT #
;#######################
core = 6.x
api = 2
projects[drupal][type] = "core"

projects[hostmaster][type] = "profile"
projects[hostmaster][download][type] = "git"
projects[hostmaster][download][url] = "git://github.com/Pearance/hostmaster.git"
;projects[hostmaster][download][tag] = "6.x-1.1.a"
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


# START SCRIPT
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
aptitude install -y apache2 php5 php5-cli php5-gd php5-mysql mysql-server
aptitude install -y phpmyadmin landscape-common postfix sudo rsync
aptitude install -y bash-completion git-core git-completion update-notifier-common
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
update_mcrypt_ini > /etc/php5/cli/conf.d/mcrypt.ini
echo -e "\n${BLD}${RED} Update mcrypt.ini ${BLD}${GREEN}| Done!${RESET}\n"



# Create Aegir Account
adduser --system --group --home /srv/aegir aegir
adduser aegir www-data
echo -e "\n${BLD}${RED} Create Aegir Account ${BLD}${GREEN}| Done!${RESET}\n"



# Create Support Account
if [ $(id -u) -eq 0 ]; then
  read -s -p "Enter password for support account: " password
  echo -e "\n"
  egrep "^support" /etc/passwd >/dev/null
  if [ $? -eq 0 ]; then
      echo -e "\nPearance support account already exists!"
  else
    pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
    useradd -m -p $pass -s /bin/bash support
    usermod -G www-data,aegir,sudo support
    cd /home/support/
    su -s /bin/bash support -c 'cd; curl -O https://raw.github.com/Bashtopia/Bashtopia/master/.aux/install.sh; chmod 770 install.sh; ./install.sh'

    [ $? -eq 0 ] && echo -e "\n${BLD}${RED} Create Support Account ${BLD}${GREEN}| Done!${RESET}\n" || echo -e "\nFailed to add support account!"
  fi
else
  echo -e "\nOnly root may add a user to the system\n"
fi



# Create Additional Account
echo -n -e "\nDo you want to add another user? [y/n] "
read -N 1 REPLY
if test "$REPLY" = "y" -o "$REPLY" = "Y"; then
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
        useradd -m -p $pass -s /bin/bash $username
        usermod -G www-data,aegir,sudo $username
        su -s /bin/bash support -c 'cd; curl -O https://raw.github.com/Bashtopia/Bashtopia/master/.aux/install.sh; chmod 770 install.sh; ./install.sh'

        [ $? -eq 0 ] && echo -e "\n${BLD}${RED} Create Additional Account $username ${BLD}${GREEN}| Done!${RESET}\n" || echo -e "\nFailed to add another user!"
    fi
  else
    echo -e "\nOnly root may add a user to the system"
  fi
else
  echo -e "\nProceeding..."
fi



# Configure Apache
a2enmod rewrite
ln -s /srv/aegir/config/apache.conf /etc/apache2/conf.d/aegir.conf
echo -e "\n${BLD}${RED} Configure Apache ${BLD}${GREEN}| Done!${RESET}\n"



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
su -s /bin/bash aegir -c '/srv/aegir/drush/drush dl --destination=/srv/aegir/.drush provision-6.x-1.4'
echo -e "\n${BLD}${RED} Install Provision ${BLD}${GREEN}| Done!${RESET}\n"



# Configure Aegir Make
/bin/cp -n /srv/aegir/.drush/provision/aegir.make /srv/aegir/.drush/provision/aegir.make.bak
update_aegir_make > /srv/aegir/.drush/provision/aegir.make
echo -e "\n${BLD}${RED} Configure Aegir Make ${BLD}${GREEN}| Done!${RESET}\n"



# Install SaaS Hostmaster
su -s /bin/bash aegir -c 'cd /srv/aegir && /srv/aegir/drush/drush hostmaster-install'
echo -e "\n${BLD}${RED} Install SaaS Hostmaster ${BLD}${GREEN}| Done!${RESET}\n"

  # Patch Modules
  # uc_better_cart_links - http://drupal.org/node/1090092#comment-4245384
  # cd /srv/aegir/hostmaster-*/profiles/hostmaster/modules/contrib/uc_better_cart_links
  # mkdir backups && cp uc_better_cart_links.module backups && cp uc_better_cart_links.pages.inc backups
  # su -s /bin/bash aegir -c 'wget "http://drupal.org/files/issues/uc-better-links-fix.patch"'
  # su -s /bin/bash aegir -c 'git apply -v uc-better-links-fix.patch'
  # echo -e "\n${BLD}${RED} Patch uc_better_cart_links ${BLD}${GREEN}| Done!${RESET}\n"

