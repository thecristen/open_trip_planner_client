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
  alias OpenTripPlannerClient.ItineraryTag

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
    @fixture File.read!("test/fixture/north_station_to_park_plaza.json")

    test "can apply tags", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(:ok, @fixture)
      end)

      {:ok, itineraries} =
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

      tags =
        itineraries
        |> Enum.map(
          &(&1
            |> Map.get("tags")
            |> MapSet.to_list())
        )

      assert [
               [],
               three_tags,
               [],
               [],
               two_tags
             ] = tags

      assert :shortest_trip in three_tags
      assert :earliest_arrival in three_tags
      assert :least_walking in three_tags

      assert :least_walking in two_tags
      assert :shortest_trip in two_tags
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

      boylston = [lat_lon: {42.348777, -71.066481}]

      assert {:ok, itineraries} =
               plan(north_station, boylston, depart_at: DateTime.utc_now())

      refute itineraries == []
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
