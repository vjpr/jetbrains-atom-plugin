package sidekick.events

import com.intellij.openapi.vfs.newvfs.events._

trait Event {
  val methodName: String
  def method: String = "VFSEvent." + methodName
}

case class FilePropertyChangeEvent(
  var fileName: String
, var propertyName: String
, var oldValue: String
, var newValue: String
) extends Event {
  def this(e: VFilePropertyChangeEvent) = this(
    fileName = e.getFile.toString
  , propertyName = e.getPropertyName
  , oldValue = e.getOldValue.toString
  , newValue = e.getNewValue.toString
  )
  val methodName = "FilePropertyChangeEvent"
}

case class FileMoveEvent(
  var fileName: String
, var oldParent: String
, var newParent: String
) extends Event {
  def this(e: VFileMoveEvent) = this(
    fileName = e.getFile.toString
  , oldParent = e.getOldParent.toString
  , newParent = e.getNewParent.toString
  )
  val methodName = "FileMoveEvent"
}

case class FileCreateEvent(
  var childName: String
, var parent: String
, var isDirectory: Boolean
) extends Event {
  def this(e: VFileCreateEvent) = this(
    childName = e.getChildName
  , parent = e.getParent.toString
  , isDirectory = e.isDirectory
  )
  val methodName = "FileCreateEvent"
}

case class FileDeleteEvent(
  var fileName: String
) extends Event {
  def this(e: VFileDeleteEvent) = this(
    fileName = e.getFile.toString
  )
  val methodName = "FileDeleteEvent"
}

case class FileCopyEvent(
  var fileName: String
, var newParent: String
, var newChildName: String
) extends Event {
  def this(e: VFileCopyEvent) = this(
    fileName = e.getFile.toString
  , newParent = e.getNewParent.toString
  , newChildName = e.getNewChildName
  )
  val methodName = "FileCopyEvent"
}

case class FileContentChangeEvent(
  var fileName: String
, var oldModificationStamp: Long
, var newModificationStamp: Long
) extends Event {
  def this(e: VFileContentChangeEvent) = this(
    fileName = e.getFile.toString
  , oldModificationStamp = e.getOldModificationStamp
  , newModificationStamp = e.getModificationStamp
  )
  val methodName = "FileContentChangeEvent"
}
