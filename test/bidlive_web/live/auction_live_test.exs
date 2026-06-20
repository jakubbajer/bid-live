defmodule BidliveWeb.AuctionLiveTest do
  use BidliveWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bidlive.AuctionsFixtures

  @create_attrs %{
    description: "some description",
    title: "some title",
    starting_price: "120.5",
    end_time: "2026-06-19T20:28:00"
  }
  @update_attrs %{
    description: "some updated description",
    title: "some updated title",
    starting_price: "456.7",
    end_time: "2026-06-20T20:28:00"
  }
  @invalid_attrs %{
    description: nil,
    title: nil,
    starting_price: nil,
    end_time: nil
  }

  setup :register_and_log_in_user

  defp create_auction(%{scope: scope}) do
    auction = auction_fixture(scope)

    %{auction: auction}
  end

  describe "Index" do
    setup [:create_auction]

    test "lists all auctions", %{conn: conn, auction: auction} do
      {:ok, _index_live, html} = live(conn, ~p"/auctions")

      assert html =~ "Lista aukcji"
      assert html =~ auction.title
    end

    test "saves new auction", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/auctions")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "Nowa aukcja")
               |> render_click()
               |> follow_redirect(conn, ~p"/auctions/new")

      assert render(form_live) =~ "Nowa aukcja"

      assert form_live
             |> form("#auction-form", auction: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#auction-form", auction: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/auctions")

      html = render(index_live)
      assert html =~ "Aukcja utworzona pomyślnie"
      assert html =~ "some title"
    end

    test "updates auction in listing", %{conn: conn, auction: auction} do
      {:ok, index_live, _html} = live(conn, ~p"/auctions")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#auctions-#{auction.id} a", "Edytuj")
               |> render_click()
               |> follow_redirect(conn, ~p"/auctions/#{auction}/edit")

      assert render(form_live) =~ "Edycja aukcji"

      assert form_live
             |> form("#auction-form", auction: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#auction-form", auction: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/auctions")

      html = render(index_live)
      assert html =~ "Aukcja zaktualizowana pomyślnie"
      assert html =~ "some updated title"
    end

    test "deletes auction in listing", %{conn: conn, auction: auction} do
      {:ok, index_live, _html} = live(conn, ~p"/auctions")

      assert index_live |> element("#auctions-#{auction.id} a", "Usuń") |> render_click()
      refute has_element?(index_live, "#auctions-#{auction.id}")
    end
  end

  describe "Show" do
    setup [:create_auction]

    test "displays auction", %{conn: conn, auction: auction} do
      {:ok, _show_live, html} = live(conn, ~p"/auctions/#{auction}")

      assert html =~ auction.title
    end

    test "updates auction and returns to show", %{conn: conn, auction: auction} do
      {:ok, show_live, _html} = live(conn, ~p"/auctions/#{auction}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edytuj")
               |> render_click()
               |> follow_redirect(conn, ~p"/auctions/#{auction}/edit?return_to=show")

      assert render(form_live) =~ "Edycja aukcji"

      assert form_live
             |> form("#auction-form", auction: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#auction-form", auction: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/auctions/#{auction}")

      html = render(show_live)
      assert html =~ "Aukcja zaktualizowana pomyślnie"
      assert html =~ "some updated title"
    end
  end
end
