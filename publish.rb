#!/usr/bin/env ruby

load 'lib/build.rb'
load 'lib/util.rb'

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

def copy_template(template_dir, target_dir)
  Dir.glob("#{template_dir}/*").each do |f|
    if File.directory?(f)
      copy_template(template_dir, File.join(target_dir, File.basename(f)))
    elsif f =~ /\.tpl$/
      puts "TODO: #{f}"
    else
      run("mkdir -p #{target_dir}")
      run("cp #{f} #{target_dir}")
    end
  end
end

builds.each do |b|
  puts b.name
  b.generators.each do |generator|
    puts "  - " + generator
    Util.with_tmp_dir do |dir|
      puts "    dir: #{dir}"
      copy_template(File.join("templates", generator), dir)
    end
  end
end

