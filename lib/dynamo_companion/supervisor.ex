defmodule DynamoCompanion.Supervisor do
  use Supervisor.Behaviour

  def start_link do
    :supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = [
      worker(DynamoCompanion.AssetPipeline, [ asset_pipeline_config ])
    ]
    supervise(children, strategy: :one_for_one)
  end

  defp asset_pipeline_config do
    libs = Mix.project[:dynamo_companion][:libs]
    debug = Mix.project[:dynamo_companion][:debug]

    [ libs:  (if libs == nil, do: [], else: libs),
      debug: (if debug == nil, do: false, else: debug) ]
  end
end
