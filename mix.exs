defmodule OpenTripPlannerClient.MixProject do
  use Mix.Project

  def project do
    [
      app: :open_trip_planner_client,
      version: "0.1.0",
      elixir: "~> 1.16",
      deps: deps(),
      dialyzer: [plt_add_apps: [:mix]],
      test_coverage: [tool: LcovEx],
      aliases: [
        docs: ["docs --formatter html --output docs"]
      ],

      # Docs
      name: "OpenTripPlanner MBTA Client",
      source_url: "https://github.com/thecristen/open_trip_planner_client",
      homepage_url: "https://thecristen.github.io/open_trip_planner_client",
      docs: [
        # The main page in the docs
        main: "OpenTripPlannerClient.Behaviour",
        extras: ["README.md"]
      ]
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
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:lcov_ex, "~> 0.3", only: [:test], runtime: false},
      {:req, "~> 0.3"},
      {:timex, "~> 3.0"}
    ]
  end
end
