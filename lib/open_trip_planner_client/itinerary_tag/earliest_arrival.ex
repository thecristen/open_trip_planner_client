defmodule OpenTripPlannerClient.ItineraryTag.EarliestArrival do
  @moduledoc """
  The earliest arrival has the earliest `end` time.
  """

  @behaviour OpenTripPlannerClient.ItineraryTag.Behaviour

  alias OpenTripPlannerClient.Schema.Itinerary

  @impl true
  def optimal, do: :min

  @impl true
  def score(%Itinerary{end: end_time}) do
    DateTime.to_unix(end_time)
  end

  @impl true
  def tag, do: :earliest_arrival
end
