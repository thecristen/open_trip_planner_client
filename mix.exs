defmodule OpenTripPlannerClient.MixProject do
  use Mix.Project

  @version "0.8.1"

  def project do
    [
      app: :open_trip_planner_client,
      version: @version,
      elixir: "~> 1.16",
      deps: deps(),
      dialyzer: [plt_add_apps: [:mix]],
      aliases: [
        docs: ["docs --formatter html --output docs"]
      ],
      test_coverage: [
        ignore_modules: [
          Mix.Tasks.UpdateFixture,
          ~r/Jason.Encoder.OpenTripPlannerClient.Schema\./
        ]
      ],

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
      {:ex_machina, "2.7.0"},
      {:faker, "0.18.0"},
      {:jason, "~> 1.4"},
      {:jason_structs,
       git: "https://github.com/ygunayer/jason_structs.git", branch: "ygunayer-namespaced-structs"},
      {:req, "~> 0.3"},
      {:timex, "~> 3.0"}
    ]
  end
end
