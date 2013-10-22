#!/usr/bin/env ruby

require "sprockets"

environment = Sprockets::Environment.new
environment.append_path "assets/javascripts"
environment.append_path "assets/stylesheets"

ARGF.each_line do |line|
  command, file = line.split
  content = case command
            when "include"
              environment[file].to_s
            else
              "content"
            end
  $stdout << "#{content.count("\n")}\n"
  $stdout << "#{content}\n"
  $stdout.flush
end
