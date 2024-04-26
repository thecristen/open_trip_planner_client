defmodule OpenTripPlannerClient.ItineraryTagTest do
  use ExUnit.Case, async: true
  import OpenTripPlannerClientTest.Support.Factory
  alias OpenTripPlannerClient.ItineraryTag

  defmodule BadTag do
    @behaviour OpenTripPlannerClient.ItineraryTag.Behaviour

    def optimal, do: :max
    def score(_), do: nil
    def tag, do: :bad
  end

  setup_all do
    itineraries =
      build_list(9, :itinerary, %{legs: build_list(3, :leg)})

    {:ok,
     %{
       bad_itineraries: ItineraryTag.apply_tags(itineraries, [BadTag])
     }}
  end

  test "correctly ignores tags that are always nil", %{bad_itineraries: itineraries} do
    assert Enum.all?(itineraries, &is_nil(&1["tag"]))
  end

  test "overrides tags of lower priority" do
    end_dt = Faker.DateTime.backward(4)

    itineraries = [
      build(:itinerary, %{
        end: DateTime.to_iso8601(end_dt),
        tag: :least_walking,
        duration: 40
      }),
      build(:itinerary, %{
        end: DateTime.to_iso8601(end_dt),
        tag: :least_walking,
        duration: 50
      })
    ]

    # Does not override
    assert itineraries
           |> ItineraryTag.apply_tags([ItineraryTag.ShortestTrip])
           |> List.first()
           |> Map.get("tag") == :shortest_trip

    # Overrides
    assert itineraries
           |> ItineraryTag.apply_tags([ItineraryTag.EarliestArrival])
           |> List.first()
           |> Map.get("tag") == :earliest_arrival
  end

  test "sort_tagged/1 sorts by tag priority & start time" do
    start_dt = "2024-04-16T02:23:07.462033Z"
    start_dt1 = "2024-04-16T02:30:07.462033Z"
    start_dt2 = "2024-04-16T02:38:07.462033Z"

    itineraries = [
      build(:itinerary, %{
        start: start_dt,
        tag: :least_walking
      }),
      build(:itinerary, %{
        start: start_dt,
        tag: nil
      }),
      build(:itinerary, %{
        start: start_dt1,
        tag: :least_walking
      }),
      build(:itinerary, %{
        start: start_dt2,
        tag: :least_walking
      }),
      build(:itinerary, %{
        start: start_dt2,
        tag: :earliest_arrival
      }),
      build(:itinerary, %{
        start: start_dt1,
        tag: :most_direct
      })
    ]

    sorted = ItineraryTag.sort_tagged(itineraries)

    assert [
             %{"tag" => :most_direct},
             %{"tag" => :earliest_arrival},
             %{"tag" => :least_walking, "start" => ^start_dt},
             %{"tag" => :least_walking, "start" => ^start_dt1},
             %{"tag" => :least_walking, "start" => ^start_dt2},
             %{"tag" => nil}
           ] = sorted
  end
end
