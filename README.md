# scala-clients

Responsible for publishing our API Builder clients as JARs

## Usage

    ./publish.rb

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
