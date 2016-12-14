userSchema = require "../schemas/user"
validUrl = require "valid-url"
mongoose = require "mongoose"
_ = require "lodash"
assert = require "assert"

mongoose.Promise = require('q').Promise

User = mongoose.model 'User', userSchema, 'users'
dtop = (message, nick, cb) ->
	args = message.split ' '
	if args.length == 1
		return viewDtops nick, [], nick, cb
	else
		switch args[1]
			when '-a', '--add'
				regex = /\.dtop --?[a-z]+ (\S+) ?((#\S+ ?)*)/g
				dtops = []
				while match = regex.exec message
					if match[3]
						dtops.push [match[1], match[3].trim().split ' ']
					else
						dtops.push [match[1], []]
				addDtops dtops, nick, cb
			when '-d', '--delete', '--remove'
				regex = /(\d+)|((\d+)(-|:|(\.\.))(\d+))|(#\S+)|(\*)/g
				selection = []
				tags = []
				while match = regex.exec message
					console.log match
					if match[1] then selection.push match[1]
					if match[2] && match[3] && match[6]
						selection.concat [match[3]..match[6]]
					if match[7] then tags.push match[7]
					if match[8] then glob = true
				deleteDtops selection, tags, glob, nick, cb
			when '-r', '--replace'
				regex = /(\d+) (\S+) ?((#\S+ ?)+)/g
				selection = []
				dtops = []
				while match = regex.exec message
					selection.push match[1]
					dtops.push [match[2], match[3].trim().split ' ']
				replaceDtops selection, dtops, nick, cb
			when '-t', '--tags'
				regex = /(#\S+)/g
				tags = []
				while match = regex.exec message
					tags.push match[1]
				findByTags tags, cb
			else
				if args[1][0] == '#'
					regex = /(#\S+)/g
					tags = []
					while match = regex.exec message
						tags.push match[1]
					viewDtops nick, tags, nick, cb
				else
					regex = /((#\S+ ?)+)|([a-zA-Z]+)/
					tags = []
					while match = regex.exec message
						if match[2] then tags.push match[1]
						if match[3] then user = match[2]
					viewDtops user, tags, nick, cb

viewDtops = (nick, tags, requester, cb) ->
	ret = ""
	if nick && tags.length > 0
		query = User.aggregate
			$match:
				nick: nick
		.unwind 'dtops'
		.match
			"dtops.tags":
				$all: tags
		.project
			dtop: "$dtops.dtop"
			tags: "$dtops.tags"
		assert.ok(query.exec() instanceof require('q').makePromise)
		query.exec (err, doc) ->
			if err
				console.error err
			else if doc
				ret = "(#{nick}) "
				doc.forEach (element, index) ->
					ret += "[#{index+1}] #{element.dtop} #{JSON.stringify element.tags} "
			if ret then cb ret.trim()
			else cb "#{requester}: No desktops found for #{nick}."
	else if nick
		query = User.findOne
			nick: nick
		assert.ok(query.exec() instanceof require('q').makePromise)
		query.exec().then (doc) ->
			if doc && doc.dtops.length > 0
				ret = "(#{nick}) "
				doc.dtops.forEach (element, index) ->
					ret += "[#{index+1}] #{element.dtop} #{JSON.stringify element.tags} "
			if ret then cb ret.trim()
			else cb "#{requester}: No desktops found for #{nick}."


findByTags = (tags, cb) ->
	query = User.aggregate()
	.unwind "dtops"
	.match
		"dtops.tags":
			$all: tags
	.project
		nick: "$nick"
		dtop: "$dtops.dtop"
		tags: "$dtops.tags"
	.sample 10
	assert.ok(query.exec() instanceof require('q').makePromise)
	query.exec (err, doc) ->
		if err
			console.error err
		else if doc
			ret = ""
			doc.forEach (element, index) ->
				ret += "(#{element.nick}) #{element.dtop} #{JSON.stringify element.tags} "
		if ret then cb ret.trim()
		else cb "None found."


addDtops = (dtops, nick, cb) ->
	for dtop in dtops
		if validUrl.isUri(dtop[0])
			User.findOne {nick: nick}, (err, doc) ->
				if doc
					doc.dtops.push
						dtop: dtop[0]
						tags: dtop[1]
					doc.save (err) ->
						if err then console.error err
				else
					User.create
						dtops: [
							dtop: dtop[0]
							tags: dtop[1]
						]
						nick: nick
						(err, doc) ->
		else
			invalid = true
	if invalid then cb "#{nick}: Invalid URL detected."
	else if dtops.length > 1 then cb "#{nick}: Desktops added."
	else cb "#{nick}: Desktop added."

deleteDtops = (ids, tags, glob, nick, cb) ->
	numDeleted = 0
	if glob
		User.findOne
			nick: nick
			(err, doc) ->
				numDeleted = doc.dtops.length
				dtops = []
				doc.save (err) -> console.error err
				if numDeleted > 1 then cb "#{nick}: Desktops deleted."
				else if numDeleted == 1 then cb "#{nick}: Desktop deleted."
				else cb "#{nick}: No desktops removed."
	else ids.map (element) ->
			element--
	User.findOne
		nick: nick
		(err, doc) ->
			doc.dtops.forEach (element, index) ->
				if index of ids || _.intersection(element.tags, tags).length == tags.length
					element.remove()
					console.log numDeleted
					numDeleted++
					console.log "after #{numDeleted}"
			doc.save (err) -> console.error err
			if numDeleted > 1 then cb "#{nick}: Desktops deleted."
			else if numDeleted == 1 then cb "#{nick}: Desktop deleted."
			else cb "#{nick}: No desktops deleted."

replaceDtops = (ids, dtops, nick, cb) ->
	numReplaced = 0
	User.findOne
		nick: nick
		(err, doc) ->
			ids.forEach (element, index) ->
				numReplaced++
				doc.dtops[element-1].dtop = dtops[index][0]
				doc.dtops[element-1].tags = dtops[index][1]
			doc.save (err) -> console.error err
			if numReplaced > 1 then cb "#{nick}: Desktops replaced."
			else if numReplaced == 1 then cb "#{nick}: Desktop replaced."
			else cb "#{nick}: No desktops replaced."

module.exports =
	func: dtop
	help: "Set your dtops: .dtop -a dtop [tags] dtop [tags] etc. (see https://github.com/nucclearcoconut42/nano-chan for more info."
