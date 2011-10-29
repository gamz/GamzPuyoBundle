class puyo.sprite.Background extends puyo.sprite.Drawing
    constructor: (paper, width, height, @color, @delta, @round) -> super paper, width, height
    draw: (x, y)            -> @shape = (@paper.rect x-@delta, y-@delta, @width+@delta*2, @height+@delta*2, @round).attr { fill: @color, stroke: 'none' }

class puyo.sprite.Provider extends puyo.sprite.Sprite
    constructor: (paper, @conf) -> super paper
    focus:                      -> @drawings.outer.attr { fill: @conf.colors.focus }
    blur:                       -> @drawings.outer.attr { fill: @conf.colors.outer }
    draw: (paper, x, y)         ->
        @drawings.outer = new puyo.sprite.Background(paper, @conf.xscale, @conf.yscale * 2, @conf.colors.outer, 8, 4)
        @drawings.inner = new puyo.sprite.Background(paper, @conf.xscale, @conf.yscale * 2, @conf.colors.inner, 6, 2)
        @drawings.grad  = new puyo.sprite.Background(paper, @conf.xscale, @conf.yscale * 2, '270-'+@conf.colors.grad1+'-'+@conf.colors.grad2, 5, 0)
        super(x, y)

class puyo.sprite.BoardCell extends puyo.sprite.Drawing
    constructor: (paper, width, height, @dx, @dy, @color) -> super paper, width, height
    draw: (x, y)            -> @shape = (@paper.rect x+@dx*@width, y+@dy*@height, @width, @height).attr { fill: @color, stroke: 'none' }

class puyo.sprite.BoardCursor extends puyo.sprite.Drawing
    draw: (x, y)            -> @shape = (@paper.rect @x-@width/2, @y-@height/2, @width, @height).attr { fill: 'rgba(255,255,255,0.2)', stroke: 'none' }

class puyo.sprite.Board extends puyo.sprite.Sprite
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
                @drawings[index] = new puyo.sprite.BoardCell(@paper, @conf.xscale, @conf.yscale, dx, dy, color)
        super x, y
        @drawings.inner.back()
        @drawings.outer.back()
