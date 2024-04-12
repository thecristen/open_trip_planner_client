defmodule OpenTripPlannerClient.ItineraryTag.EarliestArrival do
  @moduledoc """
  The earliest arrival has the earliest `end` time.
  """
  @behaviour OpenTripPlannerClient.ItineraryTag

  @impl OpenTripPlannerClient.ItineraryTag
  def optimal, do: :min

  @impl OpenTripPlannerClient.ItineraryTag
  def score(%{"end" => iso8601_formatted_datetime}) do
    {:ok, datetime, _} = DateTime.from_iso8601(iso8601_formatted_datetime)
    DateTime.to_unix(datetime)
  end

  @impl OpenTripPlannerClient.ItineraryTag
  def tag, do: :earliest_arrival
end
