name := "{{NAME}}"

organization := "io.flow"

scalaVersion := "2.12.10"

crossScalaVersions := Seq("2.12.10")

libraryDependencies ++= Seq(
  "com.typesafe.play" %% "play-json" % "2.7.4",
  "com.ning" % "async-http-client" % "1.9.40"
)

resolvers += "Artifactory" at "https://flow.artifactoryonline.com/flow/libs-release/"

credentials += Credentials(
  "Artifactory Realm",
  "flow.artifactoryonline.com",
  System.getenv("ARTIFACTORY_USERNAME"),
  System.getenv("ARTIFACTORY_PASSWORD")
)

publishTo := {
  val host = "https://flow.artifactoryonline.com/flow"
  if (isSnapshot.value) {
    Some("Artifactory Realm" at s"$host/libs-snapshot-local;build.timestamp=" + new java.util.Date().getTime)
  } else {
    Some("Artifactory Realm" at s"$host/libs-release-local")
  }
}

version := "{{ARTIFACT_VERSION}}"
