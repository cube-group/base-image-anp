<?php

namespace Myaf\Utils;

use Swift_Attachment;
use Swift_Mailer;
use Swift_Message;
use Swift_SmtpTransport;

/**
 * Class MailUtil
 * @package Myaf\Utils
 */
class MailUtil
{
    /**
     * @var Swift_SmtpTransport
     */
    private $mail;
    /**
     * config.
     * @var array
     */
    private $options;
    /**
     * Mail constructor.
     * ['host'=>'stmp host','username'=>'sender mail','password'=>'*','port'=>20,'encryption'=>'ssl','debug'=>0,'timeout'=>5]
     * @param $options
     */
    public function __construct($options)
    {
        $this->options = $options;
        // Create the Transport
        $this->mail = (new Swift_SmtpTransport($options['host'], $options['port']))
            ->setUsername($options['username'])
            ->setPassword($options['password'])
            ->setEncryption(Arrays::get($options, 'encryption', 'tls'))
            ->setTimeout(Arrays::get($options, 'timeout', 5));
    }
    /**
     * 发送邮件.
     * @param $subject string
     * @param $html string
     * @param $from string
     * @param $receivers array
     * @param null $attaches
     * @return mixed
     */
    public function send($subject, $html, $from, $receivers, $attaches = null)
    {
        // Create the Mailer using your created Transport
        $mailer = new Swift_Mailer($this->mail);
        // Create a message
        $message = (new Swift_Message($subject))
            ->setFrom([$this->options['username'] => $from])
            ->setTo($receivers);
        $message->charsetChanged('utf-8');
        $message->setBody($html, Arrays::get($this->options, 'contentType', 'text/html'));
        //attach
        if($attaches && is_array($attaches)){
            foreach ($attaches as $attachItem) {
                $message->attach(Swift_Attachment::fromPath(
                    Arrays::get($attachItem, 'filename'), Arrays::get($attachItem, 'contentType'))->setFilename(Arrays::get($attachItem, 'name')));//附件图片
            }
        }
        // Send the message
        $result = $mailer->send($message);
        // TCP port to connect to
        return $result;
    }
}