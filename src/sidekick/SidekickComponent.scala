package sidekick

import com.intellij.openapi.actionSystem._
import com.intellij.openapi.actionSystem.{CommonDataKeys}
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
import com.intellij.openapi.actionSystem.{DataConstants, DataKeys, DataContext, PlatformDataKeys, CommonDataKeys}
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
import com.intellij.openapi.roots.{ProjectRootManager, ProjectFileIndex}
import com.typesafe.config.ConfigFactory

// This is the main entry point for our plugin.
class SidekickComponent extends ApplicationComponent with Logging {

  def initComponent {
    // Connect to Node.js web socket server.
    Socket.connect
    // Listen to application events.
    Listeners.listenToApplicationEvents
    ReconnectTimer.start
    // Listen to project events.
    ProjectManager.getInstance().addProjectManagerListener(new ProjectManagerListener {
      def canCloseProject(project: Project) = false
      def projectOpened(project: Project) {
        Listeners.listenToProjectEvents(project)
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

class MessageRouter extends Logging {

  def onMessage(message: Array[Byte]) {
    val msg = new String(message)
    log info "Recv: " + msg
    val json = net.liftweb.json.parse(msg)
    log info json.extract[Command].toString
    val method = (json \ "method").extract[String]
    val cmd = json \ "params"
    method match {
      case "openFile" => {
        log info cmd.extract[OpenFileCommand].toString
        FileNavigator findAndNavigate cmd.extract[OpenFileCommand]
      }
      case "fileChanged" => {
      }
      case "documentChanged" => {
        DocumentUpdater update cmd
      }
      case "getProjectRoot" => {
        Socket.send("ProjectRoot", SidekickProjectManager.getProjectFiles)
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

object SidekickProjectManager {
  def getProjectFiles(): String = {
    val dataContext = DataManager.getInstance.getDataContext()
    val currentProject = CommonDataKeys.PROJECT.getData(dataContext)
    currentProject.getBaseDir.getCanonicalPath
  }
}

object DocumentUpdater extends Logging {
  def update(cmd: JValue) = {
    val command = cmd.extract[UpdateElementCommand]
    val vf = LocalFileSystem.getInstance().findFileByPath(command.path)

    ApplicationManager.getApplication().invokeLater { () =>
      val dataContext = DataManager.getInstance.getDataContext()
      val currentProject = CommonDataKeys.PROJECT.getData(dataContext)
      val doc = FileDocumentManager.getInstance.getDocument(vf)
      ApplicationManager.getApplication.runWriteAction { () =>
        doc.replaceString(command.offset.asInstanceOf[Int], command.to.asInstanceOf[Int], command.body)
      }
      //val psiFile = PsiManager.getInstance(currentProject).findFile(vf)
      //val el = psiFile.getViewProvider.findElementAt(command.offset)
      //val method = PsiTreeUtil.getParentOfType(el, classOf[JSPropertyImpl])
    }

    //val doc = FileDocumentManager.getInstance().getDocument(vf)
    //val editors = EditorFactory.getInstance().getEditors(doc)
  }
}

object FileNavigator extends Logging {
  def findAndNavigate(cmd: OpenFileCommand) =
    ApplicationManager.getApplication.invokeLater { () =>
      log info "Navigating to file"
      val projects = ProjectManager.getInstance().getOpenProjects()
      for (p <- projects) {
        val file = FilenameIndex.getVirtualFilesByName(
          p, "Test", GlobalSearchScope.allScope(p))
        log info file.size().toString
      }
    }
}

