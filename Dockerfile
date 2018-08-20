FROM alpine:3.8
#alpine3.8
#php7.2.8

MAINTAINER lin2798003 development "lin2798003@sina.com"

USER root

ENV APP_NAME anp
ENV APP_PATH /var/www/html
ENV APP_PATH_INDEX /var/www/html
ENV APP_PATH_404 /var/www/html
#ENV APP_MONITOR_HOOK DINGTALK-HOOK

ENV PHP_MEM_LIMIT 512M
ENV PHP_POST_MAX_SIZE 100M
ENV PHP_UPLOAD_MAX_FILESIZE 100M

ENV FPM_MAX_CHILDREN 200
ENV FPM_SLOWLOG /var/log/fpm-slow.log
ENV FPM_SLOWLOG_TIMEOUT 2

#nginx默认
ENV NGINX_PHP_CONF default

#以下不要覆盖
ENV nginx_etc /etc/nginx
ENV nginx_conf_d /etc/nginx/conf.d
ENV nginx_conf_d_default /etc/nginx/conf.d/default.conf

ENV php_etc /etc/php7
ENV php_ini /etc/php7/php.ini
ENV php_conf_d /etc/php7/conf.d
ENV php_conf /etc/php7/php-fpm.conf
ENV fpm_conf /etc/php7/php-fpm.d/www.conf


# 备份原始文件
# 修改为国内镜像源
RUN echo "https://mirrors.aliyun.com/alpine/v3.8/main/" > /etc/apk/repositories && \
    echo "https://mirrors.aliyun.com/alpine/v3.8/community/" >> /etc/apk/repositories && \
    apk update && \
    apk add nginx && \
    apk add curl git && \
    apk add php7 php7-mbstring php7-exif php7-ftp php7-intl php7-session php7-fpm && \
    apk add php7-xml php7-soap php7-sodium php7-xsl php7-zlib && \
    apk add php7-json php7-phar php7-gd php7-iconv php7-openssl php7-dom php7-pdo php7-curl && \
    apk add php7-xmlwriter php7-xmlreader php7-ctype php7-simplexml php7-zip php7-posix && \
    apk add php7-dev php7-pear php7-tokenizer php7-bcmath php7-mongodb php7-apcu php7-fileinfo php7-gmp && \
    apk add php7-redis php7-opcache php7-amqp php7-memcached && \
    apk add php7-pdo_mysql php7-pdo_pgsql && \
    apk add autoconf make cmake gcc g++ tzdata && \
    echo "config opcache" && \
    echo 'opcache.validate_timestamps=0' >> ${php_conf_d}/00_opcache.ini && \
    echo 'opcache.enable=1' >> ${php_conf_d}/00_opcache.ini && \
    echo 'opcache.enable_cli=1' >> ${php_conf_d}/00_opcache.ini && \
    echo "config apcu" && \
    echo 'apc.enabled=1' >> ${php_conf_d}/apcu.ini && \
    echo 'apc.shm_size=32M' >> ${php_conf_d}/apcu.ini && \
    echo 'apc.enable_cli=1' >> ${php_conf_d}/apcu.ini && \
    pecl install yaf && \
    echo "config yaf" && \
    echo '[yaf]' >> ${php_conf_d}/yaf.ini && \
    echo 'extension=yaf.so' >> ${php_conf_d}/yaf.ini && \
    echo 'yaf.cache_config=1' >> ${php_conf_d}/yaf.ini && \
    echo 'yaf.use_namespace=1' >> ${php_conf_d}/yaf.ini && \
    echo 'yaf.use_spl_autoload=1' >> ${php_conf_d}/yaf.ini && \
    # remove useless
    apk del php7-dev gcc autoconf make cmake g++

#设置时区
RUN apk add bash \
    && /bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' >/etc/timezone

ADD conf/nginx.conf ${nginx_etc}/nginx.conf
ADD conf/default.conf ${nginx_conf_d}/default.conf

ADD conf/orc.conf /nginx-php-conf/orc.conf
ADD conf/tp.conf /nginx-php-conf/tp.conf
ADD conf/laravel.conf /nginx-php-conf/laravel.conf

COPY index.php ${APP_PATH}/index.php
COPY ./monitor/ /extra/monitor/
COPY ./scripts/ /extra/
COPY --from=ochinchina/supervisord:latest /usr/local/bin/supervisord /usr/local/bin/supervisord
COPY supervisor.conf /supervisor.conf

WORKDIR $APP_PATH

EXPOSE 80

STOPSIGNAL SIGTERM

ENTRYPOINT ["/bin/bash"]
CMD ["/extra/start.sh"]