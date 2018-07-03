<?php

namespace Myaf\Utils;

/**
 * 分页工具
 *
 * @author chenqionghe
 * @package Myaf\Utils
 */
class PageUtil
{
    /**
     * 当前页码
     * @var int
     */
    public $page = 1;
    /**
     * 总条数
     * @var int
     */
    public $total = 1;
    /**
     * 每页显示条数
     * @var int
     */
    public $pageSize = 10;
    /**
     * url的get参数集
     * @var array
     */
    public $gets = [];

    /**
     * Page constructor.
     * @param $totalPage int 总条数
     * @param int $pageSize 每页显示条数
     * @param int $page 当前页码
     * @param array $gets url携带get参数数组
     * @return self
     */
    public static function create($totalPage, $pageSize = 10, $page = 1, $gets = [])
    {
        $p = new PageUtil();
        if ($pageSize < 1) {
            $pageSize = 1;
        }

        $total = ceil($totalPage / $pageSize);

        if ($page < 1) {
            $page = 1;
        } else if ($page > $total) {
            $page = $total;
        }

        $p->page = $page;
        $p->gets = $gets;
        $p->total = $total;
        $p->pageSize = $pageSize;
        return $p;
    }

    /**
     * 获取分页html元素
     * @param $url string
     * @return string
     */
    public function getPagination($url)
    {
        $gets = null;
        $gets = $this->gets;
        $page = $this->page;
        $gets['pageSize'] = $this->pageSize;
        if ($page > 1) {
            $gets['page'] = 1;
            $newUrl = URLUtil::addParameter($url, $gets);
            $laquo = "<li><a href=\"{$newUrl}\">&laquo;</a></li>";
            $gets['page'] = $page - 1;
            $newUrl = URLUtil::addParameter($url, $gets);
            $left = "<li><a href=\"{$newUrl}\">&lt;</a></li>";
        } else {
            $laquo = "<li class=\"disabled\"><a href='#'>&laquo;</a></li>";
            $left = "<li class=\"disabled\"><a href='#'>&lt;</a></li>";
        }
        if ($page < $this->total) {
            $gets['page'] = $this->total;
            $newUrl = URLUtil::addParameter($url, $gets);
            $raquo = "<li><a href=\"{$newUrl}\">&raquo;</a></li>";
            $gets['page'] = $page + 1;
            $newUrl = URLUtil::addParameter($url, $gets);
            $right = "<li><a href=\"{$newUrl}\">&gt;</a></li>";
        } else {
            $raquo = "<li class=\"disabled\"><a href='#'>&raquo;</a></li>";
            $right = "<li class=\"disabled\"><a href='#'>&gt;</a></li>";
        }

        $otherPages = [];
        $start = 1;
        if ($this->total > 5) {
            $start = $page;
            while (true) {
                if ($start - 2 >= 1 && $start + 2 <= $this->total) {
                    break;
                } else if ($start - 2 <= 1) {
                    $start++;
                } else if ($start + 2 >= $this->total) {
                    $start--;
                }
            }
            $end = $start + 2;
            $start -= 2;
        } else {
            $end = $this->total;
        }
        for ($i = $start; $i <= $end; $i++) {
            if ($page == $i) {
                $otherPages[] = "<li class=\"active\"><a href=\"#\">{$i}</a></li>";
            } else {
                $gets['page'] = $i;
                $newUrl = URLUtil::addParameter($url, $gets);
                $otherPages[] = "<li><a href=\"{$newUrl}\">{$i}</a></li>";
            }
        }

        array_unshift($otherPages, $left);
        array_unshift($otherPages, $laquo);
        array_push($otherPages, $right);
        array_push($otherPages, $raquo);
        $html = '<ul class="pagination">' . join("\n", $otherPages) . '</ul>';
        return $html;
    }

    /**
     * 获取分页参数
     *
     * @param $page
     * @param $totalCount
     * @param int $pageSize
     * @return array
     */
    public static function get($page, $totalCount, $pageSize = 30)
    {
        $page = self::getPage($page);
        $pageCount = self::getPageCount($totalCount, $pageSize);
        $next = self::getNext($page, $pageCount);
        $pre = self::getPre($page);
        $limit = self::getLimit($pageSize);
        $offset = self::getOffset($page, $pageSize);
        return [
            'page' => $page,//当前页数
            'pageSize' => $pageSize,//分页大小
            'totalCount' => $totalCount,//总数
            'pageCount' => $pageCount,//总页数
            'next' => $next,//下一页
            'pre' => $pre,//上一页
            'limit' => $limit,//limit
            'offset' => $offset,//offset
        ];
    }


    /**
     * 当前页
     *
     * @param $page
     * @return int
     */
    private static function getPage($page)
    {
        $page = (int)$page;
        return !$page ? 1 : $page;
    }

    /**
     * 总页数
     *
     * @param $totalCount
     * @param $pageSize
     * @return int
     */
    private static function getPageCount($totalCount, $pageSize)
    {
        $totalCount = $totalCount < 0 ? 0 : (int)$totalCount;
        return ceil($totalCount / $pageSize);
    }


    /**
     * 获取下一页
     *
     * @param $page
     * @param $pageCount
     * @return int
     */
    private static function getNext($page, $pageCount)
    {
        if ($pageCount > 1 && $page >= 0 && $page < $pageCount) {
            return $page + 1;
        } else {
            return 0;
        }
    }

    /**
     * 获取上一页
     *
     * @param $page
     * @return int
     */
    private static function getPre($page)
    {
        if ($page <= 1) {
            return 0;
        }
        return $page - 1;
    }


    /**
     * 获取offset
     *
     * @param $page
     * @param $pageSize
     * @return int
     */
    private static function getOffset($page, $pageSize)
    {
        return $pageSize < 1 ? 0 : ($page - 1) * $pageSize;
    }

    /**
     * 获取limit
     *
     * @param $pageSize
     * @return int
     */
    private static function getLimit($pageSize)
    {
        return $pageSize < 1 ? -1 : $pageSize;
    }
}
