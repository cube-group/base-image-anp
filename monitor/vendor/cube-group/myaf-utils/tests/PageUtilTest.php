<?php
use Myaf\Utils\PageUtil;
use PHPUnit\Framework\TestCase;

class PageUtilTest extends TestCase
{
    /**
     * @test
     */
    public function getPagination()
    {
        $this->assertRegExp(
            '/\<li.*<\/li\>/',
            PageUtil::create(42, 10, 1, ['environment_id' => '', 'micro_service_name' => 'de'])->getPagination('/index')
        );
    }
}