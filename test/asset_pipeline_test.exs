defmodule AssetPipelineTest do
  use ExUnit.Case

  alias DynamoCompanion.AssetPipeline

  test "request static asset content in dev mode" do
    AssetPipeline.start_link
    assert AssetPipeline.get(:dev, "allo.js") == "ze content"
    AssetPipeline.stop
  end
end
