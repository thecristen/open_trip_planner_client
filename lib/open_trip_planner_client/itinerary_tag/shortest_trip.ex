defmodule OpenTripPlannerClient.ItineraryTag.ShortestTrip do
  @moduledoc """
  The shortest trip is the itinerary having the shortest travel time, e.g. the
  smallest `duration`.
  """
  @behaviour OpenTripPlannerClient.ItineraryTag.Behaviour

  @impl true
  def optimal, do: :min

  @impl true
  def score(%{"duration" => duration}), do: duration

  @impl true
  def tag, do: :shortest_trip
end
