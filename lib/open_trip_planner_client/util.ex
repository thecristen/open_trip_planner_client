defmodule OpenTripPlannerClient.Util do
  @moduledoc false

  @spec to_snake_keys(binary() | atom()) :: atom()
  def to_snake_keys(term) when is_binary(term) or is_atom(term) do
    term
    |> Macro.underscore()
    |> to_existing_atom()
  end

  def to_snake_keys(other), do: other

  @spec to_uppercase_atom(binary()) :: atom()
  def to_uppercase_atom(term) when is_binary(term) do
    term
    |> String.upcase()
    |> to_existing_atom()
  end

  def to_uppercase_atom(other), do: other

  @spec to_local_time(Timex.Types.valid_datetime()) :: DateTime.t()
  def to_local_time(datetime) do
    Timex.to_datetime(
      datetime,
      Application.fetch_env!(:open_trip_planner_client, :timezone)
    )
  end

  @spec local_now :: DateTime.t()
  def local_now do
    Application.fetch_env!(:open_trip_planner_client, :timezone)
    |> Timex.now()
  end

  @doc """
  A safe version of String.to_existing_atom/1 ensuring atoms are already loaded
  """
  @spec to_existing_atom(String.t()) :: atom()
  def to_existing_atom(string) do
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

    String.to_existing_atom(string)
  end
end
