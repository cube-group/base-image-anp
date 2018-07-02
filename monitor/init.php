<?php
/**
 * Created by PhpStorm.
 * User: linyang
 * Date: 2018/7/2
 * Time: 上午9:16
 */

use Myaf\Net\LDing;
use Myaf\Utils\Arrays;
use Myaf\Utils\FileUtil;

require __DIR__ . '/vendor/autoload.php';

/**
 * 初始化
 * Class InitMonitor
 */
class InitMonitor
{
    private $appName = 'apc';
    private $ding = 'https://oapi.dingtalk.com/robot/send?access_token=86a6a6c2f0fde8811412b39739bed47155e88982ac6ddc203ddc43e9cb920287';

    public function __construct()
    {
        error_reporting('E_ALL & ~E_NOTICE');

        if ($appName = getenv('APP_NAME')) {
            $this->appName = $appName;
        }
        echo "[INIT] appName: {$this->appName}\n";

        //ding talk hook url
        if ($ding = getenv('APP_MONITOR_HOOK')) {
            $this->ding = $ding;
        }
        echo "[INIT] ding: {$this->ding}\n";

        if (!$appInitShell = getenv('APP_INIT_SHELL')) {
            echo "can't find env APP_INIT_SHELL\n";
            exit();
        }
        echo "APP_INIT_SHELL {$appInitShell}\n";

        system("{$appInitShell} >> /cli-init-shell.log 2>&1");
        if ($content = system("cat /cli-init-shell.log")) {
            $this->sendDing("[INIT-SHELL] {$appInitShell}\n{$content}\n");
        }
    }

    /**
     * 获取外网IP-内网IP
     * @return mixed
     */
    private function serverIp()
    {
        return $_SERVER['REMOTE_ADDR'] . '-' . gethostbyname(exec('hostname'));
    }

    private function sendDing($msg)
    {
        if ($this->ding) {
            $d = new LDing($this->ding);
            $d->send("[{$this->appName}][{$this->serverIp()}] {$msg}");
        } else {
            echo "can't find env APP_MONITOR_HOOK, can't send ding.\n";
        }
    }
}

new CronTabMonitor();