#!/usr/bin/env ruby

require "optparse"
require "sprockets"

class CommandLineProcessor
  attr_reader :arguments

  def initialize(arguments)
    @arguments = arguments
  end

  def process!
    options[:libs].each { |lib| require lib }
  end

  private

  def options
    options = {:libs => []}
    parser = OptionParser.new do |o|
      o.on("-r", "--require LIBRARY", "require the library specified") do |lib|
        options[:libs] << lib
      end
    end
    parser.parse!
    options
  end
end

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
    "ok"
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
    return path unless bundle
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

CommandLineProcessor.new(ARGV).process!
proxy = SprocketsProxy.new(Sprockets::Environment.new)

ARGF.each_line do |line|
  command, *args = line.split
  content = proxy.process_command(command, args)
  num_lines = content.count("\n")
  num_lines = 1 if num_lines.zero?
  $stdout << "#{num_lines}\n"
  $stdout << "#{content}\n"
  $stdout.flush
end
