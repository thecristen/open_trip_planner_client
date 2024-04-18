defmodule OpenTripPlannerClient.ItineraryTag.LeastWalking do
  @moduledoc """
  The least walking has the shortest `distance` covered by walking legs.
  """

  @behaviour OpenTripPlannerClient.ItineraryTag.Behaviour

  @impl true
  def optimal, do: :min

  @impl true
  def score(%{"walkDistance" => distance}), do: distance

  @impl true
  def tag, do: :least_walking
end
