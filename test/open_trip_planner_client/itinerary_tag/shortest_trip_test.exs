defmodule OpenTripPlannerClient.ItineraryTag.ShortestTripTest do
  use ExUnit.Case, async: true
  alias OpenTripPlannerClient.ItineraryTag

  test "tags" do
    itineraries = [
      %{"duration" => 100, "tag" => nil},
      %{"duration" => 123, "tag" => nil},
      %{"duration" => 99, "tag" => nil},
      %{"duration" => 99, "tag" => nil}
    ]

    tagged = ItineraryTag.apply_tags(itineraries, [ItineraryTag.ShortestTrip])

    assert tagged == [
             %{"duration" => 100, "tag" => nil},
             %{"duration" => 123, "tag" => nil},
             %{"duration" => 99, "tag" => :shortest_trip},
             %{"duration" => 99, "tag" => :shortest_trip}
           ]
  end
end
