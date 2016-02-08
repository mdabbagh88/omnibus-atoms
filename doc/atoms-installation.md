## Atoms package installation (recommended)
We recommend installing the Omnibus package instead of installing [AeroGear](https://github.com/aerogear/aerogear-unifiedpush-server) from source. Omnibus Atoms takes just 2 minutes to install and is packaged in the popular [deb](http://packages.atomsd.org/packages/) and [rpm](http://packages.atomsd.org/packages/) formats. Compared to an installation from source, the Omnibus package is faster to install and upgrade, more reliable to upgrade and maintain, and it shortens the response time for our subscribers' issues. A package contains Atoms Server and all its depencies (Nginx, PostgreSQL, Wildfly, AeroGear, etc.), it can be installed without an internet connection. For troubleshooting and configuration options please see the [Omnibus Atoms Configuration](doc/settings/configuration.md#configuration-options).

## Install Atoms
Since an installation from source is a lot of work and error prone we strongly recommend the fast and reliable Omnibus package installation (deb/rpm).

[Download the package](http://packages.atomsd.org/packages/)
### Install and configure the necessary dependencies
#### CentOS/RHEL/Fedora
On Centos 6 and 7, the commands below will also open HTTP and SSH access in the system firewall.

    sudo yum install java-1.7.0-openjdk
    sudo firewall-cmd --permanent --add-service=http

#### Debian/Ubuntu

    apt-get install openjdk-7-jdk

### Add the Atoms package server and install the package

    curl -LJO http://packages.atomsd.org/packages/el/7/atoms-XXX.rpm
    sudo rpm -i atoms-XXX.rpm

## Configure and start Atoms Server
    sudo atoms-ctl reconfigure

### After Installation 
Your Atoms instance should reachable over HTTP at the IP or hostname of your server. You can login as an admin user with **username:** admin and **password:** 123.

### Configuration Options 
See [Configuration Options](doc/settings/atoms-configuration-options.md)

## Operating Systems
### Supported Unix distributions

* Ubuntu
* Debian
* CentOS
* Red Hat Enterprise Linux (please use the CentOS packages and instructions)
* Fedora
