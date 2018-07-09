<?php

namespace Myaf\Utils;

use Exception;
use Gregwar\Captcha\CaptchaBuilder;
use Gregwar\Image\Image;
use Myaf\Utils\ColorMatrix;
use Myaf\Utils\ContentType;
use BaconQrCode\Renderer\Image\Png;
use BaconQrCode\Writer;

/**
 * Class ImageUtil
 * @package Myaf\Image
 */
class ImageUtil
{
    /**
     * 图片验证码的默认背景RGB值.
     * @var array
     */
    private static $backgroundColor = [255, 255, 255];
    /**
     * 图片验证码的默认字体颜色RGB值.
     * @var array
     */
    private static $textColor = [0, 0, 0];
    /**
     * 本地验证码字体文件地址.
     * @var string
     */
    private static $captchaFont = '';

    /**
     * 设置图片验证码的字体.
     * @param $file
     * @return bool
     */
    public static function setCaptchaFont($file)
    {
        if (is_file($file)) {
            self::$captchaFont = $file;
            return true;
        }
        return false;
    }

    /**
     * 设置图片验证码的背景颜色.
     * @param string $value
     */
    public static function setCaptchaBackground($value = '#ffffff')
    {
        $arr = ColorMatrix::hex2Rgb($value);
        if ($arr) {
            self::$backgroundColor = $arr;
        }
    }

    /**
     * 设置图片验证码的字体颜色
     * @param string $value
     */
    public static function setCaptchaTextColor($value = '#ffffff')
    {
        $arr = null;
        if (!is_array($value)) {
            $arr = ColorMatrix::hex2Rgb($value);
        }
        if ($arr) {
            self::$textColor = $arr;
        }
    }

    /**
     * jpeg元数据.
     * @param $value
     * @param int $width
     * @param int $height
     * @param int $quality
     * @return string
     */
    public static function getCaptchaData($value, $width = 200, $height = 100, $quality = 100)
    {
        $builder = new CaptchaBuilder($value);
//        $builder->setTextColor(self::$textColor[0], self::$textColor[1], self::$textColor[2]);
//        $builder->setBackgroundColor(self::$backgroundColor[0], self::$backgroundColor[1], self::$backgroundColor[2]);
        $builder->build($width, $height, self::$captchaFont ? self::$captchaFont : null);
        return $builder->get($quality);
    }


    /**
     * 直接给浏览器返回该图片.
     * @param $value
     * @param int $width
     * @param int $height
     * @param int $quality
     */
    public static function downloadCaptcha($value, $width = 200, $height = 100, $quality = 100)
    {
        $builder = new CaptchaBuilder($value);
        $builder->setTextColor(self::$textColor[0], self::$textColor[1], self::$textColor[2]);
        $builder->setBackgroundColor(self::$backgroundColor[0], self::$backgroundColor[1], self::$backgroundColor[2]);
        $builder->build($width, $height, self::$captchaFont ? self::$captchaFont : null);

        header('Content-type: image/jpeg');
        $builder->output($quality);
    }


    /**
     * 保存成为验证码本地图片文件.
     * @param $value
     * @param $localFile
     * @param int $width
     * @param int $height
     * @param int $quality
     * @return bool
     */
    public static function saveCaptcha($value, $localFile, $width = 200, $height = 100, $quality = 100)
    {
        $builder = new CaptchaBuilder($value);
        $builder->setTextColor(self::$textColor[0], self::$textColor[1], self::$textColor[2]);
        $builder->setBackgroundColor(self::$backgroundColor[0], self::$backgroundColor[1], self::$backgroundColor[2]);
        $builder->build($width, $height, self::$captchaFont ? self::$captchaFont : null);
        return $builder->save($localFile, $quality);
    }


    /**
     * 获取图片创建实例.
     * @param int $width
     * @param int $height
     * @return static
     */
    public static function createImage($width = 320, $height = 240)
    {
        return Image::create($width, $height);
    }

    /**
     * 获取图片操作实例.
     * @param $fileName
     * @return static
     */
    public static function readImage($fileName)
    {
        return Image::open($fileName);
    }

    /**
     * 改变图片尺寸.
     * @param $file
     * @param $width
     * @param $height
     * @param string $desFile
     * @return bool
     */
    public static function resizeImage($file, $width, $height, $desFile = '')
    {
        try {
            if (is_file($file)) {
                if (!$desFile) {
                    $desFile = $file;
                }
                Image::open($file)->resize($width, $height)->save($desFile);
                return true;
            }
        } catch (Exception $e) {
        }
        return false;
    }

    /**
     * 图片转动生成新的图片.
     * @param $file
     * @param $rotate
     * @param string $desFile
     * @param int $backgroundColor
     * @return bool
     */
    public static function rotateImage($file, $rotate, $desFile = '', $backgroundColor = 0xFFFFFF)
    {
        try {
            if (is_file($file)) {
                if (!$desFile) {
                    $desFile = $file;
                }
                Image::open($file)->rotate($rotate, $backgroundColor)->save($desFile);
                return true;
            }
        } catch (Exception $e) {
        }
        return false;
    }

    /**
     * 给原图片添加水印并替换原图片.
     * @param $file
     * @param $waterFile
     * @param $desFile
     * @param int $x
     * @param int $y
     * @param int $width
     * @param int $height
     * @return bool
     */
    public static function waterMarkImage($file, $waterFile, $desFile = false, $x = 10, $y = 10, $width = 200, $height = 100)
    {
        try {
            if (is_file($file) && is_file($waterFile)) {
                $ext = pathinfo($file)['extension'];
                $saveFile = $desFile ? $desFile : sys_get_temp_dir() . '/' . uniqid() . '.' . $ext;
                Image::open($file)->merge(Image::open($waterFile), $x, $y, $width, $height)->save($saveFile);

                if (!$desFile && is_file($saveFile)) {
                    $contentType = ContentType::getFileContentType($saveFile);
                    header('Content-type: ' . $contentType);
                    readfile($saveFile);
                }
                return true;
            }
        } catch (Exception $e) {
        }
        return false;
    }


    /**
     * 图片转换为jpeg格式.
     * @param $file
     * @param int $quality
     * @return bool|mixed|string
     */
    public static function image2Jpeg($file, $quality = 80)
    {
        try {
            if (is_file($file)) {
                return Image::open($file)->setCacheDir(dirname($file))->jpeg($quality);
            }
        } catch (Exception $e) {
        }
        return false;
    }

    /**
     * 图片转换为png格式.
     * @param $file
     * @return bool|mixed|string
     */
    public static function image2Png($file)
    {
        try {
            if (is_file($file)) {
                return Image::open($file)->setCacheDir(dirname($file))->png();
            }
        } catch (Exception $e) {
        }
        return false;
    }


    /**
     * 图片转换为gif格式.
     * @param $file
     * @return bool|mixed|string
     */
    public static function image2Gif($file)
    {
        try {
            if (is_file($file)) {
                return Image::open($file)->setCacheDir(dirname($file))->gif();
            }
        } catch (Exception $e) {
        }
        return false;
    }

    /**
     * 生成png二维码.
     * @param $text string 文字内容
     * @param $filename string 文件名称
     * @param $width int
     * @param $height int
     * @param $margin int
     * @return mixed
     */
    public static function qrcodePng($text, $filename = '', $width = 256, $height = 256, $margin = 1)
    {
        $sourceFile = $filename ? $filename : (sys_get_temp_dir() . '/' . uniqid() . '.png');
        $renderer = new Png();
        $renderer->setHeight($width);
        $renderer->setWidth($height);
        $renderer->setMargin($margin);
        $writer = new Writer($renderer);
        try {
            $writer->writeFile($text, $sourceFile);
        } catch (Exception $e) {
            echo "";
            return false;
        }

        if ($filename) {
            return $filename;
        }

        @header('Content-Type: image/png');
        @readfile($sourceFile);
        @unlink($sourceFile);
        return true;
    }


    /**
     * 生成带有水印的二维码
     * @param $text string
     * @param $waterFile string 水印文件地址
     * @param $outFile string 新文件地址
     * @param int $width
     * @param int $height
     * @return bool
     */
    public static function qrcodePngWithWaterMark($text, $waterFile, $outFile = false, $width = 256, $height = 256, $margin = 1)
    {
        if (!is_file($waterFile)) {
            return false;
        }
        $sourceFile = $outFile ? $outFile : (sys_get_temp_dir() . '/' . uniqid() . '.png');
        $renderer = new Png();
        $renderer->setHeight($width);
        $renderer->setWidth($height);
        $renderer->setMargin($margin);
        $writer = new Writer($renderer);
        try {
            $writer->writeFile($text, $sourceFile);
        } catch (Exception $e) {
            echo "";
            return false;
        }

        if (!is_file($sourceFile)) {
            return false;
        }
        if(!$img = @imagecreatefromjpeg($waterFile)){
            return false;
        }
        $waterWidth = imagesx($img);
        $waterHeight = imagesy($img);

        $result = self::waterMarkImage(
            $sourceFile,
            $waterFile,
            $sourceFile,
            (int)(($width - $waterWidth) >> 1),
            (int)(($height - $waterHeight) >> 1),
            $waterWidth,
            $waterHeight
        );

        if (!$outFile) {
            header('Content-type: ' . ContentType::getFileContentType($sourceFile));
            readfile($sourceFile);
            @unlink($sourceFile);
        }
        return $result;
    }
}