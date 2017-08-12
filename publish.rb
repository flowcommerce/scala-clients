#!/usr/bin/env ruby

load 'lib/build.rb'
load 'lib/generator.rb'
load 'lib/util.rb'

ORG = "flow"

generators = [Generator.new("play_2_4_client", "app"),
              Generator.new("play_2_x_standalone_json", "src/main/scala")]

#generators = [Generator.new("play_2_4_client", "app")]

builds = [
  Build.new("api", generators)
]

class Executor

  attr_reader :log

  def initialize(dir)
    @dir = dir
    @log = File.join(dir, "build.log")
  end

  def run(cmd)
    File.open(@log, "a") do |out|
      out << cmd << "\n"
    end
    `#{cmd}`
  end

  def interpolate(source_path, path, substitutions)
    found = false
    Util.with_tmp_file do |tmp|
      File.open(tmp, "w") do |out|
        i=j=nil
        IO.readlines(path).each do |l|
          i = l.index("{{")
          j = l.index("}}")
          while i && j && i < j
            found = true
            name = l[i+2, j-i-2]
            value = substitutions[name]
            if value.nil?
              puts "ERROR: File %s requires a variable named [%s]" % [source_path, name]
              exit(1)
            end
            l = l[0, i] + value + l[j+2, l.length]
            i = l.index("{{")
            j = l.index("}}")
          end

          out << l
        end
      end
      if found
        run("cp #{tmp} #{path}")
      end
    end
  end

  def copy_template(template_dir, target_dir, substitutions)
    run("mkdir -p #{target_dir}")

    Dir.glob("#{template_dir}/*").each do |f|
      if File.directory?(f)
        name = File.basename(f)
        copy_template(File.join(template_dir, name), File.join(target_dir, name), substitutions)
      elsif f =~ /\.tpl$/
        name = File.basename(f).sub(/\.tpl$/, '')
        target = File.join(target_dir, name)
        run("cp #{f} #{target}")
        interpolate(f, target, substitutions)
      else
        run("cp #{f} #{target_dir}")
      end
    end
  end

end

def latest_apibuilder_version(org, name)
  url = 'http://api.apibuilder.io/%s/metadata/%s/versions/latest.txt' % [org, name]
  cmd = "curl --silent %s" % url
  version = `#{cmd}`.strip.split.first.to_s.strip

  if version.empty?
    puts "ERROR: No versions found for %s/%s" % [org, name]
    puts "  URL: %s" % url
    exit(1)
  end

  if !version.match(/^\d+\.\d+\.\d+/)
    puts "ERROR: Invalid version '%s' - expected a sem ver version" % version
    puts "       %s" % url
    exit(1)
  end

  version
end

builds.each do |b|
  puts "%s/%s" % [ORG, b.name]

  b.generators.each do |generator|
    artifact_name = ("%s_%s" % [b.name, generator.key]).gsub(/\_/, '-')

    artifact_version = latest_apibuilder_version(ORG, b.name)
    substitutions = {
      "NAME" => artifact_name,
      "ARTIFACT_VERSION" => artifact_version,
      "PLAY_JSON_VERSION" => "2.4.11",
      "PLAY_VERSION" => "2.4.11"
    }

    Util.with_tmp_dir do |dir|
      puts "  - %s" % generator.key
      puts "    - using temporary directory: %s" % dir

      executor = Executor.new(dir)
      puts "    - log: %s" % executor.log

      executor.copy_template(File.join("templates", generator.key), dir, substitutions)

      srcdir = File.join(dir, generator.srcdir)
      executor.run("mkdir -p #{srcdir}")
      Dir.chdir(dir) do
        b.applications.each do |app|
          version = app == b.name ? artifact_version : latest_apibuilder_version(ORG, app)
          puts "    - generating code for %s/%s:%s" % [ORG, app, version]
          executor.run("apibuilder code %s %s %s %s %s" % [ORG, app, version, generator.key, srcdir])
        end
      end
    end
  end
end

