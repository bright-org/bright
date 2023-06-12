defmodule Bright.Repo do
  use Ecto.Repo,
    otp_app: :bright,
    adapter: Ecto.Adapters.Postgres
end
