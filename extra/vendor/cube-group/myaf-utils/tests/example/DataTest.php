<?php
use PHPUnit\Framework\TestCase;

/**
 * 数据供给器
 * 用 @dataProvider 标注来指定使用哪个数据供给器方法。
 * 数据供给器方法必须声明为 public，其返回值要么是一个数组，其每个元素也是数组；
 * 要么是一个实现了 Iterator 接口的对象，在对它进行迭代时每步产生一个数组。
 * 每个数组都是测试数据集的一部分，将以它的内容作为参数来调用测试方法。
 *
 * Class DataTest
 */
class DataTest extends TestCase
{
    /**
     * @dataProvider additionProvider
     *
     *
     * @dataProvider additionProviderName
     */
    public function testAdd($a, $b, $expected)
    {
        $this->assertEquals($expected, $a + $b);
    }


    /**
     * 1.索引数组
     */
    public function additionProvider()
    {
        return [
            [0, 0, 0],
            [0, 1, 1],
            [1, 0, 1],
            [1, 1, 3]
        ];
    }

    /**
     * 2.带key的数组，更好的报错
     */
    public function additionProviderName()
    {
        return [
            'adding zeros'  => [0, 0, 0],
            'zero plus one' => [0, 1, 1],
            'one plus zero' => [1, 0, 1],
            'one plus one'  => [1, 1, 3]
        ];
    }

    /**
     * 3.使用返回迭代器对象的数据供给器
     */
    public function additionProviderIterator()
    {
        return new CsvFileIterator('data.csv');
    }



}
?>