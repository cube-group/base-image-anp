<?php
use Myaf\Utils\Strings;
use PHPUnit\Framework\TestCase;


/**
 * Array测试用例
 * Class ArraysTest
 */
class StringsTest extends TestCase
{

    /**
     * @test
     */
    public function random()
    {
        $str = Strings::random();
        var_dump($str);
        $this->assertEquals(16, strlen(Strings::random()));
    }

    /**
     * @test
     */
    public function randomNumber()
    {
        $str = Strings::randomNumber();
        var_dump($str);
        $this->assertEquals(16, strlen(Strings::randomNumber()));
    }

}
