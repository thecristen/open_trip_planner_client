import Config

if config_env() != :test and System.get_env("OTP_URL", "") != "" do
  config :open_trip_planner_client,
    otp_url: System.get_env("OTP_URL")
end
