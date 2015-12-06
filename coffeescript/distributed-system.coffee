class Message
        constructor: (@sender, @receiver, @content) ->

        stringify: ->
                JSON.stringify(this)
                
class Future
        constructor: (@delay, @endCallback, @tickCallback = ->) ->
                @cancelled = false

        tick: ->
                return if @finished()
                @tickCallback(@delay)
                @endCallback() if not @cancelled and @delay-- == 0

        finished: ->
                @cancelled or @delay < 0

        cancel: ->
                @cancelled = true

class Delivery extends Future
        constructor: (@message, @network) ->
                @latency = @network.latency(@message)
                @willFail = @network.shouldFail(@message)
                @failDelay = if @willFail then random(@latency) else -1
                #log("Delivery: message = #{@message.stringify()}, latency = #{@latency}, willFail = #{@willFail}, failDelay = #{@failDelay}")
                super(@latency, (-> @succeed()), ((delay) -> @onTick(delay)))

        fail: ->
                @network.onDeliveryFailed(@message)
                @cancel()

        succeed: ->
                @network.onDeliverySucceeded(@message)

        onTick: (delay) ->
                @fail() if delay == @failDelay                        
                
class Network
        @ipCounter: 1
        
        constructor: ->
                @ips = {}
                @connections = {}
                @deliveries = []
        
        connect: (server) ->
                ip = Network.ipCounter++
                connection = new Connection(ip, this, server)
                @ips[ip] = ip                
                @connections[ip] = connection
                connection

        broadcast: (from, msgContent) ->
                @send(from, to, msgContent) for toKey, to of @ips when to != from

        send: (from, to, msgContent) ->                
                message = new Message(from, to, msgContent)
                delivery = new Delivery(message, this)
                @deliveries.push(delivery)

        onDeliveryFailed: (message) ->
                log("Failed to deliver: #{message.stringify()}")

        onDeliverySucceeded: (message) ->
                @connections[message.receiver].mailbox.push(message)

        latency: (message) ->
                randomBetween(100, 300)

        shouldFail: (message) ->
                random(2) == 0

        tick: ->
                @tickDeliveries()
                connection.fillReceiveQueue() for ip, connection of @connections
                connection.receiveMessages() for ip, connection of @connections

        tickDeliveries: ->
                newDeliveries = []
                for delivery in @deliveries
                        delivery.tick()
                        newDeliveries.push(delivery) if !delivery.finished()
                @deliveries = newDeliveries

class Connection
        constructor: (@ip, @network, @server) ->
                @mailbox = []
                @receiveQueue = []
                @ips = @network.ips

        broadcast: (messageContent) ->
                @network.broadcast(@ip, messageContent)

        send: (ip, messageContent) ->
                @network.send(@ip, ip, messageContent)

        fillReceiveQueue: ->
                @receiveQueue = @mailbox
                @mailbox = []

        receiveMessages: ->
                @server.receive(message) for message in @receiveQueue
                @receiveQueue = []

class Server
        connect: (network) ->
                @connection = network.connect(this)

        receive: (message) ->
                @log("received \"#{JSON.stringify(message)}\"")

        log: (msg) ->
                console.log("Server(#{@connection.ip}) #{msg}")

        broadcast: (msg) ->
                @connection.broadcast(msg)
