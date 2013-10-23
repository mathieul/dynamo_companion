defmodule DynamoCompanion.SprocketsProxy do
  require IEx
  def start(options // []) do
    cmd = Keyword.get options, :command, 'bundle exec bin/asset_pipeline.rb'
    cmd = if is_bitstring(cmd), do: bitstring_to_list(cmd), else: cmd
    port = open_port cmd
    paths = Keyword.get options, :paths, []
    unless Enum.empty?(paths), do: send_request(port, :append_paths, paths)
    port
  end

  defp open_port(cmd) do
    Port.open { :spawn, cmd }, [
      { :line, 4096 },
        :exit_status,
        :hide,
        :use_stdio,
        :stderr_to_stdout
      ]
  end

  def stop(port), do: Port.close(port)

  def send_request(port, cmd, args) do
    request = '#{cmd} #{Enum.join args, " "}\n'
    port <- { self, { :command, request } }
  end

  def receive_content(port) do
    num_lines = read_num_lines_in_response(port)
    if num_lines > 0 do
      1..num_lines
        |> Enum.map(fn _ -> read_line(port) end)
        |> Enum.join("\n")
    else
      ""
    end
  end

  defp read_line(port), do: read_line(port, [])
  defp read_line(port, read) do
    receive do
      { ^port, { :data, data } } ->
        case data do
          { :noeol, chunk } -> read_line(port, [ chunk | read ])
          { :eol, chunk }   -> [ chunk | read ] |> Enum.reverse |> Enum.join
        end
    end
  end

  defp read_num_lines_in_response(port) do
    { num_lines, rest } = Integer.parse read_line(port)
    num_lines
  end
end
