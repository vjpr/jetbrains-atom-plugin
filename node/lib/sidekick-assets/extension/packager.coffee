#region Imports
logger = require('onelog').get 'ExtensionPackager'
ChromeExtension = require 'crx'
__ = require 'errto'
wrench = require 'wrench'
fs = require 'fs'
mkdirp = require 'mkdirp'
path = require 'path'
#endregion

#region Libs
assetsConfig = require '../config'
#endregion

module.exports = class ExtensionPackager

  # Package Chrome Extension as `.crx` file.
  @package: (unpackedDir, done) ->

    logger.info 'Package extension: started'

    crx = new ChromeExtension
      codebase: assetsConfig.extension.package.codebase
      privateKey: fs.readFileSync path.join(__dirname, 'chrome.pem')
      rootDirectory: unpackedDir

    crx.load __ done, ->
      @pack __ done, (data) ->
        updateXML = @generateUpdateXML()
        {outputDir, crxName} = assetsConfig.extension.package
        wrench.rmdirSyncRecursive outputDir, true
        mkdirp.sync outputDir
        fs.writeFileSync path.join(outputDir, 'update.xml'), updateXML
        fs.writeFileSync path.join(outputDir, crxName), data

        logger.info "Package extension: #{'successful'.green}"

        done()
