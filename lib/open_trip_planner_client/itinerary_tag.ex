defmodule OpenTripPlannerClient.ItineraryTag do
  @moduledoc """
  Logic for a tag which can be applied to itineraries which are the best by some criterion.
  """
  alias OpenTripPlannerClient.Behaviour

  @callback optimal :: :max | :min
  @callback score(Behaviour.itinerary()) :: number() | nil
  @callback tag :: tag()

  @type t :: module()
  @type tag :: atom()

  @doc """
  Applies the tag defined by the given module to the itinerary with the optimal score.

  If multiple itineraries are optimal, they will each get the tag.
  If all itineraries have a score of nil, nothing gets the tag.
  """
  @spec apply_tag(t(), [Behaviour.itinerary()]) :: [Behaviour.itinerary_with_tags()]
  @spec apply_tag(t(), [Behaviour.itinerary_with_tags()]) :: [Behaviour.itinerary_with_tags()]
  def apply_tag(tag_module, [%{} | _] = untagged_itineraries) do
    apply_tag(tag_module, Enum.map(untagged_itineraries, &{[], &1}))
  end

  def apply_tag(tag_module, itineraries) do
    scores = itineraries |> Enum.map(fn {_tags, itinerary} -> tag_module.score(itinerary) end)
    {min_score, max_score} = Enum.min_max(scores |> Enum.reject(&is_nil/1), fn -> {nil, nil} end)

    best_score =
      case tag_module.optimal() do
        :max -> max_score
        :min -> min_score
      end

    Enum.zip(itineraries, scores)
    |> Enum.map(fn {{existing_tags, itinerary}, score} ->
      if not is_nil(score) and score == best_score do
        {[tag_module.tag() | existing_tags], itinerary}
      else
        {existing_tags, itinerary}
      end
    end)
  end
end
