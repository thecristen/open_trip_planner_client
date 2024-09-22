defmodule OpenTripPlannerClient.Schema.Step do
  @moduledoc """
  Part of a walking leg.

  https://docs.opentripplanner.org/api/dev-2.x/graphql-gtfs/types/step
  """
  use Jason.Structs.Struct
  use OpenTripPlannerClient.Schema

  @absolute_direction [
    :NORTH,
    :NORTHEAST,
    :EAST,
    :SOUTHEAST,
    :SOUTH,
    :SOUTHWEST,
    :WEST,
    :NORTHWEST
  ]

  @typedoc """
  The cardinal (compass) direction taken when engaging a walking/driving step.
  """
  @type absolute_direction ::
          unquote(
            @absolute_direction
            |> Enum.map_join(" | ", &inspect/1)
            |> Code.string_to_quoted!()
          )

  @relative_direction [
    :DEPART,
    :HARD_LEFT,
    :LEFT,
    :SLIGHTLY_LEFT,
    :CONTINUE,
    :SLIGHTLY_RIGHT,
    :RIGHT,
    :HARD_RIGHT,
    :CIRCLE_CLOCKWISE,
    :CIRCLE_COUNTERCLOCKWISE,
    :ELEVATOR,
    :UTURN_LEFT,
    :UTURN_RIGHT,
    :ENTER_STATION,
    :EXIT_STATION,
    :FOLLOW_SIGNS
  ]

  @typedoc """
  Actions to take relative to the current position when engaging a
  walking/driving step.
  """
  @type relative_direction ::
          unquote(
            @relative_direction
            |> Enum.map_join(" | ", &inspect/1)
            |> Code.string_to_quoted!()
          )

  jason_struct do
    field(:distance, distance_meters())
    field(:street_name, String.t())
    field(:absolute_direction, absolute_direction())
    field(:relative_direction, relative_direction())
  end

  @spec absolute_direction :: [absolute_direction()]
  def absolute_direction, do: @absolute_direction

  @spec relative_direction :: [relative_direction()]
  def relative_direction, do: @relative_direction
end
