Mark = require 'models/mark'
{Module, Events} = require 'spine'
Kinetic = window.Kinetic
$ = require 'jqueryify'
style = require 'lib/style'

doc = $(document)
body = $(document.body)

class MarkingTool extends Module
  @extend Events
  @include Events

  @mark: Mark

  mark: null
  stage: null

  events: null

  cursors: null

  targetMin: if 'Touch' of window then 15 else 10

  layer: null

  constructor: (params = {}) ->
    @[property] = value for own property, value of params when property of @
    throw new Error 'Marking tool needs a stage' unless @stage?

    @mark ?= new @constructor.mark params
    @mark.bind 'change', @render
    @mark.bind 'destroy', @remove

    @layer = new Kinetic.Layer
    @stage.add @layer

    # Methods named "on <event-type> <shape-name (optional)>" will be
    # automatically handled. "Drag" is special and handled on mouse down.
    @layer.on 'mousedown touchstart', @handleLayerEvent

    if @cursors?
      @layer.on 'mousemove', ({shape}) =>
        cursor = @cursors[shape.getName()] || ''
        body.css {cursor}

      @layer.on 'mouseout', =>
        body.css cursor: ''

    # Then create dots and lines or whatever.

  onFirstClick: (e) ->
    # Modify the mark.

  onFirstDrag: (e) ->
    # Modify the mark.

  handleLayerEvent: (e) =>
    type = e.type
    name = e.shape?.getName()

    # TODO: Probably not this.
    type = switch
      when 'touchstart' then 'mousedown'
      when 'touchmove' then 'mousemove'
      when 'touchend' then 'mouseup'
      else type

    @["on #{type}"]?.call @, arguments...
    @["on #{type} #{name}"]?.call @, arguments...

    if type in ['mousedown', 'touchstart']
      onDrag = @["on drag"]
      onNamedDrag = @["on drag #{name}"]

      if typeof onDrag is 'function'
        dragAttached = true
        doc.on 'mousemove.drag touchmove.drag', => onDrag.call @, arguments...

      if name and typeof onNamedDrag is 'function'
        dragAttached = true
        doc.on 'mousemove.drag touchmove.drag', => onNamedDrag.call @, arguments...

      if dragAttached
        doc.one 'mouseup touchend', => doc.off '.drag'

  'on mousedown': (e) ->
    e.stopPropagation() # TODO: Prevent default instead (broke on touch?).
    @select()

  mouseDownPos: null
  handleDrag: (e, property) =>
    {x, y} = @mouseOffset e

    if @mouseDownPos
      x = @mouseDownPos.x + x
      y = @mouseDownPos.y + y

      @mark.set property, {x, y}

    else
      @mouseDownPos =
        x: (@mark[property].x || @mark[property][0]) - x
        y: (@mark[property].y || @mark[property][1]) - y

      $(document).one 'mouseup touchend', =>
        @mouseDownPos = null

  render: =>
    # Draw dots and lines or whatever.
    @layer.draw()

  select: ->
    @layer.setOpacity 1
    @trigger 'select'
    @layer.moveToTop()
    @layer.draw()

  deselect: ->
    @layer.setOpacity 0.5
    @trigger 'deselect'
    @layer.draw()

  remove: =>
    @trigger 'remove'
    @layer.off 'mousedown mousemove mouseup click'
    @layer.remove()

  isComplete: ->
    true

  # Get event position relative to the container.
  mouseOffset: (e) ->
    e = e.originalEvent if 'originalEvent' of e
    e = e.touches[0] if 'touches' of e
    {left, top} = $(@stage.getContainer()).offset()
    x: e.pageX - left
    y: e.pageY - top

  createTarget: (shape) ->
    naturalTarget = if 'getOuterRadius' of shape
      shape.getOuterRadius() + 5
    else if 'getRadius' of shape
      shape.getRadius() + 5

    targetRadius = Math.max @targetMin, naturalTarget

    group = new Kinetic.Group
    target = new Kinetic.Circle $.extend {name: shape.getName(), radius: targetRadius}, style.target
    group.add target
    group.add shape
    group

module.exports = MarkingTool
