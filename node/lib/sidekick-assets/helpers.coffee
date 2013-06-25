#region Imports
config = require('config')()
assetsConfig = require './config'
_ = require 'underscore'
{join} = require 'path'
#endregion

localhost = "http://localhost:#{config.port}"
# These are helpers available in eco templates.
@get = (opts) ->
  _.defaults opts,
    isExtension: false

  socket: 'TEST'

  extension: ->

    excludeGlobs: JSON.stringify [
      "#{localhost}/sidebar*"
      "#{localhost}/home*"
    ]

    contentSecurityPolicy:
      "script-src 'self' #{localhost}/; object-src 'self'"

    config: JSON.stringify getExtensionConfig(), null, 2

getExtensionConfig = ->

  apiBase: config.app.url + '/api'
  appBase: config.app.url



