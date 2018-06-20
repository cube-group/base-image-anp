#!/bin/bash

# Increase the nginx default.conf
if [ ! -z "$APP_PATH_INDEX" ]; then
 sed -i "s#root /var/www/html;#root ${APP_PATH_INDEX};#g" /etc/nginx/conf.d/default.conf
fi

# Increase the nginx default.conf
if [ ! -z "$APP_PATH_404" ]; then
 sed -i "s#root /var/www/errors;#root ${APP_PATH_404};#g" /etc/nginx/conf.d/default.conf
fi

# Increase the memory_limit
if [ ! -z "$PHP_MEM_LIMIT" ]; then
 sed -i "s#memory_limit = 128M#memory_limit = ${PHP_MEM_LIMIT}M#g" /usr/local/etc/php/conf.d/docker-vars.ini
fi

# Increase the post_max_size
if [ ! -z "$PHP_POST_MAX_SIZE" ]; then
 sed -i "s#post_max_size = 100M#post_max_size = ${PHP_POST_MAX_SIZE}M#g" /usr/local/etc/php/conf.d/docker-vars.ini
fi

# Increase the upload_max_filesize
if [ ! -z "$PHP_UPLOAD_MAX_FILESIZE" ]; then
 sed -i "s#upload_max_filesize = 100M#upload_max_filesize= ${PHP_UPLOAD_MAX_FILESIZE}M#g" /usr/local/etc/php/conf.d/docker-vars.ini
fi

#nginx
if [ "$NGINX_PHP_CONF" == "tp" ];then
    rm -rf /etc/nginx/conf.d/default.conf
    rm -rf /etc/nginx/conf.d/orc.conf
elif [ "$NGINX_PHP_CONF" == "orc" ];then
    rm -rf /etc/nginx/conf.d/default.conf
    rm -rf /etc/nginx/conf.d/tp.conf
else
    rm -rf /etc/nginx/conf.d/orc.conf
    rm -rf /etc/nginx/conf.d/tp.conf
fi

#日志权限处理
chown -R nginx:nginx $APP_PATH
chmod -R 777 $APP_PATH
mkdir -p /data/log
chown -R nginx:nginx /data/log
chmod -R 777 /data/log

#create cli.log
touch /cli.log

#extra third shell start
sh /extra/external.sh

#php-fpm start
/usr/local/sbin/php-fpm &
#nginx start
/usr/sbin/nginx -g "daemon off; error_log /dev/stderr info;"