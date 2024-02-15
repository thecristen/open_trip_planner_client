defmodule OpenTripPlannerClient.ItineraryTag.LeastWalkingTest do
  use ExUnit.Case, async: true
  alias OpenTripPlannerClient.ItineraryTag

  test "tags, sorts, breaks tie" do
    itineraries = [
      %{
        "walkDistance" => 287
      },
      %{
        "walkDistance" => 198
      },
      %{
        "walkDistance" => 198
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
