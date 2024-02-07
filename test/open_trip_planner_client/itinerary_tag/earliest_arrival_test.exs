defmodule OpenTripPlannerClient.ItineraryTag.EarliestArrivalTest do
  use ExUnit.Case, async: true
  alias OpenTripPlannerClient.ItineraryTag

  test "works" do
    itineraries = [
      %{"endTime" => 12_345_678},
      %{"endTime" => 12_345_888},
      %{"endTime" => 12_345_678}
    ]

    tags =
      ItineraryTag.EarliestArrival
      |> ItineraryTag.apply_tag(itineraries)
      |> Enum.map(&elem(&1, 0))

    assert tags == [[:earliest_arrival], [], [:earliest_arrival]]
  end
end
