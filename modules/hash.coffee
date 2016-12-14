crypto = require 'crypto'

hash = (message, nick, cb) ->
	match = message.match /--(\S+) (.+)/
	if match
		pt = match[2]
		switch match[1]
			when 'md5'
				cb crypto.createHash('md5').update(pt).digest 'hex'
			when 'sha1'
				cb crypto.createHash('sha1').update(pt).digest 'hex'
			when 'sha256'
				cb crypto.createHash('sha256').update(pt).digest 'hex'
			when 'sha512'
				cb crypto.createHash('sha512').update(pt).digest 'hex'
	else cb "Invalid arguments."
module.exports =
	func: hash
	help: 'Hash a string [.hash {--md5 | --sha1 | --sha256 | --sha512] [string])'
