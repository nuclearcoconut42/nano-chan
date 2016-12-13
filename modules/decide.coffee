_ = require 'lodash'
choices = ["Yes.", "No."]

module.exports =
	func: (message, nick, cb) ->
		regex = /(\S+)(( or)|( \|)|( \|\|)|,|$)/g
		options = []
		while match = regex.exec message
			options.push match[1]
		if options.length > 1
			cb _.sample options
		else
			cb _.sample choices
	help: "Picks a random course of action based on arguments passed"
