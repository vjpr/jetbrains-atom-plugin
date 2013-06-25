app.get "/", routes.index
app.listen 3005
console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env

pluginSocket = null

clientSocket = null

# IntelliJ Plugin websocket communications
# ------------------------------------------------------------------------------

wio = ws.listen 4949
wio.on 'connection', (socket) ->
  console.log 'Plugin connection request received'
  routes.setSocket socket
  pluginSocket = socket
  socket.on 'message', (data) ->
    data = JSON.parse data
    console.log data.method
    switch data.method
      when 'FileEditorEvent.SelectionChanged'
        console.log "Sending"
        clientSocket.emit 'fileOpen', data.params

# Socket.io
# ------------------------------------------------------------------------------

sio = io.listen app

sio.configure ->
  sio.set 'log level', 1

## For Heroku-compatability
#if app.settings.env is 'production'
#  sio.configure ->
#    sio.set "transports", ["xhr-polling"]
#    sio.set "polling duration", 10

sio.sockets.on 'connection', (socket) ->
  clientSocket = socket

  socket.emit 'import',
    redirect: "http://www.scala-lang.org/api/current/index.html#scala.actors.Reactor"

  socket.on 'message', (q, fn) ->
    console.log q
