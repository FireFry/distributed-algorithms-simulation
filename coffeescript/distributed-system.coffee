class Network
	ipCounter: 1
	ips: {}
	servers: {}

	connect: (server) ->
		ip = @ipCounter++
		@ips[ip] = ip
		@servers[ip] = server
		new Connection(ip, this)

	send: (message) ->
		@servers[message.receiver].receive(message)

class Connection
	constructor: (@ip, @network) ->

	ips: -> @network.ips

	broadcast: (messageContent) ->
		@send(ip, messageContent) for ipKey, ip of @network.ips when ip != @ip
			
	send: (ip, messageContent) ->
		@network.send({
			sender: @ip
			receiver: ip
			content: messageContent
		})

class Server
	connect: (network) ->
		@connection = network.connect(this)

	receive: (message) ->
		@log("received \"#{message.content}\"")

	log: (msg) ->
		console.log("Server(#{@connection.ip}) #{msg}")

	broadcast: (message) ->
		@connection.broadcast(message)

	send: (ip, message) ->
		@connection.send(ip, message)
