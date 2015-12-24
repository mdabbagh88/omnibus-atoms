name "atoms"
maintainer "support@atomsd.org"
maintainer_email "support@atomsd.org"
license "Apache 2.0"
description "Install and configure Atoms Server from Omnibus"
long_description "Install and configure Atoms Server from Omnibus"
version "1.0.0"

recipe "atoms", "Configures Atoms Server from Omnibus"
recipe "atoms-server", "Configures Atoms Application Server from Omnibus"

supports 'centos'
supports 'redhat'
supports 'fedora'
supports 'debian'
supports 'ubuntu'

depends "runit"
depends "package"
