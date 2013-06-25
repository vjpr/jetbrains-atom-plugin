module.exports = class TestController

  allTests: (req, res) ->
    res.render process.cwd() + '/test/client/views/test'
