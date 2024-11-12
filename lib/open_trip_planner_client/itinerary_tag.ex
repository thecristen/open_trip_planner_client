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

  @spec tag_priority_order() :: [atom()]
  def tag_priority_order, do: @tag_priority_order

  @spec default_arriving() :: [Behaviour.t()]
  def default_arriving, do: [ShortestTrip, MostDirect, LeastWalking]

  @spec default_departing() :: [Behaviour.t()]
  def default_departing, do: [EarliestArrival, MostDirect, LeastWalking]

  @doc """
  Apply scores from a number of modules implementing the
  `OpenTripPlannerClient.ItineraryTag.Behaviour` behaviour, choosing tags for
  each eligible itinerary according to `@tag_priority_order`.
  """
  @spec apply_tags([Behaviour.itinerary_map()], [Behaviour.t()]) :: [Behaviour.itinerary_map()]
  def apply_tags([], _), do: []
  def apply_tags(itineraries, []), do: itineraries
  # Don't apply tags if there's only one itinerary returned
  def apply_tags([%{}] = itineraries, _), do: itineraries

  def apply_tags(itineraries, tag_modules) do
    itineraries =
      itineraries
      |> Enum.map(&Map.put_new(&1, :candidate_tags, []))

    tag_modules
    |> Enum.reduce(itineraries, &apply_candidate_tag/2)
    |> Enum.map(&with_winning_tag/1)
    |> sort_tagged()
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
    |> Enum.map(fn scoring_fn ->
      itineraries
      |> scoring_fn.()
      |> Enum.with_index()
    end)
    |> consolidate_indexed_rankings()
  end

  # Multiple scoring criteria are ordered, only proceeding to the next in the
  # event of a tie. Therefore walk through each set of scores and stop when
  # there's a single winner or after every score has been considered. Subsequent
  # rounds of scoring should only be applied on winners from the prior round.
  defp consolidate_indexed_rankings([single_ranking]) do
    if single_ranking == [] do
      []
    else
      {best_value, _} =
        single_ranking
        |> Enum.min_by(&elem(&1, 0))

      single_ranking
      |> Enum.filter(&(elem(&1, 0) == best_value))
      |> Enum.map(&elem(&1, 1))
    end
  end

  defp consolidate_indexed_rankings([single_ranking | other_rankings]) do
    winning_indexes = consolidate_indexed_rankings([single_ranking])

    if length(winning_indexes) == 1 do
      winning_indexes
    else
      other_rankings
      |> Enum.map(fn indexed_rankings ->
        indexed_rankings
        |> Enum.filter(&(elem(&1, 1) in winning_indexes))
      end)
      |> consolidate_indexed_rankings()
    end
  end

  defp with_winning_tag(%{candidate_tags: candidate_tags} = itinerary) do
    winning_tag =
      Enum.find(@tag_priority_order, &Enum.member?(candidate_tags, &1))

    itinerary
    |> Map.put(:tag, winning_tag)
    |> Map.drop([:candidate_tags])
  end

  @spec sort_tagged([Behaviour.itinerary_map()]) :: [Behaviour.itinerary_map()]
  def sort_tagged(tagged_itineraries) do
    chrono_sorter = fn itinerary ->
      itinerary.start
      |> DateTime.to_unix()
    end

    priority_sorter = fn itinerary ->
      @tag_priority_order
      |> Enum.find_index(&(&1 === itinerary.tag))
    end

    tagged_itineraries
    |> Enum.sort_by(&{priority_sorter.(&1), chrono_sorter.(&1)})
  end
end
