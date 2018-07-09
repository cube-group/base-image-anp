<?php

use PHPUnit\Framework\TestCase;


/**
 * DatabaseTest.php 2018年05月08日 下午4:34
 * @author chenqionghe
 */
class SkipTest  extends TestCase
{
    protected function setUp()
    {
        if (!extension_loaded('mysqli')) {
            $this->markTestSkipped(
                'MySQLi 扩展不可用。'
            );
        }
    }

    /**
     * @requires PHP 5.3
     */
    public function testRequires()
    {
        echo $GLOBALS['DB_DSN'];DIE;
    }
}