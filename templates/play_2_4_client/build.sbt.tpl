name := "{{NAME}}"

organization := "io.flow"

scalaVersion in ThisBuild := "2.12.2"

crossScalaVersions := Seq("2.12.2", "2.11.11", "2.10.6")

lazy val root = project
  .in(file("."))
  .settings(
      libraryDependencies ++= Seq(
      "com.typesafe.play" %% "play-json" % "{{PLAY_JSON_VERSION}}"
    ),
    resolvers += "Typesafe repository" at "http://repo.typesafe.com/typesafe/releases/",
    resolvers += "scalaz-bintray" at "https://dl.bintray.com/scalaz/releases",
    resolvers += "Artifactory" at "https://flow.artifactoryonline.com/flow/libs-release/",
    credentials += Credentials(
      "Artifactory Realm",
      "flow.artifactoryonline.com",
      System.getenv("ARTIFACTORY_USERNAME"),
      System.getenv("ARTIFACTORY_PASSWORD")
    )
)

publishTo := {
  val host = "https://flow.artifactoryonline.com/flow"
  if (isSnapshot.value) {
    Some("Artifactory Realm" at s"$host/libs-snapshot-local;build.timestamp=" + new java.util.Date().getTime)
  } else {
    Some("Artifactory Realm" at s"$host/libs-release-local")
  }
}

version := "{{VERSION}}"
