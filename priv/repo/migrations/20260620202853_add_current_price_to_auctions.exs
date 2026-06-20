defmodule Bidlive.Repo.Migrations.AddCurrentPriceToAuctions do
  use Ecto.Migration

  def change do
    alter table(:auctions) do
      add :current_price, :decimal, default: fragment("starting_price"), null: false
    end
  end
end
