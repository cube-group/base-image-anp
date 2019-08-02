FROM geekidea/alpine-a:3.8
#alpine3.8+php7.2 DNS无问题版本

MAINTAINER lin2798003 development "lin2798003@sina.com"

USER root

#app级别环境变量（重要）
ENV APP_NAME anp
ENV APP_PATH /var/www/html
ENV APP_PATH_INDEX /var/www/html
ENV APP_PATH_404 /var/www/html
ENV APP_INIT_SHELL ""
ENV APP_MONITOR_HOOK DINGTALK-HOOK

#php配置（尽量勿动）
ENV PHP_MEM_LIMIT 512M
ENV PHP_POST_MAX_SIZE 100M
ENV PHP_UPLOAD_MAX_FILESIZE 100M

#php-fpm配置（尽量勿动）
ENV FPM_MAX_CHILDREN 200
ENV FPM_START_SERVERS 10
ENV FPM_MIN_SPARE_SERVERS 8
ENV FPM_MAX_SPARE_SERVERS 15
ENV FPM_MAX_REQUESTS 200
ENV FPM_SLOWLOG /var/log/fpm-slow.log
ENV FPM_SLOWLOG_TIMEOUT 2

#nginx fastcgi默认配置default/orc/tp/laravel/yaf
ENV NGINX_PHP_CONF default
#是否开启opache功能
ENV ENABLE_OPCACHE "1"

#nginx内部环境变量（勿动）
ENV nginx_etc /etc/nginx
ENV nginx_conf_d /etc/nginx/conf.d
ENV nginx_conf_d_default /etc/nginx/conf.d/default.conf

#php-fpm内部环境变量（勿动）
ENV php_etc /etc/php7
ENV php_ini /etc/php7/php.ini
ENV php_conf_d /etc/php7/conf.d
ENV php_conf /etc/php7/php-fpm.conf
ENV php_fpm_conf /etc/php7/php-fpm.d/www.conf

RUN apk add bash vim curl nginx php7-fpm


# 修改为国内镜像源
RUN echo "https://mirrors.aliyun.com/alpine/v3.8/main/" > /etc/apk/repositories && \
    echo "https://mirrors.aliyun.com/alpine/v3.8/community/" >> /etc/apk/repositories && \
    apk update && \
    apk add zlib zlib-dev && \
    apk add autoconf make cmake gcc g++ tzdata ca-certificates && \
    apk add librdkafka librdkafka-dev && \
    apk add php7 php7-dev php7-opcache php7-mbstring php7-session php7-zip && \
    apk add php7-xml php7-simplexml php7-zlib && \
    apk add php7-json php7-gd php7-iconv php7-openssl php7-curl && \
    apk add php7-pear php7-tokenizer php7-mongodb php7-apcu php7-fileinfo && \
    apk add php7-redis php7-memcached && \
    apk add php7-pdo php7-pdo_mysql php7-pdo_pgsql && \
    apk add php7-bcmath php7-ctype php7-phar php7-xmlwriter && \
    apk add php7-gmp php7-posix php7-exif php7-intl php7-soap php7-sodium php7-xsl php7-dom php7-xmlreader php7-amqp && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo 'Asia/Shanghai' >/etc/timezone && \
    echo "config opcache" && \
    echo 'opcache.validate_timestamps=0' >> ${php_conf_d}/00_opcache.ini && \
    echo 'opcache.enable=1' >> ${php_conf_d}/00_opcache.ini && \
    echo 'opcache.enable_cli=1' >> ${php_conf_d}/00_opcache.ini && \
    echo "config apcu" && \
    echo 'apc.enabled=1' >> ${php_conf_d}/apcu.ini && \
    echo 'apc.shm_size=32M' >> ${php_conf_d}/apcu.ini && \
    echo 'apc.enable_cli=1' >> ${php_conf_d}/apcu.ini && \
    pecl install http://pecl.php.net/get/yaf-3.0.8.tgz && \
    echo "config yaf" && \
    echo '[yaf]' >> ${php_conf_d}/yaf.ini && \
    echo 'extension=yaf.so' >> ${php_conf_d}/yaf.ini && \
    echo 'yaf.cache_config=1' >> ${php_conf_d}/yaf.ini && \
    echo 'yaf.use_namespace=1' >> ${php_conf_d}/yaf.ini && \
    echo 'yaf.use_spl_autoload=1' >> ${php_conf_d}/yaf.ini && \
    pecl install http://pecl.php.net/get/protobuf-3.9.0.tgz && \
    echo 'extension=protobuf.so' >> ${php_conf_d}/protobuf.ini && \
    pecl install http://pecl.php.net/get/grpc-1.22.0.tgz && \
    echo 'extension=grpc.so' >> ${php_conf_d}/grpc.ini && \
    pecl install http://pecl.php.net/get/rdkafka-3.1.2.tgz && \
    echo 'extension=rdkafka.so' >> ${php_conf_d}/rdkafka.ini && \
    apk del php7-dev php7-pear gcc autoconf make cmake g++ zlib-dev librdkafka-dev && \
    #修复iconv上传报错问题 https://github.com/aliyun/aliyun-oss-php-sdk/issues/97
    apk add --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/community gnu-libiconv

ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

ADD conf /nginx-php-conf/
ADD conf/nginx.conf ${nginx_etc}/nginx.conf
ADD conf/default.conf ${nginx_conf_d}/default.conf

COPY run.sh /run.sh
COPY index.php ${APP_PATH}/index.php
COPY supervisor.conf /supervisor.conf
COPY supervisor /etc/supervisor/
COPY extra /extra/
COPY --from=ochinchina/supervisord:latest /usr/local/bin/supervisord /usr/local/bin/supervisord

WORKDIR $APP_PATH

EXPOSE 80

STOPSIGNAL SIGTERM

ENTRYPOINT ["/bin/bash"]
CMD ["/run.sh"]