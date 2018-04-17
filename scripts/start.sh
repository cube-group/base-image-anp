#!/bin/bash

# Increase the NGINX_BODY_SIZE
if [ ! -z "$NGINX_BODY_SIZE" ]; then
 sed -i "s/client_max_body_size 100m;/client_max_body_size ${FPM_SLOWLOG};/g" /etc/nginx/nginx.conf
fi

# Increase the FPM_MAX_CHILDREN
# pm.max_children
if [ ! -z "$FPM_MAX_CHILDREN" ]; then
 sed -i "s/pm.max_children = 4/pm.max_children = ${FPM_MAX_CHILDREN}/g" /usr/local/etc/php-fpm.d/www.conf
fi

# Increase the FPM_START_SERVERS
# pm.start_servers
if [ ! -z "$FPM_START_SERVERS" ]; then
 sed -i "s/pm.start_servers = 3/pm.start_servers = ${FPM_START_SERVERS}/g" /usr/local/etc/php-fpm.d/www.conf
fi

# Increase the FPM_MIN_SPARE_SERVERS
# pm.min_spare_servers
if [ ! -z "$FPM_MIN_SPARE_SERVERS" ]; then
 sed -i "s/pm.start_servers = 3/pm.start_servers = ${FPM_MIN_SPARE_SERVERS}/g" /usr/local/etc/php-fpm.d/www.conf
fi

# Increase the FPM_MAX_SPARE_SERVERS
# pm.max_spare_servers
if [ ! -z "$FPM_MAX_SPARE_SERVERS" ]; then
 sed -i "s/pm.start_servers = 3/pm.start_servers = ${FPM_MAX_SPARE_SERVERS}/g" /usr/local/etc/php-fpm.d/www.conf
fi

# Increase the FPM_SLOWLOG
# slowlog
if [ ! -z "$FPM_SLOWLOG" ]; then
 sed -i "s/;slowlog = log/$pool.log.slow/slowlog = ${FPM_SLOWLOG}/g" /usr/local/etc/php-fpm.d/www.conf
fi

# Increase the FPM_SLOWLOG_TIMEOUT
# request_slowlog_timeout
if [ ! -z "$FPM_SLOWLOG_TIMEOUT" ]; then
 sed -i "s/;request_slowlog_timeout = 0/;request_slowlog_timeout = ${FPM_SLOWLOG_TIMEOUT}/g" /usr/local/etc/php-fpm.d/www.conf
fi

# 写死
sed -i "s/;slowlog = log/$pool.log.slow/slowlog = var/log/$pool.log.slow/g" /usr/local/etc/php-fpm.d/www.conf


# restart nginx
supervisorctl restart php-fpm
# restart nginx
supervisorctl restart nginx