defmodule DynamoCompanion.AssetRouter do
  use Dynamo.Router

  get "/:type/*" when type in %W[stylesheets javascripts] do
    path = [ conn.params[:type] ] ++ conn.params[''] |> Enum.join "/"
    conn.resp 200, content(path, conn.params[:body])
  end
  defp content(path, body) do
    if body do
      DynamoCompanion.AssetPipeline.render_file path
    else
      DynamoCompanion.AssetPipeline.render_bundle path
    end
  end
end
