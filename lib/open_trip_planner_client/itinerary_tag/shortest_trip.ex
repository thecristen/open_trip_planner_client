defmodule OpenTripPlannerClient.ItineraryTag.ShortestTrip do
  @moduledoc """
  The shortest trip is determined by having the smallest `duration`.
  """
  alias OpenTripPlannerClient.ItineraryTag
  @behaviour ItineraryTag

  @impl ItineraryTag
  def optimal, do: :min

  @impl ItineraryTag
  def score(%{"duration" => duration}), do: duration

  @impl ItineraryTag
  def tag, do: :shortest_trip
end
