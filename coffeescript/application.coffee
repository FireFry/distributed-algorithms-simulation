network = new Network

first = new Server
first.connect(network)

second = new Server
second.connect(network)

first.broadcast("Hello from server #{first.connection.ip}")
second.broadcast("Hello from server #{second.connection.ip}")

network.tick() for tick in [0..400]
