defmodule Bidlive.Auctions.Auction do
  @derive Jason.Encoder
  use Ecto.Schema
  import Ecto.Changeset

  schema "auctions" do
    field :title, :string
    field :description, :string
    field :starting_price, :decimal
    field :current_price, :decimal
    field :end_time, :naive_datetime
    field :image_url, :string
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(auction, attrs, user_scope) do
    auction
    |> cast(attrs, [:title, :description, :starting_price, :end_time, :image_url])
    |> validate_required([:title, :description, :starting_price, :end_time, :image_url])
    |> put_change(:user_id, user_scope.user.id)
    |> put_change(
      :current_price,
      case Decimal.cast(attrs["starting_price"] || attrs.starting_price) do
        {:ok, val} -> val
        _ -> Decimal.new("0")
      end
    )
  end

  @doc false
  def changeset(auction, attrs) do
    auction
    |> cast(attrs, [:title, :description, :starting_price, :end_time, :image_url])
    |> validate_required([:title, :description, :starting_price, :end_time, :image_url])
  end

  @doc false
  def bid_changeset(auction, amount) do
    current = auction.current_price
    max_allowed = Decimal.mult(current, 2)

    auction
    |> change(current_price: amount)
    |> validate_required([:current_price])
    |> validate_bid_amount(current, max_allowed)
  end

  defp validate_bid_amount(changeset, current, max_allowed) do
    amount = get_change(changeset, :current_price)

    cond do
      is_nil(amount) ->
        changeset

      Decimal.compare(amount, current) != :gt ->
        add_error(changeset, :current_price, "musi być większa niż #{current} zł")

      Decimal.compare(amount, max_allowed) == :gt ->
        add_error(
          changeset,
          :current_price,
          "może być maksymalnie #{max_allowed} zł (podwójna cena bieżąca)"
        )

      true ->
        changeset
    end
  end
end
