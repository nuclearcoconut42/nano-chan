userSchema = require "../schemas/user"
validUrl = require "valid-url"
mongoose = require "mongoose"

User = mongoose.model('User', userSchema)

selfie = (message, nick) ->
  args = message.split(' ')[1..]
  if args.length == 0
    viewSelfies nick
  else
    switch args[0]
      when "-a", "--add"
        if args.length > 1
          if args[1..].every((url) -> validUrl.isUri(url))
            checkUser nick, args[1..]
          else
            cb "Invalid URL detected."
        else
          cb "Arguments are required for -a."
      when "-d", "--delete", "--remove"
        if args.length > 1
          deleteSelfie nick, args[1..]
        else
          cb "Arguments are required for -d."
      when "-r", "--replace"
        if data.args.length > 1
          replaceSelfie nick, data.args[1..]
        else
          cb "Arguments are required for -r."
      else viewSelfies args[0]

viewSelfies = (nick) ->
  User.findOne {nick: nick}, (err, doc) ->
    if err then console.error "An error occurred: #{err}"
    if doc
      if doc.selfies.length == 0
        cb "No selfies found for #{nick}."
      else
        i = 0
        say = "(#{nick}) "
        while i < doc.selfies.length - 1
          say += "[#{i + 1}] #{doc.selfies[i]} "
          i++
        say += "[#{doc.selfies.length}] #{doc.selfies[doc.selfies.length - 1]}"
        say
    else
      cb "No selfies found for #{nick}."

checkUser = (nick, urls) ->
  User.findOne {nick: nick}, (err, doc) ->
    if err then console.error "An error occurred: #{err}"
    if doc
      doc.selfies = doc.selfies.concat urls[..10 - doc.selfies.length]
      doc.save (err) ->
        if err then console.error "An error occurred: #{err}"
        else
          if urls.length > 1 then cb "Saved new selfies."
          else cb "Saved new selfie."
    if !doc
      addUser nick, urls

addUser = (nick, urls) ->
  newUser = new User
    nick: nick
    selfies: urls
  newUser.save (err) ->
    if err then console.err "An error occurred: #{err}"
    else
      if urls.length > 1 then cb "Saved new selfies."
      else cb "Saved new selfie."

deleteSelfie = (nick, args) ->
  User.findOne {nick: nick}, (err, doc) ->
    if err then console.error "An error occurred: #{err}"
    if doc
      if doc.selfies.length == 0
        cb "You don't have any selfies to delete."
      else
        if args[0] == "*"
          doc.selfies = []
          cb "All selfies deleted."
        else
          deleted = 0
          for arg in args
            selfies = doc.selfies
            if arg.match /:/ then slice = arg.split ':'
            else if arg.match /\.\./ then slice = arg.split '..'
            else if arg.match /\-/ then slice = arg.split '-'
            if slice
              if slice.every((index) -> ((!isNaN index) && ((parseInt index) == (Math.floor index)) index < doc.selfies.length))
                doc.selfies.splice slice[0]-1, slice[1]-slice[0]
              else invalid = true
            else
              if (!isNaN arg) && ((parseInt arg) == (Math.floor arg))
                doc.selfies.splice arg - deleted, 1
                deleted++
              else
                invalid = true
          if invalid
            cb "Non-integer value detected."
          else

            doc.save (err) ->
              if deleted > 1
                cb "Selfies deleted."
              else if deleted == 1
                cb "Selfie deleted."
              else if deleted == 0
                cb "No selfies deleted."
              if err then console.error "An error occurred: #{err}"
    else cb "You don't have any selfies to delete."

replaceSelfie = (nick, args) ->
  User.findOne {nick: nick}, (err, doc) ->
    if err then console.error "An error occured: #{err}"
    else
      if doc
        if doc.selfies.length == 0 then cb "You don't have any selfies to replace."
        else
          changed = 0
          if args[0] == "*"
            if args[1]
              if validUrl.isUri(args[1])
                doc.selfies = []
                doc.selfies.push args[1]
                changed = doc.selfies.length
              else cb "Invalid URL detected."
            else cb "Invalid arguments."
          else
            i = 0
            while i < args.length
              if validUrl.isUri(args[i+1])
                doc.selfies.set args[i] - 1, args[i+1]
                changed++
              else
                invalid = true
              i += 2
        if invalid then cb "Invalid URL detected."
        else
          doc.save (err) ->
            if err then console.error "An error occured: #{err}"
            else
              if changed > 1 then cb "Selfies changed."
              if changed == 1 then cb "Selfie changed."
              else cb "No selfies changed."
      else cb "You don't have any selfies to delete."

module.exports =
  func: selfie
  help: "Save selfies: .selfie [-a|--add] [-d|--delete] [-r|--replace] args (see https://github.com/nuclearcoconut42/nano-chan)"
