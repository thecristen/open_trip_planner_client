defmodule OpenTripPlannerClient.Schema.Place do
  @moduledoc """
  https://docs.opentripplanner.org/api/dev-2.x/graphql-gtfs/types/Place
  """

  use Jason.Structs.Struct
  use OpenTripPlannerClient.Schema

  alias OpenTripPlannerClient.Schema.Stop

  jason_struct do
    field(:name, String.t())
    field(:lat, float(), @nonnull_field)
    field(:lon, float(), @nonnull_field)
    field(:stop, Stop.t())
  end
end
