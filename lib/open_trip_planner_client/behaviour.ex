defmodule OpenTripPlannerClient.Behaviour do
  @moduledoc """
  A behaviour that specifies the API for the `OpenTripPlannerClient`.

  May be useful for testing with libraries like [Mox](https://hex.pm/packages/mox).
  """

  alias OpenTripPlannerClient.ItineraryTag.Behaviour
  alias OpenTripPlannerClient.PlanParams

  @typedoc """
  Places are used in the `c:plan/3` callback to denote each of origin and
  destination for a trip plan. Either both `latitude` and `longitude`, or
  `stop_id` are required for successful trip planning.
  """
  @type place ::
          {:name, String.t()}
          | {:stop_id, String.t()}
          | {:lat_lon, {float, float}}

  @typedoc """
  Arguments to be passed into OpenTripPlanner or processed post-planning.

    * `:arrive_by` - The DateTime to get to the destination by. Will assume a
      value of now if absent.
    * `:depart_at` - The DateTime to depart from the origin. Will assume a value
      of now if absent. Note this will be overridden by `:arrive_by` should that
      be present.
    * `:wheelchair` - Limit itineraries to those that are wheelchair accessible.
    * `:tags` - A list of tags to apply to itineraries.
  """
  @type plan_opt ::
          {:arrive_by, DateTime.t()}
          | {:depart_at, DateTime.t()}
          | {:wheelchair, boolean}
          | {:tags, [Behaviour.t()]}

  @typedoc """
  Possible planner error messages, taken from `Message.properties` in the OTP
  source. Possible values as of OTPv2.4.0:

  * `SYSTEM_ERROR`: We're sorry. The trip planner is temporarily unavailable.
  Please try again later.

  * `GRAPH_UNAVAILABLE`: We're sorry. The trip planner is temporarily
  unavailable. Please try again later.

  * `OUTSIDE_BOUNDS`: Trip is not possible. You might be trying to plan a trip
  outside the map data boundary.

  * `PROCESSING_TIMEOUT`: The trip planner is taking too long to process your
  request.

  * `BOGUS_PARAMETER`: The request has errors that the server is not willing or
    able to process.

  * `LOCATION_NOT_ACCESSIBLE`: The location was found, but no stops could be
  found within the search radius.

  * `PATH_NOT_FOUND`: No trip found. There may be no transit service within the
  maximum specified distance or at the specified time, or your start or end
  point might not be safely accessible.

  * `NO_TRANSIT_TIMES`: No transit times available. The date may be past or too
  far in the future or there may not be transit service for your trip at the
  time you chose.

  * `GEOCODE_FROM_NOT_FOUND`: Origin is unknown. Can you be a bit more
    descriptive?

  * `GEOCODE_TO_NOT_FOUND`: Destination is unknown.  Can you be a bit more
    descriptive?

  * `GEOCODE_FROM_TO_NOT_FOUND`: Both origin and destination are unknown. Can
    you be a bit more descriptive?

  * `GEOCODE_INTERMEDIATE_NOT_FOUND` An intermediate destination is unknown. Can
  you be a bit more descriptive?.

  * `TOO_CLOSE`: Origin is within a trivial distance of the destination.

  * `UNDERSPECIFIED_TRIANGLE`: All of triangleSafetyFactor, triangleSlopeFactor,
  and triangleTimeFactor must be set if any are

  * `TRIANGLE_NOT_AFFINE`: The values of triangleSafetyFactor,
  triangleSlopeFactor, and triangleTimeFactor must sum to 1

  * `TRIANGLE_OPTIMIZE_TYPE_NOT_SET`: If triangleSafetyFactor,
  triangleSlopeFactor, and triangleTimeFactor are provided, OptimizeType must be

  * `TRIANGLE_VALUES_NOT_SET`: If OptimizeType is TRIANGLE,
  triangleSafetyFactor, triangleSlopeFactor, and triangleTimeFactor must be set
  """
  @type planner_error_code :: String.t()

  @type error ::
          OpenTripPlannerClient.Plan.RoutingError.code()
          | planner_error_code
          | String.t()

  @type plan_result :: {:ok, [map()]} | {:error, error()}
  @callback plan(from :: [place], to :: [place], opts :: [plan_opt()]) :: plan_result()
  @callback plan(params :: PlanParams.t()) :: plan_result()
  @callback plan(
              params :: PlanParams.t(),
              opts :: [{:tags, [OpenTripPlannerClient.ItineraryTag.Behaviour.t()]}]
            ) :: plan_result()
end
