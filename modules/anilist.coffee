userSchema = require "../schemas/user"
mongoose = require "mongoose"
validUrl = require "valid-url"

User = mongoose.model('User', userSchema)

anilist = (message, nick, cb) ->
	args = message.split ' '
	if args.length == 1
		viewAnilist nick
	else
		switch args[1]
			when "-s", "--set"
				checkUser nick, message.replace(/\S+/, '').trim()
			else viewAnilist args[1]

viewAnilist = (nick) ->
	User.findOne {nick: nick}, (err, doc) ->
		if err then console.error "An error occurred: #{err}"
		if doc
			if doc.anilist
				doc.anilist
			else
				cb "No anilist found for #{nick}."
		else
			cb "No anilist found for #{nick}."

checkUser = (nick, anilist) ->
	User.findOne {nick: nick}, (err, doc) ->
		if err then console.error "An error occurred: #{err}"
		if doc
			if validUrl.isUri(anilist)
				doc.anilist = anilist
				changed = true
			else
				cb "Invalid URL detected."
			doc.save (err) ->
				if err then console.error "An error occurred: #{err}"
				else
					if changed then cb "Saved anilist."
		if !doc
			addUser nick, anilist

addUser = (nick, anilist) ->
	if validUrl.isUri anilist
		newUser = new User
			nick: nick
			anilist: anilist
	else
		cb "Invalid URL detected."
	newUser.save (err) ->
		if err then console.err "An error occurred: #{err}"
		else
			cb "Saved anilist."

module.exports =
	func: anilist
	help: "Save anilist: .anilist -s anilist"
