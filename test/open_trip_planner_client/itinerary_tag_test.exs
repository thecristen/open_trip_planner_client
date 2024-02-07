defmodule OpenTripPlannerClient.ItineraryTagTest do
  use ExUnit.Case, async: true
  alias OpenTripPlannerClient.ItineraryTag

  defmodule BadTag do
    @behaviour OpenTripPlannerClient.ItineraryTag

    def optimal, do: :max
    def score(_), do: nil
    def tag, do: :bad
  end

  test "correctly ignores tags that are always nil" do
    itineraries = [%{"startTime" => 1, "endTime" => 2}]
    tags = ItineraryTag.apply_tag(BadTag, itineraries)
    assert tags == [%{"startTime" => 1, "endTime" => 2, "tags" => MapSet.new([])}]
  end
end
