#region Imports
logger = require('onelog').get()
path = require 'path'
watchr = require 'watchr'
assetsConfig = require '../config'
ExtensionCompiler = require './compiler'
#endregion

# Whether we are already running a precompile job.
# Without this check multiple precompile jobs are run unneccessarily.
isCompiling = false

###
- Recompile extension when files change.
- Reload all Chrome extensions by sending a socket.io message.

NOTE: You must have installed the `Reload Extensions` Chrome extension
  for this to work.
###
module.exports = class ExtensionWatcher

  @watch: (ctx, compileFn, done) ->

    watchr.watch
      duplicateDelay: 1000
      paths: assetsConfig.extension.extensionWatchDirs
      listeners:
        change: (changeType, filePath) =>
          logger.debug "File changed:", filePath
          # Don't reload for CSS - let LiveReload do that.
          return if path.extname(filePath) is '.less'
          return if isCompiling
          isCompiling = true
          await compileFn defer err
          isCompiling = false
          return if err
          ctx.socketsService.reloadExtension()
      next: done
