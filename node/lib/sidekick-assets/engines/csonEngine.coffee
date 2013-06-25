# stdlib
extname = require("path").extname

# 3rd-party
_ = require("underscore")
cson = undefined # initialized later

# internal
Template = require("mincer/lib/mincer/template")
{prop} = require("mincer/lib/mincer/common")

# Class constructor
CsonEngine = module.exports = CsonEngine = ->
  Template.apply this, arguments

require("util").inherits CsonEngine, Template

# Check whenever coffee-script module is loaded
CsonEngine::isInitialized = ->
  !!cson

# Autoload coffee-script library
CsonEngine::initializeEngine = ->
  cson = @require("cson")

# Render data
CsonEngine::evaluate = (context, locals, callback) ->
  
  #jshint unused:false
  try
    result = cson.parseSync @data
    callback null, JSON.stringify result, null, 2
  catch err
    callback err

# Expose default MimeType of an engine
prop CsonEngine, "defaultMimeType", "application/json"
