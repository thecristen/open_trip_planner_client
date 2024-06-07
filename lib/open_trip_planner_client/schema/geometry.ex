defmodule OpenTripPlannerClient.Schema.Geometry do
  @moduledoc """
  https://docs.opentripplanner.org/api/dev-2.x/graphql-gtfs/types/Geometry
  """

  use Jason.Structs.Struct
  use OpenTripPlannerClient.Schema

  @typedoc """
  List of coordinates of in a Google encoded polyline format (see
  https://developers.google.com/maps/documentation/utilities/polylinealgorithm)
  """
  @type polyline :: String.t()

  @typedoc """
  * length - The number of points in the string
  * points - List of coordinates of in a Google encoded polyline format (see
    https://developers.google.com/maps/documentation/utilities/polylinealgorithm)
  """
  jason_struct do
    field(:length, non_neg_integer())
    field(:points, polyline())
  end
end
