#
# Copyright:: Copyright (c) 2015.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

name "atoms"
default_version "1.1.2-SNAPSHOT"

dependency "ruby"
dependency "bundler"
dependency "rsync"
dependency "postgresql"
dependency "wildfly"

version "1.1.2-SNAPSHOT" do
  source md5: "b3381d0dc51249f91d5269f9d7c9f54c"
end

repo_home = if "#{version}".end_with?("SNAPSHOT") then "libs-snapshot-local" else "libs-release-local" end

source url: "http://ci.atomsd.org/artifactory/#{repo_home}/org/jboss/aerogear/unifiedpush/unifiedpush-package/#{version}/unifiedpush-package-#{version}.tar.gz"

relative_path "unifiedpush-package"

build do
  command "mkdir -p #{install_dir}/embedded/apps/atoms"
  sync "#{project_dir}/", "#{install_dir}/embedded/apps/atoms/"

  link "#{install_dir}/embedded/apps/atoms/unifiedpush-server-wildfly-#{version}.war", "#{install_dir}/embedded/apps/atoms/atoms-server.war"
  link "#{install_dir}/embedded/apps/atoms/unifiedpush-auth-server-#{version}.war", "#{install_dir}/embedded/apps/atoms/auth-server.war"

  erb source: "version.yml.erb",
      dest: "#{install_dir}/embedded/apps/atoms/version.yml",
      mode: 0644,
      vars: { default_version: default_version }
end

# Build initdb project to allow JPA based schema creation.
build do
  command "mkdir -p #{install_dir}/embedded/apps/atoms/initdb"
  command "tar -xzf #{project_dir}/unifiedpush-initdb-#{version}.tar.gz --strip-components 1 -C #{install_dir}/embedded/apps/atoms/initdb"
end
