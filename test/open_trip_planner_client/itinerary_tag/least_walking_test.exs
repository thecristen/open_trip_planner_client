defmodule OpenTripPlannerClient.ItineraryTag.LeastWalkingTest do
  use ExUnit.Case, async: true
  alias OpenTripPlannerClient.ItineraryTag

  test "works" do
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

    tags =
      ItineraryTag.apply_tag(ItineraryTag.LeastWalking, itineraries)
      |> Enum.map(&elem(&1, 0))

    assert tags == [[:least_walking], [], []]
  end
end
