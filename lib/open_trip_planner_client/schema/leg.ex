# credo:disable-for-this-file Credo.Check.Warning.IoInspect
defmodule OpenTripPlannerClient.Schema.Leg do
  @moduledoc """
  Part of an itinerary. Can represent a transit trip or a sequence of walking
  steps.

  https://docs.opentripplanner.org/api/dev-2.x/graphql-gtfs/types/Leg
  """

  use OpenTripPlannerClient.Schema

  alias OpenTripPlannerClient.Schema.{Agency, Geometry, LegTime, Place, Route, Step, Stop, Trip}

  @realtime_state [
    :SCHEDULED,
    :UPDATED,
    :CANCELED,
    :ADDED,
    :MODIFIED
  ]

  @typedoc """
  State of real-time data, if present.

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
            |> Enum.map_join(" | ", &inspect/1)
            |> Code.string_to_quoted!()
          )

  defimpl Nestru.PreDecoder do
    # credo:disable-for-next-line
    def gather_fields_for_decoding(_, _, map) do
      updated_map =
        map
        |> update_in([:intermediate_stops], &replace_nil_with_list/1)
        |> update_in([:next_legs], &replace_nil_with_list/1)
        |> update_in([:steps], &replace_nil_with_list/1)

      {:ok, updated_map}
    end

    defp replace_nil_with_list(nil), do: []
    defp replace_nil_with_list(other), do: other
  end

  @derive {Nestru.Decoder,
           hint: %{
             agency: Agency,
             end: LegTime,
             from: Place,
             intermediate_stops: [Stop],
             leg_geometry: Geometry,
             mode: &__MODULE__.to_atom/1,
             next_legs: [__MODULE__],
             realtime_state: &__MODULE__.to_atom/1,
             route: Route,
             start: LegTime,
             steps: [Step],
             trip: Trip,
             to: Place
           }}
  schema do
    field(:agency, Agency.t())
    field(:distance, distance_meters())
    field(:duration, duration_seconds())
    field(:end, LegTime.t(), @nonnull_field)
    field(:from, Place.t(), @nonnull_field)
    field(:intermediate_stops, [Stop.t()])
    field(:leg_geometry, Geometry.t())
    field(:mode, PlanParams.mode_t())
    field(:next_legs, [__MODULE__.t()])
    field(:real_time, boolean())
    field(:realtime_state, realtime_state())
    field(:route, Route.t())
    field(:start, LegTime.t(), @nonnull_field)
    field(:steps, [Step.t()])
    field(:transit_leg, boolean())
    field(:trip, Trip.t())
    field(:to, Place.t(), @nonnull_field)
  end

  @spec realtime_state :: [realtime_state()]
  def realtime_state, do: @realtime_state

  @spec to_atom(any()) :: {:ok, any()}
  def to_atom(string) when is_binary(string),
    do: {:ok, OpenTripPlannerClient.Util.to_existing_atom(string)}

  def to_atom(other), do: {:ok, other}
end
