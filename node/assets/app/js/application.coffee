#= require underscore/underscore
#= require backbone/backbone
#= require ./list

class App

  start: ->
    window.list = new List

    list.appendHtml "<div>Hello!</div>"

    socket = io.connect 'http://localhost'

    socket.on 'fileOpen', (data) ->
      data = JSON.parse data
      list.appendEditor data.fileName, data.contents

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
