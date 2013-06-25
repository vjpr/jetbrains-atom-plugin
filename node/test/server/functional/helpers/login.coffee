superagent = require 'superagent'
et = require 'errto'

@login = (request, user, done) ->
  agent = superagent.agent()
  await request
    .post('/login')
    .send({username: user.email, password: user.password})
    .end et done, defer res
  agent.saveCookies res
  done null, agent

# TODO: Failure of registration results in a redirect to getRegisterPath
#   and a flash message.
@register = (request, user, done) ->
  agent = superagent.agent()
  await request
    .post('/register')
    .send({name: user.name, username: user.email, password: user.password})
    .end et done, defer res
  agent.saveCookies res
  done null, agent
