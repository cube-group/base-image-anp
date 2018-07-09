<?php
use PHPUnit\Framework\TestCase;

class ExpectedErrorTest extends TestCase
{
    /**
     * @expectedException PHPUnit\Framework\Warning
     */
    public function testFailingInclude()
    {
        include 'not_existing_file.php';
    }
}
?>