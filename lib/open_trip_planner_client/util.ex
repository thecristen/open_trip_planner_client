defmodule OpenTripPlannerClient.Util do
  @moduledoc false

  @spec to_snake_keys(binary() | atom()) :: atom()
  def to_snake_keys(term) when is_binary(term) or is_atom(term) do
    term
    |> Macro.underscore()
    |> String.to_existing_atom()
  end

  def to_snake_keys(other), do: other

  @spec to_uppercase_atom(binary()) :: atom()
  def to_uppercase_atom(term) when is_binary(term) do
    term
    |> String.upcase()
    |> String.to_existing_atom()
  end

  def to_uppercase_atom(other), do: other

  @spec to_local_time(Timex.Types.valid_datetime()) :: DateTime.t()
  def to_local_time(datetime) do
    Timex.to_datetime(
      datetime,
      Application.fetch_env!(:open_trip_planner_client, :timezone)
    )
  end

  @doc """
  Because underlying functionality uses String.to_existing_atom, we have to load
  modules so that the atoms exist.
  """
  @spec ensure_loaded :: :ok
  def ensure_loaded do
    for mod <- [
          OpenTripPlannerClient.Plan,
          OpenTripPlannerClient.PlanParams,
          OpenTripPlannerClient.Schema.Agency,
          OpenTripPlannerClient.Schema.Geometry,
          OpenTripPlannerClient.Schema.Itinerary,
          OpenTripPlannerClient.Schema.LegTime,
          OpenTripPlannerClient.Schema.Leg,
          OpenTripPlannerClient.Schema.Place,
          OpenTripPlannerClient.Schema.Route,
          OpenTripPlannerClient.Schema.Step,
          OpenTripPlannerClient.Schema.Stop,
          OpenTripPlannerClient.Schema.Trip
        ] do
      Code.ensure_compiled!(mod)
    end
  end
end
