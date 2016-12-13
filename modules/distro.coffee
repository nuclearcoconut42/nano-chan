userSchema = require "../schemas/user"
mongoose = require "mongoose"

User = mongoose.model('User', userSchema)

distro = (message, nick, cb) ->
	args = message.split ' '
	if args.length == 1
		viewDistro nick, cb
	else
		switch args[1]
			when "-s", "--set"
				checkUser nick, args[2..].join(' '), cb
			else viewDistro args[1], cb

viewDistro = (nick, cb) ->
	User.findOne {nick: nick}, (err, doc) ->
		if err then console.error "An error occurred: #{err}"
		if doc
			if doc.distro
				cb doc.distro
			else
				cb "No distro found for #{nick}."
		else
			cb "No distro found for #{nick}."

checkUser = (nick, distro, cb) ->
	User.findOne {nick: nick}, (err, doc) ->
		if err then console.error "An error occurred: #{err}"
		if doc
			doc.distro = distro
			changed = true
			doc.save (err) ->
				if err then console.error "An error occurred: #{err}"
				else if changed then cb "Saved distro."
		if !doc
			addUser nick, distro, cb

addUser = (nick, distro, cb) ->
	newUser = new User
		nick: nick
		distro: distro
	newUser.save (err) ->
		if err then console.err "An error occurred: #{err}"
		else
			cb "Saved distro."

module.exports =
	func: distro
	help: "Save distro: .distro -s distro"
