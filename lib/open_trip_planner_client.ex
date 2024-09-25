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
    with {:ok, response} <- log_response(params),
         %{status: 200, body: body} <- response do
      {:ok, body}
    else
      %{status: _} = response ->
        {:error, response}

      error ->
        error
    end
  end

  defp req_request do
    [
      base_url: plan_url(),
      cache: true,
      compressed: true,
      decode_json: [keys: &key_as_atom/1]
    ]
    |> Req.new()
    |> AbsintheClient.attach()
  end

  defp plan_url do
    Application.fetch_env!(:open_trip_planner_client, :otp_url) <> "/otp/routers/default/index/"
  end

  defp key_as_atom(string_key) do
    string_key
    |> Macro.underscore()
    |> String.to_existing_atom()
  end

  defp log_response(params) do
    {duration, response} =
      :timer.tc(
        Req,
        :post,
        [req_request(), [graphql: {@plan_query, params}]]
      )

    meta = [
      params: inspect(params),
      duration: duration / :timer.seconds(1)
    ]

    case response do
      {:ok, %{status: code}} ->
        Logger.info(%{status: code}, meta)

      {:error, error} ->
        Logger.error(%{status: "error", error: inspect(error)}, meta)
    end

    response
  end
end
