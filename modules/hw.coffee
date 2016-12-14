userSchema = require "../schemas/user"
validUrl = require "valid-url"
mongoose = require "mongoose"

User = mongoose.model('User', userSchema)

hw = (message, nick, cb) ->
	args = message.split(' ')[1..]
	if args.length == 0
		viewHws nick, cb
	else
		switch args[0]
			when "-a", "--add"
				if args.length > 1
					if args[1..].every((url) -> validUrl.isUri(url))
						checkUser nick, args[1..], cb
					else
						cb "Invalid URL detected."
				else
					cb "Arguments are required for -a."
			when "-d", "--delete", "--remove"
				if args.length > 1
					deleteHw nick, args[1..], cb
				else
					cb "Arguments are required for -d."
			when "-r", "--replace"
				if data.args.length > 1
					replaceHw nick, data.args[1..], cb
				else
					cb "Arguments are required for -r."
			else viewHws args[0], cb

viewHws = (nick, cb) ->
	User.findOne {nick: nick}, (err, doc) ->
		if err then console.error "An error occurred: #{err}"
		if doc
			if doc.hws.length == 0
				cb "No handwritings found for #{nick}."
			else
				i = 0
				say = "(#{nick}) "
				while i < doc.hws.length - 1
					say += "[#{i + 1}] #{doc.hws[i]} "
					i++
				say += "[#{doc.hws.length}] #{doc.hws[doc.hws.length - 1]}"
				cb say
		else
			cb "No handwritings found for #{nick}."

checkUser = (nick, urls, cb) ->
	User.findOne {nick: nick}, (err, doc) ->
		if err then console.error "An error occurred: #{err}"
		if doc
			doc.hws = doc.hws.concat urls[..10 - doc.hws.length]
			doc.save (err) ->
				if err then console.error "An error occurred: #{err}"
				else
					if urls.length > 1 then cb "Saved new handwritings."
					else cb "Saved new handwriting."
		if !doc
			addUser nick, urls, cb

addUser = (nick, urls, cb) ->
	newUser = new User
		nick: nick
		hws: urls
	newUser.save (err) ->
		if err then console.err "An error occurred: #{err}"
		else
			if urls.length > 1 then cb "Saved new handwritings."
			else cb "Saved new handwriting."

deleteHw = (nick, args, cb) ->
	User.findOne {nick: nick}, (err, doc) ->
		if err then console.error "An error occurred: #{err}"
		if doc
			if doc.hws.length == 0
				cb "You don't have any handwritings to delete."
			else
				if args[0] == "*"
					doc.hws = []
					cb "All handwritings deleted."
				else
					deleted = 0
					for arg in args
						hws = doc.hws
						if arg.match /:/ then slice = arg.split ':'
						else if arg.match /\.\./ then slice = arg.split '..'
						else if arg.match /\-/ then slice = arg.split '-'
						if slice
							if slice.every((index) -> ((!isNaN index) && ((parseInt index) == (Math.floor index)) index < doc.hws.length))
								doc.hws.splice slice[0]-1, slice[1]-slice[0]
							else invalid = true
						else
							if (!isNaN arg) && ((parseInt arg) == (Math.floor arg))
								doc.hws.splice arg - deleted, 1
								deleted++
							else
								invalid = true
					if invalid
						cb "Non-integer value detected."
					else
						doc.save (err) ->
							if deleted > 1
								cb "Handwritings deleted."
							else if deleted == 1
								cb "Handwriting deleted."
							else if deleted == 0
								cb "No handwritings deleted."
							if err then console.error "An error occurred: #{err}"
		else cb "You don't have any handwritings to delete."

replaceHw = (nick, args, cb) ->
	User.findOne {nick: nick}, (err, doc) ->
		if err then console.error "An error occured: #{err}"
		else
			if doc
				if doc.hws.length == 0 then cb "You don't have any handwritings to replace."
				else
					changed = 0
					if args[0] == "*"
						if args[1]
							if validUrl.isUri(args[1])
								doc.hws = []
								doc.hws.push args[1]
								changed = doc.hws.length
							else cb "Invalid URL detected."
						else cb "Invalid arguments."
					else
						i = 0
						while i < args.length
							if validUrl.isUri(args[i+1])
								doc.hws.set args[i] - 1, args[i+1]
								changed++
							else
								invalid = true
							i += 2
				if invalid then cb "Invalid URL detected."
				else
					doc.save (err) ->
						if err then console.error "An error occured: #{err}"
						else
							if changed > 1 then cb "Handwritings changed."
							if changed == 1 then cb "Handwriting changed."
							else cb "No handwritings changed."
			else cb "You don't have any handwritings to delete."

module.exports =
	func: hw
	help: "Save handwritings: .hw [-a|--add] [-d|--delete] [-r|--replace] args (see https://github.com/nuclearcoconut42/nano-chan)"
