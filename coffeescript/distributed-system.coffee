class Message
        constructor: (@sender, @receiver, @content) ->

class Future
        constructor: (@delay, @endCallback, @tickCallback = ->) ->

        tick: ->
                return if @finished()
                @tickCallback(@delay)
                @endCallback() if @delay-- == 0

        finished: ->
                @delay < 0

class Network
        @ipCounter: 1
        
        constructor: ->
                @ips = {}
                @connections = {}
                @futures = []
        
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
                
                latency = @latency(from, to)
                willFail = @shouldFail(from, to)
                failDelay = if willFail then random(latency) else 0

                
                
                @connections[message.receiver].mailbox.push(message)

        latency: (from, to) ->
                randomBetween(100, 300)

        shouldFail: (from, to) ->
                false

        tick: ->
                connection.fillReceiveQueue() for ip, connection of @connections
                connection.receiveMessages() for ip, connection of @connections

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
