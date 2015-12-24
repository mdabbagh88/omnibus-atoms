# Configuration options

Atoms Server is configured by setting relevant options in
`/etc/atoms/atoms.rb`. For a complete list of available options, visit the
[atoms.rb.template](https://github.com/atomsd/omnibus-atoms/blob/master/files/atoms-config-template/atoms.rb.template).


### Configuring the external URL for Atoms

In order for Atoms to display correct repository clone links to your users
it needs to know the URL under which it is reached by your users, e.g.
`http://atoms.example.com`. Add or edit the following line in
`/etc/Atoms/Atoms.rb`:

```ruby
external_url "http://atoms.example.com"
```

Run `sudo atoms-ctl reconfigure` for the change to take effect.

### Loading external configuration file from non-root user

ATOMS package loads all configuration from `/etc/atoms/atoms.rb` file.
This file has strict file permissions and is owned by the `root` user. The reason for strict permissions
and ownership is that `/etc/atoms/atoms.rb` is being executed as Ruby code by the `root` user during `atoms-ctl reconfigure`. This means
that users who have write access to `/etc/atoms/atoms.rb` can add configuration that will be executed as code by `root`.

In certain organizations it is allowed to have access to the configuration files but not as the root user.
You can include an external configuration file inside `/etc/atoms/atoms.rb` by specifying the path to the file:

```ruby
from_file "/home/admin/external_atoms.rb"

```

Please note that code you include into `/etc/atoms/atoms.rb` using `from_file` will run with `root` privileges when you run `sudo atoms-ctl reconfigure`.
Any configuration that is set in `/etc/atoms/atoms.rb` after `from_file` is included will take precedence over the configuration from the included file.

### Storing Documents data in an alternative directory

By default, Atoms stores documents data under
`/var/opt/atoms/atoms-server/documents/`: uploads are stored in
`/var/opt/atoms/atoms-server/documents/`.  You can change the location of
the above directories by editing the following lines to
`/etc/atoms/atoms.rb`.

```ruby
atoms_server['documents_directory'] = "/var/opt/atoms/atoms-server/documents"
atoms_server['uploads_directory'] = "/var/opt/atoms/atoms-server/uploads"
```

Note that the target directory and any of its subpaths must not be a symlink.

Run `sudo atoms-ctl reconfigure` for the change to take effect.

### Changing the name of the Atoms user / group

By default, Atoms uses the user name `atoms` for ownership of the Atoms data itself.

We do not recommend changing the user/group of an existing installation because it can cause unpredictable side-effects.
If you still want to do change the user and group, you can do so by adding the following lines to
`/etc/atoms/atoms.rb`.

```ruby
user['username'] = "atoms"
user['group'] = "atoms"
```

Run `sudo atoms-ctl reconfigure` for the change to take effect.

Note that if you are changing the username of an existing installation, the reconfigure run won't change the ownership of the nested directories so you will have to do that manually. Make sure that the new user can access `documents` as well as the `uploads` directory.

### Specify numeric user and group identifiers

Atoms creates users for Atoms, PostgreSQL, and NGINX. You can
specify the numeric identifiers for these users in `/etc/atoms/atoms.rb` as
follows.

```ruby
user['uid'] = 1234
user['gid'] = 1234
postgresql['uid'] = 1235
postgresql['gid'] = 1235
nginx['uid'] = 1237
nginx['gid'] = 1237
```

Run `sudo atoms-ctl reconfigure` for the changes to take effect.

## Only start Atoms services after a given filesystem is mounted

If you want to prevent Atoms services (NGINX, PostgresSQL.)
from starting before a given filesystem is mounted, add the following to
`/etc/atoms/atoms.rb`:

```ruby
# wait for /var/opt/atoms to be mounted
high_availability['mountpoint'] = '/var/opt/atoms'
```

Run `sudo atoms-ctl reconfigure` for the change to take effect.

### Enable HTTPS

See [doc/settings/nginx.md](nginx.md#enable-https).

#### Redirect `HTTP` requests to `HTTPS`.

See [doc/settings/nginx.md](nginx.md#redirect-http-requests-to-https).

#### Change the default port and the ssl certificate locations.

See
[doc/settings/nginx.md](nginx.md#change-the-default-port-and-the-ssl-certificate-locations).

### Use non-packaged web-server

For using an existing Nginx, Passenger, or Apache webserver see [doc/settings/nginx.md](nginx.md#using-a-non-bundled-web-server).

### Using a non-packaged PostgreSQL database management server

To connect to an external PostgreSQL or MySQL DBMS see [doc/settings/database.md](database.md).

### Adding ENV Vars to the Atoms Runtime Environment

See
[doc/settings/environment-variables.md](environment-variables.md).

### Setting the NGINX listen address or addresses

See [doc/settings/nginx.md](nginx.md#setting-the-nginx-listen-address-or-addresses).

### Inserting custom NGINX settings into the Atoms server block

See [doc/settings/nginx.md](nginx.md).

### Inserting custom settings into the NGINX config

See [doc/settings/nginx.md](nginx.md).
