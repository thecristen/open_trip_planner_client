defmodule OpenTripPlannerClient.ItineraryTag.EarliestArrival do
  @moduledoc """
  The earliest arrival has the earliest `endTime`.
  """

  alias OpenTripPlannerClient.ItineraryTag
  @behaviour ItineraryTag

  @impl ItineraryTag
  def optimal, do: :min

  @impl ItineraryTag
  def score(%{"endTime" => ms_after_epoch}), do: ms_after_epoch

  @impl ItineraryTag
  def tag, do: :earliest_arrival
end
