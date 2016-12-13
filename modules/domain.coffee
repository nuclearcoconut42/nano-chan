userSchema = require "../schemas/user"
mongoose = require "mongoose"
validUrl = require "valid-url"

User = mongoose.model('User', userSchema)

domain = (message, nick, cb) ->
	args = message.split ' '
	if args.length == 1
		viewDomain nick, cb
	else
		switch args[1]
			when "-s", "--set"
				checkUser nick, args[2..].join(' '), cb
			else viewDomain args[1], cb

viewDomain = (nick, cb) ->
	User.findOne {nick: nick}, (err, doc) ->
		if err then console.error "An error occurred: #{err}"
		if doc
			if doc.domain
				cb doc.domain
			else
				cb "No domain found for #{nick}."
		else
			cb "No domain found for #{nick}."

checkUser = (nick, domain, cb) ->
	User.findOne {nick: nick}, (err, doc) ->
		if err then console.error "An error occurred: #{err}"
		if doc
			if validUrl.isUri(domain)
				doc.domain = domain
				changed = true
			else
				cb "Invalid URL detected."
			doc.save (err) ->
				if err then console.error "An error occurred: #{err}"
				else
					if changed then cb "Saved domain."
		if !doc
			addUser nick, domain, cb

addUser = (nick, domain, cb) ->
	if validUrl.isUri domain
		newUser = new User
			nick: nick
			domain: domain
	else
		cb "Invalid URL detected."
	newUser.save (err) ->
		if err then console.err "An error occurred: #{err}"
		else
			cb "Saved domain."

module.exports =
	func: domain
	help: "Save domain: .domain -s domain"
