defmodule OpenTripPlannerClient.MixProject do
  use Mix.Project

  def project do
    [
      app: :open_trip_planner_client,
      version: "0.1.0",
      elixir: "~> 1.16",
      deps: deps(),
      dialyzer: [plt_add_apps: [:mix]],
      test_coverage: [tool: LcovEx]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:absinthe_client, "~> 0.1.0"},
      {:bypass, "~> 2.1", only: :test},
      {:credo, "~> 1.7", only: [:dev, :test]},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:lcov_ex, "~> 0.3", only: [:test], runtime: false},
      {:req, "~> 0.3"},
      {:timex, "~> 3.7"}
    ]
  end
end
