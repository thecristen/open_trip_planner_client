defmodule OpenTripPlannerClient.ItineraryTag.Scorer do
  @moduledoc """
  Computes scores for a set of itineraries from a module implementing the
  `OpenTripPlannerClient.ItineraryTag.Behaviour` behaviour.
  """

  alias OpenTripPlannerClient.ItineraryTag.Behaviour

  @typedoc """
  A function which, for a list of itineraries, outputs a list of indexes
  associated with the itineraries meeting the scoring criteria.
  """
  @type best_score_fn_t :: ([Behaviour.itinerary_map()] -> [non_neg_integer()])

  @doc """
  Returns at least one itinerary scoring function `t:best_score_fn_t/0`. Because
  `OpenTripPlannerClient.ItineraryTag.Behaviour` allows for defining tiebreaking
  functions, an arbitrary number of scoring functions is possible.
  """
  @spec itinerary_scorers(Behaviour.t()) :: list(best_score_fn_t())
  def itinerary_scorers(tag_module) do
    with {:module, tag_module} <- Code.ensure_loaded(tag_module) do
      scorings =
        if function_exported?(tag_module, :tiebreakers, 0) do
          [tag_module | tag_module.tiebreakers()]
        else
          [tag_module]
        end

      scorings
      |> Enum.map(&score_fn/1)
    end
  end

  @spec score_fn(Behaviour.t() | Behaviour.tiebreaker_t()) :: best_score_fn_t()
  defp score_fn({score_fn, optimal}) do
    fn itineraries ->
      scores =
        itineraries
        |> Enum.map(score_fn)

      {min_score, max_score} =
        scores
        |> Enum.reject(&is_nil/1)
        |> Enum.min_max(fn -> {nil, nil} end)

      best_score =
        case optimal do
          :max -> max_score
          :min -> min_score
        end

      scores
      |> Enum.with_index()
      |> Enum.filter(&(elem(&1, 0) === best_score))
      |> Enum.map(&elem(&1, 1))
    end
  end

  defp score_fn(tag_module) do
    {&tag_module.score/1, tag_module.optimal()}
    |> score_fn()
  end
end
