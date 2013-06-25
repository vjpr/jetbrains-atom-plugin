class Routes

  setSocket: (socket) =>
    @socket = socket

  index: (req, res) =>
    if @socket?
      @socket.send JSON.stringify
        method: 'openFile'
        params:
          fileName: 'something'
          line: 1
          column: 1

    res.render 'index',
      title: 'Sidekick for Programmers'

exports.Routes = Routes
