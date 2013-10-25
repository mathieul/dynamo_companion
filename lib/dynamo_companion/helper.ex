defmodule DynamoCompanion.Helper do
  alias DynamoCompanion.AssetPipeline

  def javascript_include_tag path do
    render_asset_tag path, ".js", fn file ->
      %s[<script src="#{file}"></script>]
    end
  end

  def stylesheet_link_tag path do
    render_asset_tag path, ".css", fn file ->
      %s[<link href="#{file}" media="all" rel="stylesheet" />]
    end
  end

  defp render_asset_tag path, suffix, renderer do
    unless String.ends_with?(path, suffix) || String.contains?(path, ".") do
      path = path <> suffix
    end
    if Mix.env == :dev do
      AssetPipeline.get_files(path)
        |> Enum.map(renderer)
        |> Enum.join("\n")
    else
      renderer.(path)
    end
  end
end
