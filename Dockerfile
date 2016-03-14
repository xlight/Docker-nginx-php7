FROM php:7-fpm

MAINTAINER xLight <xbluelight@gmail.com>

# install php pdo_mysql
RUN docker-php-ext-install pdo_mysql mysqli iconv mbstring json  opcache bcmath
RUN echo "opcache.enable_cli=1" >>  /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini

RUN echo "log_errors = On" >> /usr/local/etc/php/conf.d/log.ini


#################   start nginx #########
ENV NGINX_VERSION=1.9.12-1~jessie

RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62  && echo "deb http://nginx.org/packages/mainline/debian/ jessie nginx" >> /etc/apt/sources.list  && apt-get update  && apt-get install -y       ca-certificates       nginx=${NGINX_VERSION}       nginx-module-xslt       nginx-module-geoip       nginx-module-image-filter       gettext-base  && rm -rf /var/lib/apt/lists/*

RUN ln -sf /dev/stdout /var/log/nginx/access.log  && ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 443/tcp 80/tcp

WORKDIR /usr/share/nginx/html

RUN mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.bak

ENV NGINX_CONF /etc/nginx/conf.d/phpfpm.conf
RUN echo "server {" > $NGINX_CONF && \
    echo "    listen       80;" >> $NGINX_CONF && \
    echo "    #server_name  .*;" >> $NGINX_CONF && \
    echo "    #access_log  /var/log/nginx/log/host.access.log  main;" >> $NGINX_CONF && \
    echo "  location ~ ^/(images|javascript|js|css|flash|media|static|fonts|easyui)/ {" >> $NGINX_CONF && \
    echo "               root /usr/share/nginx/html;" >> $NGINX_CONF && \
    echo "               expires 30d;" >> $NGINX_CONF && \
    echo "  }" >> $NGINX_CONF && \
    echo "  location ~ \.php$ {" >> $NGINX_CONF && \
    echo "      fastcgi_split_path_info ^(.+?\.php)(/.*)$;" >> $NGINX_CONF && \
    echo "      if (!-f \$document_root\$fastcgi_script_name) {" >> $NGINX_CONF && \
    echo "          return 404;" >> $NGINX_CONF && \
    echo "      }" >> $NGINX_CONF && \
    echo "      root /usr/share/nginx/html;" >> $NGINX_CONF && \
    echo "      fastcgi_pass 127.0.0.1:9000;" >> $NGINX_CONF && \
    echo "      fastcgi_index index.php;" >> $NGINX_CONF && \
    echo "      fastcgi_param  SCRIPT_FILENAME  \$document_root\$fastcgi_script_name;" >> $NGINX_CONF && \
    echo "      include fastcgi_params;" >> $NGINX_CONF && \
    echo "  }" >> $NGINX_CONF && \
    echo "  location / {" >> $NGINX_CONF && \
    echo "    try_files $uri $uri/ /index.php?\$query_string;" >> $NGINX_CONF && \
    echo "  }" >> $NGINX_CONF && \
    echo "}" >> $NGINX_CONF


CMD nginx && php-fpm
