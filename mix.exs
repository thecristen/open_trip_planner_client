defmodule OpenTripPlannerClient.MixProject do
  use Mix.Project

  @version "0.8.1"

  def project do
    [
      app: :open_trip_planner_client,
      version: @version,
      elixir: "~> 1.16",
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      dialyzer: [plt_add_apps: [:mix]],
      aliases: [
        docs: ["docs --formatter html --output docs"]
      ],
      test_coverage: [ignore_modules: [Mix.Tasks.UpdateFixture]],

      # Docs
      name: "OpenTripPlanner MBTA Client",
      source_url: "https://github.com/thecristen/open_trip_planner_client",
      homepage_url: "https://thecristen.github.io/open_trip_planner_client",
      docs: [
        main: "readme",
        extras: ["README.md"],
        source_ref: "v#{@version}"
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

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
      {:ex_doc, "~> 0.32", only: :dev, runtime: false},
      {:ex_machina, "2.7.0", only: :test},
      {:faker, "0.17.0", only: :test},
      {:jason, "~> 1.4"},
      {:req, "~> 0.3"},
      {:timex, "~> 3.0"}
    ]
  end
end
