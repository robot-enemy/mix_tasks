defmodule MixTasks.MixProject do
  @moduledoc false
  use Mix.Project

  def project do
    [
      app: :mix_tasks,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ecto, "~> 3.7"},
    ]
  end
end
