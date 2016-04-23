package sidekick

import com.intellij.openapi.diagnostic.Logger
import net.liftweb.json.DefaultFormats
import com.typesafe.config.ConfigFactory

// Mixin to a class or extend an object for logging purposes.
trait Logging {
  type Printable = { def toString: String }
  val log: Logger = Logger.getInstance(getClass)
  def debug(message: Printable) = log debug message.toString
  def info(message: Printable) = log info message.toString
}

object Implicits {
  // Use default formats for LiftJSON serialization.
  implicit val formats = DefaultFormats
  // Allows use of an anonymous Scala function for methods expecting a runnable.
  // Comes in handy for running a block of code in another thread.
  implicit def runnable(f: () => Unit): Runnable = new Runnable() { def run() = f() }
}

// Allow access to configuration.
object Config {
  // Load configuration.
  val conf = ConfigFactory.load
  System.out.println(conf.root().render())
}
