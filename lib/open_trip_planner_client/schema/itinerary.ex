defmodule OpenTripPlannerClient.Schema.Itinerary do
  @moduledoc """
  Details regarding a single planned journey.

  https://docs.opentripplanner.org/api/dev-2.x/graphql-gtfs/types/Itinerary
  """
  use OpenTripPlannerClient.Schema

  alias OpenTripPlannerClient.Schema.Leg

  @typedoc """
  Computes a numeric accessibility score between 0 and 1.

  The closer the value is to 1 the better the wheelchair-accessibility of this
  itinerary is. A value of null means that no score has been computed, not that
  the leg is inaccessible.
  """
  @type accessibility_score :: float() | nil

  @derive {Nestru.Decoder, hint: %{end: DateTime, legs: [Leg], start: DateTime}}
  schema do
    field(:accessibility_score, accessibility_score())
    field(:duration, duration_seconds())
    field(:end, offset_datetime())
    field(:legs, [Leg.t()], @nonnull_field)
    field(:number_of_transfers, non_neg_integer(), @nonnull_field)
    field(:start, offset_datetime())
    field(:walk_distance, distance_meters())
  end
end
