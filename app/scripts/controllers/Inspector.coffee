'use strict'

angular.module('neo4jApp.controllers')
  .controller 'InspectorCtrl', [
    '$scope',
    'GraphStyle'
    ($scope, GraphStyle) ->
      $scope.sizes = GraphStyle.defaultSizes()
      $scope.colors = GraphStyle.defaultColors()
      $scope.style = $scope.colors[0]
      $scope.$watch 'selectedGraphItem', (item) ->
        return unless item
        $scope.item = angular.copy(item)
        # Need to transform attrs into array due to some angular repeater problem
        $scope.item.attrs = ({key: k, value: v} for own k, v of item.attrs)
        $scope.style = GraphStyle.forNode(item).props
        if $scope.style.caption
          $scope.selectedCaption = $scope.style.caption.replace(/\{([^{}]*)\}/, "$1")

      $scope.selectSize = (size) ->
        $scope.style.diameter = size.diameter
        $scope.saveStyle()

      $scope.selectScheme = (color) ->
        $scope.style = color
        $scope.saveStyle()

      $scope.selectCaption  = (caption) ->
        $scope.selectedCaption = caption
        $scope.style.caption = '{' + caption + '}'
        $scope.saveStyle()

      $scope.saveStyle = ->
        GraphStyle.changeForNode($scope.item, $scope.style)

  ]
