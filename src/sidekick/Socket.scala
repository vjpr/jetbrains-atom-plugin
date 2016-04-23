package sidekick

import org.jfarcand.wcs.{MessageListener, WebSocket}
import java.util.concurrent.ExecutionException
import scala.actors.{TIMEOUT, Actor}

// Handles web socket communication.
object Socket extends Logging {

  val URL = "ws://localhost:4949"
  var ws = WebSocket()
  var status = 'closed
  var lastConnectAttempt: Option[Long] = None

  def connect {
    log info "Connecting to " + URL
    status = 'connecting
    lastConnectAttempt = Some(System.currentTimeMillis())
    val router = new MessageRouter
    ws listener new MessageListener {
      override def onMessage(message: Array[Byte]) {
        router onMessage message
      }
      override def onOpen() {
        Socket.status = 'open
        log info "Connection opened"
        log info ws.isOpen.toString
      }
      override def onClose() {
        Socket.status = 'closed
        log info "Connection closed"
      }
      override def onError(t: Throwable) {
        log info "Websockets error:"
        log info t.getMessage
        log info t.getStackTraceString
      }
    }
    try {
      ws = ws open URL
    } catch {
      case e: ExecutionException => {
        log info e.getMessage
        status = 'closed
      }
    }
  }

  def send(method: String, params: String) {
    import net.liftweb.json.JsonDSL._
    import net.liftweb.json._
    val json =
      ("method" -> method) ~
      ("params" -> params)
    log info "Sending: " + compact(render(json))
    ws send compact(render(json))
  }

}

// Attempts to reconnect to web sockets server if not connected.
object ReconnectTimer extends Logging {

  var sched: Actor = null
  val RECONNECT_TIMEOUT = 5000

  def start =
    sched = scheduler(RECONNECT_TIMEOUT) {
      log info s"WebSockets status: ${Socket.status}"
      if (Socket.status == 'closed) Socket.connect
    }

  def stop = sched ! 'stop

  def scheduler(time: Long)(f: => Unit) = {
     def fixedRateLoop {
       Actor.reactWithin(time) {
         case TIMEOUT => f; fixedRateLoop
         case 'stop => exit
       }
     }
     Actor.actor(fixedRateLoop)
   }
}
