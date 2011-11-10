<?php

namespace Gamz\PuyoBundle\Controller;

use Sensio\Bundle\FrameworkExtraBundle\Configuration;

class GameController
{
    /**
     * @Configuration\Route("/", name="puyo_game_modes")
     * @Configuration\Template
     */
    public function modesAction()
    {
        return array();
    }

    /**
     * @Configuration\Route("/arcade", name="puyo_game_arcade")
     * @Configuration\Template
     */
    public function arcadeAction()
    {
        return array();
    }

    /**
     * @Configuration\Route("/practice", name="puyo_game_practice")
     * @Configuration\Template
     */
    public function practiceAction()
    {
        return array();
    }
}
