#db = require 'bookshelf-db'
util = require 'util'
_ = require 'underscore'
__ = require 'errto'

Function::getter = (prop, get) ->
  Object.defineProperty @prototype, prop, {get, configurable: yes}

Function::setter = (prop, set) ->
  Object.defineProperty @prototype, prop, {set, configurable: yes}

module.exports = class BaseController

  # NOTE: Only use @next from within a controller.
  constructor: (@req, @res, @next) ->
    #@send = (val) =>
    #  val = if val.toJSON? then val.toJSON() else val
    #  @res.send val, _.rest arguments

    @send = _.bind @res.send, @res
    @render = _.bind @res.render, @res
    @redirect = _.bind @res.redirect, @res
    @console = __.bind @res.console, @res
    @assert = @req.assert
    @query = @req.query
    @body = @req.body
    @user = @req.user
    @ok = __.bind null, @next
    @resourceName = null # This is set by the controller path.

  @getPage: (req) ->
    if req.query.p? then parseInt(req.query.p) else 1

  # Items per page.
  @PAGE_ITEMS = 10

  #@getter 'db', -> db.Models

  invalid: =>
    errors = @req.validationErrors()
    return false unless errors?
    # TODO: Create error string for html response.
    # TODO: Use express content-negotiation instead.
    switch @req.params.format
      when 'json' then @send 400, errors: util.inspect(errors)
      when 'html' then @send 400, errors
      else @send 400, errors
    return true

  loadResource: (resourceName, idParam, loadFn, next) =>
    return next() unless loadFn?
    # Get id from request.
    id = @req.params[idParam]
    unless id? then return @send 400, 'No resource id given'
    # TODO: User should not be able to call @next method as it will terminate the request pipeline.
    #   Maybe we should rebind it when running helpers/filters/etc.
    await loadFn.call @, @req, id, __ next, defer resource
    unless resource?
      if @req.controller.action is 'destroy'
        return @send 204
      else
        return @send 404
    @req[resourceName] = resource
    # Don't override any props.
    unless @[resourceName]? then @[resourceName] = resource
    next()
