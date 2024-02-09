defmodule OpenTripPlannerClient.ItineraryTag.LeastWalkingTest do
  use ExUnit.Case, async: true
  alias OpenTripPlannerClient.ItineraryTag

  test "tags and sorts" do
    itineraries = [
      %{
        "legs" => [%{"mode" => "SUBWAY"}]
      },
      %{
        "legs" => [%{"mode" => "WALK", "distance" => 10}]
      },
      %{
        "legs" => [%{"mode" => "WALK", "distance" => 8}, %{"mode" => "WALK", "distance" => 8}]
      }
    ]

    tagged =
      ItineraryTag.LeastWalking
      |> ItineraryTag.apply_tag(itineraries)

    assert tagged == [
             %{
               "legs" => [%{"mode" => "SUBWAY"}],
               "tag" => :least_walking
             },
             %{
               "legs" => [%{"mode" => "WALK", "distance" => 10}],
               "tag" => nil
             },
             %{
               "legs" => [
                 %{"mode" => "WALK", "distance" => 8},
                 %{"mode" => "WALK", "distance" => 8}
               ],
               "tag" => nil
             }
           ]
  end
end
