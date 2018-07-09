<?php

namespace Myaf\Utils;

/**
 * Class ContentType
 * @package Myaf\Utils
 */
class ContentType
{
    /**
     * 根据文件名称获取相关联的ContentType.
     * @param $filename
     * @return string
     */
    public static function getFileContentType($filename)
    {
        $path_parts = pathinfo($filename);//返回文件路径的信息
        $ext = strtolower($path_parts["extension"]); //将字符串转化为小写
        // Determine Content Type
        switch ($ext) {
            case "ico":
                $cType = "image/x-icon";
                break;
            case "pdf":
                $cType = "application/pdf";
                break;
            case "exe":
                $cType = "application/octet-stream";
                break;
            case "zip":
                $cType = "application/zip";
                break;
            case "doc":
                $cType = "application/msword";
                break;
            case "xls":
            case "xlsx":
                $cType = "application/vnd.ms-excel";
                break;
            case "ppt":
                $cType = "application/vnd.ms-powerpoint";
                break;
            case "gif":
                $cType = "image/gif";
                break;
            case "png":
                $cType = "image/png";
                break;
            case "jpeg":
            case "jpg":
                $cType = "image/jpg";
                break;
            case "css":
                $cType = "text/css";
                break;
            case "js":
                $cType = "text/x-javascript";
                break;
            case "html":
                $cType = "text/html";
                break;
            case "txt":
            case "xml":
                $cType = "text/xml";
                break;
            default:
                $cType = "application/force-download";
                break;
        }

//        header("Pragma", "public"); // required 指明响应可被任何缓存保存
//        header("Expires", "0");
//        header("Cache-Control", "must-revalidate, post-check=0, pre-check=0");
//        header("Content-Type", $cType);
        return $cType;
    }
}