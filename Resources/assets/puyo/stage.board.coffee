class puyo.stage.Board
    constructor: (@events, @conf) ->
        @events.bind puyo.game.Events.RESOLVE, ()=> @resolve()
        @matrix     = new puyo.stage.Matrix(@conf.size.columns, @conf.size.rows)
        @controller = new puyo.stage.Controller(@events)
        if @conf.level.gtime? then @gravity = new puyo.stage.Gravity(@events, @conf)
        @keyboard   = new puyo.game.Keyboard(@events, @conf)
        @resolver   = new puyo.stage.Resolver(@events, @matrix)
    draw: (paper, x, y)     ->
        @sprite = new puyo.sprite.Board(paper, @conf)
        @sprite.draw(x, y)
    start: (group) ->
        @controller.bind @bubble(1, group.master), @bubble(0, group.slave)
        @controller.orient = puyo.stage.ControlGroup.NORTH
        if @conf.level.gtime? then @gravity.bind @controller
        @keyboard.start()
    resolve:                ->
        if @conf.level.gtime? then @gravity.unbind()
        @controller.unbind()
        @keyboard.stop()
        @resolver.resolve()
    available:              -> not @matrix.get(@conf.size.xstart, 0)? and not @matrix.get(@conf.size.xstart, 1)?
    bubble: (y, cell)       ->
        if cell.color? then new puyo.stage.ColoredBubble(@matrix, @conf.size.xstart, y, cell.sprite, @conf, cell.color)
        else new puyo.stage.Bubble(@matrix, @conf.size.xstart, y, cell.sprite, @conf)

class puyo.stage.Bubble extends puyo.stage.Cell
    @BUBBLEMOVE: 75  # bubble move time
    constructor: (matrix, x, y, @sprite, @conf) ->
        super(matrix, x, y)
        @sprite.move 0, 2*@conf.size.cellHeight, 2*puyo.stage.Bubble.BUBBLEMOVE
    remove:                 -> super() ; @sprite.explode()
    move: (dx, dy)          -> super(dx, dy) ; @sprite.move(dx*@conf.size.cellWidth, dy*@conf.size.cellHeight, puyo.stage.Bubble.BUBBLEMOVE)
    fall: (dy)              -> super(dy) ; @sprite.fall(dy*@conf.size.cellHeight, dy*puyo.stage.Bubble.BUBBLEMOVE)
    match: (bubble)         -> false
    test: (dx, dy)          -> if super(dx, dy) then true else (@sprite.flash() ; false)

class puyo.stage.ColoredBubble extends puyo.stage.Bubble
    constructor: (matrix, x, y, sprite, conf, @color) -> super(matrix, x, y, sprite, conf)
    match: (bubble)         -> bubble.color is @color or not bubble.color?

class puyo.stage.Gravity
    constructor: (events, @conf) ->
        @pulsar = new gamz.utils.Pulsar((()=> @down()), @conf.level.gtime)
        events.bind puyo.game.Events.KEYDOWN, ()=> @pulsar.reset()
        events.bind puyo.game.Events.SETUP,   ()=> @pulsar.time = @conf.level.gtime
    bind: (@controller)     -> @pulsar.start()
    unbind:                 -> @controller = null ; @pulsar.stop()
    down:                   -> @controller?.keydown()

class puyo.stage.Controller extends puyo.stage.ControlGroup
    constructor: (@events)  -> super() ; @events.subscribe @
    keyleft:                -> if not @move 'left'  then @events.dispatch puyo.game.Events.BLOCKED
    keyright:               -> if not @move 'right' then @events.dispatch puyo.game.Events.BLOCKED
    keyturn:                -> if not @move 'turn'  then @events.dispatch puyo.game.Events.BLOCKED
    keydown:                -> if @move 'down' then @events.dispatch puyo.game.Events.FORWARD else @events.dispatch puyo.game.Events.RESOLVE
    keydrop:                -> @events.dispatch puyo.game.Events.DROP ; @events.dispatch puyo.game.Events.RESOLVE

class puyo.stage.Resolver
    @AFTERFALLED:   150 # sleep time after falled
    @AFTERMATCH:    200 # sleep time after matching
    constructor: (@events, @matrix) ->
    resolve:                -> @gravity()
    gravity:                ->
        [cells, delta] = new puyo.stage.GravityResolver(@matrix).resolve()
        if delta? then setTimeout (()=> @matches(cells)), delta * puyo.stage.Bubble.BUBBLEMOVE + puyo.stage.Resolver.AFTERFALLED
        else @resolved()
    matches: (cells)        ->
        groups = new puyo.stage.MatchesResolver(cells).resolve()
        if groups?
            @events.dispatch puyo.game.Events.MATCHED, groups
            setTimeout (()=>@gravity()), puyo.stage.Resolver.AFTERMATCH
        else @resolved()
    resolved:               -> @events.dispatch puyo.game.Events.RESOLVED, @matrix

class puyo.stage.GravityResolver
    constructor: (@matrix)  -> @cells = [] ; @delta = 0
    accept: (cell)          -> @matrix.available cell.x, cell.y+1
    add: (group)            ->
        @cells.push c for c in group.cells
        if group.delta > @delta then @delta = group.delta
    resolve:                ->
        for id, cell of @matrix.cells
            if @accept cell then @add new puyo.stage.FallingGroup(cell)

        [@cells, @delta]

class puyo.stage.MatchesResolver
    constructor: (@cells)   -> @groups = []
    accept: (group)         -> group.size() >= 4 and not @has group.root
    add: (group)            -> if @accept group then (@groups.push group ; @remove group)
    remove: (group)         -> cell.remove() for cell in group.cells
    has: (cell)             ->
        for group in @groups
            if group.has cell then return true
        false
    resolve:                ->
        for cell in @cells
            @add new puyo.stage.MatchingGroup(cell)
        if @groups.length > 0 then @groups else null


