defmodule OpenTripPlannerClient.ItineraryTag.MostDirect do
  @moduledoc """
  The most direct trip is the itinerary having the fewest number of transit
  legs. If two itineraries have the same number of transit legs, break ties by
  selecting the one with the minimal total walking distance.
  """
  @behaviour OpenTripPlannerClient.ItineraryTag

  @impl OpenTripPlannerClient.ItineraryTag
  def optimal, do: [:min, :min]

  @impl OpenTripPlannerClient.ItineraryTag
  def score(%{"legs" => legs}) do
    num_transit_legs = legs |> Enum.count(& &1["transitLeg"])

    total_walking_distance =
      legs
      |> Enum.filter(& &1["steps"])
      |> Enum.map(& &1["steps"]["distance"])
      |> Enum.sum()

    [num_transit_legs, total_walking_distance]
  end

  @impl OpenTripPlannerClient.ItineraryTag
  def tag, do: :most_direct
end
