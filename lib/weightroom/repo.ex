defmodule Weightroom.Repo do
  use Ecto.Repo,
    otp_app: :weightroom,
    adapter: Ecto.Adapters.Postgres
end
