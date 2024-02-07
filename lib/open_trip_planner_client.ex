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

  @type error :: OpenTripPlannerClient.Behaviour.error()
  @type plan_opt :: OpenTripPlannerClient.Behaviour.plan_opt()
  @type place :: OpenTripPlannerClient.Behaviour.place()

  @impl OpenTripPlannerClient.Behaviour
  @doc """
  Generate a trip plan with the given endpoints and options.
  """
  @spec plan(place(), place(), [plan_opt()]) ::
          {:ok, [OpenTripPlannerClient.Behaviour.itinerary_with_tags()]} | {:error, error()}
  def plan(from, to, opts) do
    {postprocess_opts, opts} = Keyword.split(opts, [:tags])

    with {:ok, params} <- ParamsBuilder.build_params(from, to, opts) do
      graphql_query =
        {"""
          query TripPlan(
            $fromPlace: String!
            $toPlace: String!
            $date: String
            $time: String
            $arriveBy: Boolean
            $wheelchair: Boolean
            $transportModes: [TransportMode]
          ) {
            plan(
             fromPlace: $fromPlace
             toPlace: $toPlace
             date: $date
             time: $time
             arriveBy: $arriveBy
             wheelchair: $wheelchair
             transportModes: $transportModes

             # Increased from 30 minutes, a 1-hour search window accomodates infrequent routes
             searchWindow: 3600

             # Increased from 3 to offer more itineraries for potential post-processing
             numItineraries: 5

             # Increased from 2.0 to reduce number of itineraries with significant walking
             walkReluctance: 5.0

             # Theoretically can be configured in the future for visitors using translation?
             locale: "en"

             # Prefer MBTA transit legs over Massport or others.
             preferred: { agencies: "mbta-ma-us:1" }
            )
            #{itinerary_shape()}
         }
         """, params}

      root_url =
        Keyword.get(opts, :root_url, Application.fetch_env!(:open_trip_planner_client, :otp_url))

      graphql_url = "#{root_url}/otp/routers/default/index/"

      with {:ok, body} <- send_request(graphql_url, graphql_query),
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

    _ =
      Logger.info(fn ->
        "#{__MODULE__}.plan_response url=#{url} params=#{inspect(params)} #{status_text(response)} duration=#{duration / :timer.seconds(1)}"
      end)

    response
  end

  defp status_text({:ok, %{status: code}}) do
    "status=#{code}"
  end

  defp status_text({:error, error}) do
    "status=error error=#{inspect(error)}"
  end

  defp itinerary_shape do
    """
    {
      routingErrors {
        code
        description
      }
      itineraries {
        accessibilityScore
        startTime
        endTime
        duration
        legs {
          mode
          startTime
          endTime
          distance
          duration
          intermediateStops {
            gtfsId
            name
            desc
            lat
            lon
            code
            locationType
          }
          transitLeg
          headsign
          realTime
          realtimeState
          agency {
            gtfsId
            name
            url
          }
          alerts {
            id
            alertHeaderText
            alertDescriptionText
          }
          fareProducts {
            id
            product {
              id
              name
              riderCategory {
                id
                name
              }
            }
          }
          from {
            name
            lat
            lon
            departureTime
            arrivalTime
            stop {
              gtfsId
            }
          }
          to {
            name
            lat
            lon
            departureTime
            arrivalTime
            stop {
              gtfsId
            }
          }
          route {
            gtfsId
            longName
            shortName
            desc
            color
            textColor
          }
          trip {
            gtfsId
          }
          steps {
            distance
            streetName
            lat
            lon
            absoluteDirection
            relativeDirection
            stayOn
          }
          legGeometry {
            points
          }
        }
      }
    }
    """
  end
end
