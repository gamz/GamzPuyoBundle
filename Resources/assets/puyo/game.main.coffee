class puyo.game.Game
    constructor: (@container, @conf) ->
        @events   = new gamz.event.Dispatcher()
        @board    = new puyo.stage.Board @events, @conf
        @provider = new puyo.stage.Provider @events, @conf
        @messages = new puyo.game.Messages @container.find(@conf.jquery.messages), @events
        @score    = new puyo.game.Score @container.find(@conf.jquery.score), @events, @conf
        @conf.setup @events
        @events.bind puyo.game.Events.RESOLVED, (matrix)=> @resolved matrix
    draw: (paper, x, y)         ->
        @board.draw paper, x, y + @conf.size.cellHeight * 2
        @provider.draw paper, x + @conf.size.xstart * @conf.size.cellWidth, y
    start: (scheme)             -> @messages.ready() ; @score.reset() ; @provider.setup scheme ; setTimeout (()=> @strike()), 1000
    resolved: (matrix)          -> setTimeout (()=> @next()), if matrix.length() is 0 then @messages.clear() ; 1000 else 100
    next:                       -> if @board.available() then @strike() else @loose()
    strike:                     -> next = @provider.next() ; if next then (@board.start next ; @score.strike()) else @win()
    loose:                      -> @messages.loose()
    win:                        -> @messages.win()
    clear:                      -> @messages.clear()

class puyo.game.Messages
    constructor: (@container)   ->
    ready:                      -> @display 'lets',  'go!',    1000
    clear:                      -> @display 'stage', 'clear!', 1000
    win:                        -> @display 'you',   'win!',   1000
    loose:                      -> @display 'you',   'loose',  null
    display: (m1, m2, time)     ->
        t1 = @build(m1, -300, 0) ; t2 = @build(m2, 300, 50) ; @appear t1 ; @appear t2
        if time? then setTimeout (()=> @disappear t1 ; @disappear t2), time
    clean:                      -> @disappear tag for tag in @container
    build: (message, x, y)      -> @container.append tag = $('<p>'+message+'</p>').css { top: y+'px', left: (x)+'px', opacity: 0 } ; tag
    appear: (tag)               -> tag.animate { left: '0', opacity: 0.5 }, 150
    disappear: (tag)            -> tag.animate { opacity: 0 }, 150, ()-> @remove

class puyo.game.Scheme
    constructor: (@scheme)      -> @strike = 0
    shift:                      -> @strike += 1 ; @scheme.shift()
    empty:                      -> @scheme.length is 0

class puyo.game.SchemeGenerator
    constructor: (@colors)      ->
    add: (plus = 1)             -> @colors += plus
    shift:                      -> [@color(), @color()]
    color:                      -> Math.floor Math.random() * (@colors - 0.0000000001)
    empty:                      -> false

class puyo.game.Config
    constructor:                ->
        @size     = { columns: 13, rows: 16, cellWidth: 28, cellHeight: 28, xstart: 6, bubbleWidth: 24, bubbleHeight: 24 }
        @provider = { cache: 5, yoffset: 10, xoffset: 42 }
        @score    = { bubble: 5, combo: 0.5, clear: 100, strike: 2 }
        @colors   = { hues: [0, 0.1, 0.6, 0.75], outer: '#606060', shadow: 'rgba(0,0,0,0.5)', inner: '#000000', odd: '#121212', even: '#0E0E0E', grad1: '#080808', grad2: '#181818' }
        @keys     = { 37: puyo.game.Events.KEYLEFT, 38: puyo.game.Events.KEYTURN, 39: puyo.game.Events.KEYRIGHT, 40: puyo.game.Events.KEYDOWN, 13: puyo.game.Events.KEYDROP }
        @level    = { gtime: 3000 }
        @jquery   = { messages: '#messages', score: '#score' }
    setup: (@events)            ->
    gravity: (gravity)          -> @level.gtime = gravity ; @changed()
    changed:                    -> @events?.dispatch puyo.game.Events.SETUP, @
