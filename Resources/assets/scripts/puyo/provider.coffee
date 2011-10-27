class puyo.provider.Provider
    constructor: (@events, @conf) ->
    draw: (@paper, x, y)    ->
        @conf.yslave = y + @conf.yscale/2 ; @conf.ymaster  = @conf.yslave + @conf.yscale
        @conf.xstart = x + @conf.xscale/2
        @sprite = new puyo.sprite.Provider paper, @conf ; @sprite.draw paper, x, y
    setup: (scheme)         ->
        @manipulator = new puyo.provider.Manipulator @conf
        @builder     = new puyo.provider.Builder @paper, @manipulator, @conf
        @queue       = new puyo.provider.Queue @events, @builder, @conf
        @queue.setup scheme
        @manipulator.init @queue.stack
    next:                   -> @queue.next()

class puyo.provider.Queue
    constructor: (@events, @builder, @conf) -> @stack = []
    setup: (@scheme)        -> @builder.setup scheme ; @cache @conf.cache
    cache: (length)         -> (if @builder.length() > 0 then @stack.push @builder.next()) for i in [0...length]
    next:                   ->
        next = if @stack.length > 0 then @stack.shift() else null
        index = 0 ; (group.move index ; index += 1 ) for group in @stack ; @cache 1
        next


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
    @SPACE:    20  # space between groups
    constructor: (@conf)    ->
    init: (@cache)          -> (@cache[i].draw i ; @cache[i].appear()) for i in [0...@cache.length]
    spawn: (group)          -> if @cache? then group.draw @cache.length ; group.appear()
    next: (group)           -> group.move @conf.xscale + puyo.provider.Manipulator.SPACE

class puyo.provider.Group
    @MOVETIME: 100
    constructor: (@master, @slave, @conf) ->
    draw: (index)           -> @master.sprite.draw @x(index), @conf.ymaster ; @slave.sprite.draw @x(index), @conf.yslave
    appear:                 -> @master.sprite.appear puyo.provider.Group.MOVETIME ; @slave.sprite.appear()
    x: (index)              -> @conf.xstart + index * (@conf.xscale + puyo.provider.Manipulator.SPACE)
    move:                   ->
        dx = 0 - @conf.xscale - puyo.provider.Manipulator.SPACE
        @master.sprite.move dx, 0, puyo.provider.Group.MOVETIME
        @slave.sprite.move  dx, 0, puyo.provider.Group.MOVETIME


