defmodule OpenTripPlannerClient.PlanParamsTest do
  use ExUnit.Case, async: true
  import OpenTripPlannerClient.PlanParams

  @date_regex ~r/^\d{4}-\d{2}-\d{2}$/
  @time_regex ~r/^\d?\d:\d{2}(am|pm)$/

  test "new/1 defaults to leaving now" do
    now = Timex.local()

    assert %OpenTripPlannerClient.PlanParams{
             date: date,
             time: time,
             arriveBy: false
           } = new()

    assert to_date_param(now) == date
    assert to_time_param(now) == time
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

  test "to_modes_param/1" do
    assert [%{mode: :TRANSIT}] = to_modes_param([:TRANSIT])
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
