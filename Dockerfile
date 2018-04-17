# 这里我们基于alpine linux + nginx + php7.1-fpm镜像为基础
# 在此非常感谢它的支持
# 当然如果你对alpine apk add不熟悉就使用ubuntu进行php安装较为简单
FROM richarvey/nginx-php-fpm

LABEL maintainer="lin2798003@sina.com"

# 父级镜像支持的环境变量
ENV TIMEZONE Asia/Shanghai
ENV PHP_MEM_LIMIT 512M
ENV PHP_POST_MAX_SIZE 100M
ENV PHP_UPLOAD_MAX_FILESIZE 100M
ENV WEBROOT /var/www/html

#ENV PHP_EXT_SWOOLE=swoole-2.0.6
# nginx & php-fpm conf
ENV NGINX_BODY_SIZE 100m
ENV FPM_MAX_CHILDREN 50
ENV FPM_START_SERVERS 4
ENV FPM_MIN_SPARE_SERVERS 4
ENV FPM_MAX_SPARE_SERVERS 5
ENV FPM_SLOWLOG_TIMEOUT 2

# dingding webhook
ENV APP_NAME test
ENV APP_ALERT_DINGDING false

# copy
COPY ./scripts/start.sh /extra-sh

# 备份原始文件
# 修改为国内镜像源
RUN cp /etc/apk/repositories /etc/apk/repositories.bak && \
    echo "http://mirrors.aliyun.com/alpine/v3.4/main/" > /etc/apk/repositories && \
    apk update

ENV MEMCACHED_DEPS zlib-dev libmemcached-dev cyrus-sasl-dev git
RUN set -xe \
    && apk add --no-cache libmemcached-libs zlib \
    && apk add --no-cache --virtual .memcached-deps $MEMCACHED_DEPS \
    && git clone -b php7 https://github.com/php-memcached-dev/php-memcached /usr/src/php/ext/memcached \
    && docker-php-ext-configure /usr/src/php/ext/memcached --disable-memcached-sasl \
    && docker-php-ext-install /usr/src/php/ext/memcached \
    && rm -rf /usr/src/php/ext/memcached \
    && apk del .memcached-deps

# 安装yaf扩展
RUN cd /tmp && pecl download yaf-3.0.6 && \
    mkdir -p /tmp/yaf-3.0.6 && \
    tar -xf yaf-3.0.6.tgz -C /tmp/yaf-3.0.6 --strip-components=1 && \
    docker-php-ext-configure /tmp/yaf-3.0.6 && \
    docker-php-ext-install /tmp/yaf-3.0.6 && \
    sed -i '$a\[yaf]' /usr/local/etc/php/conf.d/docker-php-ext-yaf.ini && \
    sed -i '$a\yaf.cache_config=1' /usr/local/etc/php/conf.d/docker-php-ext-yaf.ini && \
    sed -i '$a\yaf.use_namespace=1' /usr/local/etc/php/conf.d/docker-php-ext-yaf.ini && \
    sed -i '$a\yaf.use_spl_autoload=1' /usr/local/etc/php/conf.d/docker-php-ext-yaf.ini && \
    rm -rf /tmp/yaf-*

# 安装redis扩展
RUN cd /tmp && pecl download redis-3.1.6 && \
    mkdir -p /tmp/redis-3.1.6 && \
    tar -xf redis-3.1.6.tgz -C /tmp/redis-3.1.6 --strip-components=1 && \
    docker-php-ext-configure /tmp/redis-3.1.6 && \
    docker-php-ext-install /tmp/redis-3.1.6 && \
    rm -rf /tmp/redis-*

# 安装mongodb扩展
RUN cd /tmp && pecl download mongodb-1.4.2 && \
    mkdir -p /tmp/mongodb-1.4.2 && \
    tar -xf mongodb-1.4.2.tgz -C /tmp/mongodb-1.4.2 --strip-components=1 && \
    docker-php-ext-configure /tmp/mongodb-1.4.2 && \
    docker-php-ext-install /tmp/mongodb-1.4.2 && \
    rm -rf /tmp/mongodb-*

# 安装apcu扩展
RUN cd /tmp && pecl download apcu-5.1.11 && \
    mkdir -p /tmp/apcu-5.1.11 && \
    tar -xf apcu-5.1.11.tgz -C /tmp/apcu-5.1.11 --strip-components=1 && \
    docker-php-ext-configure /tmp/apcu-5.1.11 && \
    docker-php-ext-install /tmp/apcu-5.1.11 && \
    sed -i '$a\[apcu]' /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini && \
    sed -i '$a\apc.enabled=1' /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini && \
    sed -i '$a\apc.shm_size=32M' /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini && \
    sed -i '$a\apc.enable_cli=1' /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini && \
    rm -rf /tmp/apcu-*

#RUN cd /tmp \
#    && pecl download $PHP_EXT_SWOOLE \
#    && mkdir -p /tmp/$PHP_EXT_SWOOLE \
#    && tar -xf ${PHP_EXT_SWOOLE}.tgz -C /tmp/$PHP_EXT_SWOOLE --strip-components=1 \
#    && docker-php-ext-configure /tmp/$PHP_EXT_SWOOLE --enable-async-redis --enable-openssl --enable-sockets=/usr/local/include/php/ext/sockets \
#    && docker-php-ext-install /tmp/$PHP_EXT_SWOOLE \
#    && rm -rf /tmp/${PHP_EXT_SWOOLE}*

RUN composer selfupdate

CMD ["/extra-sh/start.sh"]