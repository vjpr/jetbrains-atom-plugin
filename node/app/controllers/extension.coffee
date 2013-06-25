BaseController = require 'patches/baseController'

module.exports = class ExtensionController extends BaseController

  #sidebar: ->
    #@render 'extension/sidebar'

  #home: ->
    #@render 'extension/home'
