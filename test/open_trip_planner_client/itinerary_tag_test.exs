defmodule OpenTripPlannerClient.ItineraryTagTest do
  use ExUnit.Case, async: true
  import OpenTripPlannerClientTest.Support.Factory
  alias OpenTripPlannerClient.ItineraryTag

  defmodule BadTag do
    @behaviour OpenTripPlannerClient.ItineraryTag.Behaviour

    def optimal, do: :max
    def score(_), do: nil
    def tag, do: :bad
  end

  setup_all do
    itineraries =
      build_list(9, :itinerary, %{legs: build_list(3, :leg)})

    {:ok,
     %{
       bad_itineraries: ItineraryTag.apply_tags(itineraries, [BadTag])
     }}
  end

  test "correctly ignores tags that are always nil", %{bad_itineraries: itineraries} do
    assert Enum.all?(itineraries, &is_nil(&1["tag"]))
  end

  test "overrides tags of lower priority" do
    end_dt = Faker.DateTime.backward(4)

    itineraries = [
      %{"end" => DateTime.to_iso8601(end_dt), "duration" => 40, "tag" => :least_walking},
      %{"end" => DateTime.to_iso8601(end_dt), "duration" => 50, "tag" => :least_walking}
    ]

    # Does not override
    assert itineraries
           |> ItineraryTag.apply_tags([ItineraryTag.ShortestTrip])
           |> List.first()
           |> Map.get("tag") == :shortest_trip

    # Overrides
    assert itineraries
           |> ItineraryTag.apply_tags([ItineraryTag.EarliestArrival])
           |> List.first()
           |> Map.get("tag") == :earliest_arrival
  end
end
