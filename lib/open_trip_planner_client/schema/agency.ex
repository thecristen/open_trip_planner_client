defmodule OpenTripPlannerClient.Schema.Agency do
  @moduledoc """
  A public transport agency

  https://docs.opentripplanner.org/api/dev-2.x/graphql-gtfs/types/Agency
  """

  use Jason.Structs.Struct
  use OpenTripPlannerClient.Schema

  jason_struct do
    field(:name, String.t(), @default_field)
  end
end
