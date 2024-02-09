defmodule OpenTripPlannerClient.ItineraryTag.ShortestTripTest do
  use ExUnit.Case, async: true
  alias OpenTripPlannerClient.ItineraryTag

  test "tags and sorts" do
    itineraries = [
      %{"duration" => 100},
      %{"duration" => 123},
      %{"duration" => 99}
    ]

    tagged =
      ItineraryTag.ShortestTrip
      |> ItineraryTag.apply_tag(itineraries)

    assert tagged == [
             %{"duration" => 99, "tag" => :shortest_trip},
             %{"duration" => 100, "tag" => nil},
             %{"duration" => 123, "tag" => nil}
           ]
  end
end
