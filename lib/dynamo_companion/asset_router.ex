defmodule DynamoCompanion.AssetRouter do
  use Dynamo.Router

  get "/:type/*" when type in %W[stylesheets javascripts] do
    path = [ conn.params[:type] ] ++ conn.params[''] |> Enum.join "/"
    IO.puts "path = #{inspect path}"
    conn.resp 200, DynamoCompanion.AssetPipeline.render_bundle path
  end
end
