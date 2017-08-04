#!/usr/bin/env ruby

load 'lib/build.rb'

#generators = ["play_2_x_standalone_json", "play_2_4_client"]
generators = ["play_2_4_client"]

builds = [
  Build.new("api", generators),
  Build.new("api-event", generators)
]

builds.each do |b|
  puts b.name
  b.generators.each do |generator|
    puts "  - " + generator
  end
end

