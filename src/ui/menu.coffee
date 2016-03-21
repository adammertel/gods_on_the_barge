define 'Menu', ['Ui', 'MiniMap', 'Text', 'Button', 'OverviewPanel', 'IslandsPanel', 'CultPanel', 'ShipsPanel'], (Ui, MiniMap, Text, Button, OverviewPanel, IslandsPanel, CultPanel, ShipsPanel) ->
  class Menu extends Ui
    constructor: () ->
      h = 150
      super 'menu', 0, app.state.view.h - h, app.state.view.w, h
      @mm = new MiniMap()
      @panelW = 80
      @panels = []

      @init()
      return

    init: () ->
      bs = _.clone @buttonStyle
      #@registerText 'datum', {x: @w - @mm.w - 200, y: @h - 25 + @y}, app.time.getDatumLabel
      gameSpeed = app.time.state.timeSpeed

      s = (@h-1)/6
      m = 2
      x =  @w - @mm.w - s + 1
      y = @h + @y + 1
      @registerButton 'speed0', {x: x, y: y - 6*s, w: s, h: s}, @makeStaticText.bind(@, '||'), @changeSpeed0.bind(@), bs, gameSpeed == 0
      @registerButton 'speed1', {x: x, y: y - 5*s, w: s, h: s}, @makeStaticText.bind(@, '>'), @changeSpeed1.bind(@), bs, gameSpeed == 1
      @registerButton 'speed2', {x: x, y: y - 4*s, w: s, h: s}, @makeStaticText.bind(@, '>>'), @changeSpeed2.bind(@), bs, gameSpeed == 2
      @registerButton 'speed3', {x: x, y: y - 3*s, w: s, h: s}, @makeStaticText.bind(@, '>>>'), @changeSpeed3.bind(@), bs, gameSpeed == 3

      @registerButton 'zoomIn', {x: x, y: y - 2*s, w: s, h: s}, @makeStaticText.bind(@, '+'), @zoomIn.bind(@), bs, false
      @registerButton 'zoomOut', {x: x, y: y - s, w: s, h: s}, @makeStaticText.bind(@, '-'), @zoomOut.bind(@), bs, false

      @registerPanel new OverviewPanel(@)
      @registerPanel new IslandsPanel(@)
      @registerPanel new CultPanel(@)
      @registerPanel new ShipsPanel(@)

      lw = 2
      buttonH = (@h/@panels.length) - 1/2# - lw/4 * @panels.length

      @activePanel = 'Overview'
      _.each @panels, (panel, p) =>
        label = panel.label
        console.log label == @activePanel
        @registerButton 'panel' + label, {x: lw/2, y: @y + 1.5*lw + buttonH * p, w: @panelW, h: buttonH}, @makeStaticText.bind(@, label), @changeActivePanel.bind(@, label), bs, @activePanel == label

      return

    registerPanel: (panel) ->
      @panels.push panel

    getActivePanel: ->
      _.find @panels, (panel) =>
        panel.label == @activePanel

    changeActivePanel: (panelLabel)->
      @activePanel = panelLabel
      self = @
      _.each @panels, (panel, p) =>
        if panel.label == self.activePanel
          self.getButton('panel' + panel.label).activate()
        else
          self.getButton('panel' + panel.label).deactivate()
      return

    changeSpeed0: () ->
      app.time.changeGameSpeed 0
      @deactivateSpeedButtons()
      @getButton('speed0').activate()
      return

    changeSpeed1: () ->
      app.time.changeGameSpeed 1
      @deactivateSpeedButtons()
      @getButton('speed1').activate()
      return

    changeSpeed2: () ->
      app.time.changeGameSpeed 2
      @deactivateSpeedButtons()
      @getButton('speed2').activate()
      return

    changeSpeed3: () ->
      app.time.changeGameSpeed 3
      @deactivateSpeedButtons()
      @getButton('speed3').activate()
      return

    deactivateSpeedButtons: () ->
      speedButtons = ['speed0', 'speed1', 'speed2', 'speed3']
      _.each speedButtons, (button) =>
        @getButton(button).deactivate()
      return

    zoomOut: () ->
      app.zoomOut()
      return

    zoomIn: () ->
      app.zoomIn()
      return

    drawActivePanel: () ->
      @getActivePanel().draw()
      return

    draw: () ->
      super()
      @drawActivePanel()
      @mm.draw()
      return
