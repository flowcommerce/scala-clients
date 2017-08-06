#!/usr/bin/env ruby

load 'lib/build.rb'
load 'lib/util.rb'

ORG = "flow"

#generators = ["play_2_x_standalone_json", "play_2_4_client"]
generators = ["play_2_4_client"]

builds = [
  Build.new("api", generators),
  Build.new("api-event", generators)
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

builds.each do |b|
  puts b.name

  b.generators.each do |generator|
    puts "  - " + generator

    artifact_name = ("%s_%s" % [b.name, generator]).gsub(/\_/, '-')
    artifact_version = "0.3.64"
    substitutions = {
      "NAME" => artifact_name,
      "ARTIFACT_VERSION" => artifact_version,
      "PLAY_JSON_VERSION" => "2.4.11"
    }

    Util.with_tmp_dir do |dir|
      puts "    dir: #{dir}"
      copy_template(File.join("templates", generator), dir, substitutions)

      srcdir = File.join(dir, "src/main/scala")
      run("mkdir -p #{srcdir}")
      Dir.chdir(dir) do
        run("apibuilder code %s %s %s %s %s" % [ORG, b.name, artifact_version, generator, srcdir])
      end
    end
  end
end

