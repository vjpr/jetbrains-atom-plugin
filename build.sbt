name := "Sidekick for Programmers"

scalaVersion := "2.10.1"

resolvers += "Sonatype OSS Snapshots" at "https://oss.sonatype.org/content/repositories/snapshots/"

resolvers += "repo.codahale.com" at "http://repo.codahale.com"

resolvers += "Mandubian repository snapshots" at "https://github.com/mandubian/mandubian-mvn/raw/master/snapshots/"

libraryDependencies ++= Seq(
  //"net.databinder" %% "unfiltered-filter" % "0.6.3"
//, "net.databinder" %% "unfiltered-netty-server" % "0.6.3"
//, "net.databinder" %% "dispatch-http" % "0.8.8"
//, "net.databinder" %% "dispatch-nio" % "0.8.8"
  "net.liftweb" %% "lift-json" % "2.5" withSources,
  "org.jfarcand" % "wcs" % "1.2" withSources,
//, "com.codahale" %% "jerkson" % "0.5.0" withSources
  "play" %% "play-json" % "2.2-SNAPSHOT",
  "org.slf4j" % "slf4j-simple" % "1.7.5",
  "com.typesafe" % "config" % "1.0.2"
)

retrieveManaged := true
