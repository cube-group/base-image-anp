# util工具类集合
[![Latest Stable Version](https://poser.pugx.org/cube-group/myaf-utils/version)](https://packagist.org/packages/cube-group/myaf-utils)
[![Total Downloads](https://poser.pugx.org/cube-group/myaf-utils/downloads)](https://packagist.org/packages/cube-group/myaf-utils)
[![License](https://poser.pugx.org/cube-group/myaf-utils/license)](https://packagist.org/packages/cube-group/myaf-utils)

提供数组、字符串、地址解析等功能

## namespace
```
"Myaf\\Utils\\": "src/"
```

## 工具类

|类|功能|
|---|---|
|Arrays|提供数组常用操作|
|Strings|提供字符串常用操作|
|URLUtil|URL地址处理工具类|


## Arrays
* get($array, $key, $default = null) - 根据给定的key获取数组中的值，如果key的值不存在，将返回default定义的默认值
* sGet($array, $key, $default = null) - 根据给定的key获取数组中的值，如果key的值为空，将返回default定义的默认值
* lists($array, $key) - 根据key重建数组索引
* merge($a, $b) - 递归合并两个或多个数组
* keyToCamel($array) - 递归将数组的键转为驼峰
* keyToCase($array) - 递归将数组的键转为小写下划线
* removeKeys($array, $removeKeys) - 递归移除数组指定的key


## Strings
* case2camel($string) - 小写下划线字符串转换为驼峰
* camel2case($string) 驼峰字符串转为小写下划线
* random($length = 16) 创建随机数
* uuid() - 生成维一id
* parseMultiValue($value, $func = '') - 折分字符串为多个值,支持中文逗号/英文逗号/空格
* isAssoc() - 判断是否是关联数组
* isMultidim() - 判断是否是多给数组

## URLUtil
* toHttps() - 将url地址http改为https
* addParameter($url, $params) - 给URL地址追加get参数
* getParameters($url) - 根据URL地址获取query string




## 单元测试
* 1.安装单元测试依赖代码
```
composer require phpunit/phpunit
```
* 2.执行单元测试(代码位于tests文件夹)
```
phpunit
```
