defmodule OpenTripPlannerClientTest do
  use ExUnit.Case, async: true
  import OpenTripPlannerClient

  describe "plan/3" do
    test "bad options returns an error" do
      expected = {:error, {:unsupported_param, {:bad, :arg}}}

      actual =
        plan([lat_lon: {1, 1}], [lat_lon: {2, 2}], bad: :arg)

      assert expected == actual
    end
  end

  describe "plan/2" do
    test "" do
      # probably should make a PlanParams factory.
      # then use it WITH arrive_by: true
      # to create a plan
    end
  end
end
