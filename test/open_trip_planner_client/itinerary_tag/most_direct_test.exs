defmodule OpenTripPlannerClient.ItineraryTag.MostDirectTest do
  use ExUnit.Case, async: true
  import OpenTripPlannerClientTest.Support.Factory
  alias OpenTripPlannerClient.ItineraryTag

  test "tags, sorts, breaks tie" do
    itineraries = add_ties(build_list(7, :itinerary))

    with_tag =
      ItineraryTag.MostDirect
      |> ItineraryTag.apply_tag(itineraries)

    # all others should have both fewer/equal number of transfers and fewer/equal walking distance
    {[%{"numberOfTransfers" => best_transfers, "walkDistance" => best_walk}], untagged} =
      Enum.split_with(with_tag, &(&1["tag"] == :most_direct))

    for %{"numberOfTransfers" => transfers, "walkDistance" => walk} <- untagged do
      assert best_transfers <= transfers
      assert best_walk <= walk
    end
  end

  defp add_ties(itineraries) do
    itineraries
    |> Enum.map(&Map.put(&1, "numberOfTransfers", 1))
  end
end
