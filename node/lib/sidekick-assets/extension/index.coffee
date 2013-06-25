#region Imports
logger = require('onelog').get 'Extension'
_ = require 'underscore'
__ = require 'errto'
#endregion

#region Libs
ExtensionCompiler = require './compiler'
ExtensionPackager = require './packager'
ExtensionWatcher = require './watcher'
ExtensionDeployer = require './deployer'
assetsConfig = require '../config'
#endregion

# Public
# ------

@CompileExtensionOnFileChange = (env, ctx) ->

  ExtensionWatcher.watch ctx, _.partial(compileDevExtension, env), ->
    logger.info 'Watching extension assets'

@CompileExtensionOnLoad = (env, done = ->) ->
  logger.info 'Compile extension on first load: started'
  compileDevExtension env, (e, r) ->
    logger.info 'Compile extension on first load: finished'
    done e, r

@CompileExtensionForDeploy = (env, _package, deploy, done = ->) ->

  {outputDir} = assetsConfig.extension.compile.prod

  # Compile.
  files = _.flatten [
    assetsConfig.extension.extensionFiles
    assetsConfig.extension.packageExtensionFiles
  ]
  await ExtensionCompiler.compile env, files, outputDir, __ done, defer()

  return done() unless (_package or deploy)

  # Package.
  await ExtensionPackager.package outputDir, __ done, defer()

  return done() unless deploy

  # Deploy.
  packageDir = assetsConfig.extension.package.outputDir
  await ExtensionDeployer.deploy packageDir, __ done, defer()

  done()

#
# ---
#

compileDevExtension = (env, done = ->) ->

  {outputDir} = assetsConfig.extension.compile.dev

  # Compile.
  files = assetsConfig.extension.extensionFiles
  await ExtensionCompiler.compile env, files, outputDir, __ done, defer()
  done()
