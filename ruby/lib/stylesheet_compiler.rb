require "compass"
require "sass/plugin"

class StylesheetCompiler
  attr_reader :base_path

  def initialize(base_path)
    @base_path = base_path
  end

  def append_load_path(path)
    Sass.load_paths << path
  end

  def render(path)
    name = File.basename(path).gsub(/\.(s[ac]ss)$/, '')
    compiler.engine(path, "#{name}.css")
  end

  private

  def compiler
    @compiler ||= Compass::Compiler.new(
      working_path,
      from_path,
      to_path,
      sass: Compass.sass_engine_options
    )
  end

  def working_path
    File.join(base_path, "tmp")
  end

  def from_path
    File.join(base_path, "assets", "stylesheets")
  end

  def to_path
    File.join(working_path, "css")
  end
end
