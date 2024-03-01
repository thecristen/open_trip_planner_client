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

    tagged =
      ItineraryTag.LeastWalking
      |> ItineraryTag.apply_tag(itineraries)

    assert [
             %{
               "walkDistance" => 198,
               "tag" => :least_walking
             },
             %{
               "walkDistance" => _,
               "tag" => nil
             },
             %{
               "walkDistance" => _,
               "tag" => nil
             }
           ] = tagged
  end
end
