class puyo.provider.Provider
    constructor: (@events, @conf) ->
    draw: (@paper, x, y)    ->
        @conf.yslave = y + @conf.yscale/2 - @conf.yoffset ; @conf.ymaster  = @conf.yslave + @conf.yscale
        @conf.xstart = x + @conf.xscale/2
        @sprite = new puyo.sprite.Provider paper, @conf ; @sprite.draw paper, x, y
    setup: (scheme)         ->
        @manipulator = new puyo.provider.Manipulator @conf
        @builder     = new puyo.provider.Builder @paper, @manipulator, @conf
        @queue       = new puyo.provider.Queue @events, @builder, @conf
        @queue.setup scheme
        @manipulator.init @queue.stack
    next:                   -> next = @queue.next() ; @manipulator.next() ; next

class puyo.provider.Queue
    constructor: (@events, @builder, @conf) -> @stack = []
    setup: (@scheme)        -> @builder.setup scheme ; @cache @conf.cache
    cache: (length)         -> (if @builder.length() > 0 then @stack.push @builder.next()) for i in [0...length]
    next:                   -> @cache 1 ; if @stack.length > 0 then @stack.shift() else null

class puyo.provider.Builder
    constructor: (@paper, @manipulator, @conf) ->
    setup: (@scheme)        ->
    next:                   ->
        if @scheme.length is 0 then null
        else (group = @group(@scheme.shift()) ; @manipulator.spawn group ; group)
    length:                 -> @scheme.length
    group: (colors)         -> new puyo.provider.Group(
        { color: colors[0], sprite: new puyo.sprite.Bubble @paper, @conf.bubble, colors[0] } ,
        { color: colors[1], sprite: new puyo.sprite.Bubble @paper, @conf.bubble, colors[1] } , @conf )

class puyo.provider.Manipulator
    constructor: (@conf)    ->
    init: (@cache)          -> (@cache[i].draw i ; @cache[i].appear()) for i in [0...@cache.length]
    spawn: (group)          -> if @cache? then group.draw @cache.length ; group.appear()
    next:                   -> @move group, index for group, index in @cache
    move: (group, index)    -> group.move 0 - @conf.xoffset, if index is 0 then @conf.yoffset else 0

class puyo.provider.Group
    @MOVETIME: 100
    constructor: (@master, @slave, @conf) ->
    draw: (index)           ->
        if index is 0 then dy = @conf.yoffset else dy = 0
        @master.sprite.draw @x(index), @conf.ymaster + dy
        @slave.sprite.draw @x(index), @conf.yslave + dy
    appear:                 -> @master.sprite.appear puyo.provider.Group.MOVETIME ; @slave.sprite.appear()
    x: (index)              -> @conf.xstart + index * @conf.xoffset
    move: (dx, dy)          ->
        @master.sprite.move dx, dy, puyo.provider.Group.MOVETIME
        @slave.sprite.move  dx, dy, puyo.provider.Group.MOVETIME
