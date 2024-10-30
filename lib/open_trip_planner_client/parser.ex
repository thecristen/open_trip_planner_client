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
  @spec validate_body(%{}) :: {:ok, OpenTripPlannerClient.Plan.t()} | {:error, any()}
  def validate_body(body) do
    body
    |> validate_graphql()
    |> drop_walking_errors()
    |> validate_routing()
  end

  defp validate_graphql(%{errors: [_ | _] = errors} = body) do
    log_error(errors)

    case body do
      %{data: _} ->
        {:error, :graphql_field_error}

      _ ->
        {:error, :graphql_request_error}
    end
  end

  defp validate_graphql(body), do: body

  @walking_better_than_transit "WALKING_BETTER_THAN_TRANSIT"

  defp drop_walking_errors(%{data: %{plan: %{routing_errors: [_ | _]}}} = body) do
    body
    |> Map.update!(:data, fn data ->
      data
      |> Map.update!(:plan, fn plan ->
        plan
        |> Map.update!(:routing_errors, fn routing_errors ->
          routing_errors
          |> Enum.filter(fn %{code: code} -> code != @walking_better_than_transit end)
        end)
      end)
    end)
  end

  defp drop_walking_errors(body), do: body

  defp validate_routing(%{
         data: %{plan: %{routing_errors: [%{code: code} | _] = routing_errors}}
       }) do
    log_error(routing_errors)
    {:error, code}
  end

  defp validate_routing(%{data: %{plan: plan}}) do
    Nestru.decode(plan, OpenTripPlannerClient.Plan)
  end

  defp validate_routing(body), do: body

  defp log_error(errors) when is_list(errors), do: Enum.each(errors, &log_error/1)

  defp log_error(error), do: Logger.error(error)
end
