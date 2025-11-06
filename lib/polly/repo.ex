defmodule Polly.Repo do
  use Ecto.Repo,
    otp_app: :polly,
    adapter: Ecto.Adapters.Postgres
end
