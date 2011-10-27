class puyo.stage.Stage
    # conf: width, height, xscale, yxcale, xoffset, yoffset, xstart, gtime
    constructor: (@events, @conf) ->
        @events.bind @
        @matrix     = new puyo.engine.Matrix(@conf.columns, @conf.rows)
        @controller = new puyo.stage.Controller(@events)
        if @conf.gtime? then @gravity = new puyo.stage.Gravity(@events, @conf.gtime)
        @keyboard   = new puyo.core.Keyboard(@events, @conf.keys)
        @resolver   = new puyo.stage.Resolver(@events, @matrix)
    draw: (paper, x, y)              ->
        @conf.xoffset = x ; @conf.yoffset = y
        @sprite = new puyo.sprite.Stage(paper, @conf)
        @sprite.draw(x, y)
    start: (group) ->
        @controller.bind @bubble(1, group.master), @bubble(0, group.slave)
        @controller.orient = puyo.engine.ControlGroup.NORTH
        if @conf.gtime? then @gravity.bind @controller
        @keyboard.start()
    resolve:                ->
        if @conf.gtime? then @gravity.unbind()
        @controller.unbind()
        @keyboard.stop()
        @resolver.resolve()
    bubble: (y, cell) ->
        if cell.color? then new puyo.stage.ColoredBubble(@matrix, @conf.xstart, y, cell.sprite, @conf, cell.color)
        else new puyo.stage.Bubble(@matrix, @conf.xstart, y, cell.sprite, @conf)

class puyo.stage.Bubble extends puyo.engine.Cell
    @BUBBLEMOVE: 75  # bubble move time
    # conf: xscale, yxcale, xoffset, yoffset
    constructor: (matrix, x, y, @sprite, @conf) ->
        super(matrix, x, y)
        @sprite.move 0, 2*@conf.yscale, 2*puyo.stage.Bubble.BUBBLEMOVE
    remove:                 -> super() ; @sprite.explode()
    move: (dx, dy)          -> super(dx, dy) ; @sprite.move(dx*@conf.xscale, dy*@conf.yscale, puyo.stage.Bubble.BUBBLEMOVE)
    fall: (dy)              -> super(dy) ; @sprite.fall(dy*@conf.yscale, dy*puyo.stage.Bubble.BUBBLEMOVE)
    match: (bubble)         -> false
    test: (dx, dy)          -> if super(dx, dy) then true else (@sprite.flash() ; false)

class puyo.stage.ColoredBubble extends puyo.stage.Bubble
    # conf: xscale, yxcale, xoffset, yoffset
    constructor: (matrix, x, y, sprite, conf, @color) -> super(matrix, x, y, sprite, conf)
    match: (bubble)         -> bubble.color is @color or not bubble.color?

class puyo.stage.Gravity
    constructor: (events, @time) ->
        @pulsar = new puyo.core.Pulsar((()=> @down()), @time)
        events.listen puyo.core.Events.KEYDOWN, ()=> @pulsar.reset()
    bind: (@controller)     -> @pulsar.start()
    unbind:                 -> @controller = null ; @pulsar.stop()
    down:                   -> @controller?.keydown()

class puyo.stage.Controller extends puyo.engine.ControlGroup
    constructor: (@events)  -> super() ; @events.bind @
    keyleft:                -> if not @move 'left'  then @events.dispatch puyo.core.Events.BLOCKED
    keyright:               -> if not @move 'right' then @events.dispatch puyo.core.Events.BLOCKED
    keyturn:                -> if not @move 'turn'  then @events.dispatch puyo.core.Events.BLOCKED
    keydown:                -> if @move 'down' then @events.dispatch puyo.core.Events.FORWARD else @events.dispatch puyo.core.Events.RESOLVE
    keydrop:                -> @events.dispatch puyo.core.Events.DROP ; @events.dispatch puyo.core.Events.RESOLVE

class puyo.stage.Resolver
    @AFTERFALLED:   250 # sleep time after falled
    @AFTERMATCH:    250 # sleep time after matching
    @AFTERRESOLVED: 250 # sleep time after resolved
    constructor: (@events, @matrix) ->
        @events.listen puyo.core.Events.FALLED,  (cells)=> @matches(cells)
        @events.listen puyo.core.Events.MATCHED, (groups)=> @gravity()
    resolve:                -> @gravity()
    gravity:                ->
        [cells, delta] = new puyo.stage.GravityResolver(@matrix).resolve()
        if delta? then setTimeout (()=> @events.dispatch puyo.core.Events.FALLED, cells), delta * puyo.stage.Bubble.BUBBLEMOVE + puyo.stage.Resolver.AFTERFALLED
        else setTimeout (()=> @events.dispatch puyo.core.Events.RESOLVED), puyo.stage.Resolver.AFTERRESOLVED
    matches: (cells)        ->
        groups = new puyo.stage.MatchesResolver(cells).resolve()
        if groups? then setTimeout (()=> @events.dispatch puyo.core.Events.MATCHED, groups), puyo.stage.Resolver.AFTERMATCH
        else setTimeout (()=> @events.dispatch puyo.core.Events.RESOLVED), puyo.stage.Resolver.AFTERRESOLVED

class puyo.stage.GravityResolver
    constructor: (@matrix)  -> @cells = [] ; @delta = 0
    accept: (cell)          -> @matrix.available cell.x, cell.y+1
    add: (group)            ->
        @cells.push c for c in group.cells
        if group.delta > @delta then @delta = group.delta
    resolve:                ->
        for id, cell of @matrix.cells
            if @accept cell then @add new puyo.engine.FallingGroup(cell)

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
            @add new puyo.engine.MatchingGroup(cell)
        if @groups.length > 0 then @groups else null


