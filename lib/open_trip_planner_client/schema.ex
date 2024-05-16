defmodule OpenTripPlannerClient.Schema do
  @moduledoc """
  https://docs.opentripplanner.org/api/dev-2.x/graphql-gtfs/
  """
  defmacro __using__(_opts) do
    quote do
      # Using Kernel.put_in/3 and other methods requires the target to have the Access behaviour.
      @behaviour Access

      # Structs by default do not implement this. It's easy to delegate this to the Map implementation however.
      defdelegate get(schema, key, default), to: Map
      defdelegate fetch(schema, key), to: Map
      defdelegate get_and_update(schema, key, func), to: Map
      defdelegate pop(schema, key), to: Map

      @typedoc """
      The distance traveled in meters.
      """
      @type distance_meters :: float()

      @typedoc """
      Duration in seconds.
      """
      @type duration_seconds :: non_neg_integer()

      @typedoc """
      ID of a resource in format FeedId:ResourceId
      """
      @type gtfs_id :: String.t()

      @typedoc """
      An ISO-8601-formatted datetime with offset, i.e. 2023-06-13T14:30+03:00
      for 2:30pm on June 13th 2023 at Helsinki's offset from UTC at that time.

      ISO-8601 allows many different formats but OTP will only return the
      profile specified in RFC3339.
      """
      @type offset_datetime :: DateTime.t()

      @default_field []
      @nonnull_field [enforce: true, null: false]
    end
  end

  def ensure_loaded do
    Code.ensure_all_loaded([
      OpenTripPlannerClient.Schema.Agency,
      OpenTripPlannerClient.Schema.Geometry,
      OpenTripPlannerClient.Schema.Itinerary,
      OpenTripPlannerClient.Schema.LegTime,
      OpenTripPlannerClient.Schema.Leg,
      OpenTripPlannerClient.Schema.Place,
      OpenTripPlannerClient.Schema.Route,
      OpenTripPlannerClient.Schema.Step,
      OpenTripPlannerClient.Schema.Stop,
      OpenTripPlannerClient.Schema.Trip
    ])
  end
end
