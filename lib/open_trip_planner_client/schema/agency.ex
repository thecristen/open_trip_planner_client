defmodule OpenTripPlannerClient.Schema.Agency do
  @moduledoc """
  A public transport agency

  https://docs.opentripplanner.org/api/dev-2.x/graphql-gtfs/types/Agency
  """

  use OpenTripPlannerClient.Schema

  @derive Nestru.Decoder
  schema do
    field(:name, String.t())
  end
end
