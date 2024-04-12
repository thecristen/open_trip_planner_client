defmodule OpenTripPlannerClient.ItineraryTagTest do
  use ExUnit.Case, async: true
  import OpenTripPlannerClientTest.Support.Factory
  alias OpenTripPlannerClient.ItineraryTag

  defmodule ComplexTag do
    @behaviour OpenTripPlannerClient.ItineraryTag

    def optimal, do: :min
    def score(%{"legs" => legs}), do: Enum.count(legs)

    def tiebreakers do
      [
        {&tiebreaker_one/1, :max},
        {&tiebreaker_two/1, :min}
      ]
    end

    def tag, do: :most_bestest

    defp tiebreaker_one(%{"walkDistance" => w}), do: w
    defp tiebreaker_two(%{"numberOfTransfers" => n}), do: n
  end

  defmodule BadTag do
    @behaviour OpenTripPlannerClient.ItineraryTag

    def optimal, do: :max
    def score(_), do: nil
    def tag, do: :bad
  end

  setup_all do
    itineraries =
      build_list(9, :itinerary, %{legs: build_list(3, :leg)})

    max_walk =
      itineraries
      |> Enum.max_by(& &1["walkDistance"])
      |> Map.get("walkDistance")

    tied_itineraries =
      itineraries
      |> Enum.map(fn itinerary ->
        if Enum.random([true, false]) do
          Map.put(itinerary, "walkDistance", max_walk + 20)
        else
          itinerary
        end
      end)

    {:ok,
     %{
       complex_itineraries: ItineraryTag.apply_tag(ComplexTag, tied_itineraries),
       bad_itineraries: ItineraryTag.apply_tag(BadTag, itineraries)
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

  describe "can apply multiple levels of tiebreaking" do
    test "tags only a single itinerary", %{complex_itineraries: itineraries} do
      assert Enum.count(itineraries, &(&1["tag"] == :most_bestest)) == 1
    end

    test "tagged one wins all ties", %{complex_itineraries: itineraries} do
      {[
         %{
           "legs" => best_legs,
           "numberOfTransfers" => best_transfers,
           "walkDistance" => best_walk
         }
       ],
       untagged} =
        Enum.split_with(itineraries, &(&1["tag"] == :most_bestest))

      for %{"legs" => legs, "numberOfTransfers" => transfers, "walkDistance" => walk} <- untagged do
        assert Enum.count(best_legs) <= Enum.count(legs)
        assert best_transfers <= transfers
        # used :max
        assert best_walk >= walk
      end
    end
  end
end
