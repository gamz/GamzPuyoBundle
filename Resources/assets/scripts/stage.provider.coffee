class puyo.stage.Provider
    constructor: (@events, @conf) ->
    draw: (@paper, x, y)    ->
        @conf.yslave = y + @conf.yscale/2 - @conf.yoffset ; @conf.ymaster  = @conf.yslave + @conf.yscale
        @conf.xstart = x + @conf.xscale/2
        @sprite = new puyo.sprite.Provider paper, @conf ; @sprite.draw paper, x, y
    setup: (scheme)         ->
        @manipulator = new puyo.stage.ProviderManipulator @conf
        @builder     = new puyo.stage.ProviderBuilder @paper, @manipulator, @conf
        @queue       = new puyo.stage.ProviderQueue @events, @builder, @conf
        @queue.setup scheme
        @manipulator.init @queue.stack
    next:                   -> next = @queue.next() ; @manipulator.next() ; next

class puyo.stage.ProviderQueue
    constructor: (@events, @builder, @conf) -> @stack = []
    setup: (@scheme)        -> @builder.setup scheme ; @cache @conf.cache
    cache: (length)         -> (if not @builder.empty() then @stack.push @builder.next()) for i in [0...length]
    next:                   -> @cache 1 ; if @stack.length > 0 then @stack.shift() else null

class puyo.stage.ProviderBuilder
    constructor: (@paper, @manipulator, @conf) ->
    setup: (@scheme)        ->
    next:                   -> if @scheme.empty() then null else (group = @group(@scheme.shift()) ; @manipulator.spawn group ; group)
    empty:                  -> @scheme.empty()
    group: (colors)         -> new puyo.stage.ProviderGroup(
        { color: colors[0], sprite: new puyo.sprite.Bubble @paper, @conf.bubble, colors[0] } ,
        { color: colors[1], sprite: new puyo.sprite.Bubble @paper, @conf.bubble, colors[1] } , @conf )

class puyo.stage.ProviderManipulator
    constructor: (@conf)    ->
    init: (@cache)          -> (@cache[i].draw i ; @cache[i].appear()) for i in [0...@cache.length]
    spawn: (group)          -> if @cache? then group.draw @cache.length ; group.appear()
    next:                   -> @move group, index for group, index in @cache
    move: (group, index)    -> group.move 0 - @conf.xoffset, if index is 0 then @conf.yoffset else 0

class puyo.stage.ProviderGroup
    @MOVETIME: 100
    constructor: (@master, @slave, @conf) ->
    draw: (index)           ->
        if index is 0 then dy = @conf.yoffset else dy = 0
        @master.sprite.draw @x(index), @conf.ymaster + dy
        @slave.sprite.draw @x(index), @conf.yslave + dy
    appear:                 -> @master.sprite.appear puyo.stage.ProviderGroup.MOVETIME ; @slave.sprite.appear()
    x: (index)              -> @conf.xstart + index * @conf.xoffset
    move: (dx, dy)          ->
        @master.sprite.move dx, dy, puyo.stage.ProviderGroup.MOVETIME
        @slave.sprite.move  dx, dy, puyo.stage.ProviderGroup.MOVETIME



