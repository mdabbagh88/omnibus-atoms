## Logs

### Tail logs in a console on the server

If you want to 'tail', i.e. view live log updates of Atoms logs you can use
`atoms-ctl tail`.

```shell
# Tail all logs; press Ctrl-C to exit
sudo atoms-ctl tail

# Drill down to a sub-directory of /var/log/atoms
sudo atoms-ctl tail nginx

# Drill down to an individual file
sudo atoms-ctl tail nginx/atoms_access.log
```

### Runit logs

The Runit-managed services in omnibus-atoms generate log data using
[svlogd][svlogd]. See the [svlogd documentation][svlogd] for more information
about the files it generates.

You can modify svlogd settings via `/etc/atoms/atoms.rb` with the following settings:

```ruby
# Below are the default values
logging['svlogd_size'] = 200 * 1024 * 1024 # rotate after 200 MB of log data
logging['svlogd_num'] = 30 # keep 30 rotated log files
logging['svlogd_timeout'] = 24 * 60 * 60 # rotate after 24 hours
logging['svlogd_filter'] = "gzip" # compress logs with gzip
logging['svlogd_udp'] = nil # transmit log messages via UDP
logging['svlogd_prefix'] = nil # custom prefix for log messages

# Optionally, you can override the prefix for e.g. Nginx
nginx['svlogd_prefix'] = "nginx"
```

### Logrotate

Starting with omnibus-atoms 1.1.0 there is a built-in logrotate service in
omnibus-atoms. This service will rotate, compress and eventually delete the
log data that is not captured by Runit, such as `atoms-server/current`
and `nginx/atoms_access.log`. You can configure logrotate via
`/etc/atoms/atoms.rb`.

```
# Below are some of the default settings
logging['logrotate_frequency'] = "daily" # rotate logs daily
logging['logrotate_size'] = nil # do not rotate by size by default
logging['logrotate_rotate'] = 30 # keep 30 rotated logs
logging['logrotate_compress'] = "compress" # see 'man logrotate'
logging['logrotate_method'] = "copytruncate" # see 'man logrotate'
logging['logrotate_postrotate'] = nil # no postrotate command by default
logging['logrotate_dateformat'] = nil # use date extensions for rotated files rather than numbers e.g. a value of "-%Y-%m-%d" would give rotated files like production.log-2016-03-09.gz


# You can add overrides per service
nginx['logrotate_frequency'] = nil
nginx['logrotate_size'] = "200M"

# You can also disable the built-in logrotate service if you want
logrotate['enable'] = false
```

### Using a custom NGINX log format

By default the NGINX access logs will use the 'combined' NGINX
format, see
http://nginx.org/en/docs/http/ngx_http_log_module.html#log_format .
If you want to use a custom log format string you can specify it
in `/etc/atoms/atoms.rb`.

```
nginx['log_format'] = 'my format string $foo $bar'
mattermost_nginx['log_format'] = 'my format string $foo $bar'
```
