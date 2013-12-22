require "sprockets"

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
