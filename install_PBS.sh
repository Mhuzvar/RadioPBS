#/bin/bash

# WIP! DO NOT USE YET!
# The user has to be in the sudoers group
# adduser <username> sudo as root

# Run ip a to find the name of the <network_interface>

# Function to display usage
usage() {
    echo "Usage: $0 <network_interface>"
    echo "Example: $0 eth0"
    exit 1
}

# Modify the IP address in /etc/hosts
# For now, have to run the script with a specific network interface
# This is because we do not know which network interface should be used

# Check if interface is provided
if [[ $# -eq 0 ]]; then
    usage
fi

# Get the network interface
INTERFACE=$1

# Get the current hostname
HOSTNAME=$(hostname)

# Get the IP address of the specified interface
INTERFACE_IP=$(ip -4 addr show $INTERFACE | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

if [[ -z $INTERFACE_IP ]]; then
    echo "Could not retrieve IP for interface $INTERFACE"
    exit 1
fi

# Get the current IP address of the hostname in /etc/hosts
CURRENT_IP=$(grep -w "$HOSTNAME" /etc/hosts | awk '{print $1}')

# Check if hostname exists in /etc/hosts
if [[ -z $CURRENT_IP ]]; then
    echo "Hostname $HOSTNAME not found in /etc/hosts"
    exit 1
fi

# Replace the IP address
sudo sed -i "s/^$CURRENT_IP\s*$HOSTNAME/$INTERFACE_IP $HOSTNAME/" /etc/hosts

# Update repository list to add contrib and non-free
CODENAME=$(grep -oP 'VERSION_CODENAME=\K\w+' /etc/os-release)

sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup

sudo sed -i "s/ $CODENAME main$/ $CODENAME main contrib non-free non-free-firmware/" /etc/apt/sources.list
sudo sed -i "s/ ${CODENAME}-updates main$/ ${CODENAME}-updates main contrib non-free non-free-firmware/" /etc/apt/sources.list
sudo sed -i "s/ ${CODENAME}-security main$/ ${CODENAME}-security main contrib non-free non-free-firmware/" /etc/apt/sources.list

sudo apt update && apt upgrade -y

sudo apt install git gcc make libtool libhwloc-dev libx11-dev libxt-dev libedit-dev libical-dev ncurses-dev perl postgresql-server-dev-all postgresql-contrib unzip python3-dev tcl-dev tk-dev swig libexpat-dev libssl-dev libxext-dev libxft-dev autoconf automake g++ expat libedit2 libcjson-dev postgresql python3 postgresql-contrib sendmail-bin tcl tk libical3 postgresql-server-dev-all -y

# cd ~/Downloads && git clone https://github.com/openpbs/openpbs.git && cd ~/Downloads/openpbs
git clone https://github.com/openpbs/openpbs.git && cd ./openpbs

./autogen.sh

./configure --prefix=/opt/pbs

make -j

sudo make install

/opt/pbs/libexec/pbs_init.d --version

sudo /opt/pbs/libexec/pbs_postinstall

# change PBS_START_MOM=1 in /etc/pbs.conf
sudo sed -i 's/^PBS_START_MOM=0/PBS_START_MOM=1/' /etc/pbs.conf

sudo chmod 1777 /var/run/postgresql/

sudo chmod 4755 /opt/pbs/sbin/pbs_iff /opt/pbs/sbin/pbs_rcp

sudo systemctl enable pbs

sudo /etc/init.d/pbs stop

sudo rm -rf /var/spool/pbs/datastore

sudo /etc/init.d/pbs start

. /etc/profile.d/pbs.sh

#cd ~/Documents/RadioPBS
