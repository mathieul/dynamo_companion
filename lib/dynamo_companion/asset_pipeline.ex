defmodule DynamoCompanion.AssetPipeline do
  use GenServer.Behaviour

  #####
  # External API

  def start_link(command // "./bin/asset_pipeline.rb") do
    cmd = bitstring_to_list(command)
    :gen_server.start_link({ :local, :asset_pipeline }, __MODULE__, cmd, [])
  end
  def get(mode, name), do: :gen_server.call(:asset_pipeline, { :get, mode, name })
  def stop, do: :gen_server.cast(:asset_pipeline, :stop)

  #####
  # GenServer implementation

  def init(command) do
    port = Port.open({ :spawn, command },
      [ { :line, 4096 }, :exit_status, :hide, :use_stdio, :stderr_to_stdout ])
    { :ok, [ received: [], port: port ] }
  end

  def handle_call({ :get, mode, name }, _from, state = [ received: _received, port: port ]) do
    request = "GET-#{String.upcase atom_to_binary(mode)} #{name}\n"
    port <- { self, { :command, bitstring_to_list(request) } }
    # :timer.sleep 1000
    # { :reply, "nope", state }
    receive do
      { ^port, { :data, data } } ->
        { :reply, data, state }
      other ->
        { :reply, "ERR: Unexpected message received: #{inspect other}", state }
    end
  end

  def handle_cast(:stop, state) do
    { :stop, :client_request, state }
  end
  def handle_cast(message, state) do
    IO.puts "CAST: message received: #{inspect message}"
    { :noreply, state }
  end

  def terminate(_reason, [ received: _, port: port ]) do
    Port.close(port)
    :ok
  end
end
