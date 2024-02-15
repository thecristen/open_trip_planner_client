defmodule OpenTripPlannerClient.ItineraryTag.LeastWalking do
  @moduledoc """
  The least walking has the shortest `distance` covered by walking legs.
  """

  @behaviour OpenTripPlannerClient.ItineraryTag

  @impl OpenTripPlannerClient.ItineraryTag
  def optimal, do: :min

  @impl OpenTripPlannerClient.ItineraryTag
  def score(%{"walkDistance" => distance}), do: distance

  @impl OpenTripPlannerClient.ItineraryTag
  def tag, do: :least_walking
end
