<?php
use PHPUnit\Framework\TestCase;

/**
 * 断言（比如说）某方法的运行过程中生成了预期的输出（例如，通过 echo 或 print）
 * expectOutputString为字符串匹配
 * expectOutputRegex为匹配正则
 */
class OutputTest extends TestCase
{

    public function testExpectFooActualFoo()
    {
        $this->expectOutputString('foo');
        print 'foo';
    }

    public function testExpectBarActualBaz()
    {
        $this->expectOutputRegex('/ba.*/');
        print 'baz';
    }
}
?>