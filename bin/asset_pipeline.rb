#!/usr/bin/env ruby

require "sprockets"

class SprocketsProxy
  SUPPORTED_COMMANDS = %w[append_paths get_files render_file render_bundle]

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

  def get_files(paths)
    get(:file_list, paths.first)
  end

  def render_file(paths)
    get(:file, paths.first)
  end

  def render_bundle(paths)
    get(:bundle, paths.first)
  end

  def get(kind, path)
    bundle = environment[path]
    return "" unless bundle
    case kind
    when :file_list
      bundle.to_a.map(&:logical_path).join(" ")
    when :file
      bundle.body
    when :bundle
      bundle.to_s
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
