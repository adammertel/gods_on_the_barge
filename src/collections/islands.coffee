define 'Islands', ['Base', 'Collection', 'Island', 'Buildings', 'Season', 'Colors'], (Base, Collection, Island, Buildings, Season, Colors) ->
  class Islands extends Collection
    constructor: (data) ->
      @name = 'islands'
      @distanceFn = Base.distanceFromPolygon
      super data

      app.registerNewWeekAction @starvingPeople.bind @
      app.registerNewWeekAction @feedPeople.bind @
      app.registerNewSeasonAction @populationGrow.bind @
      app.registerNewSeasonAction @harvest.bind @
      app.registerNewSeasonAction @religiousConversion.bind @
      return

    setFrameFunctions: ->
      @canvas.registerFrameFunction @mouseConflict.bind @
      return

    # self-driven religious conversion
    religiousConversion: ->
      console.log 'making self-driven religious conversion'
      minStable = app.game.state.religion.minDistributionToStable
      minGrow = app.game.state.religion.minDistributionToGrow
      flow = app.game.state.religion.flow

      for island in @geometries
        onePersonDistribution = 1 / island.state.population
        onePercentPeople = 1 / onePersonDistribution

        for cult, cultName of island.state.religion
          if cult.distribution < minStable and cult.distribution != 0
            numberOfConverting = Base.round(Math.random() * flow * (minStable - cult.distribution) * onePercentPeople)
            console.log cultName, ' is falling', numberOfConverting

            for n in _.range numberOfConverting
              newReligion = app.game.getRandomPersonReligionFromIsland(island)
              if newReligion != cultName
                app.game.convertPerson island, cultName, newReligion, onePersonDistribution

          else if cult.distribution > minGrow
            numberOfConverting = Base.round(Math.random() * flow * (cult.distribution - minGrow) * onePersonDistribution)
            console.log cultName, ' is growing', numberOfConverting

            for n in _.range numberOfConverting
              oldReligion = app.game.getRandomPersonReligionFromIsland(island)
              if oldReligion != cultName
                app.game.convertPerson island, oldReligion, cultName, onePersonDistribution
      return

    distanceCoefficient: (distance, maxDistance) ->
      1 - (distance / maxDistance)

    hungryCoefficient: (island) ->
      1 - island.state.grain / island.state.maxGrain

    attractivityCoefficient: (island) ->
      attractivity = 0

      if island.state.buildings.amphiteater
        attractivity += app.game.state.islands.buildingAmphitheaterAttractivityBonus
      if island.state.event
        if island.state.event.name == 'festival'
          attractivity += app.game.state.islands.eventFestivalAttractivityBonus

      density = island.state.population/island.state.area

      # 2000~ is a density of Delos
      densityCoefficient = (density / 2000) * 0.5
      0.3 + attractivity + densityCoefficient

    tradeAttractivity: (distance, maxDistance, islandName) ->
      island = @getIslandByName(islandName)
      @distanceCoefficient(distance, maxDistance) * @hungryCoefficient(island) * @attractivityCoefficient(island)

    starvingPeople: ->
      for island in @geometries
        if island.state.starving > 0
          starvingRateBase = app.game.state.islands.starvingDeathRate
          starvingRate = if !island.state.buildings[Buildings['HOSPITAL']] then starvingRateBase else starvingRateBase/2
          diedFromStarving = Math.ceil  * island.state.starving
          island.state.starving = _.clamp(island.state.starving - diedFromStarving, 0, island.state.starving)
          island.state.population = _.clamp(island.state.population - diedFromStarving, 0, island.state.population)
      return

    feedPeople: ->
      for island in @geometries
        consumption = Base.round app.game.state.islands.citizenConsumption * island.state.population
        island.state.grain -= consumption

        # people not getting their food
        if island.state.grain < 0
          starvingChances = _.random 0.2, 0.8 # not everyone without food is starving
          proportionOfStarving = Base.round (Math.abs(island.state.grain) / consumption) * starvingChances
          console.log 'people starting to starve', island.state.name, proportionOfStarving
          island.state.starving = _.max([island.state.starving, proportionOfStarving * island.state.population])
          island.state.grain = 0
        else
          island.state.starving = 0

      return

    missingGrain: (island) ->
      island.state.maxGrain - island.state.grain

    populationGrow: ->
      for island in @geometries
        if island.state.starving == 0
          growthRateBase = app.game.state.islands.growth
          growthRate = if !island.state.buildings[Buildings['HOSPITAL']] then growthRateBase else growthRateBase * 2
          growth = Base.round growthRate * island.state.population
          island.state.population += growth
      return

    harvest: ->
      config = app.game.state.islands

      app.game.state.islands.eventFestivalAttractivityBonus
      if app.time.state.season == Season[1] or app.time.state.season == Season[3]
        for island in @geometries
          rainfall = island.state.rainfall

          if rainfall > config.idealRainfallMin and rainfall < config.idealRainfallMax
            rainfallCoefficient = 1
          else if rainfall > config.criticalRainfallMax or rainfall < config.criticalRainfallMin
            rainfallCoefficient = 0.1
          else if rainfall < config.idealRainfallMin
            rainfallCoefficient = rainfall/config.idealRainfallMin - 0.1
          else if rainfall > config.idealRainfallMax
            rainfallCoefficient = config.idealRainfallMax/rainfall - 0.1

          production = config.productionPerArea
          if island.state.buildings[Buildings.GRANARY]
            production *= config.productionGranaryBonus
          if island.state.event
            if island.state.event.name == 'infestation'
              production -= config.eventInfestationHarvestMinus

          harvested = Base.round(island.state.area * production * 26 * rainfallCoefficient)
          island.state.harvestHistory.push harvested
          @addGrainToIsland island, harvested
          island.state.rainfall = 0
      return

    addGrainToIsland: (island, quantity) ->
      island.state.grain = _.clamp(island.state.grain + +quantity, 0, island.state.maxGrain)
      return

    registerGeometries: ->
      for islandName, island of @data
        coords = []
        if island.coordinates
          for coord, c in island.coordinates[0]
            coords.push app.coordinateToMap {lon: coord[0], lat: coord[1]}
          @addGeometry new Island(coords, @ctx, island)
      return

    deactivateIslands: ->
      for island in @geometries
        island.state.active = false
      return

    activateIsland: (island)->
      @deactivateIslands()
      island.state.active = true
      return

    activateIslandByName: (name) ->
      @deactivateIslands()
      @getIslandByName(name).state.active = true
      return

    getIslandByName: (name) ->
      _.find @geometries, (island) ->
        island.data.name == name

    hasIslandBuilding: (islandName, building) ->
      island = @getIslandByName islandName
      island.state.buildings[building]

    build: (cult, islandName, buildingLabel) ->
      if !@hasIslandBuilding(islandName, buildingLabel)
        building = _.find(_.values(Buildings), {'name':buildingLabel})

        if app.game.spendGold cult, building.price
          island = @getIslandByName islandName
          island.state.buildings[building.name] = true
      return

    getActiveIsland: ->
      activeIsland = false
      for island in @geometries
        if island.state.active
          activeIsland = island
      activeIsland

    activeteIslandByClick: (island) ->
      @activateIsland(island)
      app.menu.changeActivePanel 'Islands'
      app.menu.getActivePanel().changeActiveIsland(island.state.name)
      return

    mouseConflict: ->
      if !app.isInfoWindowOpen()
        if app.isClickedMap() and !app.isMapDragging()
          for island in @geometries
            if island
                if island.mouseConflict()
                  @activeteIslandByClick island

    draw: ->
      for island in @geometries
        if island
          dominantCult = island.getDominantCult()
          @ctx.fillStyle = Colors['CULT' + _.upperCase dominantCult ]
          @ctx.beginPath()
          island.draw()
          @ctx.closePath()
          @ctx.fill()

      activeIsland = @getActiveIsland()
      if activeIsland
        activeIsland.highlight()
      return
