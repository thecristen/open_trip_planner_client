defmodule OpenTripPlannerClient.ItineraryTag.MostDirectTest do
  use ExUnit.Case, async: true

  import OpenTripPlannerClient.Test.Support.Factory

  alias OpenTripPlannerClient.ItineraryTag

  test "tags, sorts, breaks tie" do
    itineraries = add_ties(build_list(7, :itinerary))
    with_tag = ItineraryTag.apply_tags(itineraries, [ItineraryTag.MostDirect])

    # all others should have both fewer/equal number of transfers and fewer/equal walking distance
    {tagged, untagged} =
      Enum.split_with(with_tag, &(&1.tag == :most_direct))

    for %{number_of_transfers: transfers, walk_distance: walk} <- untagged do
      assert Enum.all?(tagged, &(&1.number_of_transfers <= transfers))
      assert Enum.all?(tagged, &(&1.walk_distance < walk))
    end
  end

  defp add_ties(itineraries) do
    itineraries
    |> Enum.map(&Map.put(&1, :number_of_transfers, 1))
  end
end
