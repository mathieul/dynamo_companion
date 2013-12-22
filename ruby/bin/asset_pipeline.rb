#!/usr/bin/env ruby

require "logger"
require "erlectricity"

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require "command_line_processor"
require "stylesheet_compiler"
require "sprockets_proxy"
require "query_processor"

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
