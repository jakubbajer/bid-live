defmodule Bidlive.Repo.Migrations.CreateAuctions do
  use Ecto.Migration

  def change do
    create table(:auctions) do
      add :title, :string
      add :description, :text
      add :starting_price, :decimal
      add :end_time, :naive_datetime
      add :image_url, :string
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:auctions, [:user_id])
  end
end
