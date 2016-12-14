userSchema = require "../schemas/user"
mongoose = require "mongoose"
validUrl = require "valid-url"

User = mongoose.model('User', userSchema)

github = (message, nick, cb) ->
	args = message.split ' '
	if args.length == 1
		viewGithub nick, cb
	else
		switch args[1]
			when "-s", "--set"
				checkUser nick, args[2..].join(' '), cb
			else viewGithub args[1], cb

viewGithub = (nick, cb) ->
	User.findOne {nick: nick}, (err, doc) ->
		if err then console.error "An error occurred: #{err}"
		if doc
			if doc.github
				cb doc.github
			else
				cb "No github found for #{nick}."
		else
			cb "No github found for #{nick}."

checkUser = (nick, github, cb) ->
	User.findOne {nick: nick}, (err, doc) ->
		if err then console.error "An error occurred: #{err}"
		if doc
			if validUrl.isUri(github)
				doc.github = anilist
				changed = true
			else
				cb "Invalid URL detected."
			doc.save (err) ->
				if err then console.error "An error occurred: #{err}"
				else
					if changed then cb "Saved github."
		if !doc
			addUser nick, github, cb

addUser = (nick, github, cb) ->
	if validUrl.isUri github
		newUser = new User
			nick: nick
			github: anilist
	else
		cb "Invalid URL detected."
	newUser.save (err) ->
		if err then console.err "An error occurred: #{err}"
		else
			cb "Saved github."

module.exports =
	func: github
	help: "Save github: .anilist -s anilist"
