defmodule OpenTripPlannerClient.ItineraryTag.ShortestTrip do
  @moduledoc """
  The shortest trip is the itinerary having the shortest travel time, e.g. the
  smallest `duration`.
  """
  @behaviour OpenTripPlannerClient.ItineraryTag

  @impl OpenTripPlannerClient.ItineraryTag
  def optimal, do: :min

  @impl OpenTripPlannerClient.ItineraryTag
  def score(%{"duration" => duration}), do: duration

  @impl OpenTripPlannerClient.ItineraryTag
  def tag, do: :shortest_trip
end
