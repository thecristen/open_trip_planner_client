defmodule OpenTripPlannerClient.ItineraryTag do
  @moduledoc """
  Logic for a tag which can be applied to itineraries which are the best by some criterion.
  """
  @callback optimal :: :max | :min
  @callback score(map()) :: number() | nil
  @callback tag :: atom()

  @type t :: module()

  @doc """
  Applies the tag defined by the given module to the itinerary with the optimal score.

  If multiple itineraries are optimal, they will each get the tag.
  If all itineraries have a score of nil, nothing gets the tag.
  """
  @spec apply_tag(t(), [map()]) :: [map()]
  def apply_tag(tag_module, itineraries) do
    scores = itineraries |> Enum.map(&tag_module.score/1)

    {min_score, max_score} =
      scores
      |> Enum.reject(&is_nil/1)
      |> Enum.min_max(fn -> {nil, nil} end)

    best_score =
      case tag_module.optimal() do
        :max -> max_score
        :min -> min_score
      end

    itineraries
    |> Enum.map(&initialize_tags/1)
    |> Enum.zip(scores)
    |> Enum.map(fn {itinerary, score} ->
      apply_best({itinerary, score}, score === best_score, tag_module.tag())
    end)
  end

  defp initialize_tags(%{"tags" => _} = itinerary), do: itinerary
  defp initialize_tags(itinerary), do: Map.put_new(itinerary, "tags", MapSet.new())

  defp apply_best({itinerary, nil}, _, _), do: itinerary
  defp apply_best({itinerary, _}, false, _), do: itinerary

  defp apply_best({%{} = itinerary, _}, true, tag) do
    update_in(itinerary["tags"], &MapSet.put(&1, tag))
  end
end
