@puyo = { game: {}, stage: {}, sprite: {} }

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

class puyo.game.Keyboard
    @KEYSLEEP:  100 # keyboard sleep after key press
    @KEYREPEAT: 150 # keyboard key repeat delay if down
    constructor: (@events, @conf) ->
        @pulsar = new gamz.utils.Pulsar((()=> @send()), puyo.game.Keyboard.KEYREPEAT)
        $(document).keydown (event)=> if @listen and @conf.keys[event.keyCode]? then @press   @conf.keys[event.keyCode] ; event.preventDefault()
        $(document).keyup   (event)=> if @listen and @conf.keys[event.keyCode]? then @release @conf.keys[event.keyCode] ; event.preventDefault()
    start:                  -> @listen = true
    stop:                   -> @listen = false ; @pulsar.stop()
    press: (@event)         -> @pulsar.start() ; @send()
    send:                   -> if @listen and @event and not @sleeping then (@events.dispatch @event ; @sleep())
    release: (event)        -> if event is @event then @pulsar.stop()
    sleep:                  -> @sleeping = true ; setTimeout (()=> @sleeping = false), puyo.game.Keyboard.KEYSLEEP
