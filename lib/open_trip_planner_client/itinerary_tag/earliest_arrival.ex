defmodule OpenTripPlannerClient.ItineraryTag.EarliestArrival do
  @moduledoc """
  The earliest arrival has the earliest `endTime`.
  """
  @behaviour OpenTripPlannerClient.ItineraryTag

  @impl OpenTripPlannerClient.ItineraryTag
  def optimal, do: :min

  @impl OpenTripPlannerClient.ItineraryTag
  def score(%{"endTime" => ms_after_epoch}), do: ms_after_epoch

  @impl OpenTripPlannerClient.ItineraryTag
  def tag, do: :earliest_arrival
end
