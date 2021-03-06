MarkingTool = require 'controllers/marking_tool'
EllipseMark = require 'models/ellipse_mark'
Kinetic = window.Kinetic
$ = window.jQuery
style = require 'lib/style'

class EillipseTool extends MarkingTool
  @mark: EllipseMark

  radiusHandle1: null
  radiusHandle2: null
  bounding: null

  cursors: style.cursors

  constructor: ->
    super

    @radiusHandle1 = new Kinetic.Circle $.extend {name: 'radius1'}, style.circle
    @radiusHandle2 = new Kinetic.Circle $.extend {name: 'radius2'}, style.circle
    @radiusPath = new Kinetic.Path style.dash
    @bounding = new Kinetic.Ellipse $.extend {name: 'bounding', x: 0, y: 0}, style.line

    @group = new Kinetic.Group

    @group.add @radiusHandle1
    @group.add @radiusHandle2
    @group.add @radiusPath
    @group.add @bounding
    @radiusHandle1.moveToTop()
    @radiusHandle2.moveToTop()
    @layer.add @group

  onFirstClick: (e) ->
    @mark.set center: @mouseOffset e
    super

  onFirstDrag: (e) ->
    @['on drag radius1'] e
    @mark.set radius2: @mark.radius1 * 0.75
    super

  'on drag radius1': (e) =>
    {angle, radius} = @dragRadiusHandle e
    @mark.set {angle, radius1: radius}

    $(document).one 'mouseup touchend', =>
      @trigger 'drag-radius1'

  'on drag radius2': (e) =>
    {angle, radius} = @dragRadiusHandle e
    angle += 90
    @mark.set {angle, radius2: radius}

    $(document).one 'mouseup touchend', =>
      @trigger 'drag-radius2'

  dragRadiusHandle: (e) ->
    {x, y} = @mouseOffset e

    deltaX = x - @mark.center.x
    deltaY = y - @mark.center.y
    angle = Math.atan2(deltaY, deltaX) * (180 / Math.PI)

    aSquared = Math.pow x - @mark.center.x, 2
    bSquared = Math.pow y - @mark.center.y, 2
    radius = Math.sqrt aSquared + bSquared

    {angle, radius}

  'on drag bounding': (e) =>
    @handleDrag e, 'center'

  render: ->
    @radiusHandle1.setPosition @mark.radius1, 0
    @radiusHandle2.setPosition 0, -@mark.radius2
    @bounding.setRadius @mark.radius1, @mark.radius2
    @radiusPath.setData """
      M 0 #{-@mark.radius2}
      L 0 0
      L #{@mark.radius1} 0
    """

    @group.setPosition @mark.center
    @group.setRotationDeg @mark.angle

    @deleteButton.css
      left: "#{@mark.center.x}px"
      top: "#{@mark.center.y}px"

    super

  select: ->
    @radiusHandle1.show()
    @radiusHandle2.show()
    @radiusPath.show()
    super

  deselect: ->
    @radiusHandle1.hide()
    @radiusHandle2.hide()
    @radiusPath.hide()
    super

module.exports = EillipseTool
