defmodule OpenTripPlannerClient.PlanTest do
  use ExUnit.Case, async: true
  alias OpenTripPlannerClient.Plan

  test "creates structs from maps" do
    map = %{
      itineraries: [],
      searchWindowUsed: Faker.random_between(30, 30_000)
    }

    assert {:ok, %Plan{}} = Nestru.decode(map, Plan)
  end

  test "updates unix timestamps to DateTime in local timezone" do
    map = %{date: (Faker.DateTime.forward(1) |> Timex.to_unix()) * 1000}
    assert {:ok, %Plan{date: parsed_date}} = Nestru.decode(map, Plan)
    assert parsed_date.time_zone == Application.fetch_env!(:open_trip_planner_client, :timezone)
  end
end
