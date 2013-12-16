#!/usr/bin/env ruby

require "optparse"
require "logger"
require "sprockets"

class CommandLineProcessor
  attr_reader :arguments

  def initialize(arguments)
    @arguments = arguments
  end

  def process!
    options[:libs].each { |lib| require lib }
    options
  end

  private

  def options
    @options ||= begin
      options = {libs: [], debug: false}
      parser = OptionParser.new do |o|
        o.on("-r", "--require LIBRARY", "require the library specified") do |lib|
          options[:libs] << lib
        end

        o.on("-d", "--debug", "log execution with logger to help debugging") do |debug|
          options[:debug] = debug
        end
      end
      parser.parse!
      options
    end
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

options = CommandLineProcessor.new(ARGV).process!
if options[:debug]
  logger = Logger.new "asset_pipeline.log"
  logger.level = Logger::DEBUG
else
  logger = Logger.new STDERR
  logger.level = Logger::ERROR
end
proxy = SprocketsProxy.new(Sprockets::Environment.new)

logger.info { ">>> STARTING LOG [#{$$}]" }
ARGF.each_line do |line|
  begin
  command, *args = line.split
  logger.info { "process_command(#{command.inspect}, #{args.inspect})" }
  content = proxy.process_command(command, args)
  num_lines = content.count("\n")
  num_lines = 1 if num_lines.zero?
  logger.info { "[#{$$}] num_lines: #{num_lines}" }
  logger.info { "[#{$$}] content: #{content}" }
  $stdout << "#{num_lines}\n"
  $stdout << "#{content}\n"
  $stdout.flush
  rescue StandardError => ex
    logger.warn { "Error: #{ex}\nbacktrace: #{ex.backtrace.inspect}" }
  end
end
logger.info { "<<<FINISHING LOG [#{$$}]" }
logger.close
