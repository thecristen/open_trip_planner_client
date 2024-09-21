import Config

config :open_trip_planner_client,
  otp_url: "http://otp2-local.mbtace.com",
  # otp_url: "http://localhost:8080",
  timezone: "America/New_York"

config :logger, :default_formatter,
  format: "[$level] $message $metadata\n",
  metadata: [:mfa, :error_code, :file, :line, :crash_reason]
