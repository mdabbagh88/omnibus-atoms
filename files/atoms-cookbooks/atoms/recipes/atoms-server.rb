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

require 'openssl'

# Default location of install-dir is /opt/atoms/. This path is set during build time.
# DO NOT change this value unless you are building your own Atoms packages
install_dir = node['package']['install-dir']
ENV['PATH'] = "#{install_dir}/bin:#{install_dir}/embedded/bin:#{ENV['PATH']}"

server_dir = node['atoms']['atoms-server']['dir']
server_log_dir = node['atoms']['atoms-server']['log_directory']
server_doc_dir = node['atoms']['atoms-server']['documents_directory']
server_upl_dir = node['atoms']['atoms-server']['uploads_directory']
server_conf_dir = "#{server_dir}/standalone/configuration"

account_helper = AccountHelper.new(node)
atoms_user = account_helper.atoms_user

# These directories do not need to be writable for atoms-server
[ 
  server_dir,
  server_log_dir,
  server_doc_dir, 
  server_upl_dir
].each do |dir_name|
  directory dir_name do
    owner atoms_user
    group 'root'
    mode '0775'
    recursive true
  end
end

execute 'extract_wildfly' do
  command "tar xzvf #{install_dir}/embedded/apps/wildfly/wildfly-8.2.1.Final.tar.gz --strip-components 1"
  cwd "#{server_dir}"

  not_if { File.exists?(server_dir + "/README.txt") }
end

execute "chown-atoms-server" do
  command "chown -R #{atoms_user}:root #{server_dir}"
  action :run
end

include_recipe "atoms::atoms-server-wildfly-conf"

template "#{server_conf_dir}/atoms-server.properties" do
  source "atoms-server.properties.erb"
  owner atoms_user
  mode "0644"
  variables(node['atoms']['atoms-server'].to_hash)
end

runit_service "atoms-server" do
  down node['atoms']['atoms-server']['ha']
  options({
    :log_directory => server_log_dir
  }.merge(params))
  log_options node['atoms']['logging'].to_hash.merge(node['atoms']['atoms-server'].to_hash)
end

if node['atoms']['bootstrap']['enable']
  execute "/opt/atoms/bin/atoms-ctl start atoms-server" do
    retries 20
  end
end

