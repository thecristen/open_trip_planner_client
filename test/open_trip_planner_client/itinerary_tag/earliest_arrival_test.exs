defmodule OpenTripPlannerClient.ItineraryTag.EarliestArrivalTest do
  use ExUnit.Case, async: true
  alias OpenTripPlannerClient.ItineraryTag

  test "tags, sorts, breaks tie" do
    itineraries = [
      %{"endTime" => 12_345_678, "tag" => nil},
      %{"endTime" => 12_345_888, "tag" => nil},
      %{"endTime" => 12_345_678, "tag" => nil}
    ]

    tagged =
      ItineraryTag.EarliestArrival
      |> ItineraryTag.apply_tag(itineraries)

    assert [
             %{"endTime" => 12_345_678, "tag" => :earliest_arrival},
             %{"tag" => nil},
             %{"tag" => nil}
           ] = tagged
  end
end
