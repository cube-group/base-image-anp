#!/bin/bash

#启动初始化shell
php /extra/monitor/init.php >> /cli.log &
#监控启动
php /extra/monitor/start.php >> /cli.log &

