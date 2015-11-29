network = new Network
network.broadcast("Hello first time!")
new Server().connect(network)
network.broadcast("Hello second time!")
new Server().connect(network)
network.broadcast("Hello finally!")
