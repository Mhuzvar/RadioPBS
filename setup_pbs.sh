#/bin/bash

# jen na Debianu (nahradit username uzivatelskym jmenem)
nano /etc/sudoers
# najit radek s root ALL=(ALL:ALL) ALL a pod nej dat
username ALL=(ALL:ALL) ALL
# pripdane by melo fungovat i
adduser username sudo
#

sudo apt update && sudo apt upgrade -y

sudo apt install git gcc make libtool libhwloc-dev libx11-dev libxt-dev libedit-dev libical-dev ncurses-dev perl postgresql-server-dev-all postgresql-contrib unzip python3-dev tcl-dev tk-dev swig libexpat-dev libssl-dev libxext-dev libxft-dev autoconf automake g++ expat libedit2 libcjson-dev postgresql python3 postgresql-contrib sendmail-bin tcl tk libical3 postgresql-server-dev-all -y

# jako root? sudo su -

# jen na ubuntu
ufw disable

# asi neni potreba
iptables -A INPUT -p tcp --dport 15001:15009 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 15001:15009 -j ACCEPT
iptables -A INPUT -p tcp --dport 17001 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 17001 -j ACCEPT

# jestli je potreba
iptables -A OUTPUT -p tcp --dport 1:1024 -j ACCEPT
iptables-save

# upravit ip adresu u hostname
# musi byt staticka adresa
sudo nano /etc/hosts

cd ~/Downloads && git clone https://github.com/openpbs/openpbs.git && cd ~/Downloads/openpbs

./autogen.sh

# nebo i bez PBS_VERSION
./configure PBS_VERSION=23.06.06 --prefix=/opt/pbs

make -j

sudo make install

/opt/pbs/libexec/pbs_init.d --version

sudo /opt/pbs/libexec/pbs_postinstall

# PBS_START_MOM=1
sudo nano /etc/pbs.conf

sudo chmod 1777 /var/run/postgresql/

sudo chmod 4755 /opt/pbs/sbin/pbs_iff /opt/pbs/sbin/pbs_rcp

. /etc/profile.d/pbs.sh

sudo systemctl enable pbs

sudo /etc/init.d/pbs stop

sudo rm -rf /var/spool/pbs/datastore

sudo /etc/init.d/pbs start

# jako root lze pridat dalsi queues
qmgr -c "create queue testq queue_type=e,enabled=t,started=t"
