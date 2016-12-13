# wfcache-mruby [DEPRECATED]
[UPDATE 13 DECEMBER 2016: As announced back in October, Wordfence has dropped the Falcon Cache as of version 6.2.8. For WordPress caching, we have switched to WP Super Cache, for which a fork of wfcache-mruby is made available under https://github.com/utrenkner/wpsupercache-mruby. wfcache-mruby is therefore deprecated.]

wfcache-mruby allows using the Wordfence Falcon Cache with the h2o web server using mruby.

wfcache-mruby is based on the nginx configuration for the Falcon Cache (https://www.wordfence.com/txt/nginxConf.txt)
and also on Wordfence's .htaccess for the Falcon Cache (https://github.com/wp-plugins/wordfence/blob/master/lib/wfCache.php)

The X-Wfcache-Hit headers were inspired by Maxime Jobin's Rocket-Nginx (https://github.com/maximejobin/rocket-nginx)

#Usage
To use this wfache-mruby as an mruby-handler in h2o, add something like this to your path in h2o.conf
```
paths:
  "/":
    reproxy: ON
    mruby.handler-file: /path/to/wfcache.rb
    file.dir: "/path/to/wordpress-dir"   # serve static files if found
    redirect:           # if not found, internally redirect to /index.php/<path>
      url: /index.php/
      internal: YES 
      status: 307
```

# License
wfacache-mruby is licensed under the 2-clause BSD license. Please feel free to contribute patches.
