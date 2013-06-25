package sidekick

import reflect.{BeanInfo, BeanProperty}
import net.liftweb.json.JsonAST.{JObject, JValue}

case class Command(
  var method: String
, var params: JObject
) { def this() = this("",null) }

case class OpenFileCommand(
  var fileName: String
, var line: Int
, var column: Int
) { def this() = this("",0,0) }
