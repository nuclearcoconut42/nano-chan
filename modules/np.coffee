userSchema = require "../schemas/user"
mongoose = require "mongoose"
api = require "lastfm-njs"
config = require "../config.coffee"

User = mongoose.model('User', userSchema)

np = (message, nick) ->
	args = message.split(' ')[1..]
	if args.length == 0
		nowplaying nick
	else
		switch args[0]
			when "-s", "--set"
				if args.length > 1
					checkUser data.from, data.to, args[1], bot
				else
					checkUser data.from, data.to, "", bot
			else nowplaying data.to, args[0], bot

nowplaying = (nick) ->
	User.findOne {nick: nick}, (err, doc) ->
		if err then console.error "An error occurred: #{err}"
		else if doc && doc.lastfm
			lfm = new api
				apiKey: config.lastfmApiKey
				apiSecret: config.lastfmSecret
				username: doc.lastfm
			lfm.user_getRecentTracks({
				callback: (res) ->
					track = res['track'][0]
					if track['@attr'] && track['@attr']['nowplaying']
						cb "#{track['artist']['#text']} - #{track['name']}"
					else
						cb "#{doc.lastfm} isn't playing anything right now. Most recent track: #{track['artist']['#text']} - #{track['name']}"
			})
		else
			cb "No last.fm account found for #{nick}."

checkUser = (nick, channel, lastfm, bot) ->
	User.findOne {nick: nick}, (err, doc) ->
		if err then console.error "An error occurred: #{err}"
		if doc
			doc.lastfm = lastfm
			doc.save (err) ->
				if err then console.error "An error occurred: #{err}"
				else
					cb "Saved last.fm account."
		if !doc
			addUser nick, channel, lastfm, bot

addUser = (nick, channel, lastfm, bot) ->
	newUser = new User
		nick: nick
		lastfm: lastfm
	newUser.save (err) ->
		if err then console.err "An error occurred: #{err}"
		else
			cb "Saved last.fm account."

module.exports =
	func: np
	help: "Save last.fm account: .np -s [username]; Find now playing songs .np [nick]"
