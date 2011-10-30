@puyo = { game: {}, stage: {}, sprite: {} }

class puyo.game.Reflection
    constructor:            ->
    values: (obj)           -> vals = [] ; vals.push obj[name] for name, val of obj ; vals
    methods: (obj)          ->
        meths = {}
        for name, meth of obj
            if typeof meth is 'function' then meths[name] = meth
        meths

class puyo.game.Events
    @SETUP:    'setup'    # on config changed
    @KEYTURN:  'keyturn'  # on press keyboard turn (cw) key
    @KEYDOWN:  'keydown'  # on press keyboard down key
    @KEYLEFT:  'keyleft'  # on press keyboard left key
    @KEYRIGHT: 'keyright' # on press keyboard right key
    @KEYDROP:  'keydrop'  # on press keyboard fall key
    @BLOCKED:  'blocked'  # on control group blocked (by bounds or bubbles)
    @RESOLVE:  'resolve'  # on control group stage starts resolve
    @FORWARD:  'forward'  # on control group goes forward
    @DROP:     'drop'     # on control group drops bubbles
    @MATCHED:  'matched'  # on stage resolved matching bubbles (explosions)
    @RESOLVED: 'resolved' # on stage resolved strike
    @COMPLETE: 'complete' # on completed stage and still alive!
    constructor:            -> @listeners = {} ; @reflection = new puyo.game.Reflection
    dispatch: (event, args...) -> if @listeners[event]? then listener[0].apply(listener[1], args) for listener in @listeners[event]
    listen: (event, func, subject = @) ->
        if not @listeners[event]? then @listeners[event] = []
        @listeners[event].push [func, subject]
    bind: (obj)             ->
        for name, meth of @reflection.methods obj
            if typeof meth is 'function' and name in @reflection.values puyo.game.Events then @listen name, meth, obj

class puyo.game.Pulsar
    constructor: (@func, @time) ->
    start:                  -> if @started then @unschedule() else @started = true ; @schedule()
    schedule:               -> @timer = setTimeout (()=> @call()), @time
    unschedule:             -> clearTimeout(@timer)
    call:                   -> @schedule() ; if @started then @func.call @
    stop:                   -> @unschedule() ; @started = false
    reset:                  -> @stop() ; @start()

class puyo.game.Keyboard
    @KEYSLEEP:  100 # keyboard sleep after key press
    @KEYREPEAT: 150 # keyboard key repeat delay if down
    constructor: (@events, @conf) ->
        @pulsar = new puyo.game.Pulsar((()=> @send()), puyo.game.Keyboard.KEYREPEAT)
        $(document).keydown (event)=> if @listen and @conf.keys[event.keyCode]? then @press   @conf.keys[event.keyCode] ; event.preventDefault()
        $(document).keyup   (event)=> if @listen and @conf.keys[event.keyCode]? then @release @conf.keys[event.keyCode] ; event.preventDefault()
    start:                  -> @listen = true
    stop:                   -> @listen = false ; @pulsar.stop()
    press: (@event)         -> @pulsar.start() ; @send()
    send:                   -> if @listen and @event and not @sleeping then (@events.dispatch @event ; @sleep())
    release: (event)        -> if event is @event then @pulsar.stop()
    sleep:                  -> @sleeping = true ; setTimeout (()=> @sleeping = false), puyo.game.Keyboard.KEYSLEEP
