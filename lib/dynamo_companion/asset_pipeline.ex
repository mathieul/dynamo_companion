defmodule DynamoCompanion.AssetPipeline do
  use ExActor, export: :asset_pipeline
  alias DynamoCompanion.SprocketsProxy

  @paths [ "test/fixtures/assets/javascripts", "test/fixtures/assets/stylesheets" ]

  defrecordp :state_rec, received: [], port: nil

  definit command do
   port = SprocketsProxy.open_port(command)
   SprocketsProxy.send_request(port, :append_paths, @paths)
   state_rec(port: port)
  end

  defcall render(path), state: state = state_rec(port: port) do
    SprocketsProxy.send_request(port, :render, [ path ])
    reply SprocketsProxy.receive_content(port), state
  end

  defcast stop, state: state do
    { :stop, :normal, state }
  end

  def terminate(_reason, state) do
    SprocketsProxy.close_port state_rec(state, :port)
    :ok
  end
end
