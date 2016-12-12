mongoose = require 'mongoose'
Schema = mongoose.Schema

userSchema = new Schema
	nick: String
	dtops: [{dtop: String, tags: [String]}]
	distro: String
	github: String
	domain: String
	anilist: String
	hws: [String]
	waifu: String
	hscrs: [String]
	selfies: [String]
	lastfm: String
	wm: String
module.exports = userSchema
