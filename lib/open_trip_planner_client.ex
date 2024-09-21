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

  alias OpenTripPlannerClient.{ItineraryTag, ParamsBuilder, Parser, PlanParams, Util}

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
        params
        |> PlanParams.new()
        |> do_plan(tags)

      error ->
        error
        |> inspect()
        |> Logger.error(%{from: from, to: to, opts: opts})

        error
    end
  end

  @impl OpenTripPlannerClient.Behaviour
  def plan(params, tags \\ nil) do
    tags = if tags, do: tags, else: default_tags(params)
    do_plan(params, tags)
  end

  defp do_plan(params, tags) do
    case send_request(params) do
      {:ok, plan} ->
        plan
        |> update_in([:itineraries], fn itineraries ->
          itineraries
          |> Enum.map(&Map.put_new(&1, :tag, nil))
          |> ItineraryTag.apply_tags(tags)
        end)
        |> then(&{:ok, &1})

      error ->
        error
        |> inspect()

        error
    end
  end

  defp default_tags(%{arrive_by: true}), do: ItineraryTag.default_arriving()
  defp default_tags(_), do: ItineraryTag.default_departing()

  @spec send_request(PlanParams.t()) :: {:ok, map()} | {:error, any()}
  def send_request(params) do
    with {:ok, %Req.Response{status: 200, body: body}} <- log_response(params),
         {:ok, plan} <- Parser.validate_body(body) do
      {:ok, plan}
    else
      {:error, _} = error ->
        error

      other_error ->
        {:error, other_error}
    end
  end

  defp do_request(%PlanParams{} = params) do
    [
      base_url: plan_url(),
      cache: true,
      compressed: true,
      decode_json: [keys: &Util.to_snake_keys/1]
    ]
    |> Req.new()
    |> AbsintheClient.attach()
    |> Req.post(graphql: {@plan_query, params})
  end

  defp plan_url do
    Application.fetch_env!(:open_trip_planner_client, :otp_url) <> "/otp/routers/default/index/"
  end

  defp log_response(params) do
    {duration, response} = :timer.tc(&do_request/1, [params])

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
