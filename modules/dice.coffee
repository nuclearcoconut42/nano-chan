dice = (message, nick, cb) ->
	args = message.split(' ')[1..]
	sum = 0
	for roll in args
		parsed = roll.split 'd'
		sum += Math.floor(Math.random() * parsed[1]) for i in [1..parsed[0]]
	cb sum
module.exports =
	func: dice
	help: "Rolls dice using standard notation: (3d4 rolls three four-sided dice)"
