define 'Cursor', ['App', 'Base'], (app, Base) ->
  class Cursor
    constructor: ->
      @setCanvas()
      coords = [[0,0], [0,10], [3,7], [8,12], [9,11], [4,6], [8,3]]
      @path = new Path2D Base.buildPathString coords, true

    setCanvas: ->
      @canvas = app.getCanvasById('over')
      @ctx = @canvas.ctx
      @canvas.registerDrawFunction @draw.bind(@)

    getPosition: ->
      {x: (@x - (app.state.position.x)) * app.state.zoom, y: (@y - (app.state.position.y)) * app.state.zoom}

    draw: ->
      mp = app.state.controls.mousePosition
      app.drawPath @ctx, @path, mp, 1, 0, 'black', false, false
      return
