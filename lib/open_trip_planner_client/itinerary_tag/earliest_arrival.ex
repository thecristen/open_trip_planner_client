defmodule OpenTripPlannerClient.ItineraryTag.EarliestArrival do
  @moduledoc """
  The earliest arrival has the earliest `end` time.
  """
  @behaviour OpenTripPlannerClient.ItineraryTag.Behaviour

  @impl true
  def optimal, do: :min

  @impl true
  def score(%{"end" => iso8601_formatted_datetime}) do
    {:ok, datetime, _} = DateTime.from_iso8601(iso8601_formatted_datetime)
    DateTime.to_unix(datetime)
  end

  @impl true
  def tag, do: :earliest_arrival
end
