defmodule Mix.Tasks.UpdateFixture do
  @moduledoc "Run: `mix update_fixture` to request new data."
  use Mix.Task

  alias OpenTripPlannerClient.ItineraryTag

  @spec run(command_line_args :: [binary]) :: any()
  def run(_) do
    Mix.Task.run("app.start")
    from = [stop_id: "place-alfcl"]
    to = [name: "Franklin Park Zoo", lat_lon: {42.305067, -71.090434}]

    tags = [
      ItineraryTag.EarliestArrival,
      ItineraryTag.LeastWalking,
      ItineraryTag.ShortestTrip
    ]

    {:ok, itineraries} = OpenTripPlannerClient.plan(from, to, tags: tags)

    encoded =
      Jason.encode!(%{data: %{plan: %{routing_errors: [], itineraries: itineraries}}},
        pretty: true
      )

    File.write("test/fixture/alewife_to_franklin_park_zoo.json", encoded)
  end
end
