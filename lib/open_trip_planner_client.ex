defmodule OpenTripPlannerClient do
  @moduledoc """
  Fetches data from the OpenTripPlanner API.

  ## Configuration

  ```elixir
  config :open_trip_planner_client,
    otp_url: "http://localhost:8080",
    timezone: "America/New_York"
  ```
  """

  @behaviour OpenTripPlannerClient.Behaviour
  alias OpenTripPlannerClient.{ItineraryTag, ParamsBuilder, Parser}

  require Logger

  @plan_query File.read!("priv/plan.graphql")

  @impl OpenTripPlannerClient.Behaviour
  @doc """
  Generate a trip plan with the given endpoints and options.
  """
  def plan(from, to, opts) do
    {tags, opts} = Keyword.pop(opts, :tags, default_tags(opts))

    case ParamsBuilder.build_params(from, to, opts) do
      {:ok, params} ->
        with {:ok, body} <- send_request(params),
             {:ok, itineraries} <- Parser.validate_body(body) do
          itineraries
          |> Enum.map(&Map.put_new(&1, :tag, nil))
          |> ItineraryTag.apply_tags(tags)
          |> then(&{:ok, &1})
        end

      error ->
        error
        |> inspect()
        |> Logger.error(%{from: from, to: to, opts: opts})

        error
    end
  end

  defp default_tags(%{arriveBy: true}), do: ItineraryTag.default_arriving()
  defp default_tags(_), do: ItineraryTag.default_departing()

  defp send_request(params) do
    url =
      Application.fetch_env!(:open_trip_planner_client, :otp_url) <> "/otp/routers/default/index/"

    query = {@plan_query, params}

    with {:ok, response} <- log_response(url, query),
         %{status: 200, body: body} <- response do
      {:ok, body}
    else
      %{status: _} = response ->
        {:error, response}

      error ->
        error
    end
  end

  defp log_response(url, {query, params}) do
    graphql_req =
      [
        base_url: url,
        decode_json: [
          keys: fn string ->
            string
            |> Macro.underscore()
            |> String.to_existing_atom()
          end
        ]
      ]
      |> Req.new()
      |> AbsintheClient.attach()

    {duration, response} =
      :timer.tc(
        Req,
        :post,
        [graphql_req, [graphql: {query, params}]]
      )

    logged =
      [
        url: url,
        params: inspect(params),
        duration: duration / :timer.seconds(1)
      ]

    case response do
      {:ok, %{status: code}} ->
        logged
        |> Keyword.put_new(:status, code)
        |> Logger.info()

      {:error, error} ->
        logged
        |> Keyword.put_new(:status, "error")
        |> Keyword.put_new(:error, inspect(error))
        |> Logger.error()
    end

    response
  end
end
