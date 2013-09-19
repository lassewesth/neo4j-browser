'use strict'

clickcancel = ->
  cc = (selection) ->

    # euclidean distance
    dist = (a, b) ->
      Math.sqrt Math.pow(a[0] - b[0], 2), Math.pow(a[1] - b[1], 2)
    down = undefined
    tolerance = 5
    last = undefined
    wait = null
    selection.on "mousedown", ->
      d3.event.target.__data__.fixed = yes
      down = d3.mouse(document.body)
      last = +new Date()

    selection.on "mouseup", ->
      if dist(down, d3.mouse(document.body)) > tolerance
        return
      else
        if wait
          window.clearTimeout wait
          wait = null
          event.dblclick d3.event.target.__data__
        else
          wait = window.setTimeout(((e) ->
            ->
              event.click e.target.__data__
              wait = null
          )(d3.event), 250)

  event = d3.dispatch("click", "dblclick")
  d3.rebind cc, event, "on"

angular.module('neo4jApp.controllers')
  .controller('D3GraphCtrl', [
    '$element'
    '$rootScope'
    '$scope'
    'GraphExplorer'
    'GraphRenderer'
    'GraphStyle'
    'GraphGeometry'
    ($element, $rootScope, $scope, GraphExplorer, GraphRenderer, GraphStyle, GraphGeometry) ->
      #
      # Local variables
      #
      el = d3.select($element[0])
      el.append('defs')
      graph = null

      selectedItem = null

      $scope.style = GraphStyle.rules
      $scope.$watch 'style', (val) =>
        return unless val
        @update()
      , true

      #
      # Local methods
      #

      naturalViewBox = (width, height) ->
        [
          0
          0
          width
          height
        ].join(" ")

      resize = ->
        height = $element.height()
        width  = $element.width()
        force.size([width, height])
        el.attr("viewBox", naturalViewBox(width, height))

      fit = ->
        height = $element.height()
        width  = $element.width()
        box = graph.boundingBox()

        el.transition().attr("viewBox",
          if (box.x.min > 0 && box.x.max < width && box.y.min > 0 && box.y.max < height)
            naturalViewBox(width, height)
          else [
            box.x.min
            box.y.min
            box.x.max - box.x.min
            box.y.max - box.y.min
          ].join(" ")
        )

      selectItem = (item) ->
        $rootScope.selectedGraphItem = item
        $rootScope.$apply() unless $rootScope.$$phase

      onNodeDblClick = (d) =>
        #$rootScope.selectedGraphItem = d
        return if d.expanded
        GraphExplorer.exploreNeighbours(d).then (result) =>
          graph.merge(result, d)
          d.expanded = yes
          @update()
        # New in Angular 1.1.5
        # https://github.com/angular/angular.js/issues/2371
        $rootScope.$apply() unless $rootScope.$$phase

      onNodeClick = (d) =>
        d.fixed = yes
        toggleSelection(d)

      onRelationshipClick = (d) =>
        toggleSelection(d)

      toggleSelection = (d) =>
        if d is selectedItem
          d.selected = no
          selectedItem = null
        else
          selectedItem?.selected = no
          d.selected = yes
          selectedItem = d

        @update()
        selectItem(selectedItem)

      clickHandler = clickcancel()
      clickHandler.on 'click', onNodeClick
      clickHandler.on 'dblclick', onNodeDblClick

      tick = ->

        GraphGeometry.onTick(graph)

        # Only translate nodeGroups, because this simplifies node renderers;
        # relationship renderers always take account of both node positions
        nodeGroups = el.selectAll("g.node")
        .attr("transform", (node) -> "translate(" + node.x + "," + node.y + ")")

        for renderer in GraphRenderer.nodeRenderers
          nodeGroups.call(renderer.onTick)

        relationshipGroups = el.selectAll("g.relationship")

        for renderer in GraphRenderer.relationshipRenderers
          relationshipGroups.call(renderer.onTick)

      force = d3.layout.force()
        .linkDistance(60)
        .charge(-1000)
        .on('tick', tick)

      resize()

      #
      # Public methods
      #
      @update = ->
        return unless graph
        nodes         = graph.nodes()
        relationships = graph.relationships()

        force
          .nodes(nodes)
          .links(relationships)
          .on('end', fit)
          .start()

        layers = el.selectAll("g.layer").data(["relationships", "nodes"])

        layers.enter().append("g")
        .attr("class", (d) -> "layer " + d )

        relationshipGroups = el.select("g.layer.relationships")
        .selectAll("g.relationship").data(relationships, (d) -> d.id)

        relationshipGroups.enter().append("g")
        .attr("class", "relationship")
        .on("click", onRelationshipClick)

        GraphGeometry.onGraphChange(graph)

        for renderer in GraphRenderer.relationshipRenderers
          relationshipGroups.call(renderer.onGraphChange)

        relationshipGroups.exit().remove();

        nodeGroups = el.select("g.layer.nodes")
        .selectAll("g.node").data(nodes, (d) -> d.id)

        nodeGroups.enter().append("g")
        .attr("class", "node")
        .call(force.drag)
        .call(clickHandler)

        for renderer in GraphRenderer.nodeRenderers
          nodeGroups.call(renderer.onGraphChange);

        nodeGroups.exit().remove();

      @render = (g) ->
        graph = g
        return if graph.nodes().length is 0
        GraphExplorer.internalRelationships(graph.nodes())
        .then (result) =>
          graph.addRelationships(result.relationships)
          @update()
  ])