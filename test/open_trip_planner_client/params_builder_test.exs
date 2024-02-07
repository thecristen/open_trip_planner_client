defmodule OpenTripPlannerClient.ParamsBuilderTest do
  use ExUnit.Case, async: true
  import OpenTripPlannerClient.ParamsBuilder

  @from_inside [lat_lon: {42.356365, -71.060920}]
  @to_inside [lat_lon: {42.3636617, -71.0832908}]
  @from_stop [name: "FromStop", stop_id: "From_Id"]
  @to_stop [name: "ToStop", stop_id: "To_Id"]

  describe "build_params/1" do
    test "depart_at sets date/time options" do
      expected =
        {:ok,
         %{
           "date" => "2017-05-22",
           "time" => "12:04pm",
           "arriveBy" => false,
           "fromPlace" => "::42.356365,-71.06092",
           "toPlace" => "::42.3636617,-71.0832908"
         }}

      actual =
        build_params(
          @from_inside,
          @to_inside,
          depart_at: DateTime.from_naive!(~N[2017-05-22T16:04:20], "Etc/UTC")
        )

      assert expected == actual
    end

    test "arrive_by sets date/time options" do
      expected =
        {:ok,
         %{
           "date" => "2017-05-22",
           "time" => "12:04pm",
           "arriveBy" => true,
           "fromPlace" => "::42.356365,-71.06092",
           "toPlace" => "::42.3636617,-71.0832908"
         }}

      actual =
        build_params(
          @from_inside,
          @to_inside,
          arrive_by: DateTime.from_naive!(~N[2017-05-22T16:04:20], "Etc/UTC")
        )

      assert expected == actual
    end

    test ":wheelchair sets wheelchair option" do
      expected =
        {:ok,
         %{
           "wheelchair" => true,
           "fromPlace" => "::42.356365,-71.06092",
           "toPlace" => "::42.3636617,-71.0832908"
         }}

      actual = build_params(@from_inside, @to_inside, wheelchair: true)
      assert expected == actual

      assert {:ok,
              %{
                "fromPlace" => "::42.356365,-71.06092",
                "toPlace" => "::42.3636617,-71.0832908"
              }} == build_params(@from_inside, @to_inside, wheelchair: false)
    end

    test ":mode omits value if needed" do
      expected =
        {:ok,
         %{
           "fromPlace" => "::42.356365,-71.06092",
           "toPlace" => "::42.3636617,-71.0832908"
         }}

      actual = build_params(@from_inside, @to_inside, mode: [])
      assert expected == actual
    end

    test ":mode builds a comma-separated list of modes to use" do
      expected =
        {:ok,
         %{
           "transportModes" => [
             %{mode: "WALK"},
             %{mode: "BUS"},
             %{mode: "SUBWAY"},
             %{mode: "TRAM"}
           ],
           "fromPlace" => "::42.356365,-71.06092",
           "toPlace" => "::42.3636617,-71.0832908"
         }}

      actual = build_params(@from_inside, @to_inside, mode: ["BUS", "SUBWAY", "TRAM"])
      assert expected == actual
    end

    test "bad locations return an error" do
      expected = {:error, :invalid_location}
      actual = build_params([stop_id: nil], @to_inside, [])
      assert expected == actual
    end

    test "bad options return an error" do
      expected = {:error, {:unsupported_param, {:bad, :arg}}}
      actual = build_params(@from_inside, @to_inside, bad: :arg)
      assert expected == actual
    end

    test "use stop id from to/from location" do
      expected = {
        :ok,
        %{
          "fromPlace" => "FromStop::mbta-ma-us:From_Id",
          "toPlace" => "ToStop::mbta-ma-us:To_Id"
        }
      }

      actual = build_params(@from_stop, @to_stop, [])
      assert expected == actual
    end
  end
end
