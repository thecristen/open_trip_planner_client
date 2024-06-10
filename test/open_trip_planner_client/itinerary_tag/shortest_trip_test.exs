defmodule OpenTripPlannerClient.ItineraryTag.ShortestTripTest do
  use ExUnit.Case, async: true
  import OpenTripPlannerClient.Test.Factory
  alias OpenTripPlannerClient.ItineraryTag

  test "tags, sorts" do
    itineraries = [
      build(:itinerary, %{duration: 100}),
      build(:itinerary, %{duration: 123}),
      build(:itinerary, %{duration: 99}),
      build(:itinerary, %{duration: 99})
    ]

    tagged = ItineraryTag.apply_tags(itineraries, [ItineraryTag.ShortestTrip])

    assert [
             %{"duration" => 99, "tag" => :shortest_trip},
             %{"duration" => 99, "tag" => :shortest_trip},
             %{"tag" => nil},
             %{"tag" => nil}
           ] = tagged
  end
end
