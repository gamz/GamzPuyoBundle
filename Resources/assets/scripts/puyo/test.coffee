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
            cache:   5
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
        score:
            bubble: 5   # points by bubble removed
            combo:  0.5 # points coef per combo (if > 1)
            clear:  100 # points on stage clear (x combos)
            strike: 2   # points on strike

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

    paper = Raphael('paper', 372, 516)
    game  = new puyo.game.Game $('#game'), conf

    game.draw paper, 4, 8
    game.start level
