defmodule OpenTripPlannerClientTest do
  use ExUnit.Case
  doctest OpenTripPlannerClient

  test "greets the world" do
    assert OpenTripPlannerClient.hello() == :world
  end
end
