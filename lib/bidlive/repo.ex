defmodule Bidlive.Repo do
  use Ecto.Repo,
    otp_app: :bidlive,
    adapter: Ecto.Adapters.SQLite3
end
