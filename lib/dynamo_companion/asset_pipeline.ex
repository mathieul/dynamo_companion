defmodule DynamoCompanion.AssetPipeline do
  use ExActor, export: :asset_pipeline
  alias DynamoCompanion.SprocketsProxy

  defrecordp :state_rec, received: [], port: nil

  definit options do
    port = SprocketsProxy.start options
    state_rec port: port
  end

  defcall render(path), state: state = state_rec(port: port) do
    SprocketsProxy.send_request port, :render, [ path ]
    reply SprocketsProxy.receive_content(port), state
  end

  defcast stop, state: state do
    { :stop, :normal, state }
  end

  def terminate(_reason, state) do
    SprocketsProxy.stop state_rec(state, :port)
    :ok
  end
end
