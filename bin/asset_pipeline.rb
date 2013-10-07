#!/usr/bin/env ruby

# File.open "cat.log", "w" do |file|
  ARGF.each_line.with_index do |line, i|
    output = "[#{i + 1}] #{line}"
    # file << output
    # file.flush
    $stdout << output
    $stdout.flush
  end
# end
