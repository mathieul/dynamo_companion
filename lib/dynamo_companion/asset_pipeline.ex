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
    reply execute_command(:append_paths, path, state), state
  end

  defcall get_files(path), state: state do
    files = execute_command(:get_files, path, state)
    reply String.split(files), state
  end

  defcall render_file(path), state: state do
    reply execute_command(:render_file, path, state), state
  end

  defcall render_bundle(path), state: state do
    reply execute_command(:render_bundle, path, state), state
  end

  defp execute_command command, path, state_rec(port: port) do
    SprocketsProxy.send_request port, command, [ path ]
    SprocketsProxy.receive_content(port)
  end

  defcast stop, state: state do
    { :stop, :normal, state }
  end

  def terminate(_reason, state) do
    SprocketsProxy.stop state_rec(state, :port)
    :ok
  end
end
