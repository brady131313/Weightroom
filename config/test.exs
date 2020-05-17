use Mix.Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :weightroom, Weightroom.Repo,
  username: "postgres",
  password: "password",
  database: "weightroom_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :weightroom, Weightroom.Accounts.Guardian,
     issuer: "weightroom",
     secret_key: "eKYOGN8Tq4n5kJUTAYYdQLZUEW0ADSo+5A65XL9EWra3tlBQKfMBmsaDueuQbu+M"

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :weightroom, WeightroomWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
