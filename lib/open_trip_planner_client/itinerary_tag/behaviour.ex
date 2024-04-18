defmodule OpenTripPlannerClient.ItineraryTag.Behaviour do
  @moduledoc """
  Logic for a tag which can be applied to itineraries which are the best by some criterion.
  """

  @opaque itinerary_map :: map()

  @typedoc """
  Method used to determine the optimal score from a set of numbers. Currently
  supported values are :max or :min for maximum and minumum, respectively.
  """
  @type optimal_t :: :max | :min

  @typedoc """
  A function that assigns a numeric score to an itinerary.
  """
  @type score_fn :: (itinerary_map -> number() | nil)

  @typedoc """
  A tuple describing a scoring function of the same type as `t:score_fn/1` along
  with its associated `c:optimal/0` specification.
  """
  @type tiebreaker_t :: {score_fn(), optimal_t()}

  @typedoc "The module implementing this Behaviour."
  @type t :: module()

  @doc """
  The type of score which is to be considered optimal or best.
  """
  @callback optimal :: optimal_t

  @doc """
  The function which assigns a score to a particular itinerary. Expected to
  return either a number or nil.
  """
  @callback score(itinerary_map) :: number() | nil

  @doc """
  A unique atom that will assigned to the qualifying itinerary.
  """
  @callback tag :: atom()

  @doc """
  In the event of a set of itineraries having more than one best itinerary, an
  optional list of additional scoring mechanisms, here named tiebraker, can be
  described here.

  Each tiebraker is described in `t:tiebreaker_t/0` as a Tuple of a scoring
  function with an associated optimial spec.
  """
  @callback tiebreakers :: [tiebreaker_t()]

  @optional_callbacks tiebreakers: 0
end
