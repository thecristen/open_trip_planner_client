defmodule OpenTripPlannerClient.ItineraryTagTest do
  use ExUnit.Case, async: true

  import OpenTripPlannerClient.Test.Support.Factory

  alias OpenTripPlannerClient.ItineraryTag

  defmodule BadTag do
    @behaviour OpenTripPlannerClient.ItineraryTag.Behaviour

    def optimal, do: :max
    def score(_), do: nil
    def tag, do: :bad
  end

  setup_all do
    {:ok, %{itineraries: build_list(9, :itinerary)}}
  end

  test "ignores no tags/itineraries", %{itineraries: itineraries} do
    assert ItineraryTag.apply_tags(itineraries, [])
    assert ItineraryTag.apply_tags([], [ItineraryTag.ShortestTrip])
    assert ItineraryTag.apply_tags([], [])
  end

  test "correctly ignores tags that are always nil", %{itineraries: itineraries} do
    bad_itineraries = ItineraryTag.apply_tags(itineraries, [BadTag])
    assert Enum.all?(bad_itineraries, &is_nil(&1.tag))
  end

  test "overrides tags of lower priority" do
    end_dt = Faker.DateTime.backward(4)

    itineraries = [
      build(:itinerary, %{
        end: end_dt,
        duration: 40
      })
      |> Map.put(:tag, :least_walking),
      build(:itinerary, %{
        end: end_dt,
        duration: 50
      })
      |> Map.put(:tag, :least_walking)
    ]

    # Does not override
    assert itineraries
           |> ItineraryTag.apply_tags([ItineraryTag.ShortestTrip])
           |> List.first()
           |> Map.get(:tag) == :shortest_trip

    # Overrides
    assert itineraries
           |> ItineraryTag.apply_tags([ItineraryTag.EarliestArrival])
           |> List.first()
           |> Map.get(:tag) == :earliest_arrival
  end

  test "sort_tagged/1 sorts by tag priority & start time" do
    start_dt = ~U[2024-04-16T02:23:07.462033Z]
    start_dt1 = ~U[2024-04-16T02:30:07.462033Z]
    start_dt2 = ~U[2024-04-16T02:38:07.462033Z]

    itineraries = [
      build(:itinerary, %{
        start: start_dt
      })
      |> Map.put(:tag, :least_walking),
      build(:itinerary, %{
        start: start_dt
      })
      |> Map.put(:tag, nil),
      build(:itinerary, %{
        start: start_dt1
      })
      |> Map.put(:tag, :least_walking),
      build(:itinerary, %{
        start: start_dt2
      })
      |> Map.put(:tag, :least_walking),
      build(:itinerary, %{
        start: start_dt2
      })
      |> Map.put(:tag, :earliest_arrival),
      build(:itinerary, %{
        start: start_dt1
      })
      |> Map.put(:tag, :most_direct)
    ]

    sorted = ItineraryTag.sort_tagged(itineraries)

    assert [
             %{tag: :most_direct},
             %{tag: :earliest_arrival},
             %{tag: :least_walking, start: ^start_dt},
             %{tag: :least_walking, start: ^start_dt1},
             %{tag: :least_walking, start: ^start_dt2},
             %{tag: nil}
           ] = sorted
  end
end
