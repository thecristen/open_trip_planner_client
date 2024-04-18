defmodule OpenTripPlannerClient.ItineraryTag do
  @moduledoc """
  Logic for applying multiple `OpenTripPlannerClient.ItineraryTag` scoring to a
  list of itineraries.
  """

  alias OpenTripPlannerClient.ItineraryTag.{
    Behaviour,
    EarliestArrival,
    LeastWalking,
    MostDirect,
    Scorer,
    ShortestTrip
  }

  @tag_priority_order [
                        MostDirect,
                        EarliestArrival,
                        ShortestTrip,
                        LeastWalking
                      ]
                      |> Enum.map(& &1.tag())

  @doc """
  Apply scores from a number of modules implementing the
  `OpenTripPlannerClient.ItineraryTag.Behaviour` behaviour, choosing tags for
  each eligible itinerary according to `@tag_priority_order`.
  """
  @spec apply_tags([Behaviour.itinerary_map()], [Behaviour.t()]) :: [Behaviour.itinerary_map()]
  def apply_tags(itineraries, tag_modules) do
    itineraries =
      itineraries
      |> Enum.map(&Map.put_new(&1, :candidate_tags, []))

    tag_modules
    |> Enum.reduce(itineraries, &apply_candidate_tag/2)
    |> Enum.map(&with_winning_tag/1)
  end

  @spec apply_candidate_tag(Behaviour.t(), [Behaviour.itinerary_map()]) :: [
          Behaviour.itinerary_map()
        ]
  defp apply_candidate_tag(tag_module, itineraries) do
    winning_indexes = winning_indexes(tag_module, itineraries)

    itineraries
    |> Enum.with_index()
    |> Enum.map(fn {itinerary, index} ->
      if index in winning_indexes do
        %{itinerary | candidate_tags: [tag_module.tag() | itinerary.candidate_tags]}
      else
        itinerary
      end
    end)
  end

  @spec winning_indexes(Behaviour.t(), [Behaviour.itinerary_map()]) :: [non_neg_integer()]
  defp winning_indexes(tag_module, itineraries) do
    tag_module
    |> Scorer.itinerary_scorers()
    |> Enum.map(& &1.(itineraries))
    |> Enum.reduce_while([], &iterative_scoring/2)
  end

  # Multiple scoring criteria are ordered, only proceeding to the next in the
  # event of a tie. Therefore walk through each set of scores and stop when
  # there's a single winner or after every score has been considered.
  @spec iterative_scoring([non_neg_integer()], [non_neg_integer()]) ::
          {:cont, [non_neg_integer()]} | {:halt, [non_neg_integer()]}
  defp iterative_scoring(candidates, []), do: {:cont, candidates}
  defp iterative_scoring(_, [single_winner]), do: {:halt, [single_winner]}

  defp iterative_scoring(candidates, winners) do
    edits = List.myers_difference(winners, candidates)

    if Keyword.has_key?(edits, :eq) do
      {:cont, Keyword.get(edits, :eq)}
    else
      {:halt, winners}
    end
  end

  defp with_winning_tag(%{candidate_tags: candidate_tags} = itinerary) do
    winning_tag =
      Enum.find(@tag_priority_order, &Enum.member?(candidate_tags, &1))

    itinerary
    |> Map.put("tag", winning_tag)
    |> Map.drop([:candidate_tags])
  end
end
