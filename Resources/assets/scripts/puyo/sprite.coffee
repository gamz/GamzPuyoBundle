class puyo.sprite.Toolkit
    rand: (from, to)        -> Math.round Math.random() * (to - from) + from

class puyo.sprite.Drawing extends puyo.sprite.Toolkit
    constructor: (@paper, @width, @height) -> @shape = null
    xarg:                   -> 'x'
    yarg:                   -> 'y'
    posattrs: (x, y)        -> attrs = {} ; attrs[@xarg()] = x ; attrs[@yarg()] = y ; attrs
    draw: (@x, @y)          ->
    remove:                 -> @shape.remove()
    fade: (to, time, callback) -> @shape.animate { opacity: to }, time, callback
    move: (dx, dy, time, callback) -> @moveto @x+dx, @y+dy, time, callback
    moveto: (@x, @y, time, callback) -> @shape.animate @posattrs(@x, @y), time, callback
    position: (@x, @y)        -> @shape.attr @posattrs(@x, @y)

class puyo.sprite.Sprite extends puyo.sprite.Toolkit
    constructor: (@paper)   -> @drawings = {}
    draw: (@x, @y)          -> drawing.draw(@x, @y) for name, drawing of @drawings
    remove:                 -> drawing.remove() for name, drawing of @drawings
    fade: (to, time)        -> drawing.fade(to, time) for name, drawing of @drawings
    move: (dx, dy, time, callback) -> @moveto @x+dx, @y+dy, time, callback
    moveto: (@x, @y, time, callback) -> drawing.moveto(@x, @y, time, callback) for name, drawing of @drawings
    position: (@x, @y)        -> drawing.position(@x, @y) for name, drawing of @drawings

class puyo.sprite.BubbleEye extends puyo.sprite.Drawing
    constructor: (paper, width, height, @dx) -> super(paper, width, height)
    xarg:                   -> 'cx'
    yarg:                   -> 'cy'
    posattrs: (x, y)        -> super(x + @dx, y)
    draw: (@x, @y)          -> @shape = (@paper.ellipse @x+@dx, @y, 0, 0).attr { fill: '#fff', opacity: 0.75, stroke: 'none' }
    blink:                  -> @shape.animate { ry: 0 }, 50, '<', ()=> @shape.animate { ry: @height }, 150, '>'
    appear: (time, callback) -> @shape.animate { rx: @width, ry: @height, opacity: 1 }, 100, 'linear'
    disappear: (time, callback) -> @shape.animate { rx: 0, ry: 0, opacity: 0 }, 100, 'linear'

class puyo.sprite.BubbleGrey extends puyo.sprite.Drawing
    constructor: (paper, width, height) -> super(paper, width, height)
    posattrs: (x, y)        -> super(x-@width/2, y-@height/2)
    draw: (@x, @y)          -> @shape = (@paper.rect @x, @y, 0, 0, 10).attr { fill: @fill(), stroke: 'none' }
    appear: (time, callback) -> @shape.animate { x: @x-@width/2, y: @y-@height/2, width: @width, height: @height, opacity: 1 }, time, callback
    disappear: (time, callback) -> @shape.animate { x: @x, y: @y, width: 0, height: 0, opacity: 0 }, time, callback
    fill:                   -> '270°-#999-#666'

class puyo.sprite.BubbleColor extends puyo.sprite.BubbleGrey
    constructor: (paper, width, height, @hue) -> super(paper, width, height)
    fill:                   -> '270°-hsl('+@hue+',1,0.9)-hsl('+@hue+',1,0.4)'

class puyo.sprite.BubbleFlash extends puyo.sprite.BubbleGrey
    constructor: (paper, width, height) -> super(paper, width, height)
    draw: (x, y)            -> super(x, y) ; @appear 0
    explode: (time, accel)  -> @shape.animate { opacity: 0 }, time, accel, ()=> @shape.remove()
    fill:                   -> '#fff'

class puyo.sprite.Bubble extends puyo.sprite.Sprite
    # conf: width, height, hues
    constructor: (paper, @conf, @color=null) -> super(paper)
    draw: (x, y)          ->
        @drawings.back = if @color? then new puyo.sprite.BubbleColor(@paper, @conf.width, @conf.height, @conf.hues[@color])
        else new puyo.sprite.BubbleGrey(@paper, @conf.width, @conf.height)
        @drawings.eye1 = new puyo.sprite.BubbleEye(@paper, 3, 5, -5)
        @drawings.eye2 = new puyo.sprite.BubbleEye(@paper, 3, 5, 5)
        super(x, y) ; @blink()
    blink:                  -> @drawings.eye1.blink() ; @drawings.eye2.blink() ; setTimeout (()=> @blink()), (Math.random() + 0.1) * 10000
    flash:                  ->
        @drawings.flash = new puyo.sprite.BubbleFlash(@paper, @conf.width, @conf.height)
        @drawings.flash.draw(@x, @y)
        @drawings.flash.explode(350, '>')
    explode:                ->
        @disappear ()=> @remove()
#        explosion = new puyo.sprite.Explosion(@paper, @conf.hues[@color])
#        explosion.draw @x, @y ; explosion.fire()
    appear:                 -> drawing.appear(100) for name, drawing of @drawings
    disappear: (callback)   -> drawing.disappear(100, callback) for name, drawing of @drawings
    fall: (delta, time)     -> @move 0, delta, time, ()=> @flash()

class puyo.sprite.ExplosionBit extends puyo.sprite.Drawing
    constructor: (paper, @hue) -> super paper
    draw: (@x, @y)          -> @shape = (@paper.ellipse @x, @y, 1, 1).attr { fill: 'hsl('+@hue+',1,0.5)', stroke: 'none', opacity: 0.75 }
    fire: (size)            -> [dx, dy] = @vector() ; @shape.animate { cx: @x+dx, cy: @y+dy, rx: size, ry: size, opacity: 0 }, @rand(400, 700), '>'
    vector:                 -> a = @rand(0, 683) / 100 ; d = @rand 50, 150 ; [d * Math.cos(a), d * Math.sin(a)]

class puyo.sprite.Explosion extends puyo.sprite.Sprite
    constructor: (paper, @hue=null) -> super paper
    draw: (x, y)            -> @drawings['b'+i] = new puyo.sprite.ExplosionBit(@paper, @hue) for i in [0..@rand(10, 15)] ; super(x, y)
    fire:                   -> bit.fire(@rand 1, 3) for name, bit of @drawings

class puyo.sprite.Background extends puyo.sprite.Drawing
    constructor: (paper, width, height, @color, @delta, @round) -> super paper, width, height
    draw: (x, y)            -> @shape = (@paper.rect x-@delta, y-@delta, @width+@delta*2, @height+@delta*2, @round).attr { fill: @color, stroke: 'none' }

class puyo.sprite.StageCell extends puyo.sprite.Drawing
    constructor: (paper, width, height, @dx, @dy, @color) -> super paper, width, height
    draw: (x, y)            -> @shape = (@paper.rect x+@dx*@width, y+@dy*@height, @width, @height).attr { fill: @color, stroke: 'none' }

class puyo.sprite.Stage extends puyo.sprite.Sprite
    constructor: (paper, @conf) -> super paper
    focus:                  -> @drawings.outer.attr { fill: @conf.colors.focus }
    blur:                   -> @drawings.outer.attr { fill: @conf.colors.outer }
    draw: (x, y)            ->
        width = @conf.columns * @conf.xscale ; height = @conf.rows * @conf.yscale
        @drawings.outer = new puyo.sprite.Background(@paper, width, height, @conf.colors.outer, 4, 4)
        @drawings.inner = new puyo.sprite.Background(@paper, width, height, @conf.colors.inner, 2, 2)
        for dx in [0...@conf.columns]
            for dy in [0...@conf.rows]
                index = dx + dy * @conf.columns
                color = if index%2 is 0 then @conf.colors.even else @conf.colors.odd
                @drawings[index] = new puyo.sprite.StageCell(@paper, @conf.xscale, @conf.yscale, dx, dy, color)
        super x, y

class puyo.sprite.Provider extends puyo.sprite.Sprite
    constructor: (paper, @conf) -> super paper
    focus:                  -> @drawings.outer.attr { fill: @conf.colors.focus }
    blur:                   -> @drawings.outer.attr { fill: @conf.colors.outer }
    draw: (paper, x, y)     ->
        @drawings.outer = new puyo.sprite.Background(paper, @conf.xscale, @conf.yscale * 2, @conf.colors.outer, 8, 4)
        @drawings.inner = new puyo.sprite.Background(paper, @conf.xscale, @conf.yscale * 2, @conf.colors.inner, 6, 2)
        @drawings.grad  = new puyo.sprite.Background(paper, @conf.xscale, @conf.yscale * 2, '270-'+@conf.colors.grad1+'-'+@conf.colors.grad2, 5, 0)
        super(x, y)
