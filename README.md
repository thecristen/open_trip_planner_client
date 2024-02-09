# OpenTripPlannerClient

[![Documentation](https://img.shields.io/badge/-Documentation-blueviolet)](http://github.thecristen.net/open_trip_planner_client/)
![Test, Docs,
Release](https://github.com/thecristen/open_trip_planner_client/workflows/Test,%20Docs,%20Release/badge.svg)
[![Last
Updated](https://img.shields.io/github/last-commit/thecristen/open_trip_planner_client.svg)](https://github.com/thecristen/open_trip_planner_client/commits/main)

Shared functionality for working with
[OpenTripPlanner](https://docs.opentripplanner.org/en/v2.4.0/), curated to the
MBTA's needs.

Use with caution – this is in early stages and we expect things can change!
Feedback welcomed.

## Installation

Not on Hex (yet?). Github-hosted Elixir libraries such as this one can be added
to a project's dependencies in `mix.exs` in this way:

```elixir
def deps do
  [
    %{:open_trip_planner_client,
      [
        github: "thecristen/open_trip_planner_client",
        ref: "v0.3.2"
      ]}
  ]
end
```

Then run `mix deps.get`.

## Configuration

The library expects a URL to a running instance of OpenTripPlanner, and a
timezone name that's used to parse and format input `DateTime`s into the correct
strings for input into OpenTripPlanner. Valid timezone names are from the Olson
database; valid values can be found using
[`Timex.timezones/0`](https://hexdocs.pm/timex/Timex.html#timezones/0). Ideally
the timezone matches that configured in the OpenTripPlanner instance.

### OpenTripPlanner requirements

The OpenTripPlanner instance needs to be version 2, with the GraphQL API
enabled. 

If using the
[`transitModelTimeZone`](https://docs.opentripplanner.org/en/v2.4.0/BuildConfiguration/?h=timezone#transitModelTimeZone)
build parameter, it should be consistent with the timezone name indicated in
this configuration.

```elixir
config :open_trip_planner_client,
  otp_url: "http://localhost:8080",
  timezone: "America/New_York"
```

## Usage

Documentation is automatically generated with every
[release](https://github.com/thecristen/open_trip_planner_client/releases), and
the latest docs are published on [Github
Pages](http://github.thecristen.net/open_trip_planner_client/).

### Trip planning

At minimum, origin and destination must specify either a valid `:stop_id` or `:lat_lon`
value, and can optionally include a `:name`.

```elixir
origin = [stop_id: "place-north"]
destination = [name: "Park Plaza", lat_lon: %{42.348777, -71.066481}]
%{:ok, itineraries} = OpenTripPlannerClient.plan(origin, destination, [])
```

The `t:OpenTripPlannerClient.Behaviour.plan_opt/0` type describes additional expected parameters, which include specifying the departure or arrival times, filtering for wheelchair accessibility, and generating one or more supported tags.

```elixir
plan(origin, destination, arriveBy: ~N[2024-04-15T09:00:00])
plan(origin, destination, wheelchair: false, departBy: ~N[2024-03-30T11:24:00])
```

The list of itineraries returned are directly from
OpenTripPlanner, and consumers are expected to handle further parsing. See the `OpenTripPlannerClient.itinerary_shape/0` for expected fields.

```elixir
# Each itinerary might look like something this
%{
  "accessibilityScore" => 1,
  "startTime" => 1706813160000,
  "endTime" => 1706815000000,
  "duration" => 1840,
  "legs" => [
    %{
      "mode" => "WALK",
      "startTime" => 1706813160000,
      "endTime" => 1706815000000,
      "distance" => 2214.18,
      "duration" => 1840,
      "intermediateStops" => nil,
      "transitLeg" => false,
      "headsign" => nil,
      "realTime" => false,
      "realtimeState" => nil,
      "agency" => nil,
      "alerts" => [],
      "fareProducts" => [],
      "from" => %{
          "name" => "North Station",
          "lat" => 42.36528,
          "lon" => -71.060205,
          "departureTime" => 1706813160000,
          "arrivalTime" => 1706813160000,
          "stop" => %{
              "gtfsId" => "mbta-ma-us:70205"
          }
      },
      "to" => %{
          "name" => "Park Plaza",
          "lat" => 42.348777,
          "lon" => -71.066481,
          "departureTime" => 1706815000000,
          "arrivalTime" => 1706815000000,
          "stop" => nil
      },
      "route" => nil,
      "trip" => nil,
      "steps" => [
            %{
                "distance" => 135.06,
                "streetName" => "path",
                "lat" => 42.365273,
                "lon" => -71.0602162,
                "absoluteDirection" => "SOUTHEAST",
                "relativeDirection" => "DEPART",
                "stayOn" => false
            },
            %{
                "distance" => 171.32,
                "streetName" => "Valenti Way",
                "lat" => 42.36439,
                "lon" => -71.0598176,
                "absoluteDirection" => "SOUTHWEST",
                "relativeDirection" => "RIGHT",
                "stayOn" => false
            },
            ## More steps removed for brevity
            %{
                "distance" => 114.15,
                "streetName" => "path",
                "lat" => 42.3493161,
                "lon" => -71.0655133,
                "absoluteDirection" => "WEST",
                "relativeDirection" => "RIGHT",
                "stayOn" => true
            }
        ],
        "legGeometry" => %{
            "points" => "_nqaGh}upL@@zBkC@Bf@bAHKHLFNx@zADHFHr@tAFHDLBBNZHNPJ[hBFBlA`@@@t@X`A\\BBB@@DBB@DBJL[DM@AHW??DFRTLNFFFDFFHFJDf@XFBHBB@D@@@@@B?B@B?@@B?D@B?D@D?B?@?B@D?B?D?B?D?T?\\A|BCR?vAALAH@RBH@~@BP?B?V?PADAHAHAlB]B?B?FBFBX~@DGBFDAh@a@DEROhAiA~@eA@A@A?CFLPSd@h@JJp@r@|@~@FH\\^b@^NJBBJHTNx@`@B@pAh@LD\\N\\Lp@TPFD@\\JLD~@XB@h@H`@H^FF@PDNBz@Nt@LLBTDH@PDh@JTHZFDZt@ND@B?|@RD?F@VFr@JfBT?FBJDPHPFNFJBLBJ@L?P?TVBDBP?BAJT"
        }
    }
  ]
}
```

### Trip planning with tagging

A special `:tags` feature will score the list of itineraries against a specified
criteria. This client provides several tag implementations, and it's also
possible to create custom tags, by implementing the
`OpenTripPlannerClient.ItineraryTag` behaviour.


```elixir
alias OpenTripPlannerClient.ItineraryTag

tags = [
  ItineraryTag.EarliestArrival,
  ItineraryTag.LeastWalking,
  ItineraryTag.ShortestTrip
]
{:ok, itineraries} = plan(origin, destination, tags: tags)
```

The returned itineraries include an extra field, `"tag"`, which will contain the relevant tag.

```elixir
[:shortest_trip, :least_walking, nil] = Enum.map(itineraries, &Map.get(&1, "tag"))
```

## License

~~It's mine all mine~~ TBD after moving to the [https://github.com/mbta/](MBTA) organization ¯\\_(ツ)_/¯
