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
