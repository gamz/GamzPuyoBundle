<?php

namespace Gamz\PuyoBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Sensio\Bundle\FrameworkExtraBundle\Configuration;

class ScoresController extends Controller
{
    /**
     * @Configuration\Route("/", name="game_modes")
     * @Configuration\Template
     */
    public function modesAction()
    {
        return array();
    }

    /**
     * @Configuration\Route("/arcade", name="game_arcade")
     * @Configuration\Template
     */
    public function arcadeAction()
    {
        return array();
    }

    /**
     * @Configuration\Route("/practice", name="game_practice")
     * @Configuration\Template
     */
    public function practiceAction()
    {
        return array();
    }
}
