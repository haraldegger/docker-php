#!/bin/sh
#-------------------------------------------------------------------------#
#installing php 5 if required
if [ ! -z ${USE_PHP5+x} ]; then
    echo "Installing php 5..."
    export DEBIAN_FRONTEND="noninteractive"
    apt-get -y update
    apt-get -y upgrade
    apt-get -y install apt-transport-https
    apt-get -y install lsb-release
    apt-get -y install ca-certificates
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
    apt-get -y update
    apt-get -y install php5.6-fpm
fi
#-------------------------------------------------------------------------#
#installing php 7 if required
if [ ! -z ${USE_PHP7+x} ]; then
    echo "Installing php 7..."
    export DEBIAN_FRONTEND="noninteractive"
    apt-get -y update
    apt-get -y upgrade
    apt-get -y install apt-transport-https
    apt-get -y install lsb-release
    apt-get -y install ca-certificates
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
    apt-get -y update
    apt-get -y install php7.4-fpm
fi
#-------------------------------------------------------------------------#
#installing additional packages if requested
 if [ ! -z ${MY_PACKAGES+x} ]; then
    echo "Installing additional packages..."
    export DEBIAN_FRONTEND="noninteractive"
    apt-get -y update
    apt-get -y upgrade
    apt-get -y install $MY_PACKAGES
fi
#creating new user
echo "Creating new user..."
if [ -z ${MY_USERNAME+x} ]; then
    echo "At least one ENV variable was not provided, please recreate the container and pass MY_USERNAME to it"
    echo "#!/bin/sh" > /srv/bin/start.sh
    echo "echo At least one ENV variable was not provided, please recreate the container and pass MY_USERNAME to it" >> /srv/bin/start.sh
    echo "sleep 60" >> /srv/bin/start.sh
    exit
fi
if [ -z ${MY_PASSWORD+x} ]; then
    echo "At least one ENV variable was not provided, please recreate the container and pass MY_PASSWORD to it"
    echo "#!/bin/sh" > /srv/bin/start.sh
    echo "echo At least one ENV variable was not provided, please recreate the container and pass MY_PASSWORD to it" >> /srv/bin/start.sh
    echo "sleep 60" >> /srv/bin/start.sh
    exit
fi
useradd $MY_USERNAME
echo "$MY_USERNAME:$MY_PASSWORD" | chpasswd
usermod -g root $MY_USERNAME
usermod -d /srv/ $MY_USERNAME
#-------------------------------------------------------------------------#
echo "Setting up folder rights..."
chmod -R 775 /srv/*
chmod 755 /srv/
#-------------------------------------------------------------------------#
echo "Setting up php fpm..."
echo "[global]" > /etc/php/8.2/fpm/php-fpm.conf
echo "pid = /run/php/php8.2-fpm.pid" >> /etc/php/8.2/fpm/php-fpm.conf
echo "error_log = /srv/data/log/php-fpm.log" >> /etc/php/8.2/fpm/php-fpm.conf
echo "include=/srv/cfg/php-fpm.conf" >> /etc/php/8.2/fpm/php-fpm.conf
echo "include=/srv/data/cfg/php-fpm.conf" >> /etc/php/8.2/fpm/php-fpm.conf
if [ ! -z ${USE_PHP5+x} ]; then
    echo "[global]" > /etc/php/5.6/fpm/php-fpm.conf
    echo "pid = /run/php/php5.6-fpm.pid" >> /etc/php/5.6/fpm/php-fpm.conf
    echo "error_log = /srv/data/log/php-fpm.log" >> /etc/php/5.6/fpm/php-fpm.conf
    echo "include=/srv/cfg/php-fpm.conf" >> /etc/php/5.6/fpm/php-fpm.conf
    echo "include=/srv/data/cfg/php-fpm.conf" >> /etc/php/5.6/fpm/php-fpm.conf
fi
if [ ! -z ${USE_PHP7+x} ]; then
    echo "[global]" > /etc/php/7.4/fpm/php-fpm.conf
    echo "pid = /run/php/php7.4-fpm.pid" >> /etc/php/7.4/fpm/php-fpm.conf
    echo "error_log = /srv/data/log/php-fpm.log" >> /etc/php/7.4/fpm/php-fpm.conf
    echo "include=/srv/cfg/php-fpm.conf" >> /etc/php/7.4/fpm/php-fpm.conf
    echo "include=/srv/data/cfg/php-fpm.conf" >> /etc/php/7.4/fpm/php-fpm.conf
fi
#-------------------------------------------------------------------------#
echo "Setting up php executable links..."
ln -sf /etc/init.d/php8.2-fpm /srv/bin/php-fpm
ln -sf /run/php/php8.2-fpm.sock /srv/bin/php-fpm.sock
if [ ! -z ${USE_PHP5+x} ]; then
    ln -sf /etc/init.d/php5.6-fpm /srv/bin/php-fpm
    ln -sf /run/php/php5.6-fpm.sock /srv/bin/php-fpm.sock
fi
if [ ! -z ${USE_PHP7+x} ]; then
    ln -sf /etc/init.d/php7.4-fpm /srv/bin/php-fpm
    ln -sf /run/php/php7.4-fpm.sock /srv/bin/php-fpm.sock
fi
#-------------------------------------------------------------------------#
echo "Setting up SFTP for file transfer..."
mkdir /run/sshd
echo "Port 22" > /etc/ssh/sshd_config
echo "UseDNS no" >> /etc/ssh/sshd_config
echo "PermitRootLogin no" >> /etc/ssh/sshd_config
echo "X11Forwarding no" >> /etc/ssh/sshd_config
echo "AllowTcpForwarding no" >> /etc/ssh/sshd_config
echo "AllowAgentForwarding no" >> /etc/ssh/sshd_config
echo "AllowUsers $MY_USERNAME" >> /etc/ssh/sshd_config
echo "PermitTunnel no" >> /etc/ssh/sshd_config
echo "Subsystem sftp internal-sftp" >> /etc/ssh/sshd_config
echo "ForceCommand internal-sftp" >> /etc/ssh/sshd_config
echo "ChrootDirectory %h" >> /etc/ssh/sshd_config
#-------------------------------------------------------------------------#
