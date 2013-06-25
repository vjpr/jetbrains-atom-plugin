# This service should contain all Socket.IO listeners.

module.exports = class SocketService

  constructor: (@io, @pluginSocket) ->

    # DEBUG: Send some messages on load.
    @io.on 'connection', (socket) ->
      socket.emit 'import',
        redirect: "http://www.scala-lang.org/api/current/index.html#scala.actors.Reactor"
      socket.on 'message', (q, fn) ->
        console.log q
    # ---

  reloadExtension: =>
    console.log 'Reloading extension'
    @io.sockets.emit 'reloadExtension'

  reloadPage: =>
    console.log 'Reloading page'
    @io.sockets.emit 'reloadPage'
