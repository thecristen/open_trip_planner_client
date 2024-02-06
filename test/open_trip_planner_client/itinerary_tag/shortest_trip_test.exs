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
      ItineraryTag.apply_tag(ItineraryTag.ShortestTrip, itineraries)
      |> Enum.map(&elem(&1, 0))

    assert tags == [[], [], [:shortest_trip]]
  end
end
