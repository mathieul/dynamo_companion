require "optparse"

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
