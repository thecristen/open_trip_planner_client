defmodule OpenTripPlannerClient.Test.Factory do
  @moduledoc """
  Generate OpenTripPlannerClient.Schema structs
  """
  use ExMachina

  alias OpenTripPlannerClient.Schema.{
    Agency,
    Geometry,
    Itinerary,
    LegTime,
    Leg,
    Place,
    Route,
    Step,
    Stop,
    Trip
  }

  def agency_factory do
    %Agency{
      name: Faker.Util.pick(["MBTA", "Massport", "Logan Express"])
    }
  end

  def geometry_factory do
    %Geometry{
      points: Faker.Lorem.characters(12),
      length: nil
    }
  end

  def itinerary_factory do
    legs = Faker.random_between(1, 6) |> build_leg_sequence()
    %Leg{start: %LegTime{scheduled_time: first_start}} = List.first(legs)
    %Leg{end: %LegTime{scheduled_time: last_end}} = List.last(legs)

    %Itinerary{
      accessibility_score: Faker.Random.Elixir.random_uniform(),
      duration: legs |> Enum.map(& &1.duration) |> Enum.sum(),
      end: last_end,
      legs: legs,
      number_of_transfers: length(legs) - 1,
      start: first_start,
      walk_distance:
        legs |> Enum.filter(&(&1.mode == :WALK)) |> Enum.map(& &1.distance) |> Enum.sum()
    }
  end

  def leg_time_factory do
    %LegTime{
      scheduled_time: Faker.DateTime.forward(2),
      estimated: nil
    }
  end

  # Build a bunch of legs such that their start/end times follow each other
  # (e.g. creating a coherent sequence)
  defp build_leg_sequence(number) do
    base_time = Timex.now("America/New_York")

    transit_legs =
      build_list(number, :transit_leg, %{
        start:
          sequence(:leg_start, fn index ->
            build(:leg_time, %{
              scheduled_time: Timex.shift(base_time, minutes: (index + 1) * 10)
            })
          end)
      })

    %LegTime{scheduled_time: transit_start_time} = List.first(transit_legs).start
    %LegTime{scheduled_time: transit_end_time} = List.last(transit_legs).end

    first_walk_leg =
      build(:walking_leg, %{
        duration: random_seconds(),
        end:
          build(:leg_time, %{
            scheduled_time: transit_start_time
          }),
        start:
          build(:leg_time, %{
            scheduled_time: Timex.shift(transit_start_time, minutes: -random_seconds())
          })
      })

    last_walk_leg =
      build(:walking_leg, %{
        start:
          build(:leg_time, %{
            scheduled_time: transit_end_time
          })
      })

    [first_walk_leg | transit_legs ++ [last_walk_leg]]
  end

  def leg_factory(attrs) do
    # coherence between timed values - end time should be after the start time,
    # by the number of seconds specified in the duration.
    duration = attrs[:duration] || random_seconds()
    start_time = attrs[:start] || build(:leg_time)

    end_time =
      build(:leg_time, %{
        scheduled_time: Timex.shift(start_time.scheduled_time, seconds: duration)
      })

    leg = %Leg{
      agency: nil,
      distance: random_distance(),
      duration: duration,
      end: end_time,
      from: build(:place),
      intermediate_stops: nil,
      leg_geometry: build(:geometry),
      mode: nil,
      real_time: false,
      realtime_state: nil,
      route: nil,
      start: start_time,
      steps: nil,
      transit_leg: nil,
      trip: nil,
      to: build(:place)
    }

    leg
    |> merge_attributes(attrs)
    |> evaluate_lazy_attributes()
  end

  def transit_leg_factory(attrs) do
    agency = attrs[:agency] || build(:agency)
    route_gtfs_id = gtfs_prefix(agency.name) <> Faker.App.name()
    trip_gtfs_id = gtfs_prefix(agency.name) <> Faker.App.name()

    build(:leg, %{
      agency: agency,
      from:
        build(:place, %{
          stop: build(:stop, %{gtfs_id: gtfs_prefix(agency.name) <> Faker.App.name()})
        }),
      intermediate_stops:
        build_list(3, :stop, %{
          gtfs_id: fn ->
            sequence(:intermediate_stop_id, fn _ ->
              gtfs_prefix(agency.name) <> Faker.App.name()
            end)
          end
        }),
      mode: "TRANSIT",
      real_time: true,
      realtime_state: Faker.Util.pick(Leg.realtime_state()),
      route: build(:route, %{gtfs_id: route_gtfs_id}),
      to:
        build(:place, %{
          stop: build(:stop, %{gtfs_id: gtfs_prefix(agency.name) <> Faker.App.name()})
        }),
      trip: build(:trip, %{gtfs_id: trip_gtfs_id}),
      transit_leg: true
    })
  end

  def walking_leg_factory do
    build(:leg, %{
      mode: "WALK",
      steps: build_list(3, :step),
      transit_leg: false
    })
  end

  def place_factory do
    %Place{
      name: Faker.Address.street_name(),
      lat: Faker.Address.latitude(),
      lon: Faker.Address.longitude(),
      stop: nil
    }
  end

  def route_factory do
    %Route{
      gtfs_id: gtfs_prefix() <> Faker.App.name(),
      short_name: Faker.Person.suffix(),
      long_name: Faker.Color.fancy_name(),
      type: Faker.Util.pick(Route.gtfs_route_type()),
      color: Faker.Color.rgb_hex(),
      text_color: Faker.Color.rgb_hex(),
      desc: Faker.Company.catch_phrase()
    }
  end

  def step_factory do
    %Step{
      absolute_direction: Faker.Util.pick(Step.absolute_direction()) |> Atom.to_string(),
      distance: random_distance(),
      relative_direction: Faker.Util.pick(Step.relative_direction()) |> Atom.to_string(),
      street_name: Faker.Address.street_name()
    }
  end

  def stop_factory do
    %Stop{
      gtfs_id: gtfs_prefix() <> Faker.App.name(),
      name: Faker.Address.city()
    }
  end

  def trip_factory do
    %Trip{
      gtfs_id: gtfs_prefix() <> Faker.App.name()
    }
  end

  defp gtfs_prefix(agency_name \\ "MBTA")

  defp gtfs_prefix(agency_name) when agency_name in ["Massport", "Logan Express"],
    do: "massport-ma-us:"

  defp gtfs_prefix(_), do: "mbta-ma-us:"

  defp random_distance, do: Faker.random_uniform() * 2000
  defp random_seconds, do: Faker.random_between(100, 1000)
end
