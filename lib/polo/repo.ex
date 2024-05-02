defmodule Polo.Repo do
  use Ecto.Repo,
    otp_app: :polo,
    adapter: Ecto.Adapters.Postgres
end
