defmodule OpenTripPlannerClient.ItineraryTag.LeastWalking do
  @moduledoc """
  The least walking has the shortest `distance` covered by walking legs.
  """

  @behaviour OpenTripPlannerClient.ItineraryTag.Behaviour

  alias OpenTripPlannerClient.Schema.Itinerary

  @impl true
  def optimal, do: :min

  @impl true
  def score(%Itinerary{walk_distance: walk_distance}), do: walk_distance

  @impl true
  def tag, do: :least_walking
end
