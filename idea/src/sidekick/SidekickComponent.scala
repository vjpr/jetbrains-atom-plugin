package sidekick

import com.intellij.openapi.components.ApplicationComponent
import com.intellij.openapi.diagnostic.Logger
import com.intellij.openapi.application.ApplicationManager

import Implicits._
import com.intellij.openapi.vfs.{LocalFileSystem, VirtualFileManager, VirtualFile}
import com.intellij.openapi.project.{ProjectManagerListener, ProjectManager, Project}
import com.intellij.psi.search.{GlobalSearchScope, FilenameIndex}
import java.io.File
import org.jfarcand.wcs.{BinaryListener, MessageListener, WebSocket}
import java.net.ConnectException
import java.util
import util.concurrent.ExecutionException
import sun.jvm.hotspot.runtime.Bytes
import com.codahale.jerkson.Json
import scala.Predef._
import net.liftweb.json.DefaultFormats
import com.intellij.openapi.actionSystem.{DataConstants, DataKeys, DataContext, PlatformDataKeys}
import com.intellij.openapi.vfs.newvfs.BulkFileListener
import com.intellij.openapi.vfs.newvfs.events.VFileEvent
import com.intellij.openapi.fileEditor.{FileDocumentManagerListener, FileDocumentManager}
import com.intellij.ide.DataManager
import com.intellij.openapi.Disposable
import scala.actors.{TIMEOUT, Actor}
import net.liftweb.json.JsonAST.JValue
import scala.tools.cmd
import net.liftweb.json
import com.intellij.openapi.editor.EditorFactory
import com.intellij.psi.PsiManager
import com.intellij.psi.util.PsiTreeUtil
import com.intellij.lang.javascript.psi.impl.JSPropertyImpl

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
      case "fileChanged" => {
        val cmd = json \ "params"
        log info cmd.toString
      }
      case "documentChanged" => {
        val cmd = json \ "params"
        log info cmd.toString
        DocumentUpdater update cmd
      }
    }
  }

}

case class UpdateElementCommand(
  body: String,
  path: String,
  offset: Integer,
  to: Integer
)

object DocumentUpdater extends Logging {
  def update(cmd: JValue) = {
    val command = cmd.extract[UpdateElementCommand]
    val vf = LocalFileSystem.getInstance().findFileByPath(command.path)

    ApplicationManager.getApplication().invokeLater { () =>
      val dataContext = DataManager.getInstance.getDataContext()
      val currentProject = PlatformDataKeys.PROJECT.getData(dataContext)
      val doc = FileDocumentManager.getInstance.getDocument(vf)
      ApplicationManager.getApplication.runWriteAction { () =>
        doc.replaceString(command.offset.asInstanceOf[Int], command.to.asInstanceOf[Int], command.body)
      }
      //val psiFile = PsiManager.getInstance(currentProject).findFile(vf)
      //val el = psiFile.getViewProvider.findElementAt(command.offset)
      //val method = PsiTreeUtil.getParentOfType(el, classOf[JSPropertyImpl])
      //System.out.println('element, method)
    }

    //val doc = FileDocumentManager.getInstance().getDocument(vf)
    //val editors = EditorFactory.getInstance().getEditors(doc)
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

