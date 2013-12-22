defmodule DynamoCompanion.SprocketsProxy do
  def start(options // []) do
    port = open_port build_command(options)
    paths = Keyword.get options, :paths, []
    unless Enum.empty?(paths), do: append_paths(port, paths)
    port
  end

  defp build_command(options) do
    libs = Keyword.get(options, :libs, [])
      |> Enum.map(&('--require #{&1}'))
      |> Enum.join(" ")
      |> bitstring_to_list

    cmd = Keyword.get options, :command
    if nil?(cmd) do
      script_path = Path.expand('../../ruby/bin/asset_pipeline.rb', __DIR__)
      cmd = 'bundle exec #{script_path}'
    end
    if Keyword.get(options, :debug, false), do: cmd = '#{cmd} -d'
    cmd = if is_bitstring(cmd), do: bitstring_to_list(cmd), else: cmd
    unless Enum.empty?(libs), do: cmd = cmd ++ ' ' ++ libs
    cmd
  end

  defp open_port(cmd) do
    Port.open { :spawn, cmd }, [
      { :packet, 4 },
        :use_stdio,
        :exit_status,
        :binary
      ]
  end

  def stop(port), do: Port.close(port)

  def append_paths(port, paths), do: exec_request(port, { :append_paths, paths })

  def get_files(port, path), do: exec_request(port, { :get_files, path })

  def render_file(port, path), do: exec_request(port, { :render_file, path })

  def render_bundle(port, path), do: exec_request(port, { :render_bundle, path })

  defp exec_request(port, request) do
    payload = Kernel.term_to_binary(request)
    Port.command(port, payload)
    receive do
      { ^port, { :data, data } } -> binary_to_term(data)
    end
  end
end
