defmodule OpenTripPlannerClient.ParamsBuilder do
  @moduledoc """
  Handles generating query params for requests to OpenTripPlanner from user
  input and client configuration.
  """

  @doc "Convert general planning options into query params for OTP"
  @spec build_params(OpenTripPlannerClient.place(), OpenTripPlannerClient.place(), [
          OpenTripPlannerClient.plan_opt()
        ]) ::
          {:ok, %{String.t() => String.t()}} | {:error, any}
  def build_params(from, to, opts \\ []) do
    fromPlace = Keyword.put_new(from, :name, "Origin") |> location()
    toPlace = Keyword.put_new(to, :name, "Destination") |> location()

    do_build_params(opts, %{
      "fromPlace" => fromPlace,
      "toPlace" => toPlace
    })
  end

  defp location(place) do
    name = Keyword.fetch!(place, :name)

    case Keyword.fetch(place, :stop_id) do
      {:ok, stop_id} when not is_nil(stop_id) ->
        "#{name}::mbta-ma-us:#{stop_id}"

      _ ->
        {latitude, longitude} = Keyword.fetch!(place, :lat_lon)
        "#{name}::#{latitude},#{longitude}"
    end
  end

  defp do_build_params([], acc) do
    {:ok, acc}
  end

  defp do_build_params([{:wheelchair, wheelchair} | rest], acc) when is_boolean(wheelchair) do
    acc =
      if wheelchair do
        put_in(acc["wheelchair"], true)
      else
        acc
      end

    do_build_params(rest, acc)
  end

  defp do_build_params([{:depart_at, %DateTime{} = datetime} | rest], acc) do
    acc = do_date_time(false, datetime, acc)
    do_build_params(rest, acc)
  end

  defp do_build_params([{:arrive_by, %DateTime{} = datetime} | rest], acc) do
    acc = do_date_time(true, datetime, acc)
    do_build_params(rest, acc)
  end

  defp do_build_params([{:mode, []} | rest], acc) do
    do_build_params(rest, acc)
  end

  defp do_build_params([{:mode, [_ | _] = modes} | rest], acc) do
    do_build_params(
      rest,
      Map.put(acc, "transportModes", [%{mode: "WALK"} | Enum.map(modes, &%{mode: &1})])
    )
  end

  defp do_build_params([option | _], _) do
    {:error, {:unsupported_param, option}}
  end

  defp do_date_time(arriveBy, %DateTime{} = datetime, acc) do
    local =
      Timex.to_datetime(datetime, Application.fetch_env!(:open_trip_planner_client, :timezone))

    date = Timex.format!(local, "{ISOdate}")
    time = Timex.format!(local, "{h12}:{0m}{am}")

    Map.merge(acc, %{
      "date" => date,
      "time" => time,
      "arriveBy" => arriveBy
    })
  end
end
