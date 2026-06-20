defmodule BidliveWeb.AuctionLive.Index do
  use BidliveWeb, :live_view

  alias Bidlive.Auctions

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Lista aukcji
        <:actions>
          <.button :if={@current_scope} variant="primary" navigate={~p"/auctions/new"}>
            <.icon name="hero-plus" /> Nowa aukcja
          </.button>
        </:actions>
      </.header>

      <.table
        id="auctions"
        rows={@streams.auctions}
        row_click={fn {_id, auction} -> JS.navigate(~p"/auctions/#{auction}") end}
      >
        <:col :let={{_id, auction}} label="Tytuł">{auction.title}</:col>
        <:col :let={{_id, auction}} label="Cena bieżąca">{auction.current_price} zł</:col>
        <:col :let={{_id, auction}} label="Koniec">{auction.end_time}</:col>
        <:action :let={{_id, auction}}>
          <div class="sr-only">
            <.link navigate={~p"/auctions/#{auction}"}>Pokaż</.link>
          </div>
        </:action>
        <:action :let={{_id, auction}}>
          <.button :if={@current_scope} navigate={~p"/auctions/#{auction}/edit"}>
            Edytuj
          </.button>
        </:action>
        <:action :let={{id, auction}}>
          <.link
            :if={@current_scope}
            phx-click={JS.push("delete", value: %{id: auction.id}) |> hide("##{id}")}
            data-confirm="Jesteś pewien?"
            class="btn btn-primary btn-soft px-2 py-1 text-sm cursor-pointer"
          >
            Usuń
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Auctions.subscribe()
    end

    {:ok,
     socket
     |> assign(:page_title, "Lista aukcji")
     |> stream(:auctions, list_auctions())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    auction = Auctions.get_auction!(id)
    {:ok, _} = Auctions.delete_auction(socket.assigns.current_scope, auction)

    {:noreply, stream_delete(socket, :auctions, auction)}
  end

  @impl true
  def handle_info({type, %Bidlive.Auctions.Auction{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :auctions, list_auctions(), reset: true)}
  end

  defp list_auctions do
    Auctions.list_auctions()
  end
end
