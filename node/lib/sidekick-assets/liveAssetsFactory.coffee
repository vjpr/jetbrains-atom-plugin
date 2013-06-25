#region Imports
logger = require('onelog').get 'Assets'
mincerLogger = require('onelog').get 'Assets:Mincer'
path = require 'path'
_ = require 'underscore'
Assets = require 'live-assets'
JadeMultiEngine = require 'live/assets/jadeMultiEngine'
CoffeecupEngine = require 'live/assets/coffeecupEngine'
IcedCoffeeEngine = require 'live/assets/icedCoffeeEngine'
#endregion

#region Libs
EcoStaticEngine = require './engines/ecoStaticEngine'
CsonEngine = require './engines/csonEngine'
#endregion

###
Builds a LiveAssets instance. This is used in a few places.
 - Serving dynamic assets for our website and extension (dev).
 - Precompiling assets for extension.
 - Precompiling assets for website.
###
module.exports = class LiveAssetsFactory

  @getInstance: (config, _opts) ->

    # Default options.
    opts =
      paths: []
      files: []
      digest: false
      expandTags: config.assets.expandTags
      assetServePath: '/assets/'
      remoteAssetsDir: config.assets.remoteAssetsUrl
      usePrecompiledAssets: config.assets.usePrecompiledAssets
      root: process.cwd()
      logger: logger
      mincerLogger: mincerLogger
      inPageErrorVerbosity: config.assets.inPageErrorVerbosity
      afterEnvironmentCreated: ->

        Mincer = @getMincer()
        Mincer.Template.cacheDir = path.join process.cwd(), 'tmp/mincer'

        # Use IcedCoffeeScript instead of CoffeeScript
        @env.registerEngine '.coffee', IcedCoffeeEngine
        @env.registerEngine '.litcoffee', IcedCoffeeEngine
        @env.registerEngine '.mjade', JadeMultiEngine
        @env.registerEngine '.ck', CoffeecupEngine
        @env.registerEngine '.eco', EcoStaticEngine
        @env.registerEngine '.cson', CsonEngine

        @env.registerMimeType 'application/json', '.json'
        @env.registerMimeType 'text/html', '.html'

        @env.unregisterPostProcessor 'application/javascript', Mincer.DebugComments

        @env.registerPreProcessor 'text/html', Mincer.DirectiveProcessor

        @env.appendPath path.join process.cwd(), 'node_modules/flat-ui-pro/lib'

    _.extend opts, _opts

    new Assets opts
