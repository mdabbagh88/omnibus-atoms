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

####
# omnibus options
####
default['atoms']['bootstrap']['enable'] = true
# create users and groups needed for the package
default['atoms']['manage-accounts']['enable'] = true

####
## The Atoms User that services run as
####
# The Atoms User that services run as
default['atoms']['user']['username'] = "atoms"
default['atoms']['user']['group'] = "atoms"
default['atoms']['user']['uid'] = nil
default['atoms']['user']['gid'] = nil
# The shell for the atoms services user
default['atoms']['user']['shell'] = "/bin/sh"
# The home directory for the atoms services user
default['atoms']['user']['home'] = "/var/opt/atoms"

####
# Atoms Server app
####
default['atoms']['atoms-server']['enable'] = true
default['atoms']['atoms-server']['ha'] = false
default['atoms']['atoms-server']['dir'] = "/var/opt/atoms/atoms-server"
default['atoms']['atoms-server']['log_directory'] = "/var/log/atoms/atoms-server"
default['atoms']['atoms-server']['environment'] = 'production'
default['atoms']['atoms-server']['env'] = {
  'SIDEKIQ_MEMORY_KILLER_MAX_RSS' => '1000000',
  # PATH to set on the environment
  # defaults to /opt/atoms/embedded/bin:/bin:/usr/bin. The install-dir path is set at build time
  'PATH' => "#{node['package']['install-dir']}/bin:#{node['package']['install-dir']}/embedded/bin:/bin:/usr/bin"
}

default['atoms']['atoms-server']['documents_directory'] = "/var/opt/atoms/atoms-server/documents"
default['atoms']['atoms-server']['uploads_directory'] = "/var/opt/atoms/atoms-server/uploads"
default['atoms']['atoms-server']['server_host'] = node['fqdn']
default['atoms']['atoms-server']['server_port'] = 80
default['atoms']['atoms-server']['server_https'] = false
default['atoms']['atoms-server']['time_zone'] = nil


default['atoms']['atoms-server']['backup_path'] = "/var/opt/atoms/atoms-server/backups"
default['atoms']['atoms-server']['db_adapter'] = "postgresql"
default['atoms']['atoms-server']['db_encoding'] = "unicode"
default['atoms']['atoms-server']['db_database'] = "atoms_server"
default['atoms']['atoms-server']['db_keycloak_database'] = "keycloak_server"
default['atoms']['atoms-server']['db_pool'] = 10
# db_username, db_host, db_port oveeride PostgreSQL properties [sql_user, listen_address, port]
default['atoms']['atoms-server']['db_username'] = "atoms_server"
default['atoms']['atoms-server']['db_password'] = nil
# Path to postgresql socket directory
default['atoms']['atoms-server']['db_host'] = "/var/opt/atoms/postgresql"
default['atoms']['atoms-server']['db_port'] = 5432
default['atoms']['atoms-server']['db_socket'] = nil
default['atoms']['atoms-server']['db_sslmode'] = nil
default['atoms']['atoms-server']['db_sslrootcert'] = nil

default['atoms']['atoms-server']['inst_verification'] = false
default['atoms']['atoms-server']['inst_verification_class'] = "org.jboss.aerogear.unifiedpush.service.sms.ClickatellSMSSender"
default['atoms']['atoms-server']['inst_verification_properties'] = []
# Example - Additinal properties will be passed into verification class`
# ['aerogear.config.sms.sender.clickatell.api_id=','aerogear.config.sms.sender.clickatell.username=','aerogear.config.sms.sender.clickatell.password=','aerogear.config.sms.sender.clickatell.encoding=UTF-8','aerogear.config.sms.sender.clickatell.template={0}']

###
# PostgreSQL
###
default['atoms']['postgresql']['enable'] = true
default['atoms']['postgresql']['ha'] = false
default['atoms']['postgresql']['dir'] = "/var/opt/atoms/postgresql"
default['atoms']['postgresql']['data_dir'] = "/var/opt/atoms/postgresql/data"
default['atoms']['postgresql']['log_directory'] = "/var/log/atoms/postgresql"
default['atoms']['postgresql']['unix_socket_directory'] = "/var/opt/atoms/postgresql"
default['atoms']['postgresql']['username'] = "atoms-pgs"
default['atoms']['postgresql']['uid'] = nil
default['atoms']['postgresql']['gid'] = nil
default['atoms']['postgresql']['shell'] = "/bin/sh"
default['atoms']['postgresql']['home'] = "/var/opt/atoms/postgresql"
# Postgres User's Environment Path
# defaults to /opt/atoms/embedded/bin:/opt/atoms/bin/$PATH. The install-dir path is set at build time
default['atoms']['postgresql']['user_path'] = "#{node['package']['install-dir']}/embedded/bin:#{node['package']['install-dir']}/bin:$PATH"
default['atoms']['postgresql']['bin_dir'] = "#{node['package']['install-dir']}/embedded/bin"
default['atoms']['postgresql']['sql_user'] = "atoms_server"
default['atoms']['postgresql']['port'] = 5432
default['atoms']['postgresql']['listen_address'] = 'localhost'
default['atoms']['postgresql']['max_connections'] = 200
default['atoms']['postgresql']['md5_auth_cidr_addresses'] = []
default['atoms']['postgresql']['trust_auth_cidr_addresses'] = ['localhost']
default['atoms']['postgresql']['shmmax'] = kernel['machine'] =~ /x86_64/ ? 17179869184 : 4294967295
default['atoms']['postgresql']['shmall'] = kernel['machine'] =~ /x86_64/ ? 4194304 : 1048575
default['atoms']['postgresql']['semmsl'] = 250
default['atoms']['postgresql']['semmns'] = 32000
default['atoms']['postgresql']['semopm'] = 32
default['atoms']['postgresql']['semmni'] = ((node['atoms']['postgresql']['max_connections'].to_i / 16) + 250)

# Resolves CHEF-3889
if (node['memory']['total'].to_i / 4) > ((node['atoms']['postgresql']['shmmax'].to_i / 1024) - 2097152)
  # guard against setting shared_buffers > shmmax on hosts with installed RAM > 64GB
  # use 2GB less than shmmax as the default for these large memory machines
  default['atoms']['postgresql']['shared_buffers'] = "14336MB"
else
  default['atoms']['postgresql']['shared_buffers'] = "#{(node['memory']['total'].to_i / 4) / (1024)}MB"
end

default['atoms']['postgresql']['work_mem'] = "8MB"
default['atoms']['postgresql']['effective_cache_size'] = "#{(node['memory']['total'].to_i / 2) / (1024)}MB"
default['atoms']['postgresql']['checkpoint_segments'] = 10
default['atoms']['postgresql']['checkpoint_timeout'] = "5min"
default['atoms']['postgresql']['checkpoint_completion_target'] = 0.9
default['atoms']['postgresql']['checkpoint_warning'] = "30s"

####
# Web server
####
# Username for the webserver user
default['atoms']['web-server']['username'] = 'atoms-www'
default['atoms']['web-server']['group'] = 'atoms-www'
default['atoms']['web-server']['uid'] = nil
default['atoms']['web-server']['gid'] = nil
default['atoms']['web-server']['shell'] = '/bin/false'
default['atoms']['web-server']['home'] = '/var/opt/atoms/nginx'
# When bundled nginx is disabled we need to add the external webserver user to the Atoms webserver group
default['atoms']['web-server']['external_users'] = []

####
#NGINX
####
default['atoms']['nginx']['enable'] = true
default['atoms']['nginx']['ha'] = false
default['atoms']['nginx']['dir'] = "/var/opt/atoms/nginx"
default['atoms']['nginx']['log_directory'] = "/var/log/atoms/nginx"
default['atoms']['nginx']['worker_processes'] = node['cpu']['total'].to_i
default['atoms']['nginx']['worker_connections'] = 10240
default['atoms']['nginx']['sendfile'] = 'on'
default['atoms']['nginx']['tcp_nopush'] = 'on'
default['atoms']['nginx']['tcp_nodelay'] = 'on'
default['atoms']['nginx']['gzip'] = "on"
default['atoms']['nginx']['gzip_http_version'] = "1.0"
default['atoms']['nginx']['gzip_comp_level'] = "2"
default['atoms']['nginx']['gzip_proxied'] = "any"
default['atoms']['nginx']['gzip_types'] = [ "text/plain", "text/css", "application/x-javascript", "text/xml", "application/xml", "application/xml+rss", "text/javascript", "application/json" ]
default['atoms']['nginx']['keepalive_timeout'] = 65
default['atoms']['nginx']['client_max_body_size'] = '250m'
default['atoms']['nginx']['cache_max_size'] = '5000m'
default['atoms']['nginx']['redirect_http_to_https'] = false
default['atoms']['nginx']['redirect_http_to_https_port'] = 80
default['atoms']['nginx']['ssl_certificate'] = "/etc/atoms/ssl/#{node['fqdn']}.crt"
default['atoms']['nginx']['ssl_certificate_key'] = "/etc/atoms/ssl/#{node['fqdn']}.key"
default['atoms']['nginx']['ssl_ciphers'] = "ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4"
default['atoms']['nginx']['ssl_prefer_server_ciphers'] = "on"
default['atoms']['nginx']['ssl_protocols'] = "TLSv1 TLSv1.1 TLSv1.2" # recommended by https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html & https://cipherli.st/
default['atoms']['nginx']['ssl_session_cache'] = "builtin:1000  shared:SSL:10m" # recommended in http://nginx.org/en/docs/http/ngx_http_ssl_module.html
default['atoms']['nginx']['ssl_session_timeout'] = "5m" # default according to http://nginx.org/en/docs/http/ngx_http_ssl_module.html
default['atoms']['nginx']['ssl_dhparam'] = nil # Path to dhparam.pem
default['atoms']['nginx']['listen_addresses'] = ['*']
default['atoms']['nginx']['listen_port'] = nil # override only if you have a reverse proxy
default['atoms']['nginx']['listen_https'] = nil # override only if your reverse proxy internally communicates over HTTP
default['atoms']['nginx']['custom_atoms_server_config'] = nil
default['atoms']['nginx']['custom_nginx_config'] = nil

###
# Logging
###
default['atoms']['logging']['svlogd_size'] = 200 * 1024 * 1024 # rotate after 200 MB of log data
default['atoms']['logging']['svlogd_num'] = 30 # keep 30 rotated log files
default['atoms']['logging']['svlogd_timeout'] = 24 * 60 * 60 # rotate after 24 hours
default['atoms']['logging']['svlogd_filter'] = "gzip" # compress logs with gzip
default['atoms']['logging']['svlogd_udp'] = nil # transmit log messages via UDP
default['atoms']['logging']['svlogd_prefix'] = nil # custom prefix for log messages
default['atoms']['logging']['udp_log_shipping_host'] = nil # remote host to ship log messages to via UDP
default['atoms']['logging']['udp_log_shipping_port'] = 514 # remote host to ship log messages to via UDP
default['atoms']['logging']['logrotate_frequency'] = "daily" # rotate logs daily
default['atoms']['logging']['logrotate_size'] = nil # do not rotate by size by default
default['atoms']['logging']['logrotate_rotate'] = 30 # keep 30 rotated logs
default['atoms']['logging']['logrotate_compress'] = "compress" # see 'man logrotate'
default['atoms']['logging']['logrotate_method'] = "copytruncate" # see 'man logrotate'
default['atoms']['logging']['logrotate_postrotate'] = nil # no postrotate command by default

###
# Logrotate
###
default['atoms']['logrotate']['enable'] = true
default['atoms']['logrotate']['ha'] = false
default['atoms']['logrotate']['dir'] = "/var/opt/atoms/logrotate"
default['atoms']['logrotate']['log_directory'] = "/var/log/atoms/logrotate"
default['atoms']['logrotate']['services'] = %w{nginx atoms-server}
default['atoms']['logrotate']['pre_sleep'] = 600 # sleep 10 minutes before rotating after start-up
default['atoms']['logrotate']['post_sleep'] = 3000 # wait 50 minutes after rotating
