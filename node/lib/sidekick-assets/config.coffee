{join} = require 'path'
config = require('config')()

compiledRoot = join process.cwd(), 'compiled'

module.exports =

  app:

    searchPaths: [
      'assets/app/js'
      'assets/app/templates'
      'assets/app/css'
      'assets/vendor/js'
      'assets/vendor/css'
      'assets/components'
      'test/client/app'
      'test/client/vendor'
    ]

    precompileFiles: [
      'application.js'
      'style.css'
      'admin.js'
      'admin.css'
      'test.js'
      'test.css'
    ]

  extension:

    package: do ->
      crxName = 'Sidekick3.crx'
      codebase: "http://sidekick3-extension.s3-website-ap-southeast-2.amazonaws.com/#{crxName}"
      outputDir: join compiledRoot, 'extension-pkg'
      crxName: crxName

    compile:
      dev:
        outputDir: join compiledRoot, 'extension-dev'
      prod:
        outputDir: join compiledRoot, 'extension-prod'

    searchPaths: [
      'assets/extension/css'
      'assets/extension/img'
      'assets/extension/js'
      'assets/extension/json'
      'assets/extension/html'
    ]

    # Must be precompiled in development mode.
    precompileFiles: [
      #'extension/sidebar.css'
      #'extension/sidebar.js'
      #'extension/newtab/newtab.js'
      #'extension/newtab/newtab.css'
      #'extension/background/background.js'
    ]

    # These are the only files which need to be compiled during a dev
    # workflow.
    extensionFiles: [
      'manifest.json'
      # Content script.
      #'extension/contentScript.js'
      #'extension/contentScript.css'
      # New tab page override.
      #'extension/newtab/newtab.html'
      # Background page.
      #'extension/background/background.html'
    ]

    # When packaging extension these files should be included.
    packageExtensionFiles: [
      # Background page.
      #'extension/background/background.js'
      # New tab page override.
      #'extension/newtab/newtab.css'
      #'extension/newtab/newtab.js'
    ]

    # We recompile and reload extension if source files in these dirs
    # change. Extension only needs to be recompiled when manifest changes
    # or content scripts.
    # TODO: If we can serve content scripts remotely then we won't have to
    #   recompile the extension so often.
    extensionWatchDirs: [
      'assets/extension'
    ]
