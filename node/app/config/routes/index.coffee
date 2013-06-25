{Map, authenticate} = require 'routes'

module.exports = ->
  @routes = map = Map @app
  map.camelCaseHelperNames = true
  map.root 'app#index'
  map.get 'app', 'app#app'
