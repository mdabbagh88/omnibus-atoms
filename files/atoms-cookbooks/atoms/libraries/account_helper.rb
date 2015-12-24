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

class AccountHelper
  attr_reader :node

  def initialize(node)
    @node = node
  end

  def atoms_user
    node['atoms']['user']['username']
  end

  def atoms_group
    node['atoms']['user']['group']
  end

  def web_server_user
    node['atoms']['web-server']['username']
  end

  def web_server_group
    node['atoms']['web-server']['group']
  end

  def postgresgl_user
    node['atoms']['postgresql']['username']
  end

  def postgresgl_group
    node['atoms']['postgresql']['username']
  end

  def users
    %W(
        #{gitlab_user}
        #{web_server_user}
        #{postgresgl_user}
      )
  end

  def groups
    %W(
        #{gitlab_group}
        #{web_server_group}
        #{postgresgl_group}
      )
  end
end

