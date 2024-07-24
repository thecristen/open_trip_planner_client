defmodule OpenTripPlannerClient.ItineraryTag.EarliestArrivalTest do
  use ExUnit.Case, async: true

  import OpenTripPlannerClient.Test.Support.Factory

  alias OpenTripPlannerClient.ItineraryTag

  test "tags, sorts" do
    end_dt = Faker.DateTime.backward(4)
    later_dt = Timex.shift(end_dt, minutes: 11)

    itineraries = [
      build(:itinerary, %{
        end: end_dt
      }),
      build(:itinerary, %{
        end: later_dt
      }),
      build(:itinerary, %{
        end: end_dt
      })
    ]

    tagged = ItineraryTag.apply_tags(itineraries, [ItineraryTag.EarliestArrival])

    assert [
             %{end: ^end_dt, tag: :earliest_arrival},
             %{end: ^end_dt, tag: :earliest_arrival},
             %{tag: nil}
           ] = tagged
  end
end
