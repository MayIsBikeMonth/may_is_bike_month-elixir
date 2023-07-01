defmodule MayIsBikeMonth.Repo do
  use Ecto.Repo,
    otp_app: :may_is_bike_month,
    adapter: Ecto.Adapters.Postgres
end
