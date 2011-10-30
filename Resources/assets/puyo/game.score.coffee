class puyo.game.Score
    constructor: (@container, @events, @conf) ->
        @switcher = new puyo.game.ScoreSwitcher @container
        @combo    = new puyo.game.ScoreCounter @container.find '.combo strong'
        @points   = new puyo.game.ScoreCounter @container.find '.points strong'
        @events.listen puyo.game.Events.MATCHED,  (groups)=> @matched groups
        @events.listen puyo.game.Events.RESOLVED, (matrix)=> @resolved matrix
        @events.listen puyo.game.Events.RESOLVE,  ()=> setTimeout (()=> @combo.reset()), 500
    reset:                  -> @points.reset() ; @switcher.reset()
    strike:                 -> @points.add @conf.score.strike ; setTimeout (() => @switcher.points()), 500
    bubbles: (groups)       -> bubbles = 0 ; bubbles += group.size() for group in groups ; bubbles
    matched: (groups)       -> @combo.add 1 ; @remove @bubbles groups ; if @combo.get() > 1 then @switcher.combo()
    remove: (bubbles)       -> @points.add Math.round bubbles * @conf.score.bubble * (1 + (@combo.get() - 1) * @conf.score.combo)
    resolved: (matrix)      -> (if matrix.length() is 0 then @points.add @combo.get() * @conf.score.clear)

class puyo.game.ScoreCounter
    constructor: (@container) ->
    reset:                  -> @set 0
    get:                    -> parseInt @container.text()
    set: (num)              -> @container.text num ; @container.css('opacity', 1).animate { opacity: 0.5 }, 250
    add: (num)              -> @set @get() + num

class puyo.game.ScoreSwitcher
    constructor: (container) ->
        @current = null
        @containers = { points: container.find('.points'), combo: container.find('.combo') }
    reset:                  -> container.css 'top', '-60px' for name, container of @containers
    points:                 -> @display 'points'
    combo:                  -> @display 'combo'
    display: (name)         -> if name isnt @current then (if @has @current then @hide @current) ; @show name ; @current = name
    show: (name)            -> @containers[name].animate { top: 0, opacity: 1 }, 100
    hide: (name)            -> @containers[name].animate { top: '60px', opacity: 0 }, 100, ()=> @containers[name].css 'top', '-60px'
    has: (name)             -> @containers[name]?
