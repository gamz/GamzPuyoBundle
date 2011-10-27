@puyo =
    core:     {} # core classes package
    engine:   {} # matrix / cell / group package
    stage:    {} # game stage package
    sprite:   {} # svg drawer package
    provider: {} # bubbles provider package
    game:     {} # main controller package

class puyo.core.Reflection
    constructor:            ->
    values: (obj)           -> vals = [] ; vals.push obj[name] for name, val of obj ; vals
    methods: (obj)          ->
        meths = {}
        for name, meth of obj
            if typeof meth is 'function' then meths[name] = meth
        meths

class puyo.core.Events
    @KEYTURN:  'keyturn'  # on press keyboard turn (cw) key
    @KEYDOWN:  'keydown'  # on press keyboard down key
    @KEYLEFT:  'keyleft'  # on press keyboard left key
    @KEYRIGHT: 'keyright' # on press keyboard right key
    @KEYDROP:  'keydrop'  # on press keyboard fall key
    @BLOCKED:  'blocked'  # on control group blocked (by bounds or bubbles)
    @RESOLVE:  'resolve'  # on control group stage starts resolve
    @FORWARD:  'forward'  # on control group goes forward
    @DROP:     'drop'     # on control group drops bubbles
    @FALLED:   'falled'   # on stage resolved falling bubbles
    @MATCHED:  'matched'  # on stage resolved matching bubbles (explosions)
    @RESOLVED: 'resolved' # on stage resolved strike
    @STRIKE:   'strike'   # on provider send group to stage
    @COMPLETE: 'complete' # on completed stage and still alive!
    constructor:            -> @listeners = {} ; @reflection = new puyo.core.Reflection
    dispatch: (event, args...) -> if @listeners[event]? then listener[0].apply(listener[1], args) for listener in @listeners[event]
    listen: (event, func, subject = @) ->
        if not @listeners[event]? then @listeners[event] = []
        @listeners[event].push [func, subject]
    bind: (obj)             ->
        for name, meth of @reflection.methods obj
            if typeof meth is 'function' and name in @reflection.values puyo.core.Events then @listen name, meth, obj

class puyo.core.Pulsar
    constructor: (@func, @time) ->
    start:                  -> if @started then @unschedule() else @started = true ; @schedule()
    schedule:               -> @timer = setTimeout (()=> @call()), @time
    unschedule:             -> clearTimeout(@timer)
    call:                   -> @schedule() ; if @started then @func.call @
    stop:                   -> @unschedule() ; @started = false
    reset:                  -> @stop() ; @start()

class puyo.core.Keyboard
    @KEYSLEEP:  100 # keyboard sleep after key press
    @KEYREPEAT: 150 # keyboard key repeat delay if down
    constructor: (@events, @conf) ->
        @pulsar = new puyo.core.Pulsar((()=> @send()), puyo.core.Keyboard.KEYREPEAT)
        $(document).keydown (event)=> if @listen and @conf[event.keyCode]? then @press   @conf[event.keyCode] ; event.preventDefault()
        $(document).keyup   (event)=> if @listen and @conf[event.keyCode]? then @release @conf[event.keyCode] ; event.preventDefault()
    start:                  -> @listen = true
    stop:                   -> @listen = false ; @pulsar.stop()
    press: (@event)         -> @pulsar.start() ; @send()
    send:                   -> if @listen and @event and not @sleeping then (@events.dispatch @event ; @sleep())
    release: (event)        -> if event is @event then @pulsar.stop()
    sleep:                  -> @sleeping = true ; setTimeout (()=> @sleeping = false), puyo.core.Keyboard.KEYSLEEP
