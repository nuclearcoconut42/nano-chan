userSchema = require "../schemas/user"
mongoose = require "mongoose"
validUrl = require "valid-url"

User = mongoose.model('User', userSchema)

git = (message, nick, cb) ->
	args = message.split ' '
	if args.length == 1
		viewGit nick, cb
	else
		switch args[1]
			when "-s", "--set"
				checkUser nick, args[2..].join(' '), cb
			else viewGit args[1], cb

viewGit = (nick, cb) ->
	User.findOne {nick: nick}, (err, doc) ->
		if err then console.error "An error occurred: #{err}"
		if doc
			if doc.git
				cb doc.git
			else
				cb "No git found for #{nick}."
		else
			cb "No git found for #{nick}."

checkUser = (nick, git, cb) ->
	User.findOne {nick: nick}, (err, doc) ->
		if err then console.error "An error occurred: #{err}"
		if doc
			if validUrl.isUri(git)
				doc.git = git
				changed = true
			else
				cb "Invalid URL detected."
			doc.save (err) ->
				if err then console.error "An error occurred: #{err}"
				else
					if changed then cb "Saved git."
		if !doc
			addUser nick, git, cb

addUser = (nick, git, cb) ->
	if validUrl.isUri git
		newUser = new User
			nick: nick
			git: git
	else
		cb "Invalid URL detected."
	newUser.save (err) ->
		if err then console.err "An error occurred: #{err}"
		else
			cb "Saved git."

module.exports =
	func: git
	help: "Save git: .git -s git"
