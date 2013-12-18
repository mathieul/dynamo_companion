defmodule DynamoCompanion.Helpers do
  alias DynamoCompanion.AssetPipeline

  def stylesheet_link_tag path do
    render_asset_tag "stylesheets/#{path}", ".css", fn file, extra ->
      %s[<link href="#{file}#{extra}" media="all" rel="stylesheet" />]
    end
  end

  def javascript_include_tag path do
    render_asset_tag "javascripts/#{path}", ".js", fn file, extra ->
      %s[<script src="#{file}#{extra}"></script>]
    end
  end

  defp render_asset_tag path, suffix, renderer do
    unless String.ends_with?(path, suffix) || String.contains?(path, ".") do
      path = path <> suffix
    end
    if Mix.env == :dev do
      AssetPipeline.get_files(path)
        |> Enum.map(&(renderer.(&1, "?body=1")))
        |> Enum.join("\n")
    else
      renderer.(path, "")
    end
  end
end
