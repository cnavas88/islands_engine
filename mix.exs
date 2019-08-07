defmodule IslandsEngine.MixProject do
  use Mix.Project

  def project do
    [
      app: :islands_engine,
      version: "0.1.1",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {IslandsEngine.Application, []}
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.1.2", only: [:dev, :test], runtime: false}
    ]
  end
end
