#!/bin/sh
#-------------------------------------------------------------------------#
echo "Installing applications..."
export DEBIAN_FRONTEND="noninteractive"
apt-get -y update
apt-get -y upgrade
apt-get -y install nginx
apt-get -y install apache2
apt-get -y install php8.2-fpm
apt-get -y install openssl
apt-get -y install openssh-server
apt-get -y install cron
apt-get -y install nano #for convenience, when manually interventing on the system
#-------------------------------------------------------------------------#