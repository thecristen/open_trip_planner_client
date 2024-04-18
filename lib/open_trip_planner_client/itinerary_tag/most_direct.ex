defmodule OpenTripPlannerClient.ItineraryTag.MostDirect do
  @moduledoc """
  The most direct trip is the itinerary having the fewest number of transit
  legs. If two itineraries have the same number of transit legs, break ties by
  selecting the one with the minimal total walking distance.
  """
  @behaviour OpenTripPlannerClient.ItineraryTag.Behaviour

  alias OpenTripPlannerClient.ItineraryTag.LeastWalking

  @impl true
  def optimal, do: :min

  @impl true
  def score(%{"numberOfTransfers" => number}), do: number

  @impl true
  def tiebreakers do
    [{&LeastWalking.score/1, LeastWalking.optimal()}]
  end

  @impl true
  def tag, do: :most_direct
end
