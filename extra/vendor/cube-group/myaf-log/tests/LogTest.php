<?php

use Myaf\Log\Log;
use PHPUnit\Framework\TestCase;

class TestLog extends TestCase
{
    public function testCommon()
    {
        //初始化日志
        Log::init('l.eoffcn.com', __DIR__);
        //debug日志
        Log::debug("index/index", "18888888888", 9999, '{"status":"Y"}');
        //info日志
        Log::info("index/hello", "18888888888", 2002, 'hello日志内容');
        //警告日志
        Log::warn("index/hello", "18888888888", 2002, 'hello日志内容');
        //错误日志
        Log::error("index/world", "18888888888", 1001, 'world日志内容', '其他信息');
        //挂掉日志
        Log::fatal("index/world", "18888888888", 1003, 'fatal日志内容', '其他信息');
        //日志压栈存储
        Log::flush();
    }

    /**
     * 设置每次都刷日志
     */
    public function testAutoFlush()
    {
        //初始化日志
        Log::init('l.eoffcn.com', __DIR__);
        //设置每次都刷日志
        Log::setAutoFlush(true);
        Log::debug("index/hello", "18888888888", 1001, 'world', '其他信息');
        Log::debug("index/hello", "18888888888", 1001, 'world', '其他信息');
        Log::error("index/hello", "18888888888", 1001, 'world', '其他信息');
    }
}

$test = new TestLog();
$test->testCommon();
$test->testAutoFlush();
