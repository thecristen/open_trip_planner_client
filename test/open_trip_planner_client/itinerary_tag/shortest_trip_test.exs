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
      |> Enum.map(&elem(&1, 0))

    assert tags == [[], [], [:shortest_trip]]
  end
end
