defmodule OpenTripPlannerClient.Parser do
  @moduledoc """
  Basic error parsing for Open Trip Planner outputs, processing GraphQL client
  errors and trip planner errors into standard formats for logging and testing.
  """
  alias OpenTripPlannerClient.Schema.{Itinerary, Leg, LegTime}

  require Logger

  @type parse_error ::
          :graphql_field_error | :graphql_request_error | OpenTripPlannerClient.Behaviour.error()

  @doc """
  The errors entry in the response is a non-empty list of errors raised during
  the request, where each error is a map of data described by the error result
  format below.

  If present, the errors entry in the response must contain at least one error. If
  no errors were raised during the request, the errors entry must not be present
  in the result.

  If the data entry in the response is not present, the errors entry must be
  present. It must contain at least one request error indicating why no data was
  able to be returned.

  If the data entry in the response is present (including if it is the value
  null), the errors entry must be present if and only if one or more field error
  was raised during execution.
  """
  @spec validate_body(%{}) :: {:ok, list(map())} | {:error, :parse_error}
  def validate_body(%{errors: [_ | _] = errors} = body) do
    log_error(errors)

    case body do
      %{data: _} ->
        {:error, :graphql_field_error}

      _ ->
        {:error, :graphql_request_error}
    end
  end

  def validate_body(%{
        data: %{
          plan: %{
            routing_errors: [%{code: code} | _] = routing_errors
          }
        }
      }) do
    log_error(routing_errors)
    {:error, code}
  end

  def validate_body(%{
        data: %{
          plan: %{
            itineraries: itineraries
          }
        }
      }) do
    {:ok, Enum.map(itineraries, &map_to_struct/1)}
  end

  defp map_to_struct(itinerary_map) do
    itinerary_map
    |> Jason.encode!()
    |> Jason.Structs.Decoder.decode(Itinerary)
    |> then(fn {:ok, itinerary} ->
      strings_to_datetimes(itinerary)
    end)
  end

  defp strings_to_datetimes(%Itinerary{start: start_time, end: end_time, legs: legs} = itinerary) do
    %Itinerary{
      itinerary
      | start: parse_datetime(start_time),
        end: parse_datetime(end_time),
        legs: Enum.map(legs, &strings_to_datetimes/1)
    }
  end

  defp strings_to_datetimes(%Leg{} = leg) do
    %Leg{leg | start: strings_to_datetimes(leg.start), end: strings_to_datetimes(leg.end)}
  end

  defp strings_to_datetimes(%LegTime{estimated: estimated, scheduled_time: scheduled_time}) do
    parsed_estimated =
      if not is_nil(estimated),
        do: %{
          estimated
          | time: parse_datetime(estimated.time)
        }

    %LegTime{estimated: parsed_estimated, scheduled_time: parse_datetime(scheduled_time)}
  end

  defp parse_datetime(nil), do: nil

  defp parse_datetime(time) when is_binary(time) do
    time
    |> Timex.parse!("{ISO:Extended}")
    |> Timex.to_datetime(Application.fetch_env!(:open_trip_planner_client, :timezone))
  end

  defp log_error(errors) when is_list(errors), do: Enum.each(errors, &log_error/1)

  defp log_error(error), do: Logger.error(error)
end
