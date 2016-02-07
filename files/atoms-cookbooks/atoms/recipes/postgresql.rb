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

account_helper = AccountHelper.new(node)

postgresql_dir = node['atoms']['postgresql']['dir']
postgresql_data_dir = node['atoms']['postgresql']['data_dir']
postgresql_data_dir_symlink = File.join(postgresql_dir, "data")
postgresql_log_dir = node['atoms']['postgresql']['log_directory']
postgresql_user = account_helper.postgresgl_user

account "Postgresql user and group" do
  username postgresql_user
  uid node['atoms']['postgresql']['uid']
  ugid postgresql_user
  groupname postgresql_user
  gid node['atoms']['postgresql']['gid']
  shell node['atoms']['postgresql']['shell']
  home node['atoms']['postgresql']['home']
  manage node['atoms']['manage-accounts']['enable']
end

directory postgresql_dir do
  owner postgresql_user
  mode "0755"
  recursive true
end

[
  postgresql_data_dir,
  postgresql_log_dir
].each do |dir|
  directory dir do
    owner postgresql_user
    mode "0700"
    recursive true
  end
end

link postgresql_data_dir_symlink do
  to postgresql_data_dir
  not_if { postgresql_data_dir == postgresql_data_dir_symlink }
end

file File.join(node['atoms']['postgresql']['home'], ".profile") do
  owner postgresql_user
  mode "0600"
  content <<-EOH
PATH=#{node['atoms']['postgresql']['user_path']}
EOH
end

sysctl "kernel.shmmax" do
  value node['atoms']['postgresql']['shmmax']
end

sysctl "kernel.shmall" do
  value node['atoms']['postgresql']['shmall']
end

execute "/opt/atoms/embedded/bin/initdb -D #{postgresql_data_dir} -E UTF8" do
  user postgresql_user
  not_if { File.exists?(File.join(postgresql_data_dir, "PG_VERSION")) }
end

postgresql_config = File.join(postgresql_data_dir, "postgresql.conf")

template postgresql_config do
  source "postgresql.conf.erb"
  owner postgresql_user
  mode "0644"
  variables(node['atoms']['postgresql'].to_hash)
  notifies :restart, 'service[postgresql]', :immediately if OmnibusHelper.should_notify?("postgresql")
end

pg_hba_config = File.join(postgresql_data_dir, "pg_hba.conf")

template pg_hba_config do
  source "pg_hba.conf.erb"
  owner postgresql_user
  mode "0644"
  variables(node['atoms']['postgresql'].to_hash)
  notifies :restart, 'service[postgresql]', :immediately if OmnibusHelper.should_notify?("postgresql")
end

template File.join(postgresql_data_dir, "pg_ident.conf") do
  owner postgresql_user
  mode "0644"
  variables(node['atoms']['postgresql'].to_hash)
  notifies :restart, 'service[postgresql]' if OmnibusHelper.should_notify?("postgresql")
end

should_notify = OmnibusHelper.should_notify?("postgresql")

runit_service "postgresql" do
  down node['atoms']['postgresql']['ha']
  control(['t'])
  options({
    :log_directory => postgresql_log_dir
  }.merge(params))
  log_options node['atoms']['logging'].to_hash.merge(node['atoms']['postgresql'].to_hash)
end

if node['atoms']['bootstrap']['enable']
  execute "/opt/atoms/bin/atoms-ctl start postgresql" do
    retries 20
  end
end
