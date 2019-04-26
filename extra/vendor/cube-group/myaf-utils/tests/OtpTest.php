<?php

require __DIR__ . '/../vendor/autoload.php';

use Myaf\Utils\OtpUtil;

/**
 * Created by PhpStorm.
 * User: linyang
 * Date: 2018/5/29
 * Time: 下午7:50
 */
class OtpTest
{
    private static $secret = 'B4XU3OPQ2CW6KFHHBA35CHQJUJEUGO5I3RBHZMXLRM7ZA3LEUC4A';

    public static function getGoogleOtpAuthUrl()
    {
        var_dump(OtpUtil::getOtpAuthUrl(self::$secret, 'linyang'));
    }

    public static function now()
    {
        var_dump(OtpUtil::now(self::$secret));
    }

    public static function verify()
    {
        var_dump(OtpUtil::verify(self::$secret, '236938'));
    }
}

OtpTest::now();
OtpTest::verify();
//OtpTest::getGoogleOtpAuthUrl();