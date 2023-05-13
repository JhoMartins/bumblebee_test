defmodule BumblebeeTest.Repo do
  use Ecto.Repo,
    otp_app: :bumblebee_test,
    adapter: Ecto.Adapters.Postgres
end
