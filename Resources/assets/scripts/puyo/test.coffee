$ ->

    conf =
        stage:
            columns: 13
            rows:    16
            xscale:  28
            yscale:  28
            xstart:  6
            gtime:   3000
            keys:
                37: puyo.core.Events.KEYLEFT
                38: puyo.core.Events.KEYTURN
                39: puyo.core.Events.KEYRIGHT
                40: puyo.core.Events.KEYDOWN
                13: puyo.core.Events.KEYDROP
            colors:
                outer: '#666'
                focus: '#999'
                inner: '#000'
                odd:   '#121212'
                even:  '#0E0E0E'
        provider:
            xscale:  28
            yscale:  28
            cache:   10
            column:  6
            colors:
                outer: '#666'
                focus: '#999'
                inner: '#000'
                grad1: '#080808'
                grad2: '#181818'
            bubble:
                width:  24
                height: 24
                hues:   [0, 0.1, 0.6, 0.75]

    level = [
        [0, 1], [1, 0], [1, 2], [2, 1], [0, 2], [2, 0],
        [0, 1], [1, 0], [1, 2], [2, 1], [0, 2], [2, 0],
        [0, 1], [1, 0], [1, 2], [2, 1], [0, 2], [2, 0],
        [0, 1], [1, 0], [1, 2], [2, 1], [0, 2], [2, 0],
        [0, 1], [1, 0], [1, 2], [2, 1], [0, 2], [2, 0],
        [0, 1], [1, 0], [1, 2], [2, 1], [0, 2], [2, 0],
        [0, 1], [1, 0], [1, 2], [2, 1], [0, 2], [2, 0],
        [0, 1], [1, 0], [1, 2], [2, 1], [0, 2], [2, 0]
    ]

    paper = Raphael('game', 1000, 600)
    game  = new puyo.game.Game conf

    game.draw paper, 50, 50
    game.start level
    game.strike()
