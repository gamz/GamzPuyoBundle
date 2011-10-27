class puyo.game.Game
    constructor: (@conf)        ->
        @events   = new puyo.core.Events()
        @stage    = new puyo.stage.Stage @events, @conf.stage
        @provider = new puyo.provider.Provider @events, @conf.provider
        @events.listen puyo.core.Events.RESOLVED, ()=> @stage.start @provider.next()
    draw: (paper, x, y)         ->
        @stage.draw paper, x, y + @conf.stage.xscale * 2
        @provider.draw paper, x + @conf.stage.xstart * @conf.stage.xscale, y
    start: (scheme)             -> @provider.setup scheme
    strike:                     -> @stage.start @provider.next()
