class puyo.game.Game
    constructor: (@container, @conf) ->
        @events   = new puyo.game.Events()
        @board    = new puyo.stage.Board @events, @conf.stage
        @provider = new puyo.stage.Provider @events, @conf.provider
        @messages = new puyo.game.Messages @container.find('#messages'), @events
        @score    = new puyo.game.Score @container.find('#score'), @events, @conf.score
        @events.listen puyo.game.Events.RESOLVED, (matrix)=> @resolved matrix
    draw: (paper, x, y)         ->
        @board.draw paper, x, y + @conf.stage.xscale * 2
        @provider.draw paper, x + @conf.stage.xstart * @conf.stage.xscale, y
    start: (scheme)             -> @messages.ready() ; @score.reset() ; @provider.setup scheme ; setTimeout (()=> @strike()), 1000
    resolved: (matrix)          -> setTimeout (()=> @next()), if matrix.length() is 0 then @messages.clear() ; 1000 else 500
    next:                       -> if @board.available() then @strike() else @loose()
    strike:                     -> next = @provider.next() ; if next then (@board.start next ; @score.strike()) else @win()
    loose:                      -> @messages.loose()
    win:                        -> @messages.win()
    clear:                      -> @messages.clear()

class puyo.game.Messages
    constructor: (@container)   ->
    ready:                      -> @display 'lets', 'go!'
    clear:                      -> @display 'stage', 'clear!'
    win:                        -> @display 'you', 'win!'
    loose:                      -> @display 'you', 'suck!'
    display: (m1, m2)           ->
        t1 = @build(m1, -300, 0) ; t2 = @build(m2, 300, 50) ; @appear t1 ; @appear t2
        setTimeout (()=> @disappear t1 ; @disappear t2), 1000
    build: (message, x, y)      -> @container.append tag = $('<p>'+message+'</p>').css { top: y+'px', left: (x)+'px', opacity: 0 } ; tag
    appear: (tag)               -> tag.animate { left: '0', opacity: 0.5 }, 150
    disappear: (tag)            -> tag.animate { opacity: 0 }, 150, ()-> @remove

class puyo.game.Scheme
    constructor: (@scheme)  ->
    shift:                  -> @scheme.shift()
    empty:                  -> @scheme.length is 0

class puyo.game.SchemeGenerator
    constructor: (@colors)  ->
    add: (plus = 1)         -> @colors += plus
    shift:                  -> Math.floor Math.random() * (@colors - 0.0000000001)
    empty:                  -> false
