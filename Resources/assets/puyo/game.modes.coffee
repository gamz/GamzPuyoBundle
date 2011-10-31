class puyo.game.GameMode
    start:                      -> @game.start @scheme

class puyo.game.PracticeGame extends puyo.game.GameMode
    constructor: (@paper, container) ->
        @conf   = new puyo.game.Config()
        @game   = new puyo.game.Game(container, @conf)
        @scheme = new puyo.game.SchemeGenerator(3);
        @game.draw @paper, 9, 13
    gravity: (gravity)          -> @conf.gravity gravity
    colors: (colors)            -> @scheme.colors = colors

class puyo.game.ArcadeMode extends puyo.game.GameMode
