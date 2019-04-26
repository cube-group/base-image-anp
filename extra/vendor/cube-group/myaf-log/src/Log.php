<?php

namespace Myaf\Log;

use Exception;

/**
 * Class Log
 * @package Myaf\Log
 */
class Log
{
    /**
     * 日志唯一id.
     */
    const LOG_REQUEST_ID = 'requestUniqueId';

    /**
     * 是否为测试模式.
     * @var bool
     */
    private static $debug = false;

    /**
     * 本次http请求的唯一id.
     * @var string
     */
    private static $requestId = '';

    /**
     * 当前应用名称。
     * @var string
     */
    private static $app = '';

    /**
     * 日志存储目录.
     * @var string
     */
    private static $logPath = '';

    /**
     * 二维数组日志存储器.
     * @var array
     */
    private static $logs = array();

    /**
     * 开启将每次记录都写日志
     * @var bool
     */
    private static $autoFlush = false;

    /**
     * 初始化日志系统.
     *
     * @param $app string 当前应用名字
     * @param $logPath string 日志存储路径
     * @param $timeZone string 默认时区
     * @param $debug bool 是否为测试环境
     */
    public static function init($app, $logPath = '/data/log', $timeZone = 'Asia/Shanghai', $debug = false)
    {
        if (self::$app) {
            return;
        }
        self::$app = $app;
        self::$debug = $debug;
        self::$logPath = $logPath;
        self::$requestId = self::getGlobalRequestId();
        date_default_timezone_set($timeZone);
    }

    /**
     * 设置自动刷日志
     *
     * @param bool $flag
     */
    public static function setAutoFlush($flag = false)
    {
        self::$autoFlush = $flag;
    }


    /**
     * 获取全局唯一请求id.
     * 如果未设置则从$_GET、$_POST参数中区搜索.
     * 如果还未找到则直接创建.
     *
     * @return string
     */
    public static function getGlobalRequestId()
    {
        if (!self::$requestId) {
            try {
                if (isset($_GET[self::LOG_REQUEST_ID]) && $_GET[self::LOG_REQUEST_ID]) {
                    self::$requestId = $_GET[self::LOG_REQUEST_ID];
                } else if (isset($_POST[self::LOG_REQUEST_ID]) && $_POST[self::LOG_REQUEST_ID]) {
                    self::$requestId = $_POST[self::LOG_REQUEST_ID];
                } else {
                    self::$requestId = uniqid();
                }
            } catch (Exception $e) {
                self::$requestId = uniqid();
            }
        }
        return self::$requestId;
    }

    /**
     * debug日志
     *
     * @param string $route 路由
     * @param string $uid 用户类信息(例如: 相关用户id或用户名或手机号等)
     * @param string $code 业务错误码
     * @param string $msg 业务错误信息
     * @param string|array|number $ext 标准扩展字段
     * @throws Exception
     */
    public static function debug($route = '', $uid = '', $code = '', $msg = '', $ext = '')
    {
        self::append('DEBUG', $route, $uid, $code, $msg, $ext);
    }


    /**
     * 常规日志
     *
     * @param string $route 路由
     * @param string $uid 用户类信息(例如: 相关用户id或用户名或手机号等)
     * @param string $code 业务错误码
     * @param string $msg 业务错误信息
     * @param string|array|number $ext 标准扩展字段
     * @throws Exception
     */
    public static function info($route = '', $uid = '', $code = '', $msg = '', $ext = '')
    {
        self::append('INFO', $route, $uid, $code, $msg, $ext);
    }


    /**
     * 警告日志
     *
     * @param string $route 路由
     * @param string $uid 用户类信息(例如: 相关用户id或用户名或手机号等)
     * @param string $code 业务错误码
     * @param string $msg 业务错误信息
     * @param string|array|number $ext 标准扩展字段
     * @throws Exception
     */
    public static function warn($route = '', $uid = '', $code = '', $msg = '', $ext = '')
    {
        self::append('WARN', $route, $uid, $code, $msg, $ext);
    }

    /**
     * 挂掉日志
     *
     * @param string $route 路由
     * @param string $uid 用户类信息(例如: 相关用户id或用户名或手机号等)
     * @param string $code 业务错误码
     * @param string $msg 业务错误信息
     * @param string|array|number $ext 标准扩展字段
     * @throws Exception
     */
    public static function fatal($route = '', $uid = '', $code = '', $msg = '', $ext = '')
    {
        self::append('FATAL', $route, $uid, $code, $msg, $ext);
    }


    /**
     * 错误日志
     *
     * @param string $route 路由
     * @param string $uid 用户类信息(例如: 相关用户id或用户名或手机号等)
     * @param string $code 业务错误码
     * @param string $msg 业务错误信息
     * @param string|array|number $ext 标准扩展字段
     * @throws Exception
     */
    public static function error($route = '', $uid = '', $code = '', $msg = '', $ext = '')
    {
        self::append('ERROR', $route, $uid, $code, $msg, $ext);
    }


    /**
     * 将此次访问的的所有日志录入相关日志文件.
     * @return bool
     * @throws Exception
     */
    public static function flush()
    {
        if (empty(self::$logs)) {
            return true;
        }
        $logPath = self::$logPath;
        if (!realpath(self::$logPath)) {
            if (!mkdir($logPath, 0777, true)) {
                throw new Exception("can not mkdir {$logPath}");
            }
        }
        $logFileName = realpath($logPath) . DIRECTORY_SEPARATOR . date('Y-m-d') . '.txt';
        foreach (self::$logs as $item) {
            self::writeFile($logFileName, $item);
        }
        self::$logs = array();
        return true;
    }

    /**
     * 获取访问的用户IP
     * @return string
     */
    private static function requestIp()
    {
        if (getenv('HTTP_CLIENT_IP')) {
            $onlineIp = getenv('HTTP_CLIENT_IP');
        } else if (getenv('HTTP_X_FORWARDED_FOR')) {
            $onlineIp = getenv('HTTP_X_FORWARDED_FOR');
        } else if (getenv('REMOTE_ADDR')) {
            $onlineIp = getenv('REMOTE_ADDR');
        } else {
            $onlineIp = $_SERVER['REMOTE_ADDR'];
        }
        return $onlineIp;
    }

    /**
     * 将日志压入内存暂存器.
     *
     * @param $level string 日志等级
     * @param string $route 路由
     * @param string $uid 用户类信息(例如: 相关用户id或用户名或手机号等)
     * @param string $code 业务错误码
     * @param string $msg 业务错误信息
     * @param mixed $ext 标准扩展字段
     * @throws Exception
     */
    private static function append($level, $route = '', $uid = '', $code = '', $msg = '', $ext = '-')
    {
        if (!self::$requestId || !self::$logPath) {
            throw new Exception('log not initialized');
        }
        $logContent = array();
        $logContent[] = date('Y-m-d H:i:s');
        $logContent[] = self::requestIp();
        $logContent[] = $level;
        $logContent[] = self::$requestId;
        $logContent[] = self::$app;
        $logContent[] = getmypid();
        $logContent[] = $route;
        $logContent[] = $uid;
        $logContent[] = $code;
        $logContent[] = $msg;
        $logContent[] = $ext;
        $logString = self::getLogString($logContent);
        array_push(self::$logs, $logString);
        if (self::$autoFlush) {
            self::flush();
        }
    }

    /**
     * 写入日志文件
     *
     * @param string $logFile
     * @param string $content
     * @return true
     */
    private static function writeFile($logFile, $content)
    {
        $fp = fopen($logFile, 'a');
        if (flock($fp, LOCK_EX)) {
            fwrite($fp, $content . "\n");
            flock($fp, LOCK_UN);
        }
        fclose($fp);
        return true;
    }

    /**
     * 获取日志内容字符串
     *
     * @param $logContent
     * @return string
     */
    private static function getLogString($logContent)
    {
        foreach ($logContent as $k => $content) {
            if (!$content) {
                $content = '-';
            }
            if (is_array($content)) {
                $logContent[$k] = json_encode($content, JSON_UNESCAPED_UNICODE);
            }
        }
        $logString = implode('|', $logContent);
        return $logString;
    }
}
