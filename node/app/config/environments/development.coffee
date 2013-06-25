module.exports = (config) ->
  app:
    port: config.port
    #url: "http://localhost.#{config.appName}.herokuapp.com:#{config.port}"
    url: "http://localhost:#{config.port}"
    tryOtherPortsIfInUse: true
  assets:
    remoteAssetsUrl: "/"
    expandTags: true
    usePrecompiledAssets: false
    inPageErrorVerbosity: 'dev'
