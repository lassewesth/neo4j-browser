'use strict';

angular.module('neo4jApp.services')
  .factory 'motdService', [
    ->
      class Motd

        choices =
          quotes: [
            { 'text':'When you label me, you negate me', 'author':'Soren Kierkegaard' }
            { 'text':'In the beginning was the command line', 'author':'Neal Stephenson' }
            { 'text':'Remember, all I\'m offering is the truth – nothing more', 'author':'Morpheus'}
            { 'text':'Testing can show the presence of bugs, but never their absence.', 'author':'Edsger W. Dijkstra'}
            { 'text':'We think you\'re a special snowflake', 'author':'Neo4j'}
            { 'text':'Still he\'d see the matrix in his sleep, bright lattices of logic unfolding across that colorless void', 'author':'William Gibson'}
            { 'text':'Eventually everything connects.', 'author':'Charles Eames'}
            { 'text':'To develop a complete mind: study the science of art. Study the art of science. Develop your senses - especially learn how to see. Realize that everything connects to everything else', 'author':'Leonardo da Vinci'}
          ],
          tips: [
            'Use <shift-return> for multi-line, <cmd-return> to evaluate command'
            'Navigate query bar history with <ctrl- up/down arrow>.'
          ],
          unrecognizable: [
            "Interesting. How does this make you feel?"
            "Even if I squint, I can't make out what that is. Is it an elephant?"
            "This one time, at bandcamp..."
            "Ineffable, enigmatic, possibly transcendent. Also quite good looking."
            "I'm not (yet) smart enough to understand this."
            "Oh I agree. Kaaviot ovat suuria!"
          ],
          emptiness: [
            "No nodes. Know nodes?"
            "Waiting for the big bang of data"
            "Ready for anything"
            "Every graph starts with the first node"
          ]

        quote: ""

        tip: ""

        unrecognized: ""

        emptiness: ""

        constructor: ->
          @refresh()

        refresh: ->
          @quote = @pickRandomlyFrom(choices.quotes)
          @tip = @pickRandomlyFrom(choices.tips)
          @unrecognized = @pickRandomlyFrom(choices.unrecognizable)
          @emptiness = @pickRandomlyFrom(choices.emptiness)

        pickRandomlyFrom: (fromThis) ->
          return fromThis[Math.floor(Math.random() * fromThis.length)]

      new Motd
]
