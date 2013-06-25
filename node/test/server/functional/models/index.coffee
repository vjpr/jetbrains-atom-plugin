require '.'
__ = require 'errto'
_ = require 'underscore'
hash = require 'node_hash'
describe 'Models', ->

  {Models} = require 'bookshelf-db'

  describe 'Link', ->

    beforeEach ->

    it '#findOrCreate', (done) ->
      link =
        title: 'Google'
        url: 'http://google.com'
      link.urlHash = hash.sha1 link.url
      await Models.Link.findOrCreate link.title, link.url, __ done, defer actual
      actual = actual.omitGenerated()
      actual.should.eql link
      done()

  describe 'User', ->

    it '#findOrCreate', (done) ->
      profile =
        id: 'facebookid'
        displayName: 'Vaughan'
      await Models.User.findOrCreate profile, __ done, defer actual
      actual = actual.omitGenerated()
      expected =
        name: profile.displayName
        fb: JSON.stringify profile
        fbId: profile.id
      actual.should.eql expected
      done()

  describe 'UserService', ->

    it '#removeAll', (done) ->
      await Models.User.removeAll().exec __ done, defer actual
      done()

    it '#findById', (done) ->
      user =
        name: 'Vaughan'
        email: 'test1@test.com'
        password: 'test'
      await Models.User.forge(user).save().exec __ done, defer newUser
      await Models.User.findById(newUser.id).exec __ done, defer actual
      actual = actual.omitGenerated()
      actual = _.omit actual, 'id', 'salt', 'fb', 'fbId'
      actual.should.eql user
      done()

    it '#create', (done) ->
      user =
        name: 'Vaughan'
        email: 'test1@test.com'
        password: 'test'
      await Models.User.forge(user).save().exec __ done, defer actual
      actual = actual.omitGenerated()
      actual = _.omit actual, 'id', 'salt', 'fb', 'fbId'
      actual.should.eql user
      done()

    it '#find', (done) ->
      # TODO: Brittle.
      await Models.User.find({email: 'test1@test.com'}).exec __ done, defer coll
      coll.should.not.be.null
      done()
