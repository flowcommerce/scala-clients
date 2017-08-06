#!/usr/bin/env ruby

load 'lib/build.rb'
load 'lib/generator.rb'
load 'lib/util.rb'

ORG = "flow"

generators = [Generator.new("play_2_4_client", "app"),
              Generator.new("play_2_x_standalone_json", "src/main/scala")]

generators = [Generator.new("play_2_4_client", "app")]

builds = [
  Build.new("api", generators)
]

def run(cmd)
  puts "==> #{cmd}"
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

def latest_apibuilder_version(org, name)
  if name == "api"
    return "0.3.64"
  end
  cmd = "apibuilder list versions %s %s" % [org, name]
  versions = run(cmd).strip.split
  if versions.empty?
    puts "ERROR: No versions found for %s/%s" % [org, name]
    exit(1)
  end
  versions.first
end

builds.each do |b|
  puts b.name

  b.generators.each do |generator|
    puts "  - " + generator.key

    artifact_name = ("%s_%s" % [b.name, generator.key]).gsub(/\_/, '-')

    artifact_version = latest_apibuilder_version(ORG, b.name)
    substitutions = {
      "NAME" => artifact_name,
      "ARTIFACT_VERSION" => artifact_version,
      "PLAY_JSON_VERSION" => "2.4.11"
    }

    Util.with_tmp_dir do |dir|
      copy_template(File.join("templates", generator.key), dir, substitutions)

      srcdir = File.join(dir, generator.srcdir)
      run("mkdir -p #{srcdir}")
      Dir.chdir(dir) do
        b.applications.each do |app|
          version = app == b.name ? artifact_version : latest_apibuilder_version(ORG, app)
          puts "   - generating code for %s/%s:%s" % [ORG, app, version]
          run("apibuilder code %s %s %s %s %s" % [ORG, app, version, generator.key, srcdir])
        end
      end
    end
  end
end

