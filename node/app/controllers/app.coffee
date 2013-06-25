BaseController = require 'patches/baseController'

module.exports = class AppController extends BaseController

  #index: =>
  #  @render 'index'

  app: =>
    @render 'app'
