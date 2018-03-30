FROM richarvey/nginx-php-fpm

LABEL maintainer="lin2798003@sina.com"

ENV TIMEZONE Asia/Shanghai
ENV PHP_MEMORY_LIMIT 512M
ENV MAX_UPLOAD 50M
ENV PHP_MAX_FILE_UPLOAD 200
ENV PHP_MAX_POST 100M
ENV PHP_EXT_SWOOLE=swoole-2.0.6
ENV PHP_REDIS=3.1.4

# 备份原始文件
# 修改为国内镜像源
RUN cp /etc/apk/repositories /etc/apk/repositories.bak && \
    echo "http://mirrors.aliyun.com/alpine/v3.4/main/" > /etc/apk/repositories && \
    apk update
#RUN apk update && \
#  apk add tzdata curl && \
#  cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
#  echo "${TIMEZONE}" > /etc/timezone && \
#  apk add \
#    curl curl-dev postgresql-dev \
#    ## 如果使用swoole  需要取消下行注释
#    hiredis-dev libmcrypt-dev gmp-dev icu-dev linux-headers musl --virtual .phpize-deps $PHPIZE_DEPS \
#    tzdata

ENV MEMCACHED_DEPS zlib-dev libmemcached-dev cyrus-sasl-dev git
RUN set -xe \
    && apk add --no-cache libmemcached-libs zlib \
    && apk add --no-cache \
        --virtual .memcached-deps \
        $MEMCACHED_DEPS \
    && git clone -b php7 https://github.com/php-memcached-dev/php-memcached /usr/src/php/ext/memcached \
    && docker-php-ext-configure /usr/src/php/ext/memcached \
        --disable-memcached-sasl \
    && docker-php-ext-install /usr/src/php/ext/memcached \
    && rm -rf /usr/src/php/ext/memcached \
    && apk del .memcached-deps

# pecl install yaf-3.0.6 redis-3.1.6 memcached-3.0.4
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

RUN cd /tmp && pecl download redis-3.1.6 && \
    mkdir -p /tmp/redis-3.1.6 && \
    tar -xf redis-3.1.6.tgz -C /tmp/redis-3.1.6 --strip-components=1 && \
    docker-php-ext-configure /tmp/redis-3.1.6 && \
    docker-php-ext-install /tmp/redis-3.1.6 && \
    rm -rf /tmp/redis-*

#RUN cd /tmp && pecl download memcache-2.2.7 && \
#    mkdir -p /tmp/memcache-2.2.7 && \
#    tar -xf memcache-2.2.7.tgz -C /tmp/memcache-2.2.7 --strip-components=1 && \
#    docker-php-ext-configure /tmp/memcache-2.2.7 && \
#    docker-php-ext-install /tmp/memcache-2.2.7 && \
#    rm -rf /tmp/memcache-*

#RUN cd /tmp \
#    && pecl download $PHP_EXT_SWOOLE \
#    && mkdir -p /tmp/$PHP_EXT_SWOOLE \
#    && tar -xf ${PHP_EXT_SWOOLE}.tgz -C /tmp/$PHP_EXT_SWOOLE --strip-components=1 \
#    && docker-php-ext-configure /tmp/$PHP_EXT_SWOOLE --enable-async-redis --enable-openssl --enable-sockets=/usr/local/include/php/ext/sockets \
#    && docker-php-ext-install /tmp/$PHP_EXT_SWOOLE \
#    && rm -rf /tmp/${PHP_EXT_SWOOLE}*

RUN composer selfupdate
