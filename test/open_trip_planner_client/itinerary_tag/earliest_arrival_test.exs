defmodule OpenTripPlannerClient.ItineraryTag.EarliestArrivalTest do
  use ExUnit.Case, async: true
  import OpenTripPlannerClientTest.Support.Factory
  alias OpenTripPlannerClient.ItineraryTag

  test "tags, sorts" do
    end_dt = Faker.DateTime.backward(4)
    later_dt = Timex.shift(end_dt, minutes: 11)

    itineraries = [
      build(:itinerary, %{
        end: DateTime.to_iso8601(end_dt)
      }),
      build(:itinerary, %{
        end: DateTime.to_iso8601(later_dt)
      }),
      build(:itinerary, %{
        end: DateTime.to_iso8601(end_dt)
      })
    ]

    tagged = ItineraryTag.apply_tags(itineraries, [ItineraryTag.EarliestArrival])

    assert [
             %{"end" => dt, "tag" => :earliest_arrival},
             %{"end" => dt, "tag" => :earliest_arrival},
             %{"tag" => nil}
           ] = tagged

    assert {:ok, ^end_dt, _} = DateTime.from_iso8601(dt)
  end
end
