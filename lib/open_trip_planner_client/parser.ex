defmodule OpenTripPlannerClient.Parser do
  @moduledoc """
  Basic error parsing for Open Trip Planner outputs, processing GraphQL client
  errors and trip planner errors into standard formats for logging and testing.
  """
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
  def validate_body(%{"errors" => [_ | _] = errors} = body) do
    log_error(errors)

    case body do
      %{"data" => _} ->
        {:error, :graphql_field_error}

      _ ->
        {:error, :graphql_request_error}
    end
  end

  def validate_body(%{
        "data" => %{
          "plan" => %{
            "routingErrors" => [%{"code" => code} | _] = routingErrors
          }
        }
      }) do
    log_error(routingErrors)
    {:error, String.downcase(code) |> String.to_existing_atom()}
  end

  def validate_body(%{
        "data" => %{
          "plan" => %{
            "itineraries" => itineraries
          }
        }
      }) do
    {:ok, itineraries}
  end

  defp log_error(errors) when is_list(errors), do: Enum.each(errors, &log_error/1)
  defp log_error(%{"message" => message}), do: Logger.warning(message)

  defp log_error(%{"code" => _, "description" => _} = routing_error),
    do: Logger.notice(routing_error)

  defp log_error(error), do: Logger.warning(error)
end
