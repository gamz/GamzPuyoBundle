$ ->

    paper  = Raphael('paper', 382, 526)
    game   = new puyo.game.Game $('#game'), new puyo.game.Config()
    scheme = new puyo.game.SchemeGenerator 3

    game.draw   paper, 9, 13
    game.start  scheme
