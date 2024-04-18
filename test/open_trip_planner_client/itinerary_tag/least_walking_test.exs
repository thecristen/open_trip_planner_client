defmodule OpenTripPlannerClient.ItineraryTag.LeastWalkingTest do
  use ExUnit.Case, async: true
  alias OpenTripPlannerClient.ItineraryTag

  test "tags, sorts, breaks tie" do
    itineraries = [
      %{
        "walkDistance" => 287,
        "tag" => nil
      },
      %{
        "walkDistance" => 198,
        "tag" => nil
      },
      %{
        "walkDistance" => 198,
        "tag" => nil
      }
    ]

    tagged = ItineraryTag.apply_tags(itineraries, [ItineraryTag.LeastWalking])

    assert [
             %{
               "walkDistance" => _,
               "tag" => nil
             },
             %{
               "walkDistance" => 198,
               "tag" => :least_walking
             },
             %{
               "walkDistance" => 198,
               "tag" => :least_walking
             }
           ] = tagged
  end
end
