defmodule OpenTripPlannerClient.PlanParams do
  @moduledoc """
  Data type describing params for the plan query.
  https://docs.opentripplanner.org/api/dev-2.x/graphql-gtfs/queries/plan
  """

  @doc "Data type describing params for the plan query.
  https://docs.opentripplanner.org/api/dev-2.x/graphql-gtfs/queries/plan"
  @derive Jason.Encoder
  defstruct [
    :fromPlace,
    :toPlace,
    :date,
    :time,
    arriveBy: false,
    numItineraries: 5,
    transportModes: [%{mode: :WALK}, %{mode: :TRANSIT}],
    wheelchair: false
  ]

  @typedoc """
  Whether the itinerary should depart at the specified time (false), or arrive
  to the destination at the specified time (true). Default value: false.
  """
  @type arrive_by :: boolean()

  @typedoc """
  Date of departure or arrival in format YYYY-MM-DD. Default value: current date
  """
  @type date :: String.t()

  @typedoc """
  The place where the itinerary begins or ends in format name::place, where
  place is either a lat,lng pair (e.g. Pasila::60.199041,24.932928) or a stop id
  (e.g. Pasila::HSL:1000202)

  "New England Title Insurance Company, 151 Tremont St, Boston, MA, 02111,
  USA::42.354452,-71.06338" "Newton Highlands::mbta-ma-us:place-nwtn"
  """
  @type place :: String.t()

  @typedoc """
  Time of departure or arrival in format hh:mm:ss. Default value: current time
  """
  @type time :: String.t()

  @typedoc """
  List of transportation modes that the user is willing to use. Default:
  ["WALK","TRANSIT"]
  """
  @type transport_modes :: nonempty_list(transport_mode())
  @typep transport_mode :: %{mode: mode_t()}

  @modes [
    :AIRPLANE,
    :BICYCLE,
    :BUS,
    :CABLE_CAR,
    :CAR,
    # Private car trips shared with others
    :CARPOOL,
    :COACH,
    :FERRY,
    # Enables flexible transit for access and egress legs
    :FLEX,
    :FUNICULAR,
    :GONDOLA,
    # Railway in which the track consists of a single rail or a beam.
    :MONORAIL,
    :RAIL,
    :SCOOTER,
    :SUBWAY,
    # A taxi, possibly operated by a public transport agency.
    :TAXI,
    :TRAM,
    # A special transport mode, which includes all public transport.
    :TRANSIT,
    # Electric buses that draw power from overhead wires using poles.
    :TROLLEYBUS,
    :WALK
  ]

  @typedoc """
  https://docs.opentripplanner.org/api/dev-2.x/graphql-gtfs/types/Mode
  """
  @type mode_t ::
          unquote(
            @modes
            |> Enum.map_join(" | ", &inspect/1)
            |> Code.string_to_quoted!()
          )

  @typedoc """
  Whether the itinerary must be wheelchair accessible. Default value: false
  """
  @type wheelchair :: boolean()

  @typedoc """
  Arguments for the OTP plan query.
  """
  @type t :: %__MODULE__{
          arriveBy: arrive_by(),
          fromPlace: place(),
          date: date(),
          numItineraries: integer(),
          time: time(),
          toPlace: place(),
          transportModes: transport_modes(),
          wheelchair: wheelchair()
        }

  @spec modes :: [mode_t()]
  def modes, do: @modes

  @spec new(map()) :: t()
  def new(params \\ %{}) do
    %__MODULE__{}
    |> Map.put(:date, to_date_param(OpenTripPlannerClient.Util.local_now()))
    |> Map.put(:time, to_time_param(OpenTripPlannerClient.Util.local_now()))
    |> struct(params)
  end

  @spec to_place_param(map()) :: place()
  def to_place_param(%{name: name, stop_id: stop_id}) when is_binary(stop_id) do
    "#{name}::mbta-ma-us:#{stop_id}"
  end

  def to_place_param(%{name: name, latitude: latitude, longitude: longitude})
      when is_float(latitude) and is_float(longitude) do
    "#{name}::#{latitude},#{longitude}"
  end

  @spec to_modes_param([mode_t()]) :: transport_modes()
  def to_modes_param(modes) do
    modes
    |> then(fn modes ->
      if :SUBWAY in modes do
        [:TRAM | modes]
      else
        modes
      end
    end)
    |> Enum.map(&Map.new(mode: &1))
  end

  @spec to_date_param(DateTime.t()) :: date()
  def to_date_param(datetime) do
    format_datetime(datetime, "{YYYY}-{0M}-{0D}")
  end

  @spec to_time_param(DateTime.t()) :: time()
  def to_time_param(datetime) do
    format_datetime(datetime, "{h12}:{m}{am}")
  end

  defp format_datetime(datetime, formatter) do
    Timex.format!(datetime, formatter)
  end
end
