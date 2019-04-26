<?php

namespace Myaf\Utils;

use OTPHP\TOTP;
use ParagonIE\ConstantTime\Base32;

/**
 * Class OtpUtil
 * @package Myaf\Utils
 */
class OtpUtil
{
    /**
     * 获取随机秘钥
     * @return string
     */
    public static function getRandomSecret()
    {
        return trim(Base32::encodeUpper(random_bytes(32)), '=');
    }

    /**
     * 根据秘钥返回当前30秒范围内的TIME BASED OTP'S
     *
     * @param $secret string
     * @return int
     */
    public static function now($secret)
    {
        $otp = new TOTP(null, $secret);
        return $otp->now();
    }

    /**
     * 根据秘钥判断6位验证码是否匹配.
     *
     * @param $secret string
     * @param $code int|string
     * @return bool
     */
    public static function verify($secret, $code)
    {
        $otp = new TOTP(null, $secret);
        return $otp->verify($code);
    }

    /**
     * 根据秘钥和名称生成标准google otp auth url.
     *
     * @param $secret string
     * @param $mail string
     * @return string
     */
    public static function getOtpAuthUrl($secret, $mail)
    {
        $otp = new TOTP($mail, $secret);
        return $otp->getProvisioningUri();
    }
}