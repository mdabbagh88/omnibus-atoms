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

# The atoms module in this file is used to parse /etc/atoms/atoms.rb.
#
# Warning to the reader:
# Because the Ruby DSL in /etc/atoms/atoms.rb does not accept hyphens (_) in
# section names, this module translates names like 'atoms_server' to the
# correct 'atoms-server' in the `generate_hash` method. This module is the only
# place in the cookbook where we write 'atoms_server'.

require 'mixlib/config'
require 'chef/mash'
require 'chef/json_compat'
require 'chef/mixin/deep_merge'
require 'securerandom'
require 'uri'

module Atoms
  extend(Mixlib::Config)

  bootstrap Mash.new
  user Mash.new
  postgresql Mash.new
  atoms_server Mash.new
  nginx Mash.new
  logging Mash.new
  logrotate Mash.new
  node nil
  external_url nil

  class << self

    # guards against creating secrets on non-bootstrap node
    def generate_hex(chars)
      SecureRandom.hex(chars)
    end

    def generate_secrets(node_name)
      SecretsHelper.read_atoms_secrets

      # Note: If you add another secret to generate here make sure it gets written to disk in SecretsHelper.write_to_atoms_secrets
      Atoms['atoms_server']['secret_token'] ||= generate_hex(64)

      # Note: Besides the section below, atoms-secrets.json will also change
      # in CiHelper in libraries/helper.rb
      SecretsHelper.write_to_atoms_secrets
    end

    def parse_external_url
      return unless external_url

      uri = URI(external_url.to_s)

      info("Installing according to external_url -> " + uri.host)

      unless uri.host
        raise "Atoms external URL must include a schema and FQDN, e.g. http://atoms.example.com/"
      end

      Atoms['atoms_server']['server_host'] = uri.host

      case uri.scheme
      when "http"
        Atoms['atoms_server']['server_https'] = false
      when "https"
        Atoms['atoms_server']['server_https'] = true
        Atoms['nginx']['ssl_certificate'] ||= "/etc/atoms/ssl/#{uri.host}.crt"
        Atoms['nginx']['ssl_certificate_key'] ||= "/etc/atoms/ssl/#{uri.host}.key"
      else
        raise "Unsupported external URL scheme: #{uri.scheme}"
      end

      unless ["", "/"].include?(uri.path)
        raise "Unsupported external URL path: #{uri.path}"
      end

      Atoms['atoms_server']['server_port'] = uri.port
    end

    def parse_postgresql_settings
      # If the user wants to run the internal Postgres service using an alternative
      # DB username, host or port, then those settings should also be applied to
      # atoms.
      [
        # %w{atoms_server db_username} corresponds to
        # Atoms['atoms_server']['db_username'], etc.
        [%w{atoms_server db_username}, %w{postgresql sql_user}],
        [%w{atoms_server db_host}, %w{postgresql listen_address}],
        [%w{atoms_server db_port}, %w{postgresql port}]
      ].each do |left, right|
        if ! Atoms[left.first][left.last].nil?
          # If the user explicitly sets a value for e.g.
          # atoms['db_port'] in atoms.rb then we should never override
          # that.
          next
        end

        better_value_from_atoms_rb = Atoms[right.first][right.last]
        default_from_attributes = node['atoms'][right.first.gsub('_', '-')][right.last]
        Atoms[left.first][left.last] = better_value_from_atoms_rb || default_from_attributes
      end
    end

    def parse_nginx_listen_address
      return unless nginx['listen_address']

      # The user specified a custom NGINX listen address with the legacy
      # listen_address option. We have to convert it to the new
      # listen_addresses setting.
      nginx['listen_addresses'] = [nginx['listen_address']]
    end

    def parse_nginx_listen_ports
      [
        [%w{nginx listen_port}, %w{atoms_server server_port}],

      ].each do |left, right|
        if !Atoms[left.first][left.last].nil?
          next
        end

        default_set_server_port = node['atoms'][right.first.gsub('_', '-')][right.last]
        user_set_server_port = Atoms[right.first][right.last]

        Atoms[left.first][left.last] = user_set_server_port || default_set_server_port
      end
    end

    def generate_hash
      results = { "atoms" => {} }
      [
        "bootstrap",
        "user",
        "atoms_server",
        "nginx",
        "logging",
        "logrotate",
        "postgresql",
        "external_url"
      ].each do |key|
        rkey = key.gsub('_', '-')
        results['atoms'][rkey] = Atoms[key]
      end

      results
    end

    def generate_config(node_name)
      # generate_secrets(node_name)
      parse_external_url
      parse_postgresql_settings
      parse_nginx_listen_address
      parse_nginx_listen_ports
      # The last step is to convert underscores to hyphens in top-level keys
      generate_hash
    end
  end
end
