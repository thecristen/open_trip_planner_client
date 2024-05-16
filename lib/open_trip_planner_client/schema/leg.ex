defmodule OpenTripPlannerClient.Schema.Leg do
  @moduledoc """
  Part of an itinerary. Can represent a transit trip or a sequence of walking
  steps.

  https://docs.opentripplanner.org/api/dev-2.x/graphql-gtfs/types/Leg
  """

  use Jason.Structs.Struct
  use OpenTripPlannerClient.Schema

  alias OpenTripPlannerClient.Schema.{Agency, Geometry, LegTime, Place, Route, Step, Stop, Trip}

  @type mode ::
          :AIRPLANE
          | :BICYCLE
          | :BUS
          | :CABLE_CAR
          | :CAR
          | :COACH
          | :FERRY
          | :FLEX
          | :FUNICULAR
          | :GONDOLA
          | :RAIL
          | :SCOOTER
          | :SUBWAY
          | :TRAM
          | :CARPOOL
          | :TAXI
          | :TRANSIT
          | :WALK
          | :TROLLEYBUS
          | :MONORAIL

  @realtime_state [
    :SCHEDULED,
    :UPDATED,
    :CANCELED,
    :ADDED,
    :MODIFIED
  ]

  @typedoc """
  SCHEDULED The trip information comes from the GTFS feed, i.e. no real-time
  update has been applied.

  UPDATED The trip information has been updated, but the trip pattern stayed the
  same as the trip pattern of the scheduled trip.

  CANCELED The trip has been canceled by a real-time update.

  ADDED The trip has been added using a real-time update, i.e. the trip was not
  present in the GTFS feed.

  MODIFIED The trip information has been updated and resulted in a different
  trip pattern compared to the trip pattern of the scheduled trip.
  """
  @type realtime_state ::
          unquote(
            @realtime_state
            |> Enum.map(&inspect/1)
            |> Enum.join(" | ")
            |> Code.string_to_quoted!()
          )

  jason_struct do
    field(:agency, Agency.t(), @default_field)
    field(:distance, distance_meters(), @default_field)
    field(:duration, duration_seconds(), @default_field)
    field(:end, LegTime.t(), @nonnull_field)
    field(:from, Place.t(), @nonnull_field)
    field(:intermediate_stops, [Stop.t()], @default_field)
    field(:leg_geometry, Geometry.t(), @default_field)
    field(:mode, mode(), @default_field)
    field(:real_time, boolean(), @default_field)
    field(:realtime_state, realtime_state(), @default_field)
    field(:route, Route.t(), @default_field)
    field(:start, LegTime.t(), @nonnull_field)
    field(:steps, [Step.t()], @default_field)
    field(:transit_leg, boolean(), @default_field)
    field(:trip, Trip.t(), @default_field)
    field(:to, Place.t(), @nonnull_field)
  end

  def realtime_state, do: @realtime_state
end
