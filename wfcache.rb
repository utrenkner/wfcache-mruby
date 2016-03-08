###################################################################################################
#
# wfcache-mruby
#
# Allows using the Wordfence Falcon Cache with the h2o web server using mruby.
#
# wfcache-mruby is based on the nginx configuration for the Falcon Cache
# (https://www.wordfence.com/txt/nginxConf.txt)
# and also on Wordfence's .htaccess for the Falcon Cache
# (https://github.com/wp-plugins/wordfence/blob/master/lib/wfCache.php)
#
# The wfcache-hit headers were inspired by Maxime Jobin's Rocket-Nginx 
# (https://github.com/maximejobin/rocket-nginx)
#
# Author: Uwe Trenkner
# URL: https://github.com/utrenkner/wfcache-mruby
#
# License: BSD (2-Clause)
#
# Version 0.2
#
###################################################################################################

lambda do |env|
	
	#### START CONFIGRUATION ####
	# Absolute path to wfcache on the server
	wfcache_dir = "/path/to/wordpress/wp-content/wfcache"
	
	# URL of wfcache base
	wfcache_base = "https://www.example.com/wp-content/wfcache"
	
	# Should HTTPS be cached? OFF (0) by default
	wfcache_tls = 1
	
	# Set max-age header for static assets to this number of seconds or 0 (OFF)
	static_max_age = 31536000                               
	
	# Which files are considered "static"
	static_suffices = "css|js|svg|png|jpe?g|gif|ico|eot|otf|woff2?|ttf" 

    # For security: block addresses containing these strings
    # Default: block WP's main config file, 
    # and dot-files/directories (except .well-known used by letsencrypt)
    blockable_addresses = "wp\-config\.php|\/[\.](?!well\-known)(?=[a-zA-Z0-9_]+)"
	#### END CONFIGRUATION ####

	# Set max-age headers for static assets
	headers = {}
	if /\.(#{static_suffices})$/i.match(env["PATH_INFO"]) and #{static_max_age} > 0
		headers["cache-control"] = "max-age=#{static_max_age}"
	end
	
	# Do not apply caching code on cached files themeselves
	if /(wp-content\/wfcache)/ !~ env["PATH_INFO"]
		# Wordfence Cache ON by default
		wfcache_on = 1
		
		# Don't cache form submissions 
		if env["REQUEST_METHOD"] == "POST"
			wfcache_on = 0
			wfcache_hit_message = "NO HIT because POST request"
		end
		
		# Don't cache any queries
		if /(.+)/.match(env["QUERY_STRING"])
			wfcache_on = 0
			wfcache_hit_message = "NO HIT because non-empty query string"
		end
		
		# Only cache URL's ending in /
		if /([^\/]$)/.match(env["PATH_INFO"])
			wfcache_on = 0
			wfcache_hit_message = "NO HIT because URL not ending in /"
		end
		
		# Don't cache any cookies with this in their names e.g. users who are logged in
		if env["HTTP_COOKIE"]
			if /(comment_author|wp\-postpass|wf_logout|wordpress_logged_in|wptouch_switch_toggle|wpmp_switcher)/.match(env["HTTP_COOKIE"])
				wfcache_on = 0
				wfcache_hit_message = "NO HIT because Special cookies set"
			end
		end
		
		# GZIP OFF by default
		wfcache_encoding = ""
		
		# Use GZIP if accepted by client
		if /(gzip)/.match(env["HTTP_ACCEPT_ENCODING"])
			wfcache_encoding = "_gzip"
		end
		
		# Is SSL used ?
		if env["SERVER_PORT"] == "443" and #{wfcache_tls} == 1
			if wfcache_on == 1
				wfcache_https = "_https"
			end
		end
		if wfcache_on == 1
			if match =   env["PATH_INFO"].match(/^\/*(index.php\/)?([^\/]*)\/*([^\/]*)\/*([^\/]*)\/*([^\/]*)\/*([^\/]*)\/*([^\/]*).*\/*$/)
				index, wfone, wftwo, wfthree, wffour, wffive, wfsix = match.captures
				http_host = /^([^\:]*)/.match(env["HTTP_HOST"])
				wfcache_file = "#{http_host}_#{wfone}/#{wftwo}~#{wfthree}~#{wffour}~#{wffive}~#{wfsix}_wfcache#{wfcache_https}.html#{wfcache_encoding}"
				wfcache_hit_message = "NO HIT because no cached file #{wfcache_file}"
				if File.file?("#{wfcache_dir}/#{wfcache_file}")
					return [307, {"x-reproxy-url" => "#{wfcache_base}/#{wfcache_file}"}, []]
				end 
			end
		end
	else   # Apply suitable headers to cached files
		headers["Vary"] = "Accept-Encoding, Cookie"
		headers["Content-Type"] = "text/html; charset=UTF-8"
		if /^(\/index.php)?(\/.*_gzip$)/ =~ env["PATH_INFO"]
			headers["Content-Encoding"] = "gzip"
		end
		wfcache_hit_message = "HIT cached file #{$2}"
	end    
	headers["wfcache-hit"] = "#{wfcache_hit_message}"
        if /.*(#{blockable_addresses}).*/ !~ env["PATH_INFO"]
		return [399, headers, []]
	end
	[403, {'content-type' => 'text/plain'}, ["access forbidden\n"]]
end
