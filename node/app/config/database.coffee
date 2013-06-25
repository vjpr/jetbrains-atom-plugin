parseConnString = (connString) ->
  url     = require 'url'
  dbUrl   = url.parse connString
  authArr = dbUrl.auth.split ':'
  dbOptions =
    name: dbUrl.path.substring(1)
    user: authArr[0]
    pass: authArr[1]
    host: dbUrl.hostname
    port: dbUrl.port
    dialect: 'postgres'
    protocol: 'tcp'
  dbOptions

module.exports = (config) ->

  remotePostgresUrl = process.env.DATABASE_URL

  pg = if remotePostgresUrl?
    parseConnString remotePostgresUrl
  else {}

  mongo:
    development:
      url: "mongodb://localhost/#{config.appName}"
      debug: true
    test:
      url: "mongodb://localhost/#{config.appName}-test"
      debug: true
    production:
      url: process.env.MONGOLAB_URI or process.env.MONGOHQ_URL or "mongodb://localhost/#{config.appName}-prod"
      debug: false

  redis:
    development:
      url: "localhost"
    production:
      url: process.env.REDISTOGO_URL
    test:
      url: "localhost"

  postgres:
    development:
      host: 'localhost'
      name: 'sidekick3'
      dialect: 'postgres'
      username: 'postgres'
      password: null
    test:
      name: pg.name or 'sidekick3-test'
      username: pg.user or 'postgres'
      password: pg.pass or null
      host: pg.host or 'localhost'
      port: pg.port or 5432
      protocol: 'tcp'
      dialect: pg.dialect or 'postgres'
    production:
      name: pg.name or 'sidekick-prod'
      username: pg.user
      password: pg.pass
      host: pg.host
      port: pg.port
      protocol: 'tcp'
      dialect: pg.dialect
