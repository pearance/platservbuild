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

function update_bashrc {
cat <<- _EOF_

#######################
# PEARANCE AMMENDMENT #
#######################

# enable bash completion in interactive shells
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# VARIABLES
##################################################################

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


# PROMPT
##################################################################

# Set git autocompletion and PS1 integration
GIT_PS1_SHOWDIRTYSTATE=true
PS1="\n$bldgrn[$txtylw\u$bldgrn@$bldylw\H$bldgrn]$bldylw \w > $bldred\$(__git_ps1)\n$bldylw\\$ "
_EOF_
}


function update_bash_aliases {
cat <<\_EOF_

#######################
# PEARANCE AMMENDMENT #
#######################

# ALIASES
##################################################################

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


# FUNCTIONS
##################################################################

function a2 {
  sudo service apache2 $1
}
_EOF_
}


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


function setup_gitconfig {
cat > /home/$1/.gitconfig << _EOF_
#######################
# PEARANCE AMMENDMENT #
#######################

[user]
  name = $3 $4
  email = $2
[log]
decorate = full
[color]
  ui = auto
  status = auto
  branch = auto
  interactive = auto
  diff = auto
[pager]
  show-branch = true
[format]
  numbered = auto
[core]
  legacyheaders = false
  excludesfile = /home/$1/.gitignore
[alias]
  lg = log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative
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


; Dev modules
projects[devel][version] = "1.23"
projects[devel][subdir] = "dev"

projects[devel_themer][version] = "1.x-dev"
projects[devel_themer][subdir] = "dev"

projects[drupalforfirebug][version] = "1.4"
projects[drupalforfirebug][subdir] = "dev"


; Contrib modules
projects[admin_menu][type] = "module"
projects[admin_menu][version] = "1.6"
projects[admin_menu][subdir] = "contrib"

projects[openidadmin][type] = "module"
projects[openidadmin][version] = "1.2"
projects[openidadmin][subdir] = "contrib"

projects[install_profile_api][type] = "module"
projects[install_profile_api][version] = "2.1"
projects[install_profile_api][subdir] = "contrib"

projects[jquery_ui][type] = "module"
projects[jquery_ui][version] = "1.3"
projects[jquery_ui][subdir] = "contrib"

projects[modalframe][type] = "module"
projects[modalframe][version] = "1.6"
projects[modalframe][subdir] = "contrib"

projects[logintoboggan][type] = "module"
projects[logintoboggan][version] = "1.6"
projects[logintoboggan][subdir] = "contrib"

projects[diff][type] = "module"
projects[diff][version] = "2.1"
projects[diff][subdir] = "contrib"

projects[token][type] = "module"
projects[token][version] = "1.15"
projects[token][subdir] = "contrib"

projects[features][type] = "module"
projects[features][version] = "1.0"
projects[features][subdir] = "contrib"

projects[ubercart][type] = "module"
projects[ubercart][version] = "2.4"
projects[ubercart][subdir] = "contrib"

projects[uc_checkout_tweaks][type] = "module"
projects[uc_checkout_tweaks][version] = "1.x-dev"
projects[uc_checkout_tweaks][subdir] = "contrib"

projects[uc_recurring][type] = "module"
projects[uc_recurring][version] = "2.0-alpha6"
projects[uc_recurring][subdir] = "contrib"

projects[uc_optional_checkout_review][type] = "module"
projects[uc_optional_checkout_review][version] = "1.x-dev"
projects[uc_optional_checkout_review][subdir] = "contrib"

projects[uc_better_cart_links][type] = "module"
projects[uc_better_cart_links][version] = "1.x-dev"
projects[uc_better_cart_links][subdir] = "contrib"
; projects[uc_better_cart_links][patch][] = "http://drupal.org/files/issues/uc-better-links-fix.patch"
; http://drupal.org/node/1090092#comment-4245384

projects[uc_hosting][type] = "module"
projects[uc_hosting][version] = "1.0-beta1"
projects[uc_hosting][subdir] = "contrib"


; Custom modules
projects[pearance_order][type] = "module"
projects[pearance_order][subdir] = "custom"
projects[pearance_order][download][type] = "git"
projects[pearance_order][download][url] = "git://github.com/Pearance/pearance_order.git"


; Libraries
libraries[jquery_ui][download][type] = "get"
libraries[jquery_ui][download][url] = "http://jquery-ui.googlecode.com/files/jquery.ui-1.6.zip"
libraries[jquery_ui][directory_name] = "jquery.ui"
libraries[jquery_ui][destination] = "modules/contrib/jquery_ui"


projects[hostmaster][type] = "profile"
projects[hostmaster][download][type] = "git"
projects[hostmaster][download][url] = "http://git.drupal.org/project/hostmaster.git"
; projects[hostmaster][download][url] = "git://github.com/Pearance/hostmaster.git"
projects[hostmaster][download][tag] = "6.x-1.0-rc7"
_EOF_
}


# START SCRIPT
###################################################################

# Get input
clear
echo
read -p "Enter hostname: " newhostname

# Update System
#aptitude update
#aptitude full-upgrade -y
echo -e "\n${BLD}${RED} Update System ${BLD}${GREEN}| Done!${RESET}\n"

# Install Packages
aptitude install -y apache2 php5 php5-cli php5-gd php5-mysql mysql-server landscape-common
aptitude install -y postfix sudo rsync bash-completion git-core git-completion
aptitude install -y update-notifier-common unzip wget
echo -e "\n${BLD}${RED} Install Packages ${BLD}${GREEN}| Done!${RESET}\n"


# Update Hostname
echo $newhostname > /etc/hostname
hostname -F /etc/hostname
echo -e "\n${BLD}${RED} Update Hostname ${BLD}${GREEN}| Done!${RESET}\n"


# Configure Bash Environment (root)
/bin/cp -n ~/.bashrc ~/.bashrc.bak
/bin/cp -f ~/.bashrc.bak ~/.bashrc

update_bashrc >> ~/.bashrc
update_bash_aliases > ~/.bash_aliases
source ~/.bashrc
source ~/.bash_aliases
echo -e "\n${BLD}${RED} Configure Bash Environment (root) ${BLD}${GREEN}| Done!${RESET}\n"


# Configure Bash Environment (skel)
/bin/cp -n /etc/skel/.bashrc /etc/skel/.bashrc.bak
/bin/cp -f /etc/skel/.bashrc.bak /etc/skel/.bashrc
update_bashrc >> /etc/skel/.bashrc
update_bash_aliases > /etc/skel/.bash_aliases
echo -e "\n${BLD}${RED} Configure Bash Environment (skel) ${BLD}${GREEN}| Done!${RESET}\n"


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
    setup_gitconfig "support" "support@pearance.com" "Pearance" "Support"
    chown support.support /home/support/.gitconfig

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
        setup_gitconfig $username $email $firsname $lastname
        chown $username.$username /home/$username/.gitconfig
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
su -s /bin/bash aegir -c 'cd /srv/aegir && git clone --branch master http://git.drupal.org/project/drush.git'
su -s /bin/bash aegir -c 'cd /srv/aegir/drush && git checkout 7.x-4.4'
echo -e "\n${BLD}${RED} Install Drush ${BLD}${GREEN}| Done!${RESET}\n"


# Install Provision
su -s /bin/bash aegir -c 'mkdir -p /srv/aegir/.drush && /srv/aegir/drush/drush dl --destination=/srv/aegir/.drush provision-6.x'
echo -e "\n${BLD}${RED} Install Provision ${BLD}${GREEN}| Done!${RESET}\n"


# Configure Aegir Make
/bin/cp -n /srv/aegir/.drush/provision/aegir.make /srv/aegir/.drush/provision/aegir.make.bak
update_aegir_make > /srv/aegir/.drush/provision/aegir.make
echo -e "\n${BLD}${RED} Configure Aegir Make ${BLD}${GREEN}| Done!${RESET}\n"


# Install SaaS Hostmaster
su -s /bin/bash aegir -c 'cd /srv/aegir && /srv/aegir/drush/drush hostmaster-install'
echo -e "\n${BLD}${RED} Install SaaS Hostmaster ${BLD}${GREEN}| Done!${RESET}\n"

