defmodule DynamoCompanion.Mixfile do
  use Mix.Project

  def project do
    [ app: :dynamo_companion,
      version: "0.0.1",
      elixir: "~> 0.11.3-dev",
      deps: deps ]
  end

  def application do
    [ mod: { DynamoCompanion, [] } ]
  end

  defp deps do
    [ { :exactor, github: "sasa1977/exactor" } ]
  end
end
