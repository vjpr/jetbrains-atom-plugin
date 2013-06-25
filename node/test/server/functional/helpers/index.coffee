require('config/logging')()
require('chai').should()
et = require 'errto'
_ = require 'underscore'

# Monkey-patch Superagent to support custom serializers.
#superagent = require('supertest/node_modules/superagent')
#superagent.serialize['application/json-patch'] = JSON.stringify

supertest = require('supertest')

# Monkey-patch Supertest#Test to support cookies.
supertest.Test::agent = (agent) ->
  if agent? then agent.attachCookies @
  return @

@fixtures = require '../.'
{login, register} = require 'login'

@app = app = require('main/app').app()
@request = request = supertest app

# Add cookies to all Supertest Tests.
#methods = require('supertest/node_modules/methods')
#for method in methods
#  _.wrap request[method], (fn) ->
#    fn.agent(agent)

@registerUser = (user, done) ->
  ne = et.bind null, done
  await register request, user, ne defer agent
  await exports.getUser agent, ne defer user
  done null, agent, user

# TODO: Update userTest!
#@loginUser = (user, done) ->
#  await login request, user, ne defer agent
#  await exports.getUser agent, ne defer user
#  done null, agent

@getUser = (agent, done) ->
  await request.get('/api/users/me').agent(agent).end et done, defer r
  done null, r.body

@ignoreTimestamps = (body) ->
  _.omit body, 'createdAt', 'updatedAt'

#
# Global before
#
before (done) ->
  # This error-handler prints out the stack-trace.
  # Useful when we get a 500.
  errorHandler = (e, r) ->
    #console.error r.text
    errStr = "#{e}"
    if r.text?
      errStr += "\n\n--- Response Body Text ---\n\n#{r.text}\n\n---\n"
    done errStr

  # Global error handler.
  @ne = et.bind null, errorHandler

  # Recreate database.
  db = require('bookshelf-db')
  await db.sync defer()
  db.init()

  # Create two users and store their agents for accessing their cookies.
  {vaughan, laurence} = exports.fixtures.users

  # TODO: Errors are not thrown!
  await exports.registerUser vaughan, @ne defer @agent, @user
  await exports.registerUser laurence, @ne defer @agent2, @user2

  # API Testing Helpers.
  l = (url) -> "/api/#{url}"

  @get = (url, opts, done) =>
    unless done? then done = opts; opts = {}
    _.defaults opts,
      expect: 200
    opts.agent = @agent if _.isUndefined opts.agent
    await request.get(url).agent(opts.agent).expect(opts.expect).end @ne defer {body}
    done body

  @api =
    post: (url, data, opts, done) =>
      unless done? then done = opts; opts = {}
      _.defaults opts, agent: @agent
      await request.post(l url).agent(opts.agent).send(data).expect(200).end @ne defer {body}
      done body

    get: (url, opts, done) =>
      unless done? then done = opts; opts = {}
      _.defaults opts,
        agent: @agent
        expect: 200
      await request.get(l url).agent(opts.agent).expect(opts.expect).end @ne defer {body}
      done body

    del: (url, opts, done) =>
      unless done? then done = opts; opts = {}
      _.defaults opts, agent: @agent
      await request.del(l url).agent(opts.agent).expect(200).end @ne defer()
      done()

    put: (url, data, opts, done) =>
      unless done? then done = opts; opts = {}
      _.defaults opts, agent: @agent
      await request.put(l url).agent(opts.agent).send(data).expect(200).end @ne defer {body}
      done body

    #patchOverPut: (url, data, opts, done) =>
    #  unless done? then done = opts; opts = {}
    #  _.defaults opts, agent: @agent
    #  await request.put(l url)
    #    .agent(opts.agent)
    #    .send(data)
    #    .expect(200).end @ne defer {body}
    #  done body

    patch: (url, data, opts, done) =>
      unless done? then done = opts; opts = {}
      _.defaults opts, agent: @agent
      await request.patch(l url)
        .agent(opts.agent)
        .send(data)
        .expect(200).end @ne defer {body}
      done body

  done()

