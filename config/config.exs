# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :weightroom,
  ecto_repos: [Weightroom.Repo]

# Configures the endpoint
config :weightroom, WeightroomWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "XGGwlQq+OF49Ndb4SHzZHDHC2ltAv6JU/0NUDDQ2Qt0GZjKr+YQ+wJ0JZrObiILP",
  render_errors: [view: WeightroomWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Weightroom.PubSub,
  live_view: [signing_salt: "J1vSAVAn"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
