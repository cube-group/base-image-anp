<?php

namespace Myaf\Utils;

/**
 * AES加密解密封装类
 *
 * @author NewFuture
 */
class CryptUtil
{
    const MOD = 'AES-128-CBC';

    const KEY = '201707eggplant99';

    const IV = '1234567890123412';

    /**
     * 加密
     * @param $data string
     * @param string $key
     * @param string $iv
     * @return string
     */
    public static function encrypt($data, $key = self::KEY, $iv = self::IV)
    {
        return base64_encode(openssl_encrypt($data, self::MOD, $key, OPENSSL_RAW_DATA, $iv));
    }

    /**
     * 解密
     * @param $data
     * @param string $key
     * @param string $iv
     * @return string
     */
    public static function decrypt($data, $key = self::KEY, $iv = self::IV)
    {
        return openssl_decrypt(base64_decode($data), self::MOD, $key, OPENSSL_RAW_DATA, $iv);
    }
}