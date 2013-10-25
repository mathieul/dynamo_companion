defmodule DynamoCompanion.Helper do
  alias DynamoCompanion.AssetPipeline

  def javascript_include_tag path do
    if Mix.env == :dev do
      AssetPipeline.get_files(path)
        |> Enum.map(fn file -> %s[<script src="#{file}"></script>] end)
        |> Enum.join("\n")
    else
      %s[<script src="#{path}"></script>]
    end
  end
end
