defmodule OpenTripPlannerClient.PlanParamsTest do
  use ExUnit.Case, async: true
  import OpenTripPlannerClient.PlanParams

  @date_regex ~r/^\d{4}-\d{2}-\d{2}$/
  @time_regex ~r/^\d?\d:\d{2}(am|pm)$/

  test "new/1 defaults to leaving now" do
    now = OpenTripPlannerClient.Util.local_now()

    assert %OpenTripPlannerClient.PlanParams{
             date: date,
             time: time,
             arriveBy: false
           } = new()

    assert to_date_param(now) == date
    assert to_time_param(now) == time
  end

  test "new/1 defaults to having 5 itineraries" do
    assert %OpenTripPlannerClient.PlanParams{
             numItineraries: 5
           } = new()
  end

  test "new/1 allows a customizable number of itineraries" do
    assert %OpenTripPlannerClient.PlanParams{
             numItineraries: 42
           } = new(%{numItineraries: 42})
  end

  test "to_place_param/1 with stop" do
    name = Faker.App.name()
    stop_id = Faker.Internet.slug()
    expected = "#{name}::mbta-ma-us:#{stop_id}"
    assert to_place_param(%{name: name, stop_id: stop_id}) == expected
  end

  test "to_place_param/1 without stop" do
    name = Faker.App.name()
    lat = Faker.Address.latitude()
    lon = Faker.Address.longitude()
    expected = "#{name}::#{lat},#{lon}"
    assert to_place_param(%{name: name, latitude: lat, longitude: lon}) == expected
  end

  describe "to_modes_param/1" do
    test "converts to maps" do
      assert [%{mode: :TRANSIT}] = to_modes_param([:TRANSIT])
    end

    test "adds tram mode when subway is requested" do
      assert [%{mode: :TRAM}, %{mode: :BUS}, %{mode: :SUBWAY}] = to_modes_param([:BUS, :SUBWAY])
    end
  end

  test "to_date_param/1" do
    date_param = to_date_param(Faker.DateTime.forward(1))
    assert date_param |> String.match?(@date_regex)
  end

  test "to_time_param/1" do
    time_param = to_time_param(Faker.DateTime.forward(1))
    assert time_param |> String.match?(@time_regex)
  end
end
