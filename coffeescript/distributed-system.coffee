class Server
        connect: (@network) ->
                @ip = @network.connect(this)
                
        receive: (message) ->
                this.log("received \"#{message}\"")

        log: (msg) ->                        
                console.log("Server(#{@ip}): #{msg}")

class Network
        ipCounter: 0
        
        servers: []
        
        connect: (server) ->
                ip = @ipCounter
                @ipCounter++
                @servers[ip] = server
                ip

        broadcast: (message) ->
                server.receive(message) for server in @servers

