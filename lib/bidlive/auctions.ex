defmodule Bidlive.Auctions do
  @moduledoc """
  The Auctions context.
  """

  import Ecto.Query, warn: false
  alias Bidlive.Repo

  alias Bidlive.Auctions.Auction

  @topic "auctions"

  @doc """
  Subscribes to all auction changes.
  """
  def subscribe do
    Phoenix.PubSub.subscribe(Bidlive.PubSub, @topic)
  end

  defp broadcast(message) do
    Phoenix.PubSub.broadcast(Bidlive.PubSub, @topic, message)
  end

  @doc """
  Returns the list of auctions.
  """
  def list_auctions do
    Repo.all(Auction)
  end

  @doc """
  Gets a single auction.
  Raises `Ecto.NoResultsError` if the Auction does not exist.
  """
  def get_auction!(id) do
    Repo.get!(Auction, id)
  end

  @doc """
  Creates an auction.
  """
  def create_auction(scope, attrs) do
    %Auction{}
    |> Auction.changeset(attrs, scope)
    |> Repo.insert()
    |> broadcast_create()
  end

  @doc """
  Updates an auction.
  """
  def update_auction(scope, %Auction{} = auction, attrs) do
    auction
    |> Auction.changeset(attrs, scope)
    |> Repo.update()
    |> broadcast_update()
  end

  @doc """
  Deletes an auction.
  """
  def delete_auction(_scope, %Auction{} = auction) do
    Repo.delete(auction)
    |> broadcast_delete()
  end

  @doc """
  Places a bid on an auction, increasing current_price.
  """
  def place_bid(%Auction{} = auction, amount) do
    auction
    |> Auction.bid_changeset(amount)
    |> Repo.update()
    |> broadcast_update()
  end

  defp broadcast_create({:ok, auction}) do
    broadcast({:created, auction})
    {:ok, auction}
  end

  defp broadcast_create({:error, changeset}), do: {:error, changeset}

  defp broadcast_update({:ok, auction}) do
    broadcast({:updated, auction})
    {:ok, auction}
  end

  defp broadcast_update({:error, changeset}), do: {:error, changeset}

  defp broadcast_delete({:ok, auction}) do
    broadcast({:deleted, auction})
    {:ok, auction}
  end

  defp broadcast_delete({:error, changeset}), do: {:error, changeset}

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking auction changes.
  """
  def change_auction(%Auction{} = auction, attrs \\ %{}) do
    Auction.changeset(auction, attrs)
  end
end
