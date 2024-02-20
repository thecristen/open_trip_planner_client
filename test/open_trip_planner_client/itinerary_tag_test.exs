defmodule OpenTripPlannerClient.ItineraryTagTest do
  use ExUnit.Case, async: true
  alias OpenTripPlannerClient.ItineraryTag

  defmodule BadTag do
    @behaviour OpenTripPlannerClient.ItineraryTag

    def optimal, do: :max
    def score(_), do: nil
    def tag, do: :bad
  end

  test "correctly ignores tags that are always nil" do
    itineraries = [%{"startTime" => 1, "endTime" => 2}]
    tags = ItineraryTag.apply_tag(BadTag, itineraries)
    assert tags == [%{"startTime" => 1, "endTime" => 2, "tag" => nil}]
  end

  test "overrides tags of lower priority" do
    itineraries = [
      %{"startTime" => 1, "endTime" => 2, "duration" => 40, "tag" => :least_walking},
      %{"startTime" => 1, "endTime" => 2, "duration" => 50, "tag" => :least_walking}
    ]

    # Does not override
    assert ItineraryTag.ShortestTrip
           |> ItineraryTag.apply_tag(itineraries)
           |> List.first()
           |> Map.get("tag") == :shortest_trip

    # Overrides
    assert ItineraryTag.EarliestArrival
           |> ItineraryTag.apply_tag(itineraries)
           |> List.first()
           |> Map.get("tag") == :earliest_arrival
  end
end
