defmodule OpenTripPlannerClient.Schema do
  @moduledoc """
  https://docs.opentripplanner.org/api/dev-2.x/graphql-gtfs/
  """
  defmacro __using__(_opts) do
    quote do
      # Using Kernel.put_in/3 and other methods requires the target to have the Access behaviour.
      @behaviour Access

      # Structs by default do not implement this. It's easy to delegate this to the Map implementation however.
      defdelegate get(schema, key, default), to: Map
      defdelegate fetch(schema, key), to: Map
      defdelegate get_and_update(schema, key, func), to: Map
      defdelegate pop(schema, key), to: Map

      @typedoc """
      The distance traveled in meters.
      """
      @type distance_meters :: float()

      @typedoc """
      Duration in seconds.
      """
      @type duration_seconds :: non_neg_integer()

      @typedoc """
      ID of a resource in format FeedId:ResourceId
      """
      @type gtfs_id :: String.t()

      @typedoc """
      An ISO-8601-formatted datetime with offset, i.e. 2023-06-13T14:30+03:00
      for 2:30pm on June 13th 2023 at Helsinki's offset from UTC at that time.

      ISO-8601 allows many different formats but OTP will only return the
      profile specified in RFC3339.
      """
      @type offset_datetime :: DateTime.t()

      @nonnull_field [enforce: true, null: false]

      use TypedStruct

      import OpenTripPlannerClient.Schema, only: [schema: 1]
    end
  end

  defimpl Nestru.Encoder, for: DateTime do
    # credo:disable-for-next-line
    def gather_fields_from_struct(struct, _) do
      {:ok, DateTime.to_string(struct)}
    end
  end

  defimpl Nestru.Decoder, for: DateTime do
    # credo:disable-for-next-line
    def decode_fields_hint(_, _, %DateTime{} = dt) do
      {:ok, OpenTripPlannerClient.Util.to_local_time(dt)}
    end

    # credo:disable-for-next-line
    def decode_fields_hint(_, _, value) do
      case Timex.parse(value, "{ISO:Extended}") do
        {:ok, dt} ->
          {:ok, OpenTripPlannerClient.Util.to_local_time(dt)}

        error ->
          error
      end
    end
  end

  @doc """
  A drop-in replacement for the [`typedstruct`](https://hexdocs.pm/typed_struct/TypedStruct.html) macro, invoked in `use OpenTripPlannerClient.Schema` to automatically enable Jason encoding and implement the Access behaviour.
  """
  defmacro schema(do_block) do
    quote do
      @derive Jason.Encoder
      TypedStruct.typedstruct do
        unquote(do_block)
      end
    end
  end
end
