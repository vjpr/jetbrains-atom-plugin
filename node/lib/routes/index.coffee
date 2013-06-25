routes = require 'railway-routes'
_ = require 'underscore'
__ = require 'errto'

@Map = (app) ->
  routes.Map app, handler

getControllerPath = (ns, controller) -> "controllers/#{ns}#{controller}"
getControllerClass = (ns, controllerName) ->
  file = getControllerPath ns, controllerName
  require(file)

@authenticate = (req, res, next) ->
  unless req.user?
    res.format
      text: -> res.redirect 'login'
      html: -> res.redirect 'login'
      json: -> res.send 401
  else next()

makeHandlerNotFound = (ns, controller, action) ->
  return (req, res) ->
    res.send 500, "Handler not found for #{ns}#{controller}##{action}"

handler = (ns, controller, action, options) ->

  try
    responseHandler = liveControllerHandler(ns, controller, action, @latestResource, options.state?.resourceName)

  handlerNotFound = makeHandlerNotFound ns, controller, action

  # For `:controller/:action` routes.
  genericRouter = (req, res) ->
    try
      responseHandler = liveControllerHandler(ns, req.params.controller, req.params.action)
    catch e
      responseHandler = makeHandlerNotFound ns, req.params.controller, req.params.action
    responseHandler(req, res)

  if controller
    return responseHandler or handlerNotFound
  return (req, res, next) -> next()
  #else
  #  genericRouter

# For working with LiveFramework controllers. Allows us to run
# methods before and after, and pass a custom context to our controller
# methods.
#
# Returns a connect handler (req, res, next).
liveControllerHandler = (ns, controllerName, action, latestResourceName, resourceName) ->

  # Get parent Controllers
  if latestResourceName?
    parentControllers = []
    parentControllers.push
      clazz: getControllerClass ns, latestResourceName
      ns: ns
      resourceName: latestResourceName
    # TODO: Get more.

  Controller = getControllerClass ns, controllerName
  throw new Error 'Controller not found' unless Controller?

  return (req, res, next) ->

    controller = new Controller req, res, next

    # TODO: This should be a better check.
    isLiveController = controller.req?

    if isLiveController
      controller.resourceName = resourceName or controllerName
      controller.parentControllers = parentControllers
      _.extend controller.req,
        controller: {ns, controllerName, controller, action}
      await before controller, __ next, defer()

    # TODO: Check if function returns.
    unless controller[action]?
      return next "#{controllerName}##{action} does not exist"

    controller[action] req, res, next

    #if isLiveController
    #  await after controller, __ next, defer()
    #next()

before = (controller, next) ->
  await loadResources controller, __ next, defer()
  next()

# NOTE: The response is already sent!
# To add something to the response we will have to modify the @send method.
after = (controller, next) ->
  next()

loadResources = (controller, next) ->

  # Run `load` method from parent controller(s).
  # TODO: Waiting for https://github.com/1602/railway-routes/pull/19
  parentControllers = controller.parentControllers or []

  for c in parentControllers
    resourceName = c.resourceName.singularize()
    idParam = "#{resourceName}_id"
    await controller.loadResource resourceName, idParam, c.clazz::load, __ next, defer()

  # Only load on show, delete, update.
  return next() unless controller.constructor::load?
  return next() unless _(['show', 'destroy', 'update', 'patch']).contains controller.req.controller.action

  # Run `load` method from current controller.
  resourceName = controller.resourceName.singularize()
  idParam = 'id'

  await controller.loadResource resourceName, idParam, controller.constructor::load, __ next, defer()

  next()
