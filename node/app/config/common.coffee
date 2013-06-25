module.exports = (config) ->
  appName: 'sidekick-programmers'
  appPrettyName: 'Sidekick Programmers'
  port: 3031
  # TODO: Change this to the url where your site is hosted in production.
  #   See `environments/production` for usage.
  # This is provided as the address Facebook auth should callback to.
  deployUrl: null

  # Which database is used for the User model.
  services:
    user: 'bookshelf'
    #user: 'sequelize'
    #user: 'mongoose'

