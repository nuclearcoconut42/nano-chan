userSchema = require "../schemas/user"
mongoose = require "mongoose"

User = mongoose.model('User', userSchema)

wm = (message, nick, cb) ->
	args = message.split(' ')
	if args.length == 1
		viewWm nick, cb
	else
		switch args[1]
			when "-s", "--set"
				if args.length > 1
					checkUser nick, args[1..].join(" ")
				else
					checkUser nick, "", cb
			else viewWm args[1], cb

viewWm = (nick, cb) ->
	User.findOne {nick: nick}, (err, doc) ->
		if err then console.error "An error occurred: #{err}"
		if doc
			if doc.wm
				cb "(#{nick}) #{doc.wm}"
			else
				cb "No window manager found for #{nick}."
		else
			cb "No window manager found for #{nick}."

checkUser = (nick, wm, cb) ->
	User.findOne {nick: nick}, (err, doc) ->
		if err then console.error "An error occurred: #{err}"
		if doc
			doc.wm = wm
			doc.save (err) ->
				if err then console.error "An error occurred: #{err}"
				else
					cb "#{nick}: Saved window manager."
		if !doc
			addUser nick, wm, cb

addUser = (nick, wm, cb) ->
	newUser = new User
		nick: nick
		wm: "wm"
	newUser.save (err) ->
		if err then console.err "An error occurred: #{err}"
		else
			cb "#{nick}: Saved window manager."

module.exports =
	func: wm
	help: "Save window manager: .wm -s wm"
