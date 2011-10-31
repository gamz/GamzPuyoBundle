@layout = {}

class layout.Title
    constructor: (@query)       -> @fix(new layout.TitleWrapper(@query)) ; @listen(new layout.TitleRainbow(query))
    fix: (@wrapper)             -> @wrapper.fix()
    listen: (@rainbow)          -> @query.mouseenter ()=> @rainbow.start()

class layout.TitleWrapper
    constructor: (@query)       -> @text = @query.text() ; @query.empty() ; @query.html @wrap @text
    wrap:                       -> html = '' ; html += '<span>'+letter+'</span>' for letter in @text ; html
    fix:                        -> @compute() ; @position child, @left index for child, index in @query.children()
    compute:                    -> @offset = @query.width() ; @offset -= $(child).width() for child in @query.children()
    left: (index)               -> left = (@offset/4)*index ; left += $(@query.children()[i]).width() for i in [0...index] ; left
    position: (item, left)      -> $(item).css { position: 'absolute', top: 0, left: left+'px' }

class layout.TitleRainbow
    constructor: (@query)       -> @letters = @query.children() ; @length = @letters.length ; @busy = false
    start:                      -> if not @busy then @next 0 ; @busy = true
    next: (index)               -> if index <= @length then @apply index else @busy = false
    apply: (index)              -> @colorize index ; @uncolorize index-1 ; setTimeout (()=> @next index+1), 50
    colorize: (index)           -> if 0 <= index < @length then $(@query.children()[index]).addClass 'color'+(index+1)
    uncolorize: (index)         -> if 0 <= index < @length then $(@query.children()[index]).removeClass 'color'+(index+1)

$ -> new layout.Title $ 'header h1'
