defmodule OpenTripPlannerClient.ItineraryTag.MostDirectTest do
  use ExUnit.Case, async: true
  alias OpenTripPlannerClient.ItineraryTag

  test "tags and sorts" do
    itineraries = [
      %{
        "legs" => [
          %{
            "transitLeg" => false,
            "steps" => [
              %{"distance" => 5},
              %{"distance" => 5}
            ]
          },
          %{"transitLeg" => true},
          %{"transitLeg" => true},
          %{"transitLeg" => true},
          %{
            "transitLeg" => false,
            "steps" => [
              %{"distance" => 5},
              %{"distance" => 5}
            ]
          }
        ]
      }
    ]

    tagged =
      ItineraryTag.MostDirect
      |> ItineraryTag.apply_tag(itineraries)

    assert tagged
  end
end
