#!/bin/bash

mkdir -p /run/nginx

#IP
IP=`/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`
#容器ID
CONTAINER_ID=${HOSTNAME}

#设置慢日志和错误日志文件
SLOW_LOG=$FPM_SLOWLOG
ERROR_LOG="/var/log/fpm-php.www.log"
ERROR_FPM_LOG="/var/log/fpm-php.err.log"
if [ "$APP_NAME" ]; then
    SLOW_LOG=/data/log/${APP_NAME}-${IP}-${CONTAINER_ID}.phpslow
    ERROR_LOG=/data/log/${APP_NAME}-${IP}-${CONTAINER_ID}.phperror
    ERROR_FPM_LOG=/data/log/${APP_NAME}-${IP}-${CONTAINER_ID}.fpmerror
fi

#慢日志与错误日志
if [ ! -d "/data/log" ];then
    mkdir -p /data/log
    chmod 777 /data/log
fi
touch ${SLOW_LOG}
echo ${SLOW_LOG}
touch ${ERROR_LOG}
echo ${ERROR_LOG}
chmod 777 ${ERROR_LOG}

#nginx php conf select
if [ "$NGINX_PHP_CONF" == "tp" ];then
    echo "[nginx-fastcgi-conf]: thinkphp"
    cat /nginx-php-conf/tp.conf > ${nginx_conf_d_default}
elif [ "$NGINX_PHP_CONF" == "orc" ];then
    echo "[nginx-fastcgi-conf]: orc"
    cat /nginx-php-conf/orc.conf > ${nginx_conf_d_default}
elif [ "$NGINX_PHP_CONF" == "laravel" ];then
    echo "[nginx-fastcgi-conf]: laravel"
    cat /nginx-php-conf/laravel.conf > ${nginx_conf_d_default}
else
    echo "[nginx-fastcgi-conf]: yaf"
fi


# Increase the nginx default.conf
if [ ! -z "$APP_PATH_INDEX" ]; then
 sed -i "s#root /var/www/html;#root ${APP_PATH_INDEX};#g" ${nginx_conf_d_default}
fi
# Increase the nginx default.conf
if [ ! -z "$APP_PATH_404" ]; then
 sed -i "s#root /var/www/errors;#root ${APP_PATH_404};#g" ${nginx_conf_d_default}
fi
# opcache check closed
if [ "$ENABLE_OPCACHE"x = "0"x ];then
    sed -i "s#opcache.enable=1#opcache.enable=0#g" ${php_conf_d}/00_opcache.ini
fi


# 环境变量配置替换
# php配置
echo "cgi.fix_pathinfo=0" >> ${php_ini}
echo "upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}"  >> ${php_ini}
echo "post_max_size = ${PHP_POST_MAX_SIZE}"  >> ${php_ini}
echo "variables_order = \"EGPCS\""  >> ${php_ini}
echo "memory_limit = ${PHP_MEM_LIMIT}"  >> ${php_ini}

# php-fpm.d/www.conf配置
sed -i "s#;catch_workers_output\s*=\s*yes#catch_workers_output = yes#g" ${fpm_conf}
sed -i "s#pm.max_children = 5#pm.max_children = ${FPM_MAX_CHILDREN}#g" ${fpm_conf}
sed -i "s#pm.start_servers = 2#pm.start_servers = ${FPM_START_SERVERS}#g" ${fpm_conf}
sed -i "s#pm.min_spare_servers = 1#pm.min_spare_servers = ${FPM_MIN_SPARE_SERVERS}#g" ${fpm_conf}
sed -i "s#pm.max_spare_servers = 3#pm.max_spare_servers = ${FPM_MAX_SPARE_SERVERS}#g" ${fpm_conf}
sed -i "s#;pm.max_requests = 500#pm.max_requests = ${FPM_MAX_REQUESTS}#g" ${fpm_conf}
sed -i "s#;request_slowlog_timeout = 0#request_slowlog_timeout = ${FPM_SLOWLOG_TIMEOUT}#g" ${fpm_conf}
sed -i "s#user = nobody#user = root#g" ${fpm_conf}
sed -i "s#group = nobody#group = root#g" ${fpm_conf}
sed -i "s#;listen.mode = 0660#listen.mode = 0666#g" ${fpm_conf}
echo "listen.owner = root" >> ${fpm_conf}
echo "listen.group = root" >> ${fpm_conf}
echo "clear_env = no" >> ${fpm_conf}
echo "slowlog = ${SLOW_LOG}" >> ${fpm_conf}
echo "php_admin_flag[log_errors] = on" >> ${fpm_conf}
echo "php_admin_value[error_log] = ${ERROR_LOG}" >> ${fpm_conf}
echo "[global]" >> ${fpm_conf}
echo "error_log = ${ERROR_FPM_LOG}" >> ${fpm_conf}

supervisord -c /supervisor.conf