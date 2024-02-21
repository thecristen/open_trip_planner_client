defmodule OpenTripPlannerClient.ItineraryTag.MostDirect do
  @moduledoc """
  The most direct trip is the itinerary having the fewest number of transit
  legs. If two itineraries have the same number of transit legs, break ties by
  selecting the one with the minimal total walking distance.
  """
  @behaviour OpenTripPlannerClient.ItineraryTag

  alias OpenTripPlannerClient.ItineraryTag.LeastWalking

  @impl OpenTripPlannerClient.ItineraryTag
  def optimal, do: :min

  @impl OpenTripPlannerClient.ItineraryTag
  def score(%{"numberOfTransfers" => number}), do: number

  @impl OpenTripPlannerClient.ItineraryTag
  def tiebreakers do
    [{&LeastWalking.score/1, LeastWalking.optimal()}]
  end

  @impl OpenTripPlannerClient.ItineraryTag
  def tag, do: :most_direct
end
