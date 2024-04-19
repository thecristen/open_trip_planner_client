defmodule OpenTripPlannerClient.ItineraryTag.LeastWalkingTest do
  use ExUnit.Case, async: true
  import OpenTripPlannerClientTest.Support.Factory
  alias OpenTripPlannerClient.ItineraryTag

  test "tags, sorts" do
    itineraries = [
      build(:itinerary, %{
        walkDistance: 287
      }),
      build(:itinerary, %{
        walkDistance: 198
      }),
      build(:itinerary, %{
        walkDistance: 198
      })
    ]

    tagged = ItineraryTag.apply_tags(itineraries, [ItineraryTag.LeastWalking])

    assert [
             %{
               "walkDistance" => 198,
               "tag" => :least_walking
             },
             %{
               "walkDistance" => 198,
               "tag" => :least_walking
             },
             %{
               "walkDistance" => _,
               "tag" => nil
             }
           ] = tagged
  end
end
