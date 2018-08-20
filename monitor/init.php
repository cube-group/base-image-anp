<?php
/**
 * Created by PhpStorm.
 * User: linyang
 * Date: 2018/7/2
 * Time: 上午9:16
 */

use Myaf\Net\LDing;

require __DIR__ . '/vendor/autoload.php';

/**
 * 初始化
 * Class InitMonitor
 */
class InitMonitor
{
    private $appName = 'anp';
    private $ding = '';

    /**
     * InitMonitor constructor.
     */
    public function __construct()
    {
        error_reporting('E_ALL & ~E_NOTICE');

        echo __CLASS__ . "\n";

        if ($appName = getenv('APP_NAME')) {
            $this->appName = $appName;
        }
        echo "[INIT] appName: {$this->appName}\n";

        //ding talk hook url
        if ($ding = getenv('APP_MONITOR_HOOK')) {
            $this->ding = $ding;
        }
        echo "[INIT] ding: {$this->ding}\n";

        //app init shell
        if (!$appInitShell = getenv('APP_INIT_SHELL')) {
            exit("[INIT] no env APP_INIT_SHELL\n");
        }
        echo "[INIT] APP_INIT_SHELL: {$appInitShell}\n";

        //exec
        exec("{$appInitShell} >> /init-shell.out 2>> /init-shell.err");
        $out = system("cat /init-shell.out && true > /init-shell.out");
        $err = system("cat /init-shell.err && true > /init-shell.err");
        $this->sendDing("[INIT-SHELL]\n{$appInitShell}\n[OUT]\n{$out}\n[ERR]\n{$err}");
    }

    /**
     * 获取外网IP-内网IP
     * @return mixed
     */
    private function serverIp()
    {
//        return $_SERVER['REMOTE_ADDR'] . '-' . gethostbyname(exec('hostname'));
        return gethostbyname(exec('hostname'));
    }

    private function sendDing($msg)
    {
        if ($this->ding) {
            $d = new LDing($this->ding);
            $d->send("[INIT-ANP]\n[APP_NAME] {$this->appName}\n[NODE_IP] {$this->serverIp()}\n{$msg}\n");
        }
    }
}

new InitMonitor();