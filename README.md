# RadioPBS

PBS server runs on Debian 12.8 Bookworm. This repository contains instructions and hints for replicating the setup whenever neccessary.

## Setting up PBS

First, install [this version of Debian](https://cdimage.debian.org/debian-cd/12.8.0/amd64/iso-cd/). Once installed, add your user to sudoers:
```console
$ nano /etc/sudoers
```
Find a line containing `root ALL=(ALL:ALL) ALL` and add the following line under it:
```
username ALL=(ALL:ALL) ALL
```
It should also be possible to just do `adduser username sudo`, but sometimes this doesn't work.

Once the user has sudo rights there are two ways to continue with the installation.
Either manually install git and clone this entire repository:
```console
$ sudo apt update && sudo apt upgrade
$ sudo apt install git 
$ cd ~/Documents
$ git clone https://github.com/Mhuzvar/RadioPBS.git
$ cd RadioPBS
```
or only download the installation script (git and updates are later installed from within the script):
```console
$ wget https://raw.githubusercontent.com/Mhuzvar/RadioPBS/refs/heads/main/install_PBS.sh
```
Whichever option you choose, you should now be able to run the prepared installation script.
```console
$ sudo ./install_PBS.sh
$ . /etc/profile.d/pbs.sh
```

PBS server should now be up and running in its default configuration. To replicate our setup, we are working on `setup_PBS.sh` to automate this step. **This script is not finished yet and may not work at best and break your installation at worst.**
```console
$ cd ~/Documents/RadioPBS
$ ./setup_PBS.sh
```


## Older notes

[MetaCentrum](https://metavo.metacentrum.cz/) uses [OpenPBS](https://www.openpbs.org/). There is no free alternative to my knowledge.
OpenPBS offers packages for openSUSE Leap 15.4, Rocky Linux 8.8, and Ubuntu 18.04 and 20.04.
Official [GitHub repository](https://github.com/openpbs/openpbs/tree/master) contains some support for building from source.

### Setting up

- [Install guide (from source)](https://github.com/openpbs/openpbs/blob/master/INSTALL)
- [Setting up OpenPBS on only one computer](https://community.openpbs.org/t/setting-up-openpbs-on-only-one-computer/2306)
- [Quick Guide to Setting Up OpenPBS](http://www.rguha.net/misc/qopbs.html)
- [PBS installation on a single execution host](https://community.openpbs.org/t/pbs-installation-on-a-single-execution-host/2600)

### Problems

No precompiled package available, installed from [source](https://github.com/openpbs/openpbs/tree/master) on 12.8 Bookworm.
Works fine when following steps from setup_pbs.sh.


#### Troubleshooting

- [The problem with running on a clean virtual machine](https://community.openpbs.org/t/the-problem-with-running-on-a-clean-virtual-machine/1612)
- [ pbs_server, pbs_mom, pbs_comm not running in ubuntu 18.04 #2570 ](https://github.com/openpbs/openpbs/issues/2570)
- [ [BUG]: ClusterManager not working on PBS #419](https://github.com/MilesCranmer/PySR/issues/419)
- [Connection refused/qstat: cannot connect to server J35 (errno=15010)](https://community.openpbs.org/t/connection-refused-qstat-cannot-connect-to-server-j35-errno-15010/3275/5)
- [Connection Refused (errno=15010)](https://community.openpbs.org/t/connection-refused-errno-15010/3298)


### Under Ubuntu

OpenPBS has [precompiled packages](https://www.openpbs.org/Download.aspx#download) on their website. All our attempts were performed under 20.04 Noble Numbat.

#### Precompiled

Precompiled packages come with no documentation.
The .deb files contain some conflicting libraries (not all should be installed?) but we need both server and client which cannot be installed at the same time.

#### From Source

Works fine.


#### Troubleshooting

[ pbs_server not starting on Ubuntu 20.04 #2491 ](https://github.com/openpbs/openpbs/issues/2491)

### Notes

- server logs in /var/spool/pbs/server_logs/ (Debian)
