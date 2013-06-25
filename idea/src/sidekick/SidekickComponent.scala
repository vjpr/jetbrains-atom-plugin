package sidekick

import com.intellij.openapi.components.ApplicationComponent
import com.intellij.openapi.diagnostic.Logger
import com.intellij.openapi.application.ApplicationManager

import Implicits._
import com.intellij.openapi.vfs.{VirtualFileManager, VirtualFile}
import com.intellij.openapi.project.{ProjectManagerListener, ProjectManager, Project}
import com.intellij.psi.search.{GlobalSearchScope, FilenameIndex}
import java.io.File
import org.jfarcand.wcs.{BinaryListener, MessageListener, WebSocket}
import java.net.ConnectException
import java.util
import util.concurrent.ExecutionException
import actors.{TIMEOUT, Actor}
import sun.jvm.hotspot.runtime.Bytes
import com.codahale.jerkson.Json
import scala.Predef._
import net.liftweb.json.DefaultFormats
import com.intellij.openapi.actionSystem.PlatformDataKeys
import com.intellij.openapi.vfs.newvfs.BulkFileListener
import com.intellij.openapi.vfs.newvfs.events.VFileEvent
import com.intellij.openapi.fileEditor.{FileDocumentManagerListener, FileDocumentManager}
import com.intellij.ide.DataManager
import com.intellij.openapi.Disposable

trait Logging {
  val log: Logger = Logger.getInstance(getClass)
}

class SidekickComponent extends ApplicationComponent with Logging {

  def initComponent {
    Socket.connect
    Listeners.listen
    ReconnectTimer.start
    ProjectManager.getInstance().addProjectManagerListener(new ProjectManagerListener {
      def canCloseProject(project: Project) = false

      def projectOpened(project: Project) {
        Listeners.listenToProject(project)
      }

      def projectClosed(project: Project) {}

      def projectClosing(project: Project) {}
    })
  }

  def disposeComponent() {
    Socket.ws.close
    Listeners.disconnect
  }

  def getComponentName = "SidekickComponent"

}

object Implicits {

  implicit val formats = DefaultFormats
  implicit def runnable(f: () => Unit): Runnable =
    new Runnable() { def run() = f() }

}

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

object ReconnectTimer {

  var sched: Actor = null
  def start =
    sched = scheduler(5000) {
      System.out.println(Socket.status)
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

class MessageRouter extends Logging {

  def onMessage(message: Array[Byte]) {
    val msg = new String(message)
    log info "Recv: " + msg
    val json = net.liftweb.json.parse(msg)
    log info json.extract[Command].toString
    val method = (json \ "method").extract[String]
    method match {
      case "openFile" => {
        val cmd = json \ "params"
        log info cmd.toString
        log info cmd.extract[OpenFileCommand].toString
        FileNavigator findAndNavigate cmd.extract[OpenFileCommand]
      }
    }
  }

}

object FileNavigator {

  val log: Logger = Logger.getInstance(FileNavigator.getClass)

  def findAndNavigate(cmd: OpenFileCommand) =
    ApplicationManager.getApplication.invokeLater( new Runnable { override def run {
      log info "Navigating to file"
      val projects = ProjectManager.getInstance().getOpenProjects()
      for (p <- projects) {
        val file = FilenameIndex.getVirtualFilesByName(
          p, "Test", GlobalSearchScope.allScope(p))
        log info file.size().toString
      }
    }})
}

