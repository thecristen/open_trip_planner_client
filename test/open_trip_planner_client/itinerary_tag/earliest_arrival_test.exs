defmodule OpenTripPlannerClient.ItineraryTag.EarliestArrivalTest do
  use ExUnit.Case, async: true
  alias OpenTripPlannerClient.ItineraryTag

  test "tags" do
    end_dt = Faker.DateTime.backward(4)
    later_dt = Timex.shift(end_dt, minutes: 11)

    itineraries = [
      %{"end" => DateTime.to_iso8601(end_dt), "tag" => nil},
      %{"end" => DateTime.to_iso8601(later_dt), "tag" => nil},
      %{"end" => DateTime.to_iso8601(end_dt), "tag" => nil}
    ]

    tagged = ItineraryTag.apply_tags(itineraries, [ItineraryTag.EarliestArrival])

    assert [
             %{"end" => dt, "tag" => :earliest_arrival},
             %{"tag" => nil},
             %{"end" => dt, "tag" => :earliest_arrival}
           ] = tagged

    assert {:ok, ^end_dt, _} = DateTime.from_iso8601(dt)
  end
end
