<?php
/**
 * Created by PhpStorm.
 * User: linyang
 * Date: 2018/5/31
 * Time: 上午10:05
 */

namespace Myaf\Net;

use Myaf\Utils\Arrays;

/**
 * 钉钉报警机器人
 * Class LDing
 * @package Myaf\Net
 */
class LDing
{
    /**
     * @var string
     */
    private $url = '';

    /**
     * LDing constructor.
     * @param $url string dingding webhook
     */
    public function __construct($url)
    {
        $this->url = $url;
    }

    /**
     * 发送钉钉消息
     * @param $msg string
     * @return bool
     */
    public function send($msg)
    {
        if (!$this->url) {
            return false;
        }
        $data = ["msgtype" => "text", "text" => ["content" => $msg], "at" => ["isAtAll" => true]];
        $curl = new LCurl(LCurl::POST_JSON, 3);
        $result = $curl->post(
            $this->url,
            $data
        );
        if (!$result || (int)Arrays::get($result, 'errcode') != 0) {
            return false;
        }
        return true;
    }
}