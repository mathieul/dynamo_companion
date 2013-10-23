#!/usr/bin/env ruby

require "sprockets"

class SprocketsProxy
  attr_reader :environment

  def initialize(environment)
    @environment = environment
  end

  def process_command(command, args)
    case command
    when "append_paths"
      append_paths(args)
    when "render"
      render(args.first)
    else
      "ERROR: command #{command.inspect} not supported."
    end
  end

  private

  def append_paths(paths)
    paths.each { |path| environment.append_path(path) }
    []
  end

  def render(path)
    if bundle = environment[path]
      bundle.to_s
    else
      "ERROR: path #{path.inspect} not found."
    end
  end
end

proxy = SprocketsProxy.new(Sprockets::Environment.new)

ARGF.each_line do |line|
  command, *args = line.split
  content = proxy.process_command(command, args)
  unless content.empty?
    num_lines = content.count("\n")
    num_lines = 1 if num_lines.zero?
    $stdout << "#{num_lines}\n"
    $stdout << "#{content}\n"
    $stdout.flush
  end
end
