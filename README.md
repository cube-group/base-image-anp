## anp
[![996.icu](https://img.shields.io/badge/link-996.icu-red.svg)](https://996.icu)

这是一个docker镜像,它主要用于php web服务
### 几个重要指标
* 在当前的容器编排工具中,单容器资源将限制内存为4G-5G之间
* os: alpine linux 3.8
* nginx: 1.14.0
* php: php-7.2.8(fpm)
* opcache: on
* http2: on
* fpm-default-max-chilren: 200
* 注意: ```打日志、报钉钉、把PHP错误输出打印出来吧:)```

### 核心环境变量支持
* APP_NAME: app名称(一般情况下无需配置)
* APP_PATH: 项目所在目录(一定要记住默认为:/var/www/html)
* APP_PATH_INDEX: PHP项目index.php入口文件所在目录(默认为:/var/www/html)
* APP_PATH_404: PHP项目404.html文件所在目录(默认为:/var/www/html)
* APP_INIT_SHELL: 以后台方式执行当前容器初始化脚本,如:```php $APP_PATH/init.sh```
* APP_MONITOR_HOOK: app报警钉钉群机器人webhook url

### 辅助类环境变量
* NGINX_PHP_CONF: tp为thinkphp fastcgi配置、orc为orc fastcgi配置(注意:默认的配置支持laravel和yaf框架)
* NGINX_LOCATION: 特殊nginx location配置,如:rewrite、try_files或其它,如下Dockerfile中可以写为
```
ENV NGINX_LOCATION "location /web {try_files /web$uri $uri/ /index.php?$args;}"
```
* PHP_MEM_LIMIT: php进程内存限制,默认512M
* PHP_POST_MAX_SIZE: php post最大字节 默认100M
* PHP_UPLOAD_MAX_FILESIZE: php最大文件上传限制 默认100M
* FPM_MAX_CHILDREN: php-fpm最大子进程数量(默认:100)
* FPM_SLOWLOG_TIMEOUT: php-fpm慢日志超时时间(单位:秒)

### Nginx
```
nginx version: nginx/1.14.0
built with LibreSSL 2.7.2 (running with LibreSSL 2.7.4)
TLS SNI support enabled
configure arguments: --prefix=/var/lib/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules --conf-path=/etc/nginx/nginx.conf --pid-path=/run/nginx/nginx.pid --lock-path=/run/nginx/nginx.lock --http-client-body-temp-path=/var/tmp/nginx/client_body --http-proxy-temp-path=/var/tmp/nginx/proxy --http-fastcgi-temp-path=/var/tmp/nginx/fastcgi --http-uwsgi-temp-path=/var/tmp/nginx/uwsgi --http-scgi-temp-path=/var/tmp/nginx/scgi --with-perl_modules_path=/usr/lib/perl5/vendor_perl --user=nginx --group=nginx --with-threads --with-file-aio --with-http_ssl_module --with-http_v2_module --with-http_realip_module --with-http_addition_module --with-http_xslt_module=dynamic --with-http_image_filter_module=dynamic --with-http_geoip_module=dynamic --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_auth_request_module --with-http_random_index_module --with-http_secure_link_module --with-http_degradation_module --with-http_slice_module --with-http_stub_status_module --with-http_perl_module=dynamic --with-mail=dynamic --with-mail_ssl_module --with-stream=dynamic --with-stream_ssl_module --with-stream_realip_module --with-stream_geoip_module=dynamic --with-stream_ssl_preread_module --add-dynamic-module=/home/buildozer/aports/main/nginx/src/njs-0.2.0/nginx --add-dynamic-module=/home/buildozer/aports/main/nginx/src/ngx_devel_kit-0.3.0 --add-dynamic-module=/home/buildozer/aports/main/nginx/src/ngx_cache_purge-2.4.2 --add-dynamic-module=/home/buildozer/aports/main/nginx/src/echo-nginx-module-0.61 --add-dynamic-module=/home/buildozer/aports/main/nginx/src/ngx-fancyindex-0.4.2 --add-dynamic-module=/home/buildozer/aports/main/nginx/src/headers-more-nginx-module-0.33 --add-dynamic-module=/home/buildozer/aports/main/nginx/src/lua-nginx-module-0.10.12 --add-dynamic-module=/home/buildozer/aports/main/nginx/src/lua-upstream-nginx-module-0.07 --add-dynamic-module=/home/buildozer/aports/main/nginx/src/nchan-1.1.14 --add-dynamic-module=/home/buildozer/aports/main/nginx/src/nginx-http-shibboleth-2.0.1 --add-dynamic-module=/home/buildozer/aports/main/nginx/src/redis2-nginx-module-0.15 --add-dynamic-module=/home/buildozer/aports/main/nginx/src/set-misc-nginx-module-0.32 --add-dynamic-module=/home/buildozer/aports/main/nginx/src/nginx-upload-progress-module-0.9.2 --add-dynamic-module=/home/buildozer/aports/main/nginx/src/nginx-upstream-fair-0.1.3 --add-dynamic-module=/home/buildozer/aports/main/nginx/src/nginx-rtmp-module-1.2.1 --add-dynamic-module=/home/buildozer/aports/main/nginx/src/nginx-vod-module-1.22
```

### PHP Version
```
PHP 7.2.8 (cli) (built: Jul 28 2018 17:55:09) ( NTS )
Copyright (c) 1997-2018 The PHP Group
Zend Engine v3.2.0, Copyright (c) 1998-2018 Zend Technologies
    with Zend OPcache v7.2.8, Copyright (c) 1999-2018, by Zend Technologies
```

### PHP Extensions
```
[PHP Modules]
amqp
apcu
bcmath
Core
ctype
curl
date
dom
exif
fileinfo
filter
ftp
gd
gmp
hash
iconv
intl
json
libxml
mbstring
memcached
mongodb
mysqlnd
openssl
pcre
PDO
pdo_mysql
pdo_pgsql
Phar
posix
readline
redis
Reflection
session
SimpleXML
soap
sodium
SPL
standard
tokenizer
xml
xmlreader
xmlwriter
xsl
yaf
Zend OPcache
zip
zlib

[Zend Modules]
Zend OPcache
```
