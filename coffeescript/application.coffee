network = new Network

first = new Server
first.connect(network)

second = new Server
second.connect(network)

first.broadcast("Hello from server #{first.connection.ip}")
second.broadcast("Hello from server #{second.connection.ip}")

network.tick()

f = new Future(2, ( -> log("Hi future")), ((tick) -> log("Contdown: #{tick}...")))
f.tick() for i in [0..10]
