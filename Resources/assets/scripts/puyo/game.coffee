class puyo.game.Game
    constructor: (@container, @conf) ->
        @events   = new puyo.core.Events()
        @stage    = new puyo.stage.Stage @events, @conf.stage
        @provider = new puyo.provider.Provider @events, @conf.provider
        @congrats = new puyo.game.Congrats @container.find('#congrats'), @events
        @score    = new puyo.score.Score @container.find('#score'), @events, @conf.score
        @events.listen puyo.core.Events.RESOLVED, (matrix)=> @resolved matrix
    draw: (paper, x, y)         ->
        @stage.draw paper, x, y + @conf.stage.xscale * 2
        @provider.draw paper, x + @conf.stage.xstart * @conf.stage.xscale, y
    start: (scheme)             -> @congrats.ready() ; @score.reset() ; @provider.setup scheme ; setTimeout (()=> @strike()), 1000
    resolved: (matrix)          ->
        if matrix.length() is 0 then @congrats.clear() ; delay = 1000 else delay = 500
        setTimeout (()=> @next()), delay
    next:                       -> if @stage.available() then @strike() else @loose()
    strike:                     -> next = @provider.next() ; if next then (@stage.start next ; @score.strike()) else @win()
    loose:                      -> @congrats.loose()
    win:                        -> @congrats.win()
    clear:                      -> @congrats.clear()

class puyo.game.Congrats
    constructor: (@container)   ->
    ready:                      -> @start 'lets', 'go!'
    clear:                      -> @start 'stage', 'clear!'
    win:                        -> @start 'you', 'win!'
    loose:                      -> @start 'you', 'suck!'
    start: (m1, m2)             ->
        t1 = @build(m1, -300, 0) ; t2 = @build(m2, 300, 50) ; @appear t1 ; @appear t2
        setTimeout (()=> @disappear t1 ; @disappear t2), 1000
    build: (message, x, y)      -> @container.append tag = $('<p>'+message+'</p>').css { top: y+'px', left: (x)+'px', opacity: 0 } ; tag
    appear: (tag)               -> tag.animate { left: '0', opacity: 0.5 }, 150
    disappear: (tag)            -> tag.animate { opacity: 0 }, 150, ()-> @remove
