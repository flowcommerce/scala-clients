name := "{{NAME}}"

organization := "io.flow"

scalaVersion in ThisBuild := "2.11.11"

crossScalaVersions := Seq("2.11.11", "2.10.6")

lazy val root = project
  .in(file("."))
  .settings(
      libraryDependencies ++= Seq(
      "com.typesafe.play" %% "play-json" % "2.4.11"
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

version := "{{ARTIFACT_VERSION}}"
