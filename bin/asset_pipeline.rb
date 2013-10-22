#!/usr/bin/env ruby

ARGF.each_line.with_index do |line, i|
  $stdout << "[#{i + 1}] received: #{line}"
  $stdout.flush
end
