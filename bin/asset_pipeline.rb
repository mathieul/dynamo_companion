#!/usr/bin/env ruby

require "sprockets"

class SprocketsProxy
  SUPPORTED_COMMANDS = %w[append_paths render]

  attr_reader :environment

  def initialize(environment)
    @environment = environment
  end

  def process_command(command, args)
    return "ERROR: command #{command.inspect} not supported." unless SUPPORTED_COMMANDS.include?(command)
    send(command, args)
  end

  private

  def append_paths(paths)
    paths.each { |path| environment.append_path(path) }
    []
  end

  def render(paths)
    if bundle = environment[paths.first]
      bundle.to_s
    else
      ""
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
