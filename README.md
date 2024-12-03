# RadioPBS



## OpenPBS

[MetaCentrum](https://metavo.metacentrum.cz/) uses [OpenPBS](https://www.openpbs.org/). There is no free alternative to my knowledge.
OpenPBS offers packages for openSUSE Leap 15.4, Rocky Linux 8.8, and Ubuntu 18.04 and 20.04.
Official [GitHub repository](https://github.com/openpbs/openpbs/tree/master) contains some support for building from source.

### Setting up

- [Install guide (from source)](https://github.com/openpbs/openpbs/blob/master/INSTALL)
- [Setting up OpenPBS on only one computer](https://community.openpbs.org/t/setting-up-openpbs-on-only-one-computer/2306)
- [Quick Guide to Setting Up OpenPBS](http://www.rguha.net/misc/qopbs.html)
- [PBS installation on a single execution host](https://community.openpbs.org/t/pbs-installation-on-a-single-execution-host/2600)

### Problems

- SELinux status (must be disabled)
- Firewall (are ports open?)
