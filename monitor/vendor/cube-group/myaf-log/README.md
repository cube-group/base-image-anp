## LOG
[![Latest Stable Version](https://poser.pugx.org/cube-group/myaf-log/version)](https://packagist.org/packages/cube-group/myaf-log)
[![Total Downloads](https://poser.pugx.org/cube-group/myaf-log/downloads)](https://packagist.org/packages/cube-group/myaf-log)
[![License](https://poser.pugx.org/cube-group/myaf-log/license)](https://packagist.org/packages/cube-group/myaf-log)
### namespace
```
"Myaf\\Log\\": "src/"
```
### 1.日志目录

```shell
/data/log/20180528.log
```

### 2.日志结构

```shell
分隔符使用竖线 |
$date|$ip|$level|$ruid|$domain|$pid|$route|$uid|$code|$msg|$ext
```

* $date: 日期(例如: 2018-05-10 20:00)
* $ip: 用户请求的ip地址
* $level: 日志级别(INFO ERROR DEBUG WARN)
* $ruid: 请求链唯一id(request unique id,例如: md5)
* $domain: 域(例如: l.eoffcn.com)
* $pid: 进程id或线程id或协程id
* $route: web路由(例如: /user/login 或 user/login)
* $uid: 用户类信息(例如: 相关用户id或用户名或手机号等)
* $code: 业务错误码(例如: 0或10000等)
* $msg: 业务错误信息(例如: ERR_USER_LOGIN)
* $ext: 扩展字段
* 业务标准日志Demo:

```shell
2018-05-08 20:00|192.168.0.10|ERROR|1q2w3e4r522|l.eoffcn.com|7732|/user/login|1590214776|9800|ERR_SOMETHING|xxx
```

### 3.日期级别
* DEBUG 用过调试，级别最低，可以随意的使用于任何觉得有利于在调试时更详细的了解系统运行状态的东东；
* INFO 用于打印程序应该出现的正常状态信息， 便于追踪定位；
* WARN 表明系统出现轻微的不合理但不影响运行和使用；
* ERROR 表明出现了系统错误和异常，无法正常完成目标操作。
* FATAL 相当严重，可以肯定这种错误已经无法修复，并且如果系统继续运行下去的话后果严重


### 4.日志工具包
SDK地址 https://github.com/cube-group/myaf-log

### 5.安装
* composer安装 
```shell
#使用国内镜像
composer config -g repo.packagist composer https://packagist.phpcomposer.com
#安装
composer require cube-group/myaf-log
```

* 直接下载安装，SDK 没有依赖其他第三方库，但需要参照 composer的autoloader，增加一个自己的autoloader程序。
* composer.json的使用
```json
{require:{cube-group/myaf-log: "*"}}
```

### 6.工具使用
```
//初始化日志
Log::init('l.eoffcn.com', '/data/log');
//支持debug、info、warn、error、fatal类日志
Log::info("路由地址", "跟用户相关的数据", "业务线错误码", "错误码对应的错误信息");
//info日志
Log::info("/user/login", "$uid/$phone/$otherAboutUser", $code, $msg);
//demo,日志打印函数可支持无限个$ext ...
Log::info("/user/login", "24325", 9999, "ERR_USER_LOGIN", "啊哈哈", [1,2,3], ['key' => 'what you want"]);
//日志压栈存储
Log::flush();
```


