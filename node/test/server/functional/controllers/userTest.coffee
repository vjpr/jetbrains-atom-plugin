{request, fixtures} = require '.'
et = require 'errto'
_ = require 'underscore'

describe 'UserController', ->

  describe '#index', ->

    beforeEach ->

    it 'should get index if logged in', (done) ->
      await @get '/app', defer(); done()

    it 'should redirect if not logged in', (done) ->
      await @get '/app', {agent: null, expect: 302}, defer(); done()

    it 'should display users name on profile', (done) ->
      await @get '/app', {expect: ///#{@user.name}///}, defer(); done()

  describe '#me', ->

    it 'should show current user', (done) ->
      await @get '/api/users/me', defer body
      expected = _.pick @user, 'name', 'email'
      actual = _(body).omit('id')
      actual.should.eql expected
      done()
