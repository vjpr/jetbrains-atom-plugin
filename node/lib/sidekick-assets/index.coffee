#region Imports
config = require('config')()
logger = require('onelog').get 'SidekickAssets'
_ = require 'underscore'
#endregion

#region Libs
LiveAssetsFactory = require './liveAssetsFactory'
Middleware = require './middleware'
Extension = require './extension'
assetsConfig = require './config'
Helpers = require './helpers'
#endregion

###
This is the primary interface for everything to do with assets.
###
module.exports = class @SidekickAssets

  # Plugin for Express.
  @LivePlugin: ->
    @assets = getAssetManager @config,
      helpers: Helpers.get isExtension: false
      ###
      In development our background page and content script requests assets
      from localhost. With our normal app the endpoint is relative to the
      domain the page is being loaded on, so our asset path is `/assets/`.
      With our extension we need to be explicit.
      ###
      assetServePath: config.app.url + '/assets/'

    Middleware.precompileAssetsForDevelopment @app, @assets
    Middleware.attachLiveAssetsMiddleware @app, @assets

    if @config.env is 'development'
      # Use environment variables to control whether extension is compiled on
      # load and on file change.
      if process.env.SK_EXT_COMPILE is 1
        Extension.CompileExtensionOnLoad @assets.env, ->
      unless process.env.SK_EXT_WATCH is 0
        Extension.CompileExtensionOnFileChange @assets.env, @, ->

  @compileExtension: (opts = {}, done) ->
    _.defaults opts,
      minify: false
      package: false
      deploy: false

    # These options are passed to LiveAssets constructor.
    assetsOpts =
      minify: opts.minify
      # Must be set or two precompiles will be run simultaenously.
      usePrecompiledAssets: false
      helpers: Helpers.get isExtension: true
      assetServePath: if config.env is 'production'
        '/'
      else
        # Assumes assets are still being served from dev server even after
        # extension is compiled.
        # TODO: This might not be neccessary.
        config.app.url

    assets = getAssetManager config, assetsOpts
    Extension.CompileExtensionForDeploy assets.env, opts.package, opts.deploy, done

  # TODO
  #@compileWebsite: (opts) ->
    #_.defaults opts,
    #  minify: false
    #assets = getAssetManager config, opts

getAssetManager = (config, _opts) ->

  paths = _.flatten [
    assetsConfig.app.searchPaths
    assetsConfig.extension.searchPaths
  ]

  files = _.flatten [
    assetsConfig.app.precompileFiles
    assetsConfig.extension.precompileFiles
  ]

  opts =
    paths: paths
    files: files

  _.extend opts, _opts

  LiveAssetsFactory.getInstance config, opts
