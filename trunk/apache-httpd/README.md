
# Apache2 configuration

Should go to your HTTPD server's configuration directory.

At the very end of the of the file you should find

```
  <Limit PUT DELETE>
    Require ip 10 127 172 192
  </Limit>

```

It enables local clients to PUT and DELETE things through the
HTTPD. Limit that to the specific IPs of your server(s).
