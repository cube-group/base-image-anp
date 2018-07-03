#!/bin/bash

nginxDefaultConf="/etc/nginx/conf.d/default.conf"

#nginx php conf select
if [ "$NGINX_PHP_CONF" == "tp" ];then
    cat /nginx-php-conf/tp.conf > ${nginxDefaultConf}
elif [ "$NGINX_PHP_CONF" == "orc" ];then
    cat /nginx-php-conf/orc.conf > ${nginxDefaultConf}
elif [ "$NGINX_PHP_CONF" == "laravel" ];then
    cat /nginx-php-conf/laravel.conf > ${nginxDefaultConf}
else
    echo "yaf"
fi


# Increase the nginx default.conf
if [ ! -z "$APP_PATH_INDEX" ]; then
 sed -i "s#root /var/www/html;#root ${APP_PATH_INDEX};#g" ${nginxDefaultConf}
fi

# Increase the nginx default.conf
if [ ! -z "$APP_PATH_404" ]; then
 sed -i "s#root /var/www/errors;#root ${APP_PATH_404};#g" ${nginxDefaultConf}
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

# 环境变量配置替换
# php配置
echo "cgi.fix_pathinfo=0" > ${php_vars}
echo "upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}"  >> ${php_vars}
echo "post_max_size = ${PHP_POST_MAX_SIZE}"  >> ${php_vars}
echo "variables_order = \"EGPCS\""  >> ${php_vars}
echo "memory_limit = ${PHP_MEM_LIMIT}"  >> ${php_vars}

# php-fpm.d/www.conf配置
sed -i "s#;catch_workers_output\s*=\s*yes#catch_workers_output = yes#g" ${fpm_conf}
sed -i "s#pm.max_children = 5#pm.max_children = ${FPM_MAX_CHILDREN}#g" ${fpm_conf}
sed -i "s#pm.start_servers = 2#pm.start_servers = 5#g" ${fpm_conf}
sed -i "s#pm.min_spare_servers = 1#pm.min_spare_servers = 4#g" ${fpm_conf}
sed -i "s#pm.max_spare_servers = 3#pm.max_spare_servers = 6#g" ${fpm_conf}
sed -i "s#;pm.max_requests = 500#pm.max_requests = 200#g" ${fpm_conf}
sed -i "s#;request_slowlog_timeout = 0#request_slowlog_timeout = ${FPM_SLOWLOG_TIMEOUT}#g" ${fpm_conf}
sed -i "s#user = www-data#user = nginx#g" ${fpm_conf}
sed -i "s#group = www-data#group = nginx#g" ${fpm_conf}
sed -i "s#;listen.mode = 0660#listen.mode = 0666#g" ${fpm_conf}
sed -i "s#;listen.owner = www-data#listen.owner = nginx#g" ${fpm_conf}
sed -i "s#;listen.group = www-data#listen.group = nginx#g" ${fpm_conf}
touch ${FPM_SLOWLOG}
echo "slowlog = ${FPM_SLOWLOG}" >> ${fpm_conf}
echo "clear_env = no" >> ${fpm_conf}

# nginx.d/default.conf 特殊location代码替换
sed -i "s;#static rewrite or try_files;${NGINX_LOCATION};g" ${nginxDefaultConf}


#日志权限处理
chown -R nginx:nginx $APP_PATH
chmod -R 777 $APP_PATH
mkdir -p /data/log
chown -R nginx:nginx /data/log
chmod -R 777 /data/log

#create cli.log
touch /cli.log

#extra third shell start
bash /extra/external.sh

#php-fpm start
/usr/local/sbin/php-fpm >> /cli.log &
#nginx start
/usr/sbin/nginx >> /cli.log &

tail -f /cli.log