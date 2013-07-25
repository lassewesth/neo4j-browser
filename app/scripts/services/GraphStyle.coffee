'use strict';

angular.module('neo4jApp.services')
  .factory 'GraphStyle', ['$rootScope', ($rootScope) ->

    class Selector
      constructor: (selector) ->
        [@tag, @klass] = if selector.indexOf('.') > 0
          selector.split('.')
        else
          [selector, undefined]

      toString: ->
        str = @tag
        str += ".#{@klass}" if @klass?
        str

    class StyleRule
      constructor: (@selector, @props) ->

      matches: (selector) ->
        if @selector.tag is selector.tag
          if @selector.klass is selector.klass or not @selector.klass
            return yes
        return no

      matchesExact: (selector) ->
        @selector.tag is selector.tag and @selector.klass is selector.klass

    class StyleElement
      constructor: (selector, @data) ->
        @selector = selector
        @props = {}

      applyRules: (rules) ->
        for rule in rules
          angular.extend(@props, rule.props) if rule.matches(@selector)

        @

      get: (attr) ->
        @props[attr] or ''

    styledata =
      'node':
        'fill': '#C3C6C6'
        'stroke': '#B7B7B7'
        'stroke-width': '2px'
        'color': '#fff'
        'caption': '{id}'
      'relationship':
        'fill': 'none'
        'stroke': '#e3e3e3'
        'stroke-width': '1.5px'

    class GraphStyle
      constructor: -> @rules = []
      select: (selector, data) ->
        new StyleElement(selector, data).applyRules(@rules)

      findNodeRule: (node) ->
        selector = @nodeSelector(node)
        rule = r for r in @rules when r.matchesExact(selector)
        rule

      changeForNode: (node, props) ->
        rule = @findNodeRule(node)
        if not rule?
          rule = new StyleRule(@nodeSelector(node), {})
          @rules.push(rule)
        angular.extend(rule.props, props)
        rule

      forNode: (node = {}) ->
        @select(@nodeSelector(node), node)

      forRelationship: (rel) ->
        @select(@relationshipSelector(rel), rel)

      nodeSelector: (node = {}) ->
        selector = 'node'
        if node.labels?.length > 0
          selector += ".#{node.labels[0]}"
        new Selector(selector)

      relationshipSelector: (rel) ->
        selector = 'relationship'
        selector += ".#{rel.type}" if rel.type?
        new Selector(selector)


      loadSheet: (data) ->
        @rules = for rule, props of data
          new StyleRule(new Selector(rule), props)
        @
      interpolate: (str, data) ->
        # Supplant
        # http://javascript.crockford.com/remedial.html
        str.replace(
          /\{([^{}]*)\}/g,
          (a, b) ->
            r = data[b] or data.id
            return if (typeof r is 'string' or typeof r is 'number') then r else a
        )

      destroyRule: (rule) ->
        for r in @rules
          if r == rule
            @rules.splice(@rules.indexOf(rule), 1)
            break

      toString: ->
        str = ""
        for r in @rules
          str += r.selector.toString() + " {\n"
          for k, v of r.props
            v = "'#{v}'" if k == "caption"
            str += "  #{k}: #{v};\n"
          str += "}\n\n"
        str

    new GraphStyle().loadSheet(styledata)
  ]


