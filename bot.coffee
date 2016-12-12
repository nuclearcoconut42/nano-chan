irc = require "irc"
config = require "./config"
mongoose = require "mongoose"
requireDir = require "require-dir"

modules = requireDir './modules'
alias = require './alias'

mongoose.connect 'mongodb://localhost:27017/nano-chan'
db = mongoose.connection
db.on 'error', console.error.bind console, 'connection error:'
db.once 'open', ->
	console.log "Connected!"
	log = {}
	bot = new irc.Client config.network, config.nick,
		channels: config.channels

	bot.addListener 'registered', -> bot.say 'NickServ', 'identify ' + config.password

	bot.addListener 'message', (from, to, message) ->
		if log[to] && message.match /^s\/.+\/.*\/?g?i?$/
			split = message.split '/'
			if split.length == 4 && split[4]
				regex = new RegExp(split[1], split[3])
			else regex = new RegExp(split[1], '')
			for prev in log[to]
				try
					match = prev[0].match regex
				catch error
					bot.say to, "Invalid regex: #{error}"
				if match
					bot.say to, "<#{prev[1]}> #{prev[0].replace regex, split[2]}"
					break
		if log[to]
			log[to].unshift [message, from]
			if log[to].length > config.logLength
				log[to].pop()
		else
			log[to] = [[message, from]]
		message = message.trim()
		if message.match /^\.bots/
			bot.notice to, "Reporting in! [node.js] (https://github.com/nuclearcoconut42/nano-chan)"
		else if message.match /^\.help/
			bot.say from, "List of commands: #{JSON.stringify Object.keys(modules)}"
			bot.say from, "Find help on individual commands with ?[command] (without brackets)"
		else if message.match /^\./
			split = message.split ' '
			command = split[0].substring 1
			if modules[command] then modules[command].func message, from, (x) -> bot.say to, x.replace /\\r/, ''
			else if alias[command] then alias[command].func message, from, (x) -> bot.say to, x, x.replace /\\r/, ''
		else if message.match /^\?./
			split = message.split ' '
			command = split[0].substring 1
			if modules[command] then bot.say to, "#{from}: #{modules[command].help}"
			else if alias[command] then bot.say to, "#{from}: #{alias[command].help}"

	bot.addListener 'pm', (from,	message) ->
		message = message.trim()
		if message.match /^\.help/
			bot.notice from, "List of commands: #{JSON.stringify Object.keys(modules)}"
		else if message.match /^\./
			split = message.split ' '
			command = split[0].substring 1
			args = split[1..]
			if modules[command] then modules[command].func message, from, (x) -> bot.say from, x.replace /\\r/, ''
			else if alias[command] then alias[command].func message, from, (x) -> bot.say from, x.replace /\\r/, ''
		else if message.match /^\?./
			split = message.split ' '
			command = split[0].substring 1
			if modules[command] then bot.say from, "#{from}: #{modules[command].help}"
			else if alias[command] then bot.say to, "#{from}: #{alias[command].help}"
			else bot.say from, "#{from}: Unknown command."
