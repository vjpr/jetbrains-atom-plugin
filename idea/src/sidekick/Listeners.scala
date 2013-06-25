package sidekick

import com.intellij.openapi.application.ApplicationManager
import com.intellij.openapi.vfs.{VirtualFile, VirtualFileManager}
import com.intellij.openapi.vfs.newvfs.BulkFileListener
import com.intellij.openapi.vfs.newvfs.events._
import scala.collection.JavaConversions._
import net.liftweb.json
import json._
import net.liftweb.json.Serialization.{read, write}
import net.liftweb.json.JsonDSL._
import sidekick.events._
import com.intellij.openapi.fileEditor._
import com.intellij.openapi.editor.Editor
import com.intellij.openapi.actionSystem.{DataKeys, PlatformDataKeys}
import com.intellij.ide.DataManager
import com.intellij.openapi.editor.event.{CaretEvent, CaretListener}
import sidekick.Socket._
import com.intellij.openapi.project.{Project, ProjectManager}
import com.intellij.util.messages.{MessageBusConnection, MessageBus}
import com.intellij.psi.PsiDocumentManager

object Listeners extends Logging {

  var projectBus: MessageBusConnection = null

  def listenToProject(project: Project): Unit = {
    projectBus = project.getMessageBus.connect
    val fileEditorManagerListener = new SidekickFileEditorManagerListener
    projectBus.subscribe(FileEditorManagerListener.FILE_EDITOR_MANAGER, fileEditorManagerListener)
  }

  val bus = ApplicationManager.getApplication.getMessageBus.connect

  def listen {
    val bulkfileListener = new SidekickBulkFileListener
    log info Socket.ws.isOpen.toString
    bus.subscribe(VirtualFileManager.VFS_CHANGES, bulkfileListener)
  }

  def disconnect = {
    bus.disconnect()
    projectBus.disconnect()
  }

}

class SidekickBulkFileListener extends BulkFileListener with Logging {
  implicit val formats = Serialization.formats(NoTypeHints)

  def before(events: java.util.List[_ <: VFileEvent]) {

  }

  def after(events: java.util.List[_ <: VFileEvent]) {
    for (e <- events) {
      val evt: Event = e match {
        case f: VFilePropertyChangeEvent => new FilePropertyChangeEvent(f)
        case f: VFileContentChangeEvent => new FileContentChangeEvent(f)
        case f: VFileMoveEvent => new FileMoveEvent(f)
        case f: VFileCreateEvent => new FileCreateEvent(f)
        case f: VFileDeleteEvent => new FileDeleteEvent(f)
        case _ => null
      }
      if (evt != null) {
        val json = write(evt)
        log info json
        log info Socket.ws.isOpen.toString
        Socket.send(evt.method, json)
      }
    }
  }

}

class SidekickFileEditorManagerListener extends FileEditorManagerAdapter with Logging {
  implicit val formats = Serialization.formats(NoTypeHints)

  override def fileOpened(source: FileEditorManager, file: VirtualFile) {
    System.out.println("HLERWER")
    log info "Filed opened"
  }

  override def fileClosed(source: FileEditorManager, file: VirtualFile) {
    log info "File closed"
  }

  override def selectionChanged(event: FileEditorManagerEvent) {
    log info "Selection changed"
    val editor = event.getManager.getSelectedTextEditor
    val project = editor.getProject
    val document = editor.getDocument
    val psiFile = PsiDocumentManager.getInstance(project).getCachedPsiFile(document)

    //val method = GetMethodName(editor, psiFile)
    val o =
      ("file" -> event.getNewFile.toString) ~
      ("editor" -> event.getNewEditor.toString) ~
      ("provider" -> event.getNewProvider.toString) ~
      ("contents" -> psiFile.getText)
    val json = write(o)
    log info json
    Socket.send("FileEditorEvent.SelectionChanged", json)
  }
}
