defmodule OpenTripPlannerClient.ParserTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureLog
  import OpenTripPlannerClient.Parser

  describe "validate_body/1" do
    test "handles GraphQL request error" do
      assert {{:error, :graphql_request_error}, log} =
               with_log(fn ->
                 validate_body(%{
                   "errors" => [
                     %{
                       "message" =>
                         "Validation error (UndefinedVariable@[plan]) : Undefined variable 'from'",
                       "locations" => [
                         %{
                           "line" => 3,
                           "column" => 16
                         }
                       ],
                       "extensions" => %{
                         "classification" => "ValidationError"
                       }
                     },
                     %{
                       "message" =>
                         "Validation error (UnusedVariable) : Unused variable 'fromPlace'",
                       "locations" => [
                         %{
                           "line" => 1,
                           "column" => 16
                         }
                       ],
                       "extensions" => %{
                         "classification" => "ValidationError"
                       }
                     }
                   ]
                 })
               end)

      assert log =~ "Validation error"
    end

    test "handles GraphQL field error" do
      assert {{:error, :graphql_field_error}, log} =
               with_log(fn ->
                 validate_body(%{
                   "data" => %{"plan" => nil},
                   "errors" => [
                     %{
                       "message" =>
                         "Exception while fetching data (/plan) : The value is not in range[0.0, 1.7976931348623157E308]: -5.0",
                       "locations" => [
                         %{
                           "line" => 2,
                           "column" => 3
                         }
                       ],
                       "path" => [
                         "plan"
                       ],
                       "extensions" => %{
                         "classification" => "DataFetchingException"
                       }
                     }
                   ]
                 })
               end)

      assert log =~ "Exception while fetching data"
    end

    test "handles routing errors" do
      assert {{:error, "PATH_NOT_FOUND"}, log} =
               with_log(fn ->
                 validate_body(%{
                   "data" => %{"plan" => %{"routingErrors" => [%{"code" => "PATH_NOT_FOUND"}]}}
                 })
               end)

      assert log =~ "PATH_NOT_FOUND"
    end
  end
end
