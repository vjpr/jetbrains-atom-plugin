#= require underscore/underscore
#= require backbone/backbone
#= require_tree ./templates
#= require ./editor
#= require ./list
#= require jade-runtime

class App

  start: ->
    window.list = new List

    window.socket = io.connect 'http://localhost'

    socket.on 'fileOpen', (data) ->
      data = JSON.parse data
      list.appendEditor data.fileName, data.contents, data.comment

    socket.on 'CaretEvent.PositionChanged', (data) ->
      data = JSON.parse data
      #chars = ( data.whitespace.charCodeAt(i) for c, i in data.whitespace )
      #list.appendEditor null, "`#{chars}`" + data.contents
      list.appendEditor null, data.whitespace + data.contents, data.comment, data.path, data.offset

    socket.on 'message', (data) ->

    socket.on 'news', (data) ->
      console.log data
      socket.emit 'my other event', { my: 'data' }

    socket.on 'import', (data) ->
      #$('iframe').attr src: data.redirect

$(document).ready ->
  console.log "Starting Sidekick for Programmers"
  window.app = new App
  app.start()
