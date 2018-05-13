FROM php:7.2.4-fpm-alpine3.7
#alpine3.7
#php7.2

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

ENV FPM_MAX_CHILDREN 50
ENV FPM_SLOWLOG /var/log/fpm-slow.log
ENV FPM_SLOWLOG_TIMEOUT 2

#以下不要覆盖
ENV php_conf /usr/local/etc/php-fpm.conf
ENV fpm_conf /usr/local/etc/php-fpm.d/www.conf
ENV php_vars /usr/local/etc/php/conf.d/docker-vars.ini

# 备份原始文件
# 修改为国内镜像源
RUN cp /etc/apk/repositories /etc/apk/repositories.bak && \
    echo "http://mirrors.aliyun.com/alpine/v3.7/main/" > /etc/apk/repositories && \
    apk update

#install nginx
ENV NGINX_VERSION 1.13.12
RUN GPG_KEYS=B0F4253373F8F6F510D42178520A9993A1C052F8 \
	&& CONFIG="\
		--prefix=/etc/nginx \
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
		--with-http_perl_module=dynamic \
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
	" \
	&& addgroup -S nginx \
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
		perl-dev \
	&& curl -fSL https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -o nginx.tar.gz \
	&& curl -fSL https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz.asc  -o nginx.tar.gz.asc \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& found=''; \
	for server in \
		ha.pool.sks-keyservers.net \
		hkp://keyserver.ubuntu.com:80 \
		hkp://p80.pool.sks-keyservers.net:80 \
		pgp.mit.edu \
	; do \
		echo "Fetching GPG key $GPG_KEYS from $server"; \
		gpg --keyserver "$server" --keyserver-options timeout=10 --recv-keys "$GPG_KEYS" && found=yes && break; \
	done; \
	test -z "$found" && echo >&2 "error: failed to fetch GPG key $GPG_KEYS" && exit 1; \
	gpg --batch --verify nginx.tar.gz.asc nginx.tar.gz \
	&& rm -rf "$GNUPGHOME" nginx.tar.gz.asc \
	&& mkdir -p /usr/src \
	&& tar -zxC /usr/src -f nginx.tar.gz \
	&& rm nginx.tar.gz \
	&& cd /usr/src/nginx-$NGINX_VERSION \
	&& ./configure $CONFIG --with-debug \
	&& make -j$(getconf _NPROCESSORS_ONLN) \
	&& mv objs/nginx objs/nginx-debug \
	&& mv objs/ngx_http_xslt_filter_module.so objs/ngx_http_xslt_filter_module-debug.so \
	&& mv objs/ngx_http_image_filter_module.so objs/ngx_http_image_filter_module-debug.so \
	&& mv objs/ngx_http_geoip_module.so objs/ngx_http_geoip_module-debug.so \
	&& mv objs/ngx_http_perl_module.so objs/ngx_http_perl_module-debug.so \
	&& mv objs/ngx_stream_geoip_module.so objs/ngx_stream_geoip_module-debug.so \
	&& ./configure $CONFIG \
	&& make -j$(getconf _NPROCESSORS_ONLN) \
	&& make install \
	&& rm -rf /etc/nginx/html/ \
	&& mkdir /etc/nginx/conf.d/ \
	&& mkdir -p /usr/share/nginx/html/ \
	&& install -m644 html/index.html /usr/share/nginx/html/ \
	&& install -m644 html/50x.html /usr/share/nginx/html/ \
	&& install -m755 objs/nginx-debug /usr/sbin/nginx-debug \
	&& install -m755 objs/ngx_http_xslt_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_xslt_filter_module-debug.so \
	&& install -m755 objs/ngx_http_image_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_image_filter_module-debug.so \
	&& install -m755 objs/ngx_http_geoip_module-debug.so /usr/lib/nginx/modules/ngx_http_geoip_module-debug.so \
	&& install -m755 objs/ngx_http_perl_module-debug.so /usr/lib/nginx/modules/ngx_http_perl_module-debug.so \
	&& install -m755 objs/ngx_stream_geoip_module-debug.so /usr/lib/nginx/modules/ngx_stream_geoip_module-debug.so \
	&& ln -s ../../usr/lib/nginx/modules /etc/nginx/modules \
	&& strip /usr/sbin/nginx* \
	&& strip /usr/lib/nginx/modules/*.so \
	&& rm -rf /usr/src/nginx-$NGINX_VERSION \
	\
	# Bring in gettext so we can get `envsubst`, then throw
	# the rest away. To do this, we need to install `gettext`
	# then move `envsubst` out of the way so `gettext` can
	# be deleted completely, then move `envsubst` back.
	&& apk add --no-cache --virtual .gettext gettext \
	&& mv /usr/bin/envsubst /tmp/ \
	\
	&& runDeps="$( \
		scanelf --needed --nobanner /usr/sbin/nginx /usr/lib/nginx/modules/*.so /tmp/envsubst \
			| awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
			| sort -u \
			| xargs -r apk info --installed \
			| sort -u \
	)" \
	&& apk add --no-cache --virtual .nginx-rundeps $runDeps \
	&& apk del .build-deps \
	&& apk del .gettext \
	&& mv /tmp/envsubst /usr/local/bin/ \
	\
	# Bring in tzdata so users could set the timezones through the environment
	# variables
	&& apk add --no-cache tzdata \
	\
	# forward request and error logs to docker log collector
	&& ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log


#install php
RUN apk add --no-cache \
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
    echo 'zend_extension=xdebug.so' >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
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
    echo "memory_limit = ${PHP_MEM_LIMIT}"  >> ${php_vars}

RUN sed -i "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" ${fpm_conf} && \
    sed -i "s/pm.max_children = 5/pm.max_children = ${FPM_MAX_CHILDREN}/g" ${fpm_conf} && \
    sed -i "s/pm.start_servers = 2/pm.start_servers = 5/g" ${fpm_conf} && \
    sed -i "s/pm.min_spare_servers = 1/pm.min_spare_servers = 4/g" ${fpm_conf} && \
    sed -i "s/pm.max_spare_servers = 3/pm.max_spare_servers = 6/g" ${fpm_conf} && \
    sed -i "s/;pm.max_requests = 500/pm.max_requests = 200/g" ${fpm_conf} && \
    sed -i "s/;request_slowlog_timeout = 0/request_slowlog_timeout = ${FPM_SLOWLOG_TIMEOUT}/g" ${fpm_conf} && \
    sed -i "s/user = www-data/user = nginx/g" ${fpm_conf} && \
    sed -i "s/group = www-data/group = nginx/g" ${fpm_conf} && \
    sed -i "s/;listen.mode = 0660/listen.mode = 0666/g" ${fpm_conf} && \
    sed -i "s/;listen.owner = www-data/listen.owner = nginx/g" ${fpm_conf} && \
    sed -i "s/;listen.group = www-data/listen.group = nginx/g" ${fpm_conf} && \
    sed -i "s/listen = 127.0.0.1:9000/listen = \/var\/run\/php-fpm.sock/g" ${fpm_conf} && \
    touch ${FPM_SLOWLOG} && \
    echo "slowlog = ${FPM_SLOWLOG}" >> ${fpm_conf}

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

ADD conf/nginx.conf /etc/nginx/nginx.conf
ADD conf/default.conf /etc/nginx/conf.d/default.conf
ADD scripts/ /extra
ADD monitor/ /extra/monitor

WORKDIR $APP_PATH

EXPOSE 80

STOPSIGNAL SIGTERM

CMD ["sh","/extra/start.sh"]