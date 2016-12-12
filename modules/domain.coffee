userSchema = require "../schemas/user"
mongoose = require "mongoose"
validUrl = require "valid-url"

User = mongoose.model('User', userSchema)

domain = (message, nick, cb) ->
	args = message.split(' ')[1..]
	if args.length == 0
		viewDomain nick
	else
		switch args[0]
			when "-s", "--set"
				checkUser nick, message.replace(/\S+/, '').trim()
			else viewDomain args[0]

viewDomain = (nick) ->
	User.findOne {nick: nick}, (err, doc) ->
		if err then console.error "An error occurred: #{err}"
		if doc
			if doc.domain
				doc.domain
			else
				cb "No domain found for #{nick}."
		else
			cb "No domain found for #{nick}."

checkUser = (nick, domain) ->
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
					if changed then "Saved domain."
		if !doc
			addUser nick, domain

addUser = (nick, domain) ->
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
