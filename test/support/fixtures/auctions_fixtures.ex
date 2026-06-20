defmodule Bidlive.AuctionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Bidlive.Auctions` context.
  """

  @doc """
  Generate a auction.
  """
  def auction_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        description: "some description",
        end_time: ~N[2026-06-19 20:28:00],
        image_url: "some image_url",
        starting_price: "120.5",
        title: "some title"
      })

    {:ok, auction} = Bidlive.Auctions.create_auction(scope, attrs)
    auction
  end
end
