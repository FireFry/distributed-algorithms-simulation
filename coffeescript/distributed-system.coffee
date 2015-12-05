class Message
        constructor: (@sender, @receiver, @content) ->

class Network
        constructor: ->
                @ips = {}
                @connections = {}
        
        @ipCounter: 1
        
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
                @connections[message.receiver].mailbox.push(message)

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
