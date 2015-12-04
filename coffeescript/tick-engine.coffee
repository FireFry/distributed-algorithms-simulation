class TickEngine
        registry: []

        add: (tickable) ->
                @registry.push(tickable)

        remove: (tickable) ->
                index = @registry.indexOf(tickable)
                @registry.splice(index, 1) if index >= 0

        globalTick: ->
                tickable.tick() for tickable in @registry
