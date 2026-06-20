defmodule Bidlive.AuctionsTest do
  use Bidlive.DataCase

  alias Bidlive.Auctions

  describe "auctions" do
    alias Bidlive.Auctions.Auction

    import Bidlive.AccountsFixtures, only: [user_scope_fixture: 0]
    import Bidlive.AuctionsFixtures

    @invalid_attrs %{
      description: nil,
      title: nil,
      starting_price: nil,
      end_time: nil,
      image_url: nil
    }

    test "list_auctions/0 returns all auctions" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      auction = auction_fixture(scope)
      other_auction = auction_fixture(other_scope)

      assert Auctions.list_auctions() == [auction, other_auction] ||
               Auctions.list_auctions() == [other_auction, auction]
    end

    test "get_auction!/1 returns the auction with given id" do
      scope = user_scope_fixture()
      auction = auction_fixture(scope)
      assert Auctions.get_auction!(auction.id) == auction
    end

    test "create_auction/2 with valid data creates a auction" do
      valid_attrs = %{
        description: "some description",
        title: "some title",
        starting_price: "120.5",
        end_time: ~N[2026-06-19 20:28:00],
        image_url: "some image_url"
      }

      scope = user_scope_fixture()

      assert {:ok, %Auction{} = auction} = Auctions.create_auction(scope, valid_attrs)
      assert auction.description == "some description"
      assert auction.title == "some title"
      assert auction.starting_price == Decimal.new("120.5")
      assert auction.current_price == Decimal.new("120.5")
      assert auction.end_time == ~N[2026-06-19 20:28:00]
      assert auction.image_url == "some image_url"
      assert auction.user_id == scope.user.id
    end

    test "create_auction/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Auctions.create_auction(scope, @invalid_attrs)
    end

    test "update_auction/3 with valid data updates the auction" do
      scope = user_scope_fixture()
      auction = auction_fixture(scope)

      update_attrs = %{
        description: "some updated description",
        title: "some updated title",
        starting_price: "456.7",
        end_time: ~N[2026-06-20 20:28:00],
        image_url: "some updated image_url"
      }

      assert {:ok, %Auction{} = auction} = Auctions.update_auction(scope, auction, update_attrs)
      assert auction.description == "some updated description"
      assert auction.title == "some updated title"
      assert auction.starting_price == Decimal.new("456.7")
      assert auction.end_time == ~N[2026-06-20 20:28:00]
      assert auction.image_url == "some updated image_url"
    end

    test "update_auction/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      auction = auction_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Auctions.update_auction(scope, auction, @invalid_attrs)
      assert auction == Auctions.get_auction!(auction.id)
    end

    test "delete_auction/2 deletes the auction" do
      scope = user_scope_fixture()
      auction = auction_fixture(scope)
      assert {:ok, %Auction{}} = Auctions.delete_auction(scope, auction)
      assert_raise Ecto.NoResultsError, fn -> Auctions.get_auction!(auction.id) end
    end

    test "change_auction/1 returns a auction changeset" do
      scope = user_scope_fixture()
      auction = auction_fixture(scope)
      assert %Ecto.Changeset{} = Auctions.change_auction(auction)
    end

    test "place_bid/2 updates current_price" do
      scope = user_scope_fixture()
      auction = auction_fixture(scope)
      assert {:ok, %Auction{} = updated} = Auctions.place_bid(auction, Decimal.new("150.00"))
      assert updated.current_price == Decimal.new("150.00")
    end
  end
end
