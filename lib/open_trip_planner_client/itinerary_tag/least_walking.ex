defmodule OpenTripPlannerClient.ItineraryTag.LeastWalking do
  @moduledoc """
  The least walking has the shortest `distance` covered by walking legs.
  """

  @behaviour OpenTripPlannerClient.ItineraryTag

  @impl OpenTripPlannerClient.ItineraryTag
  def optimal, do: :min

  @impl OpenTripPlannerClient.ItineraryTag
  def score(%{"legs" => legs}) do
    legs
    |> Enum.map(&walking_distance/1)
    |> Enum.sum()
  end

  defp walking_distance(%{"distance" => distance, "mode" => "WALK"}), do: distance
  defp walking_distance(_), do: 0.0

  @impl OpenTripPlannerClient.ItineraryTag
  def tag, do: :least_walking
end
