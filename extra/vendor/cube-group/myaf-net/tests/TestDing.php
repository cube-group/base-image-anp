<?php

require __DIR__ . '/../src/LCurl.php';
require __DIR__ . '/../src/LDing.php';
require __DIR__ . '/../vendor/autoload.php';

/**
 * Created by PhpStorm.
 * User: linyang
 * Date: 2018/5/31
 * Time: 上午10:09
 */
class TestDing
{
    public static function send()
    {
        $ding = new \Myaf\Net\LDing('dingding');
        var_dump($ding->send('测试'));
    }
}

TestDing::send();