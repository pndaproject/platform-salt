upstream data_manager_api {
	server {{ data_manager_host }}:{{ data_manager_port }};
}

server {
	listen {{port}} default_server;

	root {{ console_dir }};
	index index.html index.htm; 

	# Make site accessible from http://localhost/
	server_name localhost;

	location / {
		# First attempt to serve request as file, then
		# as directory, then fall back to displaying a 404.
		try_files $uri $uri/ =404;
		# Uncomment to enable naxsi on this location
		# include /etc/nginx/naxsi.rules
	}

	location /socket.io/ {
    		proxy_http_version 1.1;
    		proxy_set_header Upgrade $http_upgrade;
    		proxy_set_header Connection "upgrade";
    		proxy_pass http://data_manager_api;
    	}

    	location /api/dm {
        	proxy_set_header X-Real-IP $remote_addr;
        	proxy_set_header Host $http_host;
        	proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        	proxy_pass http://data_manager_api;
        	proxy_redirect off;
    	}

	location /pam {
		proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header Host $http_host;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_pass http://data_manager_api;
                proxy_redirect off;
	}
	
	#error_page 500 502 503 504 /50x.html;
	#location = /50x.html {
	#	root /usr/share/nginx/html;
	#}

	# deny access to .htaccess files, if Apache's document root
	# concurs with nginx's one
	#
	#location ~ /\.ht {
	#	deny all;
	#}
}
