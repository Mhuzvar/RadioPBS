# RadioPBS



## OpenPBS

[MetaCentrum](https://metavo.metacentrum.cz/) uses [OpenPBS](https://www.openpbs.org/). There is no free alternative to my knowledge.
OpenPBS offers [packages](https://www.openpbs.org/Download.aspx#download) for openSUSE Leap 15.4, Rocky Linux 8.8, and Ubuntu 18.04 and 20.04.
Official [GitHub repository](https://github.com/openpbs/openpbs/tree/master) contains some support for building from source.

### Setting up guides

- [Install guide (from source)](https://github.com/openpbs/openpbs/blob/master/INSTALL)
- [Setting up OpenPBS on only one computer](https://community.openpbs.org/t/setting-up-openpbs-on-only-one-computer/2306)
- [Quick Guide to Setting Up OpenPBS](http://www.rguha.net/misc/qopbs.html)
- [PBS installation on a single execution host](https://community.openpbs.org/t/pbs-installation-on-a-single-execution-host/2600)

### Under Debian

No precompiled package available, installed from [source](https://github.com/openpbs/openpbs/tree/master) on 12.8 Bookworm.

- Initially some problems with firewall (closed ports)
- `qstat -B` gives:
> `Connection refused`
> `qstat: cannot connect to server ubuntu (errno=15010)`


#### Troubleshooting

- [The problem with running on a clean virtual machine](https://community.openpbs.org/t/the-problem-with-running-on-a-clean-virtual-machine/1612)
- [ pbs_server, pbs_mom, pbs_comm not running in ubuntu 18.04 #2570 ](https://github.com/openpbs/openpbs/issues/2570)
- [ [BUG]: ClusterManager not working on PBS #419](https://github.com/MilesCranmer/PySR/issues/419)
- [Connection refused/qstat: cannot connect to server J35 (errno=15010)](https://community.openpbs.org/t/connection-refused-qstat-cannot-connect-to-server-j35-errno-15010/3275/5)
- [Connection Refused (errno=15010)](https://community.openpbs.org/t/connection-refused-errno-15010/3298)


### Under Ubuntu

OpenPBS has [precompiled packages](https://www.openpbs.org/Download.aspx#download) on their website. All our attempts were performed under 20.04 Noble Numbat.

#### Precompiled

...

#### From Source

...

#### Troubleshooting

...

### Notes

- server logs in /var/spool/pbs/server_logs/ (Debian)
