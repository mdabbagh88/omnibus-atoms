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

atoms_username = account_helper.atoms_user
atoms_group = account_helper.atoms_group

atoms_home = node['atoms']['user']['home']

directory atoms_home do
  recursive true
end

account "Atoms user and group" do
  username atoms_username
  uid node['atoms']['user']['uid']
  ugid atoms_group
  groupname atoms_group
  gid node['atoms']['user']['gid']
  shell node['atoms']['user']['shell']
  home atoms_home
  manage node['atoms']['manage-accounts']['enable']
end
