defmodule Mix.Tasks.UpdateFixture do
  @moduledoc "Run: `mix update_fixture` to request new data."
  use Mix.Task

  alias OpenTripPlannerClient.PlanParams

  @spec run(command_line_args :: [binary]) :: any()
  def run(_) do
    Mix.Task.run("app.start")

    for mod <- [
          OpenTripPlannerClient.Plan,
          OpenTripPlannerClient.PlanParams,
          OpenTripPlannerClient.Schema.Agency,
          OpenTripPlannerClient.Schema.Geometry,
          OpenTripPlannerClient.Schema.Itinerary,
          OpenTripPlannerClient.Schema.LegTime,
          OpenTripPlannerClient.Schema.Leg,
          OpenTripPlannerClient.Schema.Place,
          OpenTripPlannerClient.Schema.Route,
          OpenTripPlannerClient.Schema.Step,
          OpenTripPlannerClient.Schema.Stop,
          OpenTripPlannerClient.Schema.Trip
        ] do
      Code.ensure_compiled!(mod)
    end

    {:ok, plan} =
      %{
        fromPlace: "::mbta-ma-us:place-alfcl",
        toPlace: "Franklin Park Zoo::42.305067,-71.090434"
      }
      |> PlanParams.new()
      |> OpenTripPlannerClient.send_request()

    encoded = Jason.encode!(%{data: %{plan: plan}}, pretty: true)

    File.write("test/fixture/alewife_to_franklin_park_zoo.json", encoded)
  end
end
