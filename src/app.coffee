define 'App', ['Base', 'Ship'], (Base, Ship) ->
  window.app =
    state:
      game:
        style:
          background-color:
        time:
          timeSpeed: 1
          year: 400
          month: 1
          day: 1
          frameInterval: 0.01 # 0.001
      fps: []
      lastTimeLoop: null
      view:
        h: 700
        w: 800
      map:
        h: 0
        w: 0
      zoom: 0.5
      zoomStep: 0.1
      minZoom: 0.3
      maxZoom: 10
      position:
        x: 0
        y: 300
      controls:
        up: false
        down: false
        right: false
        left: false
        mouseClicked: false
        mouseClickedPosition: {}
        mousePosition: {}
      pxDensity: 400
      boundingCoordinates:
        n: 41
        s: 30
        e: 32
        w: 22

    collections: []

    # links
    getPath: (start, end) ->
      alt1 = start + '-' + end
      alt2 = end + '-' + start
      path = false

      if @linksData[alt1]
        path = @linksData[alt1]
      else if @linksData[alt2]
        pathData = _.clone @linksData[alt2]
        path = _.reverse pathData
      path

    registerCollection: (collection, z) ->
      @collections.push {'collection': collection, 'z': z}
      return

    getCollection: (collectionName) ->
      foundCollection = false
      _.each @collections, (collection, c) ->
        if collection.collection.name == collectionName
          foundCollection = collection.collection
      foundCollection

    newMonth: ->
      app.getCollection('ships').createShip()
      return

    changeTime: ->
      lastFrame = _.clone @state.game.time.month
      @state.game.time.month += @state.game.time.timeSpeed * @state.game.time.frameInterval
      if _.floor(lastFrame) != _.floor(@state.game.time.month)
        console.log 'new month'
        @newMonth()

      if @state.game.time.month > 13
        console.log 'new year'
        @state.game.time.year -= 1
        @state.game.time.month = 1
        @newYear()
      return

    newYear: ->
      app.getCollection('ships').createShip()
      return

    draw: ->
      @changeTime()

      _.each _.orderBy(@collections, 'z'), (collection, c) =>
        collection.collection.draw()

      @drawBorders()
      @writeInfo()
      return

    clear: ->
      @ctx.clearRect 0, 0, @state.view.w, @state.view.h
      return

    loop: ->
      now = new Date()
      nowValue = now.valueOf()
      if app.state.lastTimeLoop
        app.state.fps.push parseInt(1/(nowValue - app.state.lastTimeLoop) * 1000)
      app.state.fps = _.takeRight app.state.fps, 30
      app.state.lastTimeLoop = nowValue

      app.clear()
      app.draw()
      app.menu.draw()
      app.cursor.draw()
      app.checkPosition()
      app.setInteractions()

      window.requestAnimationFrame app.loop
      return

    calculateMap: ->
      c = @state.boundingCoordinates
      @state.map.h = (c.n - c.s) * @state.pxDensity
      @state.map.w = (c.e - c.w) * @state.pxDensity
      @state.pxkm = @state.pxDensity/110
      return

    goTo: (coordinate) ->
      @state.position.x = coordinate.x
      @state.position.y = coordinate.y
      return

    writeInfo: ->
      @ctx.fillStyle = 'black'
      @ctx.fillText 'x: ' + @state.position.x + ' y: ' + @state.position.y + ' zoom: ' + @state.zoom, 10, 10
      @ctx.fillText 'fps : ' + parseInt(_.mean(@state.fps)), 10, 40
      return

    getClicked: ()->
      clicked = falsecd
      for g in @state.geometries
        if g.isClicked()
          clicked = g
      clicked

    getMousePosition: ->
      {x: @state.position.x, y: @state.position.y}

    isPointVisible: (point) ->
      point.x < @state.view.w and point.x > 0 and point.y < @state.view.h and point.y > 0

    drawBorders: ->
      @ctx.lineWidth = 5
      @ctx.strokeStyle = 'black'
      @ctx.strokeRect (0 - (@state.position.x)) * @state.zoom, (0 - (@state.position.y)) * @state.zoom, @state.map.w * @state.zoom, @state.map.h * @state.zoom
      # @ctx.lineWidth = 5
      # @ctx.strokeStyle = 'black'
      # @ctx.strokeRect 0, 0, @state.view.w, @state.view.h
      return

    coordinateToMap: (c) ->
      x: (c.lon - @state.boundingCoordinates.w) * @state.pxDensity
      y: @state.map.h - (c.lat - @state.boundingCoordinates.s) * @state.pxDensity

    pointToUTM: (point) ->


    setInteractions: () ->
      if @menu.mm.mouseConflict() and app.state.controls.mouseClicked
        @menu.mm.mouseClick()
        return
      # else
      #   for g in @state.geometries
      #     conflict = g.mouseConflict()
      #     g.over = conflict
      #     if app.state.controls.mouseClicked
      #       g.clicked = conflict
      #     else
      #       g.clicked = false

    coordinatesToView: (coords) ->
      _.each coords, (coord, c) =>
        @coordinateToView coord

    coordinateToView: (c) ->
      x: (c.x - (@state.position.x)) * @state.zoom,
      y: (c.y - (@state.position.y)) * @state.zoom

    checkPosition: ->
      step = 5
      p = @state.position
      if @state.controls.left
        app.setNewXPosition p.x - step
      if @state.controls.up
        app.setNewYPosition p.y - step
      if @state.controls.right
        app.setNewXPosition p.x + step
      if @state.controls.down
        app.setNewYPosition p.y + step
      return

    setNewXPosition: (newX) ->
      @state.position.x = _.clamp(newX, 0, @state.map.w - (@state.view.w / @state.zoom))
      return

    setNewYPosition: (newY) ->
      @state.position.y = _.clamp(newY, 0, @state.map.h - (@state.view.h / @state.zoom))
      return

    mouseOverMap: () ->
      !@menu.mouseConflict()

    zoomIn: ->
      if @state.zoom < @state.maxZoom
        w = @state.view.w
        h = @state.view.h
        s = @state.zoomStep
        z = @state.zoom
        @setNewXPosition @state.position.x + (w / z - (w / (z + s))) / 2
        @setNewYPosition @state.position.y + (w / z - (w / (z + s))) / 2
        @state.zoom = @state.zoom + s
      return

    zoomOut: ->
      if @state.zoom > @state.minZoom
        w = @state.view.w
        h = @state.view.h
        s = @state.zoomStep
        z = @state.zoom
        @setNewXPosition @state.position.x + (w / z - (w / (z - s))) / 2
        @setNewYPosition @state.position.y + (w / z - (w / (z - s))) / 2
        @state.zoom = @state.zoom - s
      return
