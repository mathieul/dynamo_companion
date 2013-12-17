#!/usr/bin/env ruby

require "optparse"
require "logger"
require "erlectricity"
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
  attr_reader :environment

  def initialize(environment)
    @environment = environment
  end

  def append_paths(paths)
    paths.each { |path| environment.append_path(path) }
    :ok
  rescue StandardError => ex
    [:error, ex.to_s]
  end

  def get_files(path)
    [:files, get(:file_list, path)]
  end

  def render_file(path)
    [:content, get(:file, path)]
  end

  def render_bundle(path)
    [:content, get(:bundle, path)]
  end

  private

  def get(kind, path)
    bundle = environment[path]
    return path unless bundle
    case kind
    when :file_list
      bundle.to_a.map(&:logical_path)
    when :file
      bundle.body
    when :bundle
      bundle.to_s
    end
  end
end

class QueryProcessor
  attr_reader :proxy, :logger

  def initialize(proxy, logger)
    @proxy  = proxy
    @logger = logger
  end

  def run!(receiver)
    logger.info " -> query processor setup"
    receiver.when([:append_paths, Array]) do |paths|
      logger.info " -> append_paths(#{paths.inspect})"
      receiver.send! proxy.append_paths(paths)
      receiver.receive_loop
    end

    receiver.when([:get_files, String]) do |path|
      logger.info " -> get_files(#{path.inspect})"
      receiver.send! proxy.get_files(path)
      receiver.receive_loop
    end

    receiver.when([:render_file, String]) do |path|
      logger.info " -> render_file(#{path.inspect})"
      receiver.send! proxy.render_file(path)
      receiver.receive_loop
    end

    receiver.when([:render_bundle, String]) do |path|
      logger.info " -> render_bundle(#{path.inspect})"
      receiver.send! proxy.render_bundle(path)
      receiver.receive_loop
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
query_processor = QueryProcessor.new(proxy, logger)

logger.info { ">>> BEGIN [#{$$}]" }
receive(STDIN, STDOUT) { |receiver| query_processor.run!(receiver) }
logger.info { "<<< END   [#{$$}]" }
logger.close
