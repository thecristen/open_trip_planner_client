defmodule OpenTripPlannerClient.ItineraryTag.LeastWalkingTest do
  use ExUnit.Case, async: true
  import OpenTripPlannerClient.Test.Factory
  alias OpenTripPlannerClient.ItineraryTag

  test "tags, sorts" do
    itineraries = [
      build(:itinerary, %{
        walk_distance: 287
      }),
      build(:itinerary, %{
        walk_distance: 198
      }),
      build(:itinerary, %{
        walk_distance: 198
      })
    ]

    tagged = ItineraryTag.apply_tags(itineraries, [ItineraryTag.LeastWalking])

    assert [
             %{
               walk_distance: 198,
               tag: :least_walking
             },
             %{
               walk_distance: 198,
               tag: :least_walking
             },
             %{
               walk_distance: _,
               tag: nil
             }
           ] = tagged
  end
end
