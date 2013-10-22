defmodule DynamoCompanion.AssetPipeline do
  use ExActor, export: :asset_pipeline

  defrecordp :state_rec, received: [], port: nil

  definit command do
    command = if nil?(command) do
                'bundle exec bin/asset_pipeline.rb'
              else
                bitstring_to_list(command)
              end
    port = Port.open { :spawn, command }, [
                       { :line, 4096 },
                       :exit_status,
                       :hide,
                       :use_stdio,
                       :stderr_to_stdout
                     ]
   state_rec(port: port)
  end

  defcall get(mode, name), state: state = state_rec(port: port) do
    request = "GET-#{String.upcase atom_to_binary(mode)} #{name}\n"
    port <- { self, { :command, bitstring_to_list(request) } }
    receive do
      { ^port, { :data, data } } -> reply(data, state)
      other -> reply("ERR: Unexpected message received: #{inspect other}", state)
    end
  end

  defcast stop, state: state do
    { :stop, :normal, state }
  end

  def terminate(_reason, state) do
    Port.close(state_rec(state, :port))
    :ok
  end
end
