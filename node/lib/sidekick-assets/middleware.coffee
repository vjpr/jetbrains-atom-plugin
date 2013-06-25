module.exports = class Middleware

  @precompileAssetsForDevelopment: (app, assets) ->

    # In development/test, precompile on every HTML request.
    switch app.get 'env'
      when 'development'
        app.use (req, res, next) ->
          isHTMLRequest = req.accepted[0]?.value is 'text/html'
          if isHTMLRequest
            assets.precompileForDevelopment (err) ->
              return next err if err
              next()
          else
            next()
      else break

  @attachLiveAssetsMiddleware: (app, assets) ->

    # Attach LiveAssets middleware to our application.
    assets.middleware app

