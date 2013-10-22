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

  defcall include(name), state: state = state_rec(port: port) do
    request = bitstring_to_list "include #{name}\n"
    port <- { self, { :command, request } }
    { num_lines, _ } = Integer.parse read_line(port)
    lines = Enum.map 1..num_lines, fn _ -> read_line(port) end
    reply Enum.join(lines, "\n"), state
  end
  defp read_line(port), do: read_line(port, [])
  defp read_line(port, read) do
    receive do
      { ^port, { :data, data } } ->
        case data do
          { :noeol, chunk } -> read_line(port, [ chunk | read ])
          { :eol, chunk }   -> [ chunk | read ] |> Enum.reverse |> Enum.join
          _                 -> read_line(port, read)
        end
      other ->
        IO.puts "ERR: Unexpected message received: #{inspect other}"
        read_line(port, read)
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
