#
# Copyright:: Copyright (c) 2015
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

# Default location of install-dir is /opt/atoms/. This path is set during build time.
# DO NOT change this value unless you are building your own Atoms packages

install_dir = node['package']['install-dir']
server_dir = node['atoms']['atoms-server']['dir']
modules_dir = "#{server_dir}/modules/org/postgresql/main"

account_helper = AccountHelper.new(node)
atoms_user = account_helper.atoms_user

# These directories do not need to be writable for atoms-server
[
  modules_dir 
].each do |dir_name|
  directory dir_name do
    owner atoms_user
    group "root"
    mode 0775
    recursive true
  end
end

atoms_vars = node['atoms']['atoms-server'].to_hash
 
# Update configuration 
template "#{server_dir}/bin/standalone.conf" do
  owner atoms_user
  group "root"
  mode 0755
  source "wildfly-standalone.conf.erb"
  variables(atoms_vars)
end

# Add postgres module
template "#{modules_dir}/module.xml" do
  owner atoms_user
  group "root"
  mode 0755
  source "wildfly-postgres-module.xml.erb"
end

# Copy postgres JDBC driver
remote_file "Copy postgres driver file" do
  path "#{modules_dir}/postgresql-9.4-1201-jdbc41.jar"
  source "file://#{install_dir}/embedded/apps/atoms/initdb/lib/postgresql-9.4-1201-jdbc41.jar"
  owner atoms_user
  group 'root'
  mode 0755
end

# Include additional config properties for atoms-server in standalone-full.xml
if atoms_vars['server_https']
  atoms_vars = atoms_vars.merge(
    {
      :http_listener_ssl => 'proxy-address-forwarding="true" redirect-socket="proxy-https"',
      :socket_binding_ssl => '<socket-binding name="proxy-https" port="443"/>'
    }
  )
end

# Replace standalone-full.xml with relevant datasource config
template "#{server_dir}/standalone/configuration/standalone-full.xml" do
  owner atoms_user
  group "root"
  mode 0755
  source "wildfly-standalone-full.xml.erb"
  variables(atoms_vars)
end


# Link apps
link "#{server_dir}/standalone/deployments/atoms-server.war" do
  to "#{install_dir}/embedded/apps/atoms/atoms-server.war"
end

link "#{server_dir}/standalone/deployments/auth-server.war" do
  to "#{install_dir}/embedded/apps/atoms/auth-server.war"
end
