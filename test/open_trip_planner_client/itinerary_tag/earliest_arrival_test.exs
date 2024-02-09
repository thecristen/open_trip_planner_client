defmodule OpenTripPlannerClient.ItineraryTag.EarliestArrivalTest do
  use ExUnit.Case, async: true
  alias OpenTripPlannerClient.ItineraryTag

  test "tags and sorts" do
    itineraries = [
      %{"endTime" => 12_345_678},
      %{"endTime" => 12_345_888},
      %{"endTime" => 12_345_678}
    ]

    tagged =
      ItineraryTag.EarliestArrival
      |> ItineraryTag.apply_tag(itineraries)

    assert tagged == [
             %{"endTime" => 12_345_678, "tag" => :earliest_arrival},
             %{"endTime" => 12_345_678, "tag" => :earliest_arrival},
             %{"endTime" => 12_345_888, "tag" => nil}
           ]
  end
end
