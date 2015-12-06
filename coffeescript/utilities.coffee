execLater = (ms, func) -> setTimeout func, ms

log = (message) -> console.log(message)

randomBetween = (lower, upper) -> lower + random(upper - lower)

random = (upper) -> Math.floor(Math.random() * upper)
