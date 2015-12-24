# NGINX settings
## Enable HTTPS
_**Warning**_

The Nginx config will tell browsers and clients to only communicate with your Atoms instance over a secure connection for the next 24 months. By enabling HTTPS you'll need to provide a secure connection to your instance for at least the next 24 months.
By default, ATOMS does not use HTTPS. If you want to enable HTTPS for atoms.example.com, add the following statement to /etc/atoms/atoms.rb:

    # note the 'https' below
    external_url "https://atoms.example.com"

Because the hostname in our example is 'atoms.example.com', ATOMS will look for key and certificate files called /etc/atoms/ssl/atoms.example.com.key and /etc/atoms/ssl/atoms.example.com.crt, respectively. Create the /etc/atoms/ssl directory and copy your key and certificate there.

    sudo mkdir -p /etc/atoms/ssl
    sudo chmod 700 /etc/atoms/ssl
    sudo cp atoms.example.com.key atoms.example.com.crt /etc/atoms/ssl/

For self-signed certificate, we can create the SSL key and certificate files in one motion by typing:

    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/atoms/ssl/atoms.example.com.key -out /etc/atoms/ssl/atoms.example.com.crt

Now run `sudo atoms-ctl reconfigure`. When the reconfigure finishes your Unifiedpus instance should be reachable at https://atoms.example.com.

## Redirect HTTP requests to HTTPS

By default, when you specify an external_url starting with 'https', Nginx will no longer listen for unencrypted HTTP traffic on port 80. If you want to redirect all HTTP traffic to HTTPS you can use the `redirect_http_to_https` setting.

    external_url "https://atoms.example.com"
    nginx['redirect_http_to_https'] = true

## Change the default port and the SSL certificate locations
If you need to use an HTTPS port other than the default (443), just specify it as part of the external_url.

    external_url "https://atoms.example.com:2443"

In addition proxy-https configuration should be changed to wildfly-standalone-full.xml.erb

    # vi /opt/atoms/embedded/cookbooks/atoms/templates/default/wildfly-standalone-full.xml.erb:
    <socket-binding-group name="standard-sockets" default-interface="public" port-offset="${jboss.socket.binding.port-offset:0}">
        ...
        <socket-binding name="proxy-https" port="2443"/>
        ...
    </socket-binding-group>
    
To set the location of ssl certificates create /etc/atoms/ssl directory, place the .crt and .key files in the directory and specify the following configuration:

    nginx['ssl_certificate'] = "/etc/atoms/ssl/atoms.example.crt"
    nginx['ssl_certificate_key'] = "/etc/atoms/ssl/atoms.example.com.key"

## Setting the NGINX listen address or addresses

By default NGINX will accept incoming connections on all local IPv4 addresses. You can change the list of addresses in /etc/atoms/atoms.rb.

    nginx['listen_addresses'] = ["0.0.0.0", "[::]"] # listen on all IPv4 and IPv6 addresses

## Setting the NGINX listen port

By default NGINX will listen on the port specified in external_url or implicitly use the right port (80 for HTTP, 443 for HTTPS). If you are running Atoms behind a reverse proxy, you may want to override the listen port to something else. For example, to use port 8181:
`nginx['listen_port'] = 8181`

## Using a non-bundled web-server

By default, omnibus-atoms installs Atoms with bundled Nginx.
Omnibus-atoms allows webserver access through user `atoms-www` which resides
in the group with the same name. To allow an external webserver access to
Atoms, external webserver user needs to be added `atoms-www` group.

To use another web server like Apache or an existing Nginx installation you
will have to perform the following steps:

1. **Disable bundled Nginx**

    In `/etc/atoms/atoms.rb` set:

    ```ruby
    nginx['enable'] = false
    ```
