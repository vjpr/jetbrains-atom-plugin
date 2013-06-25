{request, fixtures, ignoreTimestamps} = require '.'

et = require 'errto'
_ = require 'underscore'

api = (url) -> "/api/#{url}"

describe 'User', ->

  describe 'Link', ->

    beforeEach ->
      @fixture = fixtures.links.wikipedia

    it 'can get user link info from url', (done) ->
      await @api.post "links", @fixture, defer newUserLink
      await @api.get "links?url=#{@fixture.url}", defer userLink
      userLink.should.eql _.extend newUserLink, collections: []
      done()

    it 'can publically keep a link', (done) ->
      _.extend @fixture, 'private': false
      await @api.post "links", @fixture, defer newUserLink
      await @api.get "links/#{newUserLink.id}", defer userLink
      userLink.private.should.equal false
      done()

    # We create a Link entity the first time someone adds it, which is
    # shared with all users.
    it 'can publically keep a link which at least one other user has added', (done) ->
      _.extend @fixture, 'private': false
      await @api.post "links", @fixture, @agent2, defer userLink1
      await @api.post "links", @fixture, @agent, defer userLink2
      userLink1.link.id.should.equal userLink2.link.id
      done()

    it 'can privately keep a link', (done) ->
      _.extend @fixture, 'private': true
      await @api.post "links", @fixture, defer newUserLink
      await @api.get "links/#{newUserLink.id}", defer userLink
      userLink.private.should.equal true
      done()

    it 'can unkeep a link', (done) ->
      _.extend @fixture, 'private': true
      await @api.post "links", @fixture, defer newUserLink
      await @api.del "links/#{newUserLink.id}", defer()
      await @api.get "links/#{newUserLink.id}", {expect: 404}, defer userLink
      done()

    it 'can make keep public', (done) ->
      _.extend @fixture, 'private': true
      await @api.post "links", @fixture, defer newUserLink
      await @api.patch "links/#{newUserLink.id}", {'private': false}, defer()
      await @api.get "links/#{newUserLink.id}", defer userLink
      userLink.private.should.equal false
      done()

    it 'can make keep private', (done) ->
      _.extend @fixture, 'private': false
      await @api.post "links", @fixture, defer newUserLink
      await @api.patch "links/#{newUserLink.id}", {'private': true}, defer()
      await @api.get "links/#{newUserLink.id}", defer userLink
      userLink.private.should.equal true
      done()

    describe 'Collection Links', ->

      beforeEach (done) ->
        link = fixtures.links.wikipedia
        coll = fixtures.collections.stuff
        await @api.post "collections", coll, defer @coll
        await @api.post "collections/#{@coll.id}/links", link, defer @link
        done()

      it 'can be added to a collection', (done) ->
        await @api.get "collections/#{@coll.id}/links", defer links
        links.length.should.equal 1
        links[0].id.should.equal @link.id
        done()

      it 'can be removed from a collection', (done) ->
        await @api.del "collections/#{@coll.id}/links/#{@link.id}", {expect: 204}, defer()
        await @api.get "collections/#{@coll.id}/links", defer links
        links.length.should.equal 0
        done()

  describe 'Collection', ->

    before ->
      @fixture = fixtures.collections.stuff

    beforeEach (done) ->
      await @api.post "collections", @fixture, defer @body
      done()

    it 'can be created', (done) ->
      await @api.get "collections/#{@body.id}", defer body
      expected = _.extend @fixture, {id: body.id, UserId: @user.id}
      actual = ignoreTimestamps body
      actual.should.eql expected
      done()

    it 'can be deleted', (done) ->
      await @api.del "collections/#{@body.id}", defer()
      await @api.get "collections/#{@body.id}", {expect: 404}, defer userLink
      done()

    it 'can be archived', (done) ->
      await @api.put "collections/#{@body.id}", {archived: true}, defer()
      await @api.get "collections/#{@body.id}", defer body
      expected = _.extend @fixture, {id: body.id, UserId: @user.id}
      expected.archived = true
      actual = ignoreTimestamps body
      actual.should.eql expected
      done()

  describe 'Comments', ->

    before ->
      @link = fixtures.links.wikipedia
      @comment = fixtures.comments.hi
      @privateComment = fixtures.comments.privateComment

    beforeEach (done) ->
      await @api.post 'links', @link, defer @body; done()

    it 'can publicly comment on a link', (done) ->
      await @api.post "links/#{@body.id}/comments", @comment, defer comment
      await @api.get "links/#{@body.id}/comments", defer comments

      actual = comments.map (c) =>
        c = ignoreTimestamps c
        c = _.omit c, 'UserId'
        c
      expected = _.extend @comment,
        id: comment.id
        LinkId: @body.link.id

      actual.length.should.equal 1
      actual.should.eql [expected]
      done()

    it 'can privately comment on a link', (done) ->
      await @api.post "links/#{@body.id}/comments", @privateComment, defer comment
      await @api.get "links/#{@body.id}/comments/#{comment.id}", defer actual
      expected = _.extend @privateComment,
        id: comment.id
        createdAt: actual.createdAt
        updatedAt: actual.updatedAt
        LinkId: @body.link.id
      actual.should.eql expected
      done()

  describe 'Share', ->

    it 'can privately share a link'
