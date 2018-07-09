<?php

use Myaf\Net\LDing;

require __DIR__ . '/vendor/autoload.php';

/**
 * Created by PhpStorm.
 * User: linyang
 * Date: 2018/4/17
 * Time: 上午10:43
 * Class Monitor
 * 监控项1: php-fpm slowlog
 * 监控项2: php-fpm进程数
 */
class Monitor
{
    /**
     * 钉钉报警机器人url
     * @var string
     */
    private $ding = '';
    /**
     * app名称
     * @var string
     */
    private $appName = 'anp';
    /**
     * 监控的最大FPM进程数
     * @var int
     */
    private $maxChildren = 100;
    /**
     * 慢日志路径
     * @var string
     */
    private $slowlog = '';
    /**
     * 监控频率(单位:秒)
     * @var int
     */
    private $rate = 30;

    /**
     * Monitor constructor.
     */
    public function __construct()
    {
        if ($appName = getenv('APP_NAME')) {
            $this->appName = $appName;
        }
        if ($ding = getenv('APP_MONITOR_HOOK')) {
            $this->ding = $ding;
        }
        if ($slowlog = getenv('FPM_SLOWLOG')) {
            $this->slowlog = $slowlog;
        }

        if ($maxChildren = (int)getenv('FPM_MAX_CHILDREN')) {
            $this->maxChildren = $maxChildren;
        }
        if ($slowlogTimeout = (int)getenv('FPM_SLOWLOG_TIMEOUT')) {
            $this->slowlogTimeout = $slowlogTimeout;
        }
        $this->init();
    }

    private function init()
    {
        while (true) {
            if ($this->slowlog) {
                if ($log = system("cat {$this->slowlog} && : > {$this->slowlog}")) {
                    $this->sendDing($log);
                }
            }

            $fpmNum = (int)exec('ps axu | grep php-fpm | wc -l');
            if ($fpmNum > 0 && $fpmNum >= (int)($this->maxChildren * 0.9)) {
                $this->sendDing("php-fpm children not enough: {$fpmNum}/{$this->maxChildren}");
            }

            sleep($this->rate);
        }
    }

    /**
     * 获取外网IP-内网IP
     * @return mixed
     */
    private function serverIp()
    {
        return gethostbyname(exec('hostname'));
    }

    private function sendDing($msg)
    {
        if ($this->ding) {
            $d = new LDing($this->ding);
            $d->send("[MONITOR-ANP]\n[APP_NAME] {$this->appName}\n[NODE_IP] {$this->serverIp()}\n{$msg}\n");
        }
    }
}

new Monitor();