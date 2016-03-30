#
# Copyright:: Copyright (c) 2013, 2014
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require "#{Omnibus::Config.project_root}/lib/atoms/build_iteration"

name "atoms"
maintainer "support@atomsd.org"
homepage "https://github.com/atomsd/omnibus-atoms.git"

# Defaults to C:/atoms on Windows
# and /opt/atoms on all other platforms
install_dir "#{default_root}/atoms"

build_version   Omnibus::BuildVersion.new.semver
build_iteration Atoms::BuildIteration.new.build_iteration

override :ruby, version: '2.2.2', source: { md5: '326e99ddc75381c7b50c85f7089f3260' }
override :rubygems, version: '2.5.2'
override :'chef-gem', version: '12.6.0'
override :cacerts, version: '2016.01.20', source: { md5: '36eee0e80373937dd90a9a334ae42817' }
override :postgresql, version: '9.4.1', source: { md5: '2cf30f50099ff1109d0aa517408f8eff' }

# Creates required build directories
dependency "preparation"

# atoms dependencies/components
dependency "postgresql"
dependency "nginx"
dependency "omnibus-ctl"
dependency "chef-gem"
dependency "logrotate"
dependency "runit"

# atoms internal dependencies/components
# atoms-server is the most expensive runtime build, therefore keep it first in order.
dependency "atoms-server"
dependency "atoms-ctl"
dependency "atoms-config-template"
dependency "atoms-scripts"
dependency "atoms-cookbooks"
dependency "package-scripts"

# Version manifest file
dependency "version-manifest"

exclude "**/.git"
exclude "**/bundler/git"

# Our package scripts are generated from .erb files,
# so we will grab them from an excluded folder
package_scripts_path "#{install_dir}/.package_util/package-scripts"
exclude '.package_util'

package_user 'root'
package_group 'root'
