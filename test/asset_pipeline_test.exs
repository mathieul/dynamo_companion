defmodule AssetPipelineTest do
  use ExUnit.Case

  alias DynamoCompanion.AssetPipeline

  test "request static asset content in dev mode" do
    assert AssetPipeline.render_bundle("javascripts/allo.js") == %s{"ze content";}
  end
end
