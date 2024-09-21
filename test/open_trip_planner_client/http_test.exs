defmodule OpenTripPlannerClient.HttpTest do
  @moduledoc """
  Tests for OpenTripPlanner that require overriding the OTP host or making
  external requests.

  We pull these into a separate module so that the main body of tests can
  remain async: true.

  """
  use ExUnit.Case, async: false
  import OpenTripPlannerClient
  import Plug.Conn, only: [send_resp: 3]
  alias OpenTripPlannerClient.{ItineraryTag, Plan, PlanParams}

  setup context do
    if context[:external] do
      :ok
    else
      bypass = Bypass.open()
      host = "http://localhost:#{bypass.port}"
      old_otp_url = Application.get_env(:open_trip_planner_client, :otp_url)
      old_level = Logger.level()

      on_exit(fn ->
        Application.put_env(:open_trip_planner_client, :otp_url, old_otp_url)
        Logger.configure(level: old_level)
      end)

      Application.put_env(:open_trip_planner_client, :otp_url, host)
      Logger.configure(level: :info)

      {:ok, %{bypass: bypass}}
    end
  end

  describe "plan/3 with fixture data" do
    @fixture File.read!("test/fixture/alewife_to_franklin_park_zoo.json")

    test "can apply tags", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(:ok, @fixture)
      end)

      {:ok, plan} =
        plan(
          [
            name: "North Station",
            stop_id: "place-north",
            lat_lon: {42.365551, -71.061251}
          ],
          [lat_lon: {42.348777, -71.066481}],
          tags: [
            ItineraryTag.EarliestArrival,
            ItineraryTag.LeastWalking,
            ItineraryTag.ShortestTrip
          ]
        )

      assert plan.itineraries

      {tagged, untagged} = Enum.split_while(plan.itineraries, &(!is_nil(&1.tag)))

      assert untagged
             |> Enum.map(& &1.tag)
             |> Enum.all?(&is_nil/1)

      assert :earliest_arrival in Enum.map(tagged, & &1.tag)
    end
  end

  describe "plan/3 with real OTP" do
    @describetag :external

    test "can make a basic plan with OTP" do
      north_station = [
        name: "North Station",
        stop_id: "place-north",
        lat_lon: {42.365551, -71.061251}
      ]

      mb = [lat_lon: {42.3657472, -71.0672384}]

      {:ok, plan} = plan(north_station, mb, depart_at: DateTime.utc_now())
      assert %Plan{} = plan
      refute plan.itineraries == []
    end
  end

  describe "plan/2 with real OTP" do
    @describetag :external

    test "can make a basic plan with OTP" do
      params =
        PlanParams.new(%{
          fromPlace: "North Station::mbta-ma-us:place-north",
          toPlace: "Market Basket::42.3657472,-71.0672384"
        })

      {:ok, plan} = plan(params)
      assert %Plan{} = plan
      refute plan.itineraries == []
    end
  end

  describe "error handling/logging" do
    @tag :capture_log
    test "HTTP errors are converted to error tuples", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        send_resp(conn, 500, "{}")
      end)

      assert {:error, _} =
               plan(
                 [lat_lon: {1, 1}],
                 [lat_lon: {2, 2}],
                 depart_at: DateTime.utc_now()
               )
    end

    @tag :capture_log
    test "connection errors are converted to error tuples", %{bypass: bypass} do
      Bypass.down(bypass)

      assert {:error, _} =
               plan(
                 [lat_lon: {1, 1}],
                 [lat_lon: {2, 2}],
                 depart_at: DateTime.utc_now()
               )
    end
  end
end
