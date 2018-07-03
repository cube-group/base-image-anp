<?php
use PHPUnit\Framework\TestCase;

/**
 * Class ExceptionTest
 */
class ExceptionTest extends TestCase
{
    public function testException()
    {
        $this->expectException(InvalidArgumentException::class);
        throw new InvalidArgumentException("InvalidArgumentException");
    }

}
?>