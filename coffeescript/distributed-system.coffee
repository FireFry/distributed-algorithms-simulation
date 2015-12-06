class Message
        constructor: (@sender, @receiver, @content) ->

        stringify: ->
                JSON.stringify(this)
                
class Future
        constructor: (@delay, @endCallback, @tickCallback = ->) ->

        tick: ->
                return if @finished()
                @tickCallback(@delay)
                @endCallback() if @delay-- == 0

        finished: ->
                @delay < 0

class Delivery
        constructor: (@message, @network) ->
                @latency = @network.latency(@message)
                @willFail = @network.shouldFail(@message)
                @failDelay = if @willFail then random(@latency) else 0
                log("Delivery: message = #{@message.stringify()}, latency = #{@latency}, willFail = #{@willFail}, failDelay = #{@failDelay}")

        tick: ->
                @network.onDeliverySucceeded(@message)

        finished: ->
                true
                
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
                false

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
