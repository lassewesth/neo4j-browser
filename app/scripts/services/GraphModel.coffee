'use strict';

angular.module('neo4jApp.services')
  .factory 'GraphModel', [
    '$q'
    'Collection'
    'Cypher'
    ($q, Collection, Cypher) ->
      class GraphModel
        constructor: (cypher = {}) ->
          @nodes = new Collection(cypher.nodes)
          @links = new Collection(cypher.relationships)

        addNode: (node) ->
          return false unless node?.id?
          # TODO: merge nodes if already existing
          @nodes.add(node) unless @nodes.get(node.id)
          node

        addRelationship: (rel) ->
          return false unless rel?.id?
          @links.add(rel) unless @links.get(rel.id)
          node = @nodes.get(rel.start) or @nodes.get(rel.end)

          # Connect children if they are missing
          if node and not (node.source and source.target)
            rel.source = @nodes.get(rel.start)
            rel.target = @nodes.get(rel.end)
            rel.incoming = rel.end is node.id
            #node.relationships.push rel
            #node.children.push(if rel.source.id is node.id then rel.target else rel.source)
          rel

        expandAll: ->
          q = $q.defer()
          ids = @nodes.pluck('id')
          if ids.length is 0
            q.resolve(@)
            return q.promise

          Cypher.send("START a = node(#{ids.join(',')}) MATCH a -[r]- b RETURN r, b").then((result) =>
            # Mark current nodes as expanded
            for id in ids
              n = @nodes.get(id)
              n.expanded = yes if n

            # Add result to current graph
            @addNode(n) for n in result.nodes
            @addRelationship(r) for r in result.relationships
            q.resolve(@)
          )
          q.promise


        expand: (nodeId) ->
          node = @nodes.get(nodeId)
          q = $q.defer()
          if not node?
            q.reject()
            return q.promise

          node.$traverse().then((result)=>
            result.expanded = yes

            @addNode(n) for n in result.children
            @addRelationship(r) for r in result.relationships
            q.resolve()
          )
          q.promise

      GraphModel
]