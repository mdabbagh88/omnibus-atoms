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

# Creates required build directories
dependency "preparation"

# atoms dependencies/components
dependency "postgresql"
dependency "nginx"
dependency "omnibus-ctl"
dependency "chef"
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
