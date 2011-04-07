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

INCLUDES_DIR=`https://github.com/Pearance/drusaas/raw/master/includes`

# DEFINE FUNCTIONS
###################################################################


function update_bashrc {
  cat <<- _EOF_
  source https://github.com/Pearance/drusaas/raw/master/includes/add_msg.sh

  # enable bash completion in interactive shells
  if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
      . /etc/bash_completion
  fi


  #############
  # VARIABLES #
  #############

  txtblk='\e[0;30m' # Black - Regular
  txtred='\e[0;31m' # Red
  txtgrn='\e[0;32m' # Green
  txtylw='\e[0;33m' # Yellow
  txtblu='\e[0;34m' # Blue
  txtpur='\e[0;35m' # Purple
  txtcyn='\e[0;36m' # Cyan
  txtwht='\e[0;37m' # White
  bldblk='\e[1;30m' # Black - Bold
  bldred='\e[1;31m' # Red
  bldgrn='\e[1;32m' # Green
  bldylw='\e[1;33m' # Yellow
  bldblu='\e[1;34m' # Blue
  bldpur='\e[1;35m' # Purple
  bldcyn='\e[1;36m' # Cyan
  bldwht='\e[1;37m' # White
  unkblk='\e[4;30m' # Black - Underline
  undred='\e[4;31m' # Red
  undgrn='\e[4;32m' # Green
  undylw='\e[4;33m' # Yellow
  undblu='\e[4;34m' # Blue
  undpur='\e[4;35m' # Purple
  undcyn='\e[4;36m' # Cyan
  undwht='\e[4;37m' # White
  bakblk='\e[40m'   # Black - Background
  bakred='\e[41m'   # Red
  badgrn='\e[42m'   # Green
  bakylw='\e[43m'   # Yellow
  bakblu='\e[44m'   # Blue
  bakpur='\e[45m'   # Purple
  bakcyn='\e[46m'   # Cyan
  bakwht='\e[47m'   # White
  txtrst='\e[0m'    # Text Reset


  ##########
  # PROMPT #
  ##########
  # Set git autocompletion and PS1 integration
  GIT_PS1_SHOWDIRTYSTATE=true
  PS1="\n$bldgrn[$txtylw\u$bldgrn@$bldylw\H$bldgrn]$bldylw \w > $bldred\$(__git_ps1)\n$bldylw\\$ "
_EOF_
}


function update_bash_aliases {
  cat <<- _EOF_
  source https://github.com/Pearance/drusaas/raw/master/includes/add_msg.sh

  ###########
  # ALIASES #
  ###########

  # COMMANDS (IMPROVED WITH FLAGS)
  alias rm='rm -if'
  alias cp='cp -i'
  alias mv='mv -i'
  alias ra='rm -r * .*'
  alias df='df -h'
  alias du='du -sh'
  alias less='less -r'
  alias whence='type -a'
  alias grep='grep --color'
  alias tarx='tar -xzf'
  alias tarc='tar -zcf'

  # NAVIGATION
  alias ls='ls -hF --color --group-directories-first'
  alias ll='clear && ls -hFlX --color  --group-directories-first'
  alias la='clear && ls -hFlXa --color --group-directories-first'
  alias ..='cd ..'
  alias tt='tree -C'
  alias td='tree -dC'

  # APACHE
  alias lsa='ll /etc/apache2/sites-available'
  alias lma='ll /etc/apache2/mods-available'
  alias lse='ll /etc/apache2/sites-enabled'
  alias lme='ll /etc/apache2/mods-enabled'
  alias sa='cd /etc/apache2/sites-available && ll'
  alias ma='cd /etc/apache2/mods-available && ll'
  alias se='cd /etc/apache2/sites-enabled && ll'
  alias me='cd /etc/apache2/mods-enabled && ll'

  # GIT
  alias gitsh='git.sh'

  # DRUSH
  alias ddl='d dl --package-handler="git_drupalorg"'

  #############
  # FUNCTIONS #
  #############

  function a2 {
    sudo service apache2 $1
  }
_EOF_
}


function update_hosts {
  AEGIR_HOST=`uname -n`
  IP=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
  cat <<- _EOF_
  source https://github.com/Pearance/drusaas/raw/master/includes/add_msg.sh

  $IP         $AEGIR_HOST
_EOF_
}


function update_sshd_config {
  cat <<- _EOF_
  source https://github.com/Pearance/drusaas/raw/master/includes/add_msg.sh

  ClientAliveInterval 120
_EOF_
}


function update_sudoers {
  cat <<- _EOF_
  source https://github.com/Pearance/drusaas/raw/master/includes/add_msg.sh

  aegir ALL=NOPASSWD: /usr/sbin/apache2ctl
_EOF_
}


# START SCRIPT
###################################################################

# Get input
clear
echo ""
read -p "Enter hostname: " newhostname


# Install Packages
aptitude update
aptitude full-upgrade -y
aptitude install -y apache2 php5 php5-cli php5-gd php5-mysql mysql-server landscape-common
aptitude install -y postfix sudo rsync git-core unzip wget bash-completion
echo "${BLD}${RED} Packages Installed ${RESET}"


# Update Hostname
echo $newhostname > /etc/hostname
hostname -F /etc/hostname
echo "${BLD}${RED} Hostname Updated ${RESET}"


# Configure Bash Environment (root)
cp -n ~/.bashrc ~/.bashrc.bak
update_bashrc >> ~/.bashrc
update_bash_aliases > ~/.bash_aliases
source ~/.bashrc
source ~/.bash_aliases
echo "${BLD}${RED} Bash Environment Configured (root) ${RESET}"


# Configure Bash Environment (skel)
cp -n /etc/skel/.bashrc /etc/skel/.bashrc.bak
update_bashrc >> /etc/skel/.bashrc
update_bash_aliases > /etc/skel/.bash_aliases
echo "${BLD}${RED} Bash Environment Configured (skel) ${RESET}"


# Configure SSH
cp -n /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
update_sshd_config >> /etc/ssh/sshd_config
/etc/init.d/ssh restart
echo "${BLD}${RED} SSH Configured ${RESET}"


# Configure DNS
cp -n /etc/hosts /etc/hosts.bak
update_hosts >> /etc/hosts
AEGIR_HOST=`uname -n`
echo "${BLD}${RED} DNS Configured ${RESET}"


# Create Aegir User
adduser --system --group --home /var/aegir aegir
adduser aegir www-data
echo "${BLD}${RED} Aegir User Created ${RESET}"


# Create Pearance Support User
if [ $(id -u) -eq 0 ]; then
	# read -p "Enter username : " username
	read -s -p "Enter password for support account: " password
	egrep "^support" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
		echo -e "\nPearance support account already exists!"
		exit 1
	else
		pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
		useradd -m -p $pass support
		[ $? -eq 0 ] && echo -e"${BLD}${RED}\nPearance Support User Created ${RESET}" || echo "Failed to add support account!"
	  usermod -G www-data,aegir support
	fi
else
	echo "Only root may add a user to the system"
	exit 2
fi


# Create Additional User Account
echo -n "Do you want to add another user? [y/n] "
read -N 1 REPLY
echo
if test "$REPLY" = "y" -o "$REPLY" = "Y"; then
  if [ $(id -u) -eq 0 ]; then
  	read -p "Enter username : " username
  	read -s -p "Enter password : " password
  	read -p "Enter first name : " firstname
  	read -p "Enter last name : " lastname
  	read -p "Enter email address : " email
  	egrep "^$username" /etc/passwd >/dev/null
  	if [ $? -eq 0 ]; then
  		echo "$username exists!"
  		exit 1
  	else
  		pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
  		useradd -m -p $pass $username
  		usermod -G www-data,aegir $username
  		# Setup Git
      git config --global user.name "$firstname $lastname"
      git config --global user.email "$email"
  		[ $? -eq 0 ] && echo "User $username has been added to system!" || echo "Failed to add another user!"
  	fi
  else
  	echo "Only root may add a user to the system"
  	exit 2
  fi
else
  echo "Proceeding..."
fi


# Configure Apache
a2enmod rewrite
ln -s /var/aegir/config/apache.conf /etc/apache2/conf.d/aegir.conf
echo "${BLD}${RED} Apache Configured ${RESET}"


# Configure Sudo
cp -n /etc/sudoers /etc/sudoers.bak
update_sudoers >> /etc/sudoers
echo "${BLD}${RED} Sudo Configured ${RESET}"


# Install Drush
su -s /bin/bash aegir -c 'cd /var/aegir && git clone --branch master http://git.drupal.org/project/drush.git'
su -s /bin/bash aegir -c 'cd /var/aegir/drush && git checkout 7.x-4.4'
echo "${BLD}${RED} Drush Installed ${RESET}"


# Install Provision
# Be sure to modify for the latest release
su -s /bin/bash aegir -c 'cd /var/aegir && /var/aegir/drush/drush dl provision-6.x-1.0-rc3'


# Install Saas Master (Hostmaster)
# Be sure to modify the [url] inside /var/aegir/.drush/provision/aegir.make before proceeding
# su -s /bin/bash aegir -c 'cd /var/aegir && /var/aegir/drush/drush drush hostmaster-install'
