class puyo.engine.Matrix
    constructor: (@width, @height) -> @empty()
    empty:                  -> @cells = {}
    length:                 -> length = 0 ; length += 1 for cell of @cells ; length
    id: (x, y)              -> x+'-'+y
    available: (x, y)       -> not @cells[@id x, y]? and 0 <= x < @width and 0 <= y < @height
    get: (x, y)             -> @cells[@id x, y]
    add: (cell)             -> @cells[@id cell.x, cell.y] = cell
    pop: (x, y)             -> cell = @get x, y ; @remove x, y ; cell
    remove: (x, y)          -> delete @cells[@id x, y]
    move: (cell, x, y)      -> @cells[@id x, y] = @pop cell.x, cell.y

class puyo.engine.Cell
    constructor: (@matrix, @x, @y) -> @matrix?.add @
    neighbor: (dx, dy)      -> @matrix?.get @x+dx, @y+dy
    neighbors:              -> [(@neighbor 0, 1), (@neighbor 1, 0), (@neighbor 0, -1), (@neighbor -1, 0)]
    remove:                 -> @matrix?.remove @x, @y
    move: (dx, dy)          -> @matrix.move @, @x+dx, @y+dy ; @x=@x+dx ; @y=@y+dy
    fall: (dy)              -> @matrix.move @, @x, @y+dy ; @y=@y+dy
    test: (dx, dy)          -> @matrix.available @x+dx, @y+dy
    equals: (cell)          -> if cell? then (@x is cell.x) and (@y is cell.y) else false

class puyo.engine.Group
    constructor: (@root)    -> @cells = [] ; @add @root
    add: (cell)             -> if not @has cell then (@cells.push cell ; true) else false
    has: (cell)             -> cell in @cells
    size:                   -> @cells.length

class puyo.engine.FallingGroup extends puyo.engine.Group
    constructor: (root)     -> super(root) ; @discover @root ; @start() ; @fall()
    discover: (from)        -> cell = from.neighbor(0, -1) ; if cell? then (@add cell ; @discover cell)
    start:                  -> @delta = 0 ; @check dy for dy in [1...@root.matrix.height-@root.y]
    check: (dy)             -> if @root.neighbor 0, dy then false else @delta += 1
    fall:                   -> cell.fall(@delta) for cell in @cells

class puyo.engine.MatchingGroup extends puyo.engine.Group
    contructor: (root)      -> super(root) ; @discover @root
    discover: (cell)        -> @check(cell) for cell in cell.neighbors()
    check: (cell)           -> if cell? and @root.match cell then @add cell
    add: (cell)             -> if super(cell) then @discover cell

class puyo.engine.ControlGroup
    @NORTH: 0
    @EAST:  1
    @SOUTH: 2
    @WEST:  3
    constructor:            -> @moves =
        left:  new puyo.engine.ControlLeft()
        right: new puyo.engine.ControlRight()
        down:  new puyo.engine.ControlDown()
        turn:  new puyo.engine.ControlTurn()
    bind: (@c1, @c2)        ->
    unbind:                 -> [@c1, @c2] = [null, null]
    invert:                 -> [@c1, @c2] = [@c2, @c1]
    move: (move)            -> if @moves[move].test @ then (@moves[move].apply @ ; true) else false

class puyo.engine.ControlTrans
    test: (group, dx, dy)   -> [a = group.c1.test(dx, dy, group.c2), b = group.c2.test(dx, dy, group.c1)] ; a and b

class puyo.engine.ControlDown extends puyo.engine.ControlTrans
    test: (group)           -> switch group.orient
        when puyo.engine.ControlGroup.SOUTH then group.c2.test 0, 1
        when puyo.engine.ControlGroup.NORTH then group.c1.test 0, 1
        else super(group, 0, 1)
    apply: (group)          -> switch group.orient
        when puyo.engine.ControlGroup.SOUTH then group.c2.move 0, 1 ; group.c1.move 0, 1
        else                        group.c1.move 0, 1 ; group.c2.move 0, 1

class puyo.engine.ControlLeft extends puyo.engine.ControlTrans
    test: (group)           -> switch group.orient
        when puyo.engine.ControlGroup.WEST then group.c2.test -1, 0
        when puyo.engine.ControlGroup.EAST then group.c1.test -1, 0
        else super(group, -1, 0)
    apply: (group)          -> switch group.orient
        when puyo.engine.ControlGroup.WEST then group.c2.move -1, 0 ; group.c1.move -1, 0
        else                       group.c1.move -1, 0 ; group.c2.move -1, 0

class puyo.engine.ControlRight extends puyo.engine.ControlTrans
    test: (group)           -> switch group.orient
        when puyo.engine.ControlGroup.EAST then group.c2.test 1, 0
        when puyo.engine.ControlGroup.WEST then group.c1.test 1, 0
        else super(group, 1, 0)
    apply: (group)          -> switch group.orient
        when puyo.engine.ControlGroup.EAST then group.c2.move 1, 0 ; group.c1.move 1, 0
        else                       group.c1.move 1, 0 ; group.c2.move 1, 0

class puyo.engine.ControlTurn
    delta: (group)          -> switch group.orient
        when puyo.engine.ControlGroup.NORTH then [ 1,  1]
        when puyo.engine.ControlGroup.EAST  then [-1,  1]
        when puyo.engine.ControlGroup.SOUTH then [-1, -1]
        when puyo.engine.ControlGroup.WEST  then [ 1, -1]
    test: (group)           -> [dx, dy] = @delta group ; group.c2.test dx, dy
    apply: (group)          -> [dx, dy] = @delta group ; group.c2.move dx, dy ; group.orient = (group.orient + 1) % 4
