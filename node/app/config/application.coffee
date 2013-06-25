#region Imports
{Live} = require 'live'
config = require('config')()
path = require 'path'
logger = require('onelog').get 'BodyLogger'
#endregion

class @App extends Live.Application

  configure: ->

    @use require 'express-chrome-logger'
    @enable Live.DefaultLibraries

    # Asset Management.
    console.time 'app.assets'
    SidekickAssets = require 'sidekick-assets'
    @enable SidekickAssets.LivePlugin
    console.timeEnd 'app.assets'

    connectLogging @

    console.time 'app.middleware'
    @enable Live.RedisSession
    @enable Live.JadeTemplating
    @enable Live.StandardPipeline
    #@enable Live.PassportAuth.Middleware
    @enable Live.StandardRouter
    @enable Live.ErrorHandling
    console.timeEnd 'app.middleware'

    payloadLogging @

    console.time 'app.routes'
    @enable require('./routes')
    console.timeEnd 'app.routes'

    #@enable Live.PassportAuth.Routes

    setupSockets @

    @app.locals title: config.appPrettyName

    @app


connectLogging = (ctx) ->
  # Should be after asset serving unless we want to log asset requests.
  onelog = require 'onelog'
  #log4js = onelog.getLibrary()
  #connectLogger = require('onelog').get 'connect'
  #@use log4js.connectLogger connectLogger,
  #  level: log4js.levels.INFO
  #  format: ':method :url'
  if config.env is 'development'
    ctx.use require('connect').logger('dev')

payloadLogging = (ctx) ->
  # Log payload - must run after bodyParser.
  bodyLogger = require('onelog').get 'BodyLogger'
  switch config.env
    when 'test', 'development'
      ctx.use (req, res, next) ->
        if req.body? then bodyLogger.debug req.body
        next()
    else break

setupSockets = (ctx) ->

  clientSocket = null
  pluginSocket = null

  # IntelliJ <-> Node
  ws = require 'websocket.io'
  wio = ws.listen 4949
  wio.on 'connection', (socket) ->
    console.log 'Plugin connection request received'
    ctx.pluginSocket = socket
    socket.on 'message', (data) ->
      data = JSON.parse data
      console.log data.method
      switch data.method
        when 'FileEditorEvent.SelectionChanged'
          console.log "Sending"
          clientSocket.emit 'fileOpen', data.params

  # Node <-> Browser
  ctx.app.on 'server:listening', (server) =>
    SocketsManager = require 'live/sockets/socketsManager'
    sm = new SocketsManager server, ctx.sessionStore,
      onConnection: (socket) =>
        clientSocket = socket
        SocketsConnection = require 'sockets/socketsConnection'
        new SocketsConnection socket
    SocketsService = require 'services/socketsService'
    ctx.socketsService = new SocketsService sm.io, pluginSocket
