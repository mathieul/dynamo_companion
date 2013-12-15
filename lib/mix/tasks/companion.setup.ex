defmodule Mix.Tasks.Companion.Setup do
  use Mix.Task

  @shortdoc "Setup dynamo_companion"
  @moduledoc "A task to setup dynamo_companion"
  def run(_args) do
    setup_bundler
    setup_folders
  end

  defp setup_bundler do
    Mix.shell.info "Setup Bundler."
    source_path = Path.expand('../../..', __DIR__)
    %W[Gemfile Gemfile.lock] |> Enum.each fn name ->
      File.cp "#{source_path}/#{name}", name, ask_for_confirmation
    end
    Mix.shell.cmd "bundle install"
  end

  defp setup_folders do
    Mix.shell.info "Create folders."
    %w[assets/javascripts assets/stylesheets bower_components] |> Enum.each fn name ->
      File.mkdir_p! name
    end
    template_path = Path.expand('../../../templates', __DIR__)
    %W[javascripts/application.js stylesheets/application.css] |> Enum.each fn path ->
      File.cp "#{template_path}/#{path}", "assets/#{path}", ask_for_confirmation
    end
  end

  defp ask_for_confirmation do
    fn source, destination ->
      IO.gets("Overwriting #{destination} by #{source}. Type y to confirm.") == "y"
    end
  end
end
