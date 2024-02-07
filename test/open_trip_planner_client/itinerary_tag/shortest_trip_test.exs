defmodule OpenTripPlannerClient.ItineraryTag.ShortestTripTest do
  use ExUnit.Case, async: true
  alias OpenTripPlannerClient.ItineraryTag

  test "works" do
    itineraries = [
      %{"duration" => 100},
      %{"duration" => 123},
      %{"duration" => 99}
    ]

    tags =
      ItineraryTag.ShortestTrip
      |> ItineraryTag.apply_tag(itineraries)
      |> Enum.map(
        &(&1
          |> Map.get("tags")
          |> MapSet.to_list())
      )

    assert tags == [[], [], [:shortest_trip]]
  end
end
