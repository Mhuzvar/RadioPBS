# RadioPBS

PBS server runs on Debian 12.11 Bookworm. This repository contains instructions and hints for replicating the setup whenever neccessary.

## Setting up PBS

### Installing OS

The following installation guide is based on [this youtube tutorial](https://www.youtube.com/watch?v=9htEaXAXfdg&ab_channel=JustAGuyLinux).

Download [this version of Debian](https://cdimage.debian.org/debian-cd/12.11.0/amd64/iso-cd/) and make a bootable stick.

Select `Advanced options ...` and `... Expert install`.

Go through `Choose language`, `Configure the keyboard`, `Detect and mount instalation media`, and `Load installer components from installation media` choosing what fits or just entering through.

Only `Detect network hardware` if connected to a network and if so, you may select `<Yes>` on Auto-configuration of network.
Leave server addresses empty, set hostname (according to department instructions), leave domain name empty.

In `Set up users and passwords` choose `<Yes>` on to Allow login as root question.
Create root password and create a user named tester with a different password.

Go through `Configure the clock` and `Detect disk` by entering through.

In `Partition disks` choose `Manual`.
Select the drive that should contain the system (256 GB SSD in our case) and choose `<Yes>` to creating an empty partition table.
Select `gpt`.
Select the newly created `FREE SPACE` partition and `Create new partition`, set size to `500M` from `Beginning` and set `Use as:` to `EFI System Partition` (`Done setting up the partition` to continue).
Select the rest of the `FREE SPACE`, `Create new partition`, maximum size, set `Use as:` to `btrfs journaling file system` and `Done setting up the partition`.
Select `Finish partitioning and write changes to disk`, choose `<No>` to returning and creating swap partition and choose `<Yes>` to write changes to disks.

Press `Ctrl`+`Alt`+`F2`, press `Enter` and type:
```console
~ # df -h
```
You should see something like:
```console
Filesystem          Size    Used    Available   Use     Mounted on
...                 ...     ...     ...         ...     ...
/dev/nvme1n1p2      238.0G  5.8M    236.0G      0%      /target
/dev/nvme1n1p1      475.1M  4.0K    475.1M      0%      /target/boot/efi
```
Continue[^zstd]:
```console
~ # umount /target/boot/efi/
~ # umount /target/
~ # mount /dev/nvme1n1p2 /mnt
~ # cd mnt/
mnt/ # mv @rootfs/ @/
mnt/ # btrfs su cr @home
mnt/ # btrfs su cr @root
mnt/ # btrfs su cr @log
mnt/ # btrfs su cr @tmp
mnt/ # btrfs su cr @opt
mnt/ # mount -o noatime,compress=zstd:1,subvol=@ /dev/nvme1n1p2 /target
mnt/ # mkdir -p /target/boot/efi
mnt/ # mkdir -p /target/home
mnt/ # mkdir -p /target/root
mnt/ # mkdir -p /target/var/log
mnt/ # mkdir -p /target/tmp
mnt/ # mkdir -p /target/opt
mnt/ # mount -o noatime,compress=zstd:1,subvol=@home /dev/nvme1n1p2 /target/home
mnt/ # mount -o noatime,compress=zstd:1,subvol=@root /dev/nvme1n1p2 /target/root
mnt/ # mount -o noatime,compress=zstd:1,subvol=@log /dev/nvme1n1p2 /target/var/log
mnt/ # mount -o noatime,compress=zstd:1,subvol=@tmp /dev/nvme1n1p2 /target/tmp
mnt/ # mount -o noatime,compress=zstd:1,subvol=@opt /dev/nvme1n1p2 /target/opt
mnt/ # mount /dev/nvme1n1p1 /target/boot/efi
mnt/ # nano /taget/etc/fstab
```
[^zstd]: Setting `compress=zstd` defaults to 3. This results in relatively high CPU usage which may be improved with marginal hit to compression ratio by setting `compress=zstd:1` for NVMe drives (our case) or `compress=zstd:2` for SATA SSD drives. **The setting needs to match in `fstab`!**

You should see the content of `fstab` file now.
It should look something like:
```
# /etc/fstab: static file system information.
#
# Use 'blkid' to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# systemd generates mount units based on this file, see systemd.mount(5).
# Please run `systemctl daemon-reload` after making changes here.
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
# / was on /dev/nvme1n1p2 during installation
UUID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX /               btrfs   defaults,subvol=@rootfs 0       0
# /boot/efi was on /dev/nvme1n1p1 during installation
UUID=XXXX-XXXX  /boot/efi       vfat        umask=0077      0       1
```
Navigate to the first line starting with `UUID=` and change the part after `btrfs` so the line looks like:
```
UUID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX /         btrfs  noatime,compress=zstd:1,subvol=@     0   0
```
Press `Ctrl`+`K` to cut the line and press `Ctrl`+`U` six times to make six copies.
Modify the lines so it looks like:
```
UUID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX /         btrfs  noatime,compress=zstd:1,subvol=@     0   0
UUID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX /home     btrfs  noatime,compress=zstd:1,subvol=@home 0   0
UUID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX /root     btrfs  noatime,compress=zstd:1,subvol=@root 0   0
UUID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX /var/log  btrfs  noatime,compress=zstd:1,subvol=@log  0   0
UUID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX /tmp      btrfs  noatime,compress=zstd:1,subvol=@tmp  0   0
UUID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX /opt      btrfs  noatime,compress=zstd:1,subvol=@opt  0   0
```
Press `Ctrl`+`O`, then `Enter`, then `Ctrl`+`X` and finally `Ctrl`+`Alt`+`F1`.
You should be back in the installation menu.

Select `Install the base system`, choose `linux-image-amd64` and `generic: include all available drivers`.

In `Configure the package manager` choose `<Yes>` to use a network mirror and pick any http network mirror with no proxy.
Choose `<Yes>` both to use non-free firmware, non-free software and source repositories.
Select all three services that provide updates.

In `Select and install software` choose `No automatic updates` and `<No>` to survey participation.
Choose `standard system utilities` and `SSH server` to install.

In `Install the GRUB bootloader`, choose `<No>` to force GRUB to removable path, `<Yes>` to updating NVRAM variables and `<No>` to `os-prober`.

Select `Finish the installation`, `<Yes>` to UTC clock and `<Continue>` to reboot.

Once rebooted, login as root.
Install basic uilities:
```console
root@hostname:~# apt install zram-tools nvidia-drivier timeshift
```
and reboot afterwards. Open `zramswap` file
```console
root@hostname:~# nano /etc/default/zramswap
```
and uncomment the lines starting with `ALGO=` and `PERCENT=`. Change percentage to 25.
Restart the service:
```console
root@hostname:~# systemctl restart zramswap.service
```

Change `cgroups` from version 2 to version 1:
```console
root@hostname:~# nano /tec/default/grub
```
Edit `GRUB_CMD_LINUX_DEFAULT=` to
```
GRUB_CMD_LINUX_DEFAULT="quiet systemd.unified_cgroup_hierarchy=0"
```
and reboot. Type
```console
root@hostname:~# mount | grep cgroup
```
and look for `cpuset` and `memory`. If you can see them, cgroups is set up fine.

```console
root@hostname:~# update-grub
```

Create initial snapshot[^timeshift]:
[^timeshift]: If this does not work, check correct default subvolume setting (`btrfs su set-default 5 /`) or set device UUID (`timeshift --snapshot-device UUID`).
```console
root@hostname:~# timeshift --create -comments "some comment"
```

The base system should be installed and ready.
It is also recommended to set up grub-btrfs[^grub-btrfs].
[^grub-btrfs]: https://github.com/Antynea/grub-btrfs

### Preparing the system

#### Setup OpenPBS

Either manually install git and clone this entire repository:
```console
root@hostname:~# apt update && apt upgrade
root@hostname:~# apt install git
root@hostname:~# git clone https://github.com/Mhuzvar/RadioPBS.git
root@hostname:~# cd RadioPBS
```
or only download the installation script (git and updates are later installed from within the script):
```console
root@hostname:~# wget https://raw.githubusercontent.com/Mhuzvar/RadioPBS/refs/heads/main/install_PBS.sh
```
Whichever option you choose, you should now be able to run the prepared installation script.
```console
root@hostname:~# chmod +x ./install_PBS.sh
root@hostname:~# ./install_PBS.sh
root@hostname:~# . /etc/profile.d/pbs.sh
```
You may need to adjust the /etc/hosts file and/or run the following commands (if `sudo /etc/init.d/pbs status` results in `pbs_server is not running`):
```console
root@hostname:~# rm -rf /var/spool/pbs/datastore
root@hostname:~# /etc/init.d/pbs start
```
**RERUN THE COMMANDS ABOVE IF PBS FAILS TO START!**

Moreover, if you get `` and `` when you try to run a qsub job, you might need to run the following command as root:
```console
root@hostname:~# qmgr -c "set server flatuid=true"
```

Next up is setting up pbs hooks[^hooks]. To do so, it is needed to do the following:
[^hooks]: See also https://github.com/CESNET/pbs.hooks.
```console
#replace .split('-')[0] with .split('+')[0].split('-')[0] on line rel = list(map(int, (platform.release().split('+')[0].split('-')[0].split('.')))) in /var/spool/pbs/server_priv/hooks/pbs_cgroups.PY
root@hostname:~# nano /var/spool/pbs/server_priv/hooks/pbs_cgroups.PY

#enable cpu and memory management in /var/spool/pbs/server_priv/hooks/pbs_cgroups.CF if not enabled already
root@hostname:~# nano /var/spool/pbs/server_priv/hooks/pbs_cgroups.CF

#enable the hook
root@hostname:~# qmgr -c "import hook pbs_cgroups application/x-config default /var/spool/pbs/server_priv/hooks/pbs_cgroups.CF"
root@hostname:~# qmgr -c "import hook pbs_cgroups application/x-python default /var/spool/pbs/server_priv/hooks/pbs_cgroups.PY"
root@hostname:~# qmgr -c "set hook pbs_cgroups fail_action=none"
root@hostname:~# qmgr -c "set hook pbs_cgroups enabled=true"

#restart pbs
root@hostname:~# systemctl restart pbs
```

The configuration of the default queue (workq) can then be adjusted:
```console
root@hostname:~# qmgr -c "set queue workq resources_default.walltime=01:00:00"
root@hostname:~# qmgr -c "set queue workq resources_max.walltime=24:00:00"
root@hostname:~# qmgr -c "set queue workq resources_default.ncpus=1"
root@hostname:~# qmgr -c "set queue workq resources_max.ncpus=16"
root@hostname:~# qmgr -c "set queue workq resources_default.mem=1gb"
root@hostname:~# qmgr -c "set queue workq resources_max.mem=64gb"
```

PBS server should now be up and running in its default configuration. To replicate our setup, we are working on `setup_PBS.sh` to automate this step. **This script is not finished yet and may not work at best and break your installation at worst.**
```console
$ cd ~/Documents/RadioPBS
$ ./setup_PBS.sh
```

#### Setup cgroup limits
It is possible to also use cgroup slices to limit what users can do when they login via SSH. This should force users to leverage OpenPBS (as they will have to request resources to use more than is set up in the slices). The slices can be setup the following way:
```console
root@hostname:~# mkdir /etc/systemd/system/user-.slice.d # for all users
root@hostname:~# mkdir /etc/systemd/system/user-0.slice.d # override for root
root@hostname:~# mkdir /etc/systemd/system/user-1000.slice.d # override for a specific user
root@hostname:~# nano /etc/systemd/system/user-.slice.d/50-limits.conf #can contain:
```

```console
[Slice]
MemoryMax=1G #limit the memory
CPUQuota=50% #limit the cpu to half a thread/core
```

```console
root@hostname:~# nano /etc/systemd/system/user-0.slice.d/override.conf # and user-1000.slice.d/override.conf can contain:
```

```console
[Slice]
MemoryMax= #override the memory limit
CPUQuota= #override the cpu limit
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
Works fine when following steps from `setup_pbs.sh`.


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
