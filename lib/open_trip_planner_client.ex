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

  @impl OpenTripPlannerClient.Behaviour
  @doc """
  Generate a trip plan with the given endpoints and options.
  """
  def plan(from, to, opts) do
    {postprocess_opts, opts} = Keyword.split(opts, [:tags])

    with {:ok, params} <- ParamsBuilder.build_params(from, to, opts),
         {:ok, graphql_query} <- File.read("priv/plan.graphql") do
      root_url =
        Keyword.get(opts, :root_url, Application.fetch_env!(:open_trip_planner_client, :otp_url))

      graphql_url = "#{root_url}/otp/routers/default/index/"

      with {:ok, body} <- send_request(graphql_url, {graphql_query, params}),
           {:ok, itineraries} <- Parser.validate_body(body) do
        tags = Keyword.get(postprocess_opts, :tags, [])

        result =
          Enum.reduce(tags, itineraries, fn tag, itineraries ->
            ItineraryTag.apply_tag(tag, itineraries)
          end)

        {:ok, result}
      end
    end
  end

  defp send_request(url, query) do
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
      [base_url: url]
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
