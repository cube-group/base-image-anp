FROM php:7.2.4-fpm-alpine3.7
#alpine3.7
#php7.2

MAINTAINER lin2798003 development "lin2798003@sina.com"

USER root

ENV APP_NAME anp
ENV APP_PATH /var/www/html
#ENV APP_MONITOR_HOOK DINGTALK-HOOK

ENV PHP_MEM_LIMIT 512M
ENV PHP_POST_MAX_SIZE 100M
ENV PHP_UPLOAD_MAX_FILESIZE 100M

ENV FPM_MAX_CHILDREN 50
ENV FPM_START_SERVERS 8
ENV FPM_MIN_SPARE_SERVERS 4
ENV FPM_MAX_SPARE_SERVERS 5
ENV FPM_SLOWLOG /usr/local/var/log/slow.log
ENV FPM_SLOWLOG_TIMEOUT 2

ENV NGINX_BODY_SIZE 100m

#以下不要覆盖
ENV php_conf /usr/local/etc/php-fpm.conf
ENV fpm_conf /usr/local/etc/php-fpm.d/www.conf
ENV php_vars /usr/local/etc/php/conf.d/docker-vars.ini

# 备份原始文件
# 修改为国内镜像源
RUN cp /etc/apk/repositories /etc/apk/repositories.bak && \
    echo "http://mirrors.aliyun.com/alpine/v3.7/main/" > /etc/apk/repositories && \
    apk update

#nginx install
ENV NGINX_VERSION 1.13.12

RUN addgroup -S nginx \
    && adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx \
    && apk add --no-cache --virtual .build-deps \
        gcc \
        libc-dev \
        make \
        openssl-dev \
        pcre-dev \
        zlib-dev \
        linux-headers \
        curl \
        gnupg \
        libxslt-dev \
        gd-dev \
        geoip-dev \
    && curl -fSL https://nginx.org/download/nginx-1.13.12.tar.gz -o nginx.tar.gz \
    && curl -fSL https://nginx.org/download/nginx-1.13.12.tar.gz.asc  -o nginx.tar.gz.asc \
    && mkdir -p /usr/src \
    && tar -zxC /usr/src -f nginx.tar.gz \
    && rm nginx.tar.gz \
    && cd /usr/src/nginx-1.13.12 \
    && ./configure --prefix=/etc/nginx \
                        --sbin-path=/usr/sbin/nginx \
                        --modules-path=/usr/lib/nginx/modules \
                        --conf-path=/etc/nginx/nginx.conf \
                        --error-log-path=/var/log/nginx/error.log \
                        --http-log-path=/var/log/nginx/access.log \
                        --pid-path=/var/run/nginx.pid \
                        --lock-path=/var/run/nginx.lock \
                        --http-client-body-temp-path=/var/cache/nginx/client_temp \
                        --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
                        --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
                        --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
                        --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
                        --user=nginx \
                        --group=nginx \
                        --with-http_ssl_module \
                        --with-http_realip_module \
                        --with-http_addition_module \
                        --with-http_sub_module \
                        --with-http_dav_module \
                        --with-http_flv_module \
                        --with-http_mp4_module \
                        --with-http_gunzip_module \
                        --with-http_gzip_static_module \
                        --with-http_random_index_module \
                        --with-http_secure_link_module \
                        --with-http_stub_status_module \
                        --with-http_auth_request_module \
                        --with-http_xslt_module=dynamic \
                        --with-http_image_filter_module=dynamic \
                        --with-http_geoip_module=dynamic \
                        --with-threads \
                        --with-stream \
                        --with-stream_ssl_module \
                        --with-stream_ssl_preread_module \
                        --with-stream_realip_module \
                        --with-stream_geoip_module=dynamic \
                        --with-http_slice_module \
                        --with-mail \
                        --with-mail_ssl_module \
                        --with-compat \
                        --with-file-aio \
                        --with-http_v2_module \
    && make && make install \
    && rm -rf /etc/nginx/html/ \
    && mkdir /etc/nginx/conf.d/ \
    && mkdir -p /usr/share/nginx/html/ \
    && install -m644 html/index.html /usr/share/nginx/html/ \
    && install -m644 html/50x.html /usr/share/nginx/html/ \
    && ln -s ../../usr/lib/nginx/modules /etc/nginx/modules \
    && strip /usr/sbin/nginx* \
    && strip /usr/lib/nginx/modules/*.so \
    && rm -rf /usr/src/nginx-1.13.12 \
    && apk add --no-cache --virtual .gettext gettext \
    && mv /usr/bin/envsubst /tmp/ \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log


RUN apk add --no-cache bash \
    wget \
    supervisor \
    curl \
    libcurl \
    python \
    python-dev \
    py-pip \
    augeas-dev \
    ca-certificates \
    dialog \
    autoconf \
    make \
    gcc \
    musl-dev \
    linux-headers \
    libpng-dev \
    icu-dev \
    libpq \
    libxslt-dev \
    libffi-dev \
    freetype-dev \
    gettext-dev \
    postgresql-dev \
    libjpeg-turbo-dev && \
    docker-php-ext-configure gd \
    --with-gd \
    --with-freetype-dir=/usr/include/ \
    --with-png-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install iconv pdo_mysql pdo_pgsql gd exif intl xsl soap zip opcache && \
    docker-php-source delete

# extension memcached install
#RUN set -xe \
#    && apk add --no-cache libmemcached-libs zlib \
#    && apk add git \
#    && apk add --no-cache --virtual .memcached-deps zlib-dev libmemcached-dev cyrus-sasl-dev git \
#    && git clone -b php7 https://github.com/php-memcached-dev/php-memcached /usr/src/php/ext/memcached \
#    && docker-php-ext-configure /usr/src/php/ext/memcached --disable-memcached-sasl \
#    && docker-php-ext-install /usr/src/php/ext/memcached \
#    && rm -rf /usr/src/php/ext/memcached \
#    && apk del .memcached-deps
RUN apk add libmemcached-libs libmemcached-dev zlib-dev \
    && pecl install igbinary \
    && echo 'extension=igbinary.so' >> /usr/local/etc/php/conf.d/docker-php-ext-igbinary.ini \
    && pecl install msgpack \
    && echo 'extension=msgpack.so' >> /usr/local/etc/php/conf.d/docker-php-ext-msgpack.ini \
    && pecl install memcached \
    && echo 'extension=memcached.so' >> /usr/local/etc/php/conf.d/docker-php-ext-memcached.ini

RUN apk add rabbitmq-c-dev \
    && pecl install amqp \
    && echo 'extension=amqp.so' >> /usr/local/etc/php/conf.d/docker-php-ext-amqp.ini


# extensions install
RUN pecl install redis && \
    echo '[redis]' >> /usr/local/etc/php/conf.d/docker-php-ext-redis.ini && \
    echo 'extension=redis.so' >> /usr/local/etc/php/conf.d/docker-php-ext-redis.ini && \
    pecl install xdebug && \
    echo '[xdebug]' >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    echo 'extension=xdebug.so' >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    echo 'opcache.validate_timestamps=0' >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini && \
    echo 'opcache.enable=1' >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini && \
    echo 'opcache.enable_cli=1' >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini && \
    pecl install yaf && \
    echo '[yaf]' >> /usr/local/etc/php/conf.d/docker-php-ext-yaf.ini && \
    echo 'extension=yaf.so' >> /usr/local/etc/php/conf.d/docker-php-ext-yaf.ini && \
    echo 'yaf.cache_config=1' >> /usr/local/etc/php/conf.d/docker-php-ext-yaf.ini && \
    echo 'yaf.use_namespace=1' >> /usr/local/etc/php/conf.d/docker-php-ext-yaf.ini && \
    echo 'yaf.use_spl_autoload=1' >> /usr/local/etc/php/conf.d/docker-php-ext-yaf.ini && \
    pecl install mongodb && \
    echo '[mongodb]' >> /usr/local/etc/php/conf.d/docker-php-ext-mongodb.ini && \
    echo 'extension=mongodb.so' >> /usr/local/etc/php/conf.d/docker-php-ext-mongodb.ini && \
    pecl install apcu && \
    echo '[apcu]' >> /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini && \
    echo 'extension=apcu.so' >> /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini && \
    echo 'apc.enabled=1' >> /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini && \
    echo 'apc.shm_size=32M' >> /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini && \
    echo 'apc.enable_cli=1' >> /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini


RUN echo "cgi.fix_pathinfo=0" > ${php_vars} &&\
    echo "upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}"  >> ${php_vars} &&\
    echo "post_max_size = ${PHP_POST_MAX_SIZE}"  >> ${php_vars} &&\
    echo "variables_order = \"EGPCS\""  >> ${php_vars} && \
    echo "memory_limit = ${PHP_MEM_LIMIT}"  >> ${php_vars} && \
    sed -i \
        -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" \
        -e "s/pm.max_children = 5/pm.max_children = ${FPM_MAX_CHILDREN}/g" \
        -e "s/pm.start_servers = 2/pm.start_servers = ${FPM_START_SERVERS}/g" \
        -e "s/pm.min_spare_servers = 1/pm.min_spare_servers = ${FPM_MIN_SPARE_SERVERS}/g" \
        -e "s/pm.max_spare_servers = 3/pm.max_spare_servers = ${FPM_MAX_SPARE_SERVERS}/g" \
        -e "s/;pm.max_requests = 500/pm.max_requests = 200/g" \
        -e "s/;slowlog = log/$pool.log.slow/slowlog = ${FPM_SLOWLOG}/g" \
        -e "s/;request_slowlog_timeout = 0/request_slowlog_timeout = ${FPM_SLOWLOG_TIMEOUT}/g" \
        -e "s/user = www-data/user = nginx/g" \
        -e "s/group = www-data/group = nginx/g" \
        -e "s/;listen.mode = 0660/listen.mode = 0666/g" \
        -e "s/;listen.owner = www-data/listen.owner = nginx/g" \
        -e "s/;listen.group = www-data/listen.group = nginx/g" \
        -e "s/listen = 127.0.0.1:9000/listen = \/var\/run\/php-fpm.sock/g" \
        -e "s/^;clear_env = no$/clear_env = no/" \
        ${fpm_conf}

# remove useless
RUN apk del \
    dpkg-dev dpkg \
    file \
    g++ \
    gcc \
    libc-dev \
    make \
    pkgconf \
    re2c

ADD conf/supervisord.conf /etc/supervisord.conf
ADD conf/nginx.conf /etc/nginx/nginx.conf
ADD conf/default.conf /etc/nginx/conf.d/default.conf
ADD scripts/ /extra
ADD monitor/ /extra/monitor
ADD errors/ /var/www/errors

WORKDIR /var/www/html

EXPOSE 80

STOPSIGNAL SIGTERM

CMD ["sh","/extra/start.sh"]