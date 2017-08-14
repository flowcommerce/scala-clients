# scala-clients

Responsible for publishing our API Builder clients as JARs

## Installation

Play 2.4 client:

    "io.flow" %% "api-play-2-4-client" % "0.3.73"

Play 2.4 mock client:

    "io.flow" %% "api-play-2-4-mock-client" % "0.3.73"

Play 2.5 client:

    "io.flow" %% "api-play-2-5-client" % "0.3.73"

Play 2.5 mock client:

    "io.flow" %% "api-play-2-5-mock-client" % "0.3.73"

Play 2.x json models:

    "io.flow" %% "api-play-2-x-standalone-json" % "0.3.73"

Resolver:

    resolvers ++= Seq(
      "Artifactory" at "https://flow.artifactoryonline.com/flow/libs-release/"
     )
       
## To publish new versions of the clients

    ./publish.rb

## Configuring a new library

Generators are added in ruby code (in publish.rb) ala:

    generators = [Generator.new("play_2_4_client", "app"),
                  Generator.new("play_2_x_standalone_json", "src/main/scala")]

Parameters:

  - play_2_4_client: The apibuilder generator key (See
    https://app.apibuilder.io/generators/)
  - The source directory in which sbt will look for code. Generated
    code will be placed beneath this directory.

The script will automatically query the latest version of the Flow API
via api.apibuilder.io/flow/metadata/api/versions/latest.txt and use that
to set the version number.

# Templates

The `templates` directory must contain a directory with the exact name
of the API Builder code generator key. Files ending in `.tpl` will be
interpolated and moved into the target directory, removing the `.tpl`
suffix.
