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
webserver_username = account_helper.web_server_user
webserver_group = account_helper.web_server_group
external_webserver_users = node['atoms']['web-server']['external_users']

# Create the group for the Atoms user
# If external webserver is used, add the external webserver user to
# Atoms webserver group
append_members = external_webserver_users.any? && !node['atoms']['nginx']['enable']

account "Webserver user and group" do
  username webserver_username
  uid node['atoms']['web-server']['uid']
  ugid webserver_group
  groupname webserver_group
  gid node['atoms']['web-server']['gid']
  shell node['atoms']['web-server']['shell']
  home node['atoms']['web-server']['home']
  append_to_group append_members
  group_members external_webserver_users
  user_supports manage_home: false
  manage node['atoms']['manage-accounts']['enable']
end
