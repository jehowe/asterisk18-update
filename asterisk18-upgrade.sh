#!/bin/bash

####################################################################################
# Asterisk 18 Upgrade and Maintenance Script
#
# 11/03/2020 - jeff@jhowe.net
#
# This will take an existing Asterisk install to the current Asterisk 18 release
#
# Note - This will update Asterisk 18 minor release versions as well as
# upgrade to Asterisk 18 from any previous major version installed.
# If you are upgrading from another major version (16, 17), please check
# the Asterisk upgrade notes for ANY breaking changes!
#
# https://raw.githubusercontent.com/asterisk/asterisk/18/UPGRADE.txt
#
####################################################################################

# get users home directory path and backup the existing /etc/asterisk/ config files
# note - this can and should be extended to include any custom agi-bin files, astdb-sqlite3, etc
USER_HOME=$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)
mkdir -p $USER_HOME/asterisk-backup
sudo cp -r /etc/asterisk/ $USER_HOME/asterisk-backup/

# stop asterisk
sudo systemctl stop asterisk

# switch to working directory and remove any prior asterisk 18 tar file
cd /usr/src
sudo rm /usr/src/asterisk-18-current.tar.gz

# download latest asterisk
sudo wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-18-current.tar.gz
sudo tar zxf asterisk-18-current.tar.gz

# cd to untar'd asterisk directory
ASTDIR=$(ls -td /usr/src/ast*/ | head -1)
echo $ASTDIR
cd $ASTDIR

# begin the upgrade/update process - if mp3 is not needed, comment the get_mp3_source.sh line below
echo "starting......"
sudo contrib/scripts/get_mp3_source.sh
sudo contrib/scripts/install_prereq install
echo "configure......"
sudo ./configure
echo "make......"
sudo make
echo "make install......"
sudo make install
echo "make config......"
sudo make config
sudo ldconfig

# check for existing config files in the /etc/asterisk directory
# add sample files if no existing config files are present (expected only if this is a new install)
CONF="/etc/asterisk"

if [ "$(ls -A $CONF)" ]; then
     echo "$DIR is not Empty"
else
    echo "make samples......"
    sudo make samples
fi

sudo systemctl start asterisk

echo "Script successfully completed"
exit
