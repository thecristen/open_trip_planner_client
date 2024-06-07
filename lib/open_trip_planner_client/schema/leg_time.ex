defmodule OpenTripPlannerClient.Schema.LegTime do
  @moduledoc """
  Trip is a specific occurance of a pattern, usually identified by route,
  direction on the route and exact departure time.

  https://docs.opentripplanner.org/api/dev-2.x/graphql-gtfs/types/Trip
  """

  use Jason.Structs.Struct
  use OpenTripPlannerClient.Schema

  @typedoc """
  An ISO-8601-formatted duration, i.e. PT2H30M for 2 hours and 30 minutes.

  Negative durations are formatted like -PT10M.
  """
  @type duration :: String.t()

  @typedoc """
  Real-time estimates for a vehicle at a certain place.

  The delay represents the "earliness" of the vehicle at a certain place. If the
  vehicle is early then this is a negative duration.
  """
  @type estimated ::
          %{
            delay: duration(),
            time: offset_datetime()
          }
          | nil

  jason_struct do
    field(:scheduled_time, offset_datetime(), @nonnull_field)
    field(:estimated, estimated(), @default_field)
  end
end
