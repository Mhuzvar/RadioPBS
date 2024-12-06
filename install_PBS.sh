#/bin/bash

# WIP! DO NOT USE YET!

sudo apt install gcc make libtool libhwloc-dev libx11-dev libxt-dev libedit-dev libical-dev ncurses-dev perl postgresql-server-dev-all postgresql-contrib unzip python3-dev tcl-dev tk-dev swig libexpat-dev libssl-dev libxext-dev libxft-dev autoconf automake g++ expat libedit2 libcjson-dev postgresql python3 postgresql-contrib sendmail-bin tcl tk libical3 postgresql-server-dev-all -y

# modify IP address to static

cd ~/Downloads && git clone https://github.com/openpbs/openpbs.git && cd ~/Downloads/openpbs

./autogen.sh

./configure --prefix=/opt/pbs

make -j

sudo make install

/opt/pbs/libexec/pbs_init.d --version

sudo /opt/pbs/libexec/pbs_postinstall

# change PBS_START_MOM=1 in /etc/pbs.conf

sudo chmod 1777 /var/run/postgresql/

sudo chmod 4755 /opt/pbs/sbin/pbs_iff /opt/pbs/sbin/pbs_rcp

. /etc/profile.d/pbs.sh

sudo systemctl enable pbs

sudo /etc/init.d/pbs stop

sudo rm -rf /var/spool/pbs/datastore

sudo /etc/init.d/pbs start

cd ~/Documents/RadioPBS
