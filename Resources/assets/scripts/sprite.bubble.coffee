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
    explode:                -> @disappear ()=> @remove()
    appear:                 -> drawing.appear(100) for name, drawing of @drawings
    disappear: (callback)   -> drawing.disappear(100, callback) for name, drawing of @drawings
    fall: (delta, time)     -> @move 0, delta, time, ()=> @flash()
