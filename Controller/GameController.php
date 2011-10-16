<?php

namespace Gamz\PuyoBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Sensio\Bundle\FrameworkExtraBundle\Configuration;

class GameController extends Controller
{
    /**
     * @Configuration\Route("/", name="index")
     * @Configuration\Template
     */
    public function indexAction()
    {
        return array();
    }
}
