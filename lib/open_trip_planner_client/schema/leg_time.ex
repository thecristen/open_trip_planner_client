defmodule OpenTripPlannerClient.Schema.LegTime do
  @moduledoc """
  Trip is a specific occurance of a pattern, usually identified by route,
  direction on the route and exact departure time.

  https://docs.opentripplanner.org/api/dev-2.x/graphql-gtfs/types/Trip
  """

  use OpenTripPlannerClient.Schema

  @derive {Nestru.Decoder,
           hint: %{
             scheduled_time: DateTime,
             estimated: OpenTripPlannerClient.Schema.LegTime.Estimated
           }}
  schema do
    field(:scheduled_time, offset_datetime(), @nonnull_field)
    field(:estimated, Estimated.t())
  end

  defmodule Estimated do
    @moduledoc """
    Real-time estimates for a vehicle at a certain place.

    The delay represents the "earliness" of the vehicle at a certain place. If
    the vehicle is early then this is a negative duration.
    """
    use OpenTripPlannerClient.Schema

    @typedoc """
    An ISO-8601-formatted duration, i.e. PT2H30M for 2 hours and 30 minutes.

    Negative durations are formatted like -PT10M.
    """
    @type duration :: String.t()

    @derive {Nestru.Decoder, hint: %{time: DateTime}}
    schema do
      field(:delay, duration())
      field(:time, offset_datetime(), @nonnull_field)
    end
  end
end
