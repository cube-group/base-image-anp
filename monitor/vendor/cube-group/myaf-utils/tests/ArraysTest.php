<?php
use Myaf\Utils\Arrays;
use PHPUnit\Framework\TestCase;

/**
 * Array测试用例
 * Class ArraysTest
 */
class ArraysTest extends TestCase
{

    /**
     * 获取
     * @test
     */
    public function get()
    {
        $array = [
            'x' => [
                'y' => [
                    'z' => 'cqh'
                ],
            ],
            'name' => 'hello'
        ];
        //获取键name
        $this->assertEquals('hello', Arrays::get($array, 'name'));
        //获取子数组子元素x => y => z
        $this->assertEquals('cqh', Arrays::get($array, 'x.y.z'));
        //获取不存在的key
        $this->assertEquals(null, Arrays::get($array, 'test'));
    }

    /**
     * @test
     */
    public function sGet()
    {
        $array = [
            'name' => '0'
        ];
        //获取键name
        $this->assertEquals('chenqionghe', Arrays::sGet($array, 'name', 'chenqionghe'));
    }


    /**
     * @test
     */
    public function lists()
    {
        $array = [
            ['id' => 3, 'name' => 'x', 'age' => 18],
            ['id' => 5, 'name' => 'y', 'age' => 18],
            ['id' => 6, 'name' => 'z', 'age' => 38],
        ];

        $expected = [
            'x' => ['id' => 3, 'name' => 'x', 'age' => 18],
            'y' => ['id' => 5, 'name' => 'y', 'age' => 18],
            'z' => ['id' => 6, 'name' => 'z', 'age' => 38],
        ];
        $this->assertArraySubset($expected, Arrays::lists($array, 'name'));
    }


    /**
     * @test
     */
    public function merge()
    {
        $array1 = [
            'name' => 'array1',
            'lang' => ['php', 'java']
        ];
        $array2 = [
            'name' => 'array2',
            'lang' => ['nodeJs', 'go', 'python']
        ];

        $expected = [
            'name' => 'array2',
            'lang' => [
                'php', 'java', 'nodeJs', 'go', 'python'
            ]
        ];

        $this->assertArraySubset($expected, Arrays::merge($array1, $array2));
    }

    /**
     * @test
     */
    public function keyToCamel()
    {
        $array = [
            'my_name' => 'hello',
            'my_age' => 18,
        ];

        $expected = [
            'myName' => 'hello',
            'myAge' => 18,
        ];
        $this->assertArraySubset($expected, Arrays::keyToCamel($array));
    }


    /**
     * @test
     */
    public function keyToCase()
    {
        $array = [
            'myName' => 'hello',
            'myAge' => 18,
        ];

        $expected = [
            'my_name' => 'hello',
            'my_age' => 18,
        ];
        $this->assertArraySubset($expected, Arrays::keyToCase($array));
    }
}
