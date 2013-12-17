defmodule DynamoCompanion.AssetPipeline do
  use ExActor, export: :asset_pipeline
  alias DynamoCompanion.SprocketsProxy

  defrecordp :state_rec, received: [], port: nil

  definit options do
    paths = %W[assets bower_components] |> Enum.map fn path ->
      Path.expand path, File.cwd!
    end
    port = Keyword.merge(options, [ paths: paths ]) |> SprocketsProxy.start
    state_rec port: port
  end

  defcall append_path(path), state: state do
    result = SprocketsProxy.append_paths(state_rec(state, :port), [ path ])
    reply result, state
  end

  defcall get_files(path), state: state do
    result = SprocketsProxy.get_files(state_rec(state, :port), path)
    reply result, state
  end

  defcall render_file(path), state: state do
    result = SprocketsProxy.render_file(state_rec(state, :port), path)
    reply result, state
  end

  defcall render_bundle(path), state: state do
    result = SprocketsProxy.render_bundle(state_rec(state, :port), path)
    reply result, state
  end

  defcast stop, state: state do
    { :stop, :normal, state }
  end

  def terminate(_reason, state) do
    SprocketsProxy.stop state_rec(state, :port)
    :ok
  end
end
