#iced.catchExceptions()

findPortToRunDevServer = (cb) ->
  # We must find the port our development server is going to run on
  # because it is used in some of the auth settings.
  portscanner = require 'portscanner'
  portscanner.findAPortNotInUse 3030, 3100, 'localhost', cb

# `app` is exposed because we do not want to start the app when testing
# the server.
@app = ->
  {App} = require 'config/application'
  app = new App
  # This is the Express app object for testing purposes.
  app.app

# This is invoked in `app.js` when we want to actually run the app.
@start = (env, done = ->) ->

  console.time 'app ready'
  onStarted = (e, r) ->
    console.timeEnd 'app ready'
    done e, r

  unless env?
    env = process.env.NODE_ENV or 'development'
  unless env is 'production'
    await findPortToRunDevServer defer e, port
    return done e if e
    run env, port, onStarted
  else
    run env, null, onStarted

run = (env, port, done) ->

  console.time 'requires'
  require('config') env, null, {port}
  require('config/logging')()
  {App} = require 'config/application'
  console.timeEnd 'requires'

  console.time 'app'
  app = new App
  console.timeEnd 'app'

  console.time 'app#start'
  await app.start defer e
  console.timeEnd 'app#start'

  return done e if e
  done null, app.app
