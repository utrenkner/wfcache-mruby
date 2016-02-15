# wfcache-mruby
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
    mruby.handler-file: /usr/local/www/data/mgj/tmp/wfcache.rb
    file.dir: "/usr/local/www/data/mgj/wordpress"   # serve static files if found
    redirect:           # if not found, internally redirect to /index.php/<path>
      url: /index.php/
      internal: YES 
      status: 307
```

# License
wfacache-mruby is licensed under the 2-clause BSD license. Please feel free to contribute patches.
