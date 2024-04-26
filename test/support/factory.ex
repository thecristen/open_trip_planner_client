# credo:disable-for-this-file
defmodule OpenTripPlannerClientTest.Support.Factory do
  @moduledoc "Data generators for tests"
  use ExMachina

  def itinerary_factory(attrs) do
    legs = Map.get(attrs, :legs, Faker.random_between(1, 4) |> build_list(:leg))
    startTime = Map.get(attrs, :start, Enum.map(legs, & &1["start"]) |> List.first())
    endTime = Map.get(attrs, :end, Enum.map(legs, & &1["end"]) |> List.last())
    duration = Map.get(attrs, :duration, Enum.map(legs, & &1["duration"]) |> Enum.sum())

    %{
      "accessibilityScore" => Enum.random([0, 1]),
      "duration" => duration,
      "end" => endTime,
      "legs" => legs,
      "numberOfTransfers" => Enum.count(legs) - 1,
      "start" => startTime,
      "walkDistance" => Map.get(attrs, :walkDistance, random_distance()),
      "tag" => Map.get(attrs, :tag)
    }
  end

  def leg_factory(attrs) do
    transit_leg = Map.get(attrs, :transitLeg, random_bool())
    agency = if transit_leg, do: %{"name" => "MBTA", "url" => "https://www.mbta.com"}

    mode =
      if(transit_leg,
        do: Enum.random(["BUS", "FERRY", "RAIL", "SUBWAY", "TRAM", "TRANSIT"]),
        else: "WALK"
      )

    from = build(:place, if(transit_leg, do: %{"stop_id" => random_string(7)}, else: %{}))
    to = build(:place, if(transit_leg, do: %{"stop_id" => random_string(7)}, else: %{}))

    start_time =
      sequence(:time, &(Timex.now() |> Timex.shift(minutes: &1 * 10))) |> DateTime.to_iso8601()

    end_time =
      sequence(:time, &(Timex.now() |> Timex.shift(minutes: &1 * 10))) |> DateTime.to_iso8601()

    %{
      "agency" => agency,
      "distance" => random_distance(),
      "duration" => random_seconds(),
      "end" => end_time,
      "from" => from,
      "intermediateStops" => if(transit_leg, do: Faker.random_between(1, 4) |> build_list(:gtfs)),
      "legGeometry" => %{"points" => random_string(20)},
      "mode" => mode,
      "realTime" => if(transit_leg, do: random_bool()),
      "realtimeState" =>
        if(transit_leg,
          do: Enum.random(["SCHEDULED", "UPDATED", "CANCELED", "ADDED", "MODIFIED"])
        ),
      "route" =>
        if(transit_leg,
          do:
            build(:gtfs)
            |> Map.put_new(:shortName, random_string(4))
            |> Map.put_new(:longName, random_string(12))
        ),
      "start" => start_time,
      "steps" => if(!transit_leg, do: Faker.random_between(1, 4) |> build_list(:step)),
      "to" => to,
      "transitLeg" => transit_leg,
      "trip" => if(transit_leg, do: build(:gtfs))
    }
  end

  def step_factory do
    %{
      "absoluteDirection" =>
        Enum.random([
          "NORTH",
          "NORTHEAST",
          "EAST",
          "SOUTHEAST",
          "SOUTH",
          "SOUTHWEST",
          "WEST",
          "NORTHWEST"
        ]),
      "distance" => random_distance(),
      "relativeDirection" =>
        Enum.random([
          "DEPART",
          "HARD_LEFT",
          "LEFT",
          "SLIGHTLY_LEFT",
          "CONTINUE",
          "SLIGHTLY_RIGHT",
          "RIGHT",
          "HARD_RIGHT",
          "CIRCLE_CLOCKWISE",
          "CIRCLE_COUNTERCLOCKWISE",
          "ELEVATOR",
          "UTURN_LEFT",
          "UTURN_RIGHT",
          "ENTER_STATION",
          "EXIT_STATION",
          "FOLLOW_SIGNS"
        ]),
      "streetName" => Faker.Address.street_name()
    }
  end

  def place_factory(attrs) do
    %{
      "lat" => Faker.Address.latitude(),
      "lon" => Faker.Address.longitude(),
      "name" => Faker.Address.city(),
      "stop" => if(stop_id = Map.get(attrs, :stop_id), do: %{"gtfsId" => "mbta-ma-us:#{stop_id}"})
    }
  end

  def gtfs_factory do
    %{"gtfsId" => "mbta-ma-us:" <> random_string(8)}
  end

  defp random_bool, do: Enum.random([true, false])
  defp random_distance, do: Faker.random_uniform() * 1000
  defp random_seconds, do: Faker.random_uniform() * 500

  defp random_string(length),
    do:
      length
      |> :crypto.strong_rand_bytes()
      |> Base.url_encode64(padding: false)
end
