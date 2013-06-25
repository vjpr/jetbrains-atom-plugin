#region
logger = require('onelog').get 'ExtensionDeployer'
knox = require 'knox'
wrench = require 'wrench'
__ = require 'errto'
{join} = require 'path'
#endregion

module.exports = class ExtensionDeployer

  @deploy: (packageDir, done) ->

    logger.info 'Deploy extension: started'

    client = knox.createClient
      key: process.env.AWS_ID
      secret: process.env.AWS_SECRET
      bucket: 'sidekick3-extension'
      region: 'ap-southeast-2'

    files = wrench.readdirSyncRecursive packageDir

    for filename in files
      f = join(packageDir, filename)
      await client.putFile f, filename,
        'x-amz-acl': 'public-read'
      , __ done, defer res
      logger.debug 'Uploaded', filename

    logger.info "Deploy extension: #{'successful'.green}"

    done()
