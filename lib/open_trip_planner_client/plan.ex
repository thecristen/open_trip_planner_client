defmodule OpenTripPlannerClient.Plan do
  @moduledoc """
  Data type returned by the plan query.
  https://docs.opentripplanner.org/api/dev-2.x/graphql-gtfs/types/Plan
  """

  use OpenTripPlannerClient.Schema

  alias OpenTripPlannerClient.Plan.RoutingError
  alias OpenTripPlannerClient.Schema.Itinerary

  defimpl Nestru.PreDecoder do
    # credo:disable-for-next-line
    def gather_fields_for_decoding(_, _, map) do
      updated_map =
        map
        |> update_in([:routing_errors], &replace_nil_with_list/1)
        |> update_in([:itineraries], &replace_nil_with_list/1)
        |> update_in([:date], fn
          dt when is_integer(dt) ->
            Timex.from_unix(dt, :milliseconds)
            |> OpenTripPlannerClient.Util.to_local_time()

          dt ->
            dt
        end)

      {:ok, updated_map}
    end

    defp replace_nil_with_list(nil), do: []
    defp replace_nil_with_list(other), do: other
  end

  @derive {Nestru.Decoder,
           hint: %{
             date: DateTime,
             itineraries: [Itinerary],
             routing_errors: [OpenTripPlannerClient.Plan.RoutingError]
           }}
  schema do
    field(:date, DateTime)
    field(:itineraries, [Itinerary.t()])
    field(:routing_errors, [Plan.RoutingError.t()])
    field(:search_window_used, non_neg_integer())
  end

  defmodule RoutingError do
    @moduledoc """
    Description of the reason, why the planner did not return any results
    """

    use OpenTripPlannerClient.Schema

    @typedoc """
    Corresponds to `RoutingErrorCode` from OTP `plan` query.
    Possible values as of OTPv2.5.0:

    * `NO_TRANSIT_CONNECTION`: No transit connection was found between the origin
    and destination within the operating day or the next day, not even sub-optimal
    ones.

    * `NO_TRANSIT_CONNECTION_IN_SEARCH_WINDOW`: A transit connection was found,
    but it was outside the search window. See the metadata for a token for
    retrieving the result outside the search window.

    * `OUTSIDE_SERVICE_PERIOD`: The date specified is outside the range of data
    currently loaded into the system as it is too far into the future or the past.
    The specific date range of the system is configurable by an administrator and
    also depends on the input data provided.

    * `OUTSIDE_BOUNDS`: The coordinates are outside the geographic bounds of the
    transit and street data currently loaded into the system and therefore cannot
    return any results.

    * `LOCATION_NOT_FOUND`: The specified location is not close to any streets or
    transit stops currently loaded into the system, even though it is generally
    within its bounds. This can happen when there is only transit but no street
    data coverage at the location in question.

    * `NO_STOPS_IN_RANGE`: No stops are reachable from the start or end locations
    specified. You can try searching using a different access or egress mode, for
    example cycling instead of walking, increase the walking/cycling/driving speed
    or have an administrator change the system's configuration so that stops
    further away are considered.

    * `WALKING_BETTER_THAN_TRANSIT`: Transit connections were requested and found
    but because it is easier to just walk all the way to the destination they were
    removed. If you want to still show the transit results, you need to make
    walking less desirable by increasing the walk reluctance.
    """
    @type code :: String.t()

    @derive Nestru.Decoder
    schema do
      field(:code, code(), @nonnull_field)
      field(:description, String.t(), @nonnull_field)
    end
  end
end
