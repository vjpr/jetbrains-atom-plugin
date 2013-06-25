#region Imports
config = require('config')()
logger = require('onelog').get 'ExtensionCompiler'
path = require 'path'
wrench = require 'wrench'
path = require 'path'
__ = require 'errto'
mkdirp = require 'mkdirp'
fs = require 'fs'
wrench = require 'wrench'
_ = require 'underscore'
#endregion

module.exports = class ExtensionCompiler

  @compile: (env, filesToCompile, outputDir, done) ->

    logger.info "Compile extension: started"

    wrench.rmdirSyncRecursive outputDir, true
    await ExtensionCompiler.precompile env
    , filesToCompile
    , outputDir
    , defer err, {data, duration}
    if err
      logger.error "Precompile: #{'failed'.red}", err
      return done err
    logger.trace data
    for k of data.assets
      asset = env.findAsset k
      data = asset.buffer.toString()
      dest = path.join(outputDir, k)
      mkdirp.sync path.dirname(dest)
      fs.writeFileSync dest, data

    logger.info "Compile extension: #{'successful'.green} in #{duration}s"

    done()

  @precompile: (env, files, dest, done) ->
    unless files?
      return done 'Specify `files` as an option to allow precompiling.'
    start = new Date()

    await env.precompile files, __ done, defer data

    duration = (new Date() - start) / 1000
    done null, {data, duration}
