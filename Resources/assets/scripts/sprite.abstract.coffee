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
    front:                  -> @shape.toFront()
    back:                   -> @shape.toBack()

class puyo.sprite.Sprite extends puyo.sprite.Toolkit
    constructor: (@paper)   -> @drawings = {}
    draw: (@x, @y)          -> drawing.draw(@x, @y) for name, drawing of @drawings
    remove:                 -> drawing.remove() for name, drawing of @drawings
    fade: (to, time)        -> drawing.fade(to, time) for name, drawing of @drawings
    move: (dx, dy, time, callback) -> @moveto @x+dx, @y+dy, time, callback
    moveto: (@x, @y, time, callback) -> drawing.moveto(@x, @y, time, callback) for name, drawing of @drawings
    position: (@x, @y)        -> drawing.position(@x, @y) for name, drawing of @drawings
    front:                  -> drawing.front() for name, drawing of @drawings
    back:                   -> drawing.back() for name, drawing of @drawings




