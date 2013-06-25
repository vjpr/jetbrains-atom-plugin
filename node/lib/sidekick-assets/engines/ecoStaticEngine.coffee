"use strict"

# 3rd-party
eco = undefined # initialized later
_ = require("underscore")

# internal
Template = require("mincer/lib/mincer/template")
prop = require("mincer/lib/mincer/common").prop

#//////////////////////////////////////////////////////////////////////////////

# Class constructor
EcoStaticEngine = module.exports = EcoStaticEngine = ->
  Template.apply this, arguments

require("util").inherits EcoStaticEngine, Template

# Check whenever eco module is loaded
EcoStaticEngine::isInitialized = ->
  !!eco


# Autoload eco library
EcoStaticEngine::initializeEngine = ->
  eco = @require("eco")


# Lazy evaluation
EcoStaticEngine::toString = ->
  lazy = @lazy
  source = lazy.source
  return source(lazy.context)  if lazy and source and _.isFunction(source)
  throw new Error("EcoStaticEngine does not seem to be evaluated yet")


# Render data
EcoStaticEngine::evaluate = (context, locals, callback) ->

  # Precompile dependencyAssets except itself.
  files = (for p in context.__dependencyAssets__
    continue if p is context.pathname
    asset = context.environment.findAsset p, bundle: false
    asset.logicalPath)

  if files.length
    await context.environment.precompile files, defer e
    callback e if e

  #jshint unused:false
  try
    @lazy =
      source: eco.compile(@data.trimRight())
      context: _.extend(_.clone(context), locals)

    prop this, "lazySource", @lazy.source
    callback null, this
  catch err
    callback err
