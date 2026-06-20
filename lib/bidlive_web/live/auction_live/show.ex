defmodule BidliveWeb.AuctionLive.Show do
  use BidliveWeb, :live_view

  alias Bidlive.Auctions

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@auction.title}
        <:subtitle>
          Cena bieżąca: {@auction.current_price} zł &middot; Koniec: {@auction.end_time}
        </:subtitle>
        <:actions>
          <.button navigate={~p"/auctions"}>
            <.icon name="hero-arrow-left" /> Wstecz
          </.button>
          <.button
            :if={@current_scope}
            variant="primary"
            navigate={~p"/auctions/#{@auction}/edit?return_to=show"}
          >
            <.icon name="hero-pencil-square" /> Edytuj
          </.button>
        </:actions>
      </.header>

      <div class="mb-8 rounded-xl border-2 border-amber-400 bg-amber-50 p-6 dark:border-amber-600 dark:bg-amber-950">
        <div class="flex items-baseline gap-2 mb-4">
          <span class="text-sm font-medium text-amber-700 dark:text-amber-300">Aktualna oferta</span>
          <span class="text-4xl font-bold text-amber-900 dark:text-amber-100">
            {@auction.current_price} zł
          </span>
        </div>

        <.form for={@bid_form} id="bid-form" phx-submit="place_bid" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-amber-700 dark:text-amber-300 mb-1">
              Twoja oferta (do {@max_bid} zł)
            </label>
            <div class="flex flex-col sm:flex-row gap-2">
              <div class="relative flex-1">
                <span class="absolute left-3 top-1/2 -translate-y-1/2 text-sm font-semibold text-amber-600">zł</span>
                <.input
                  field={@bid_form[:amount]}
                  type="number"
                  step="0.01"
                  min={@min_bid}
                  max={@max_bid}
                  class="!pl-10 !text-lg !font-semibold"
                  placeholder={@max_bid}
                />
              </div>
              <.button
                phx-disable-with="Licytowanie..."
                class="btn btn-primary !text-lg px-8 w-full sm:w-auto"
              >
                Licytuj
              </.button>
            </div>
          </div>

          <div class="flex flex-wrap gap-2">
            <span class="text-xs text-amber-600 dark:text-amber-400 self-center mr-1">Szybka licytacja:</span>
            <.button
              :for={increment <- @quick_increments}
              phx-click={JS.push("quick_bid", value: %{amount: increment})}
            >
              +{increment} zł
            </.button>
            <.button phx-click={JS.push("quick_bid", value: %{amount: @max_bid})}>
              2x ({@max_bid} zł)
            </.button>
          </div>
        </.form>
      </div>

      <.list>
        <:item title="Opis">{@auction.description}</:item>
        <:item title="Cena wywoławcza">{@auction.starting_price} zł</:item>
        <:item title="Cena bieżąca">{@auction.current_price} zł</:item>
        <:item title="Koniec">{@auction.end_time}</:item>
        <:item title="Obraz">
          <%= if @auction.image_url do %>
            <img src={@auction.image_url} alt={@auction.title} class="max-w-md rounded" />
          <% end %>
        </:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Auctions.subscribe()
    end

    auction = Auctions.get_auction!(id)

    {:ok,
     socket
     |> assign(:page_title, "Szczegóły aukcji")
     |> assign(:auction, auction)
     |> assign_helpers(auction)
     |> assign_bid_form(auction)}
  end

  @impl true
  def handle_event("place_bid", %{"bid" => %{"amount" => amount_str}}, socket) do
    place_bid(socket, Decimal.cast(amount_str))
  end

  def handle_event("quick_bid", %{"amount" => amount_str}, socket) do
    place_bid(socket, Decimal.cast(amount_str))
  end

  @impl true
  def handle_info(
        {:updated, %Bidlive.Auctions.Auction{id: id} = auction},
        %{assigns: %{auction: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> assign(:auction, auction)
     |> assign_helpers(auction)
     |> assign_bid_form(auction)}
  end

  def handle_info(
        {:deleted, %Bidlive.Auctions.Auction{id: id}},
        %{assigns: %{auction: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "Ta aukcja została usunięta.")
     |> push_navigate(to: ~p"/auctions")}
  end

  def handle_info({type, %Bidlive.Auctions.Auction{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end

  defp place_bid(socket, {:ok, amount}) do
    auction = socket.assigns.auction

    case Auctions.place_bid(auction, amount) do
      {:ok, updated_auction} ->
        {:noreply,
         socket
         |> assign(:auction, updated_auction)
         |> assign_helpers(updated_auction)
         |> assign_bid_form(updated_auction)
         |> put_flash(:info, "Oferta złożona pomyślnie!")}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(:bid_form, to_form(changeset, as: :bid))}
    end
  end

  defp place_bid(socket, :error) do
    {:noreply, put_flash(socket, :error, "Nieprawidłowa kwota oferty")}
  end

  defp assign_bid_form(socket, auction) do
    assign(socket, :bid_form, to_form(%{"amount" => increment(auction.current_price)}, as: :bid))
  end

  defp assign_helpers(socket, auction) do
    socket
    |> assign(:min_bid, Decimal.add(auction.current_price, Decimal.new("0.01")))
    |> assign(:max_bid, Decimal.mult(auction.current_price, 2))
    |> assign(:quick_increments, [
      Decimal.add(auction.current_price, Decimal.new("1")),
      Decimal.add(auction.current_price, Decimal.new("5")),
      Decimal.add(auction.current_price, Decimal.new("10")),
      Decimal.add(auction.current_price, Decimal.new("50"))
    ])
  end

  defp increment(price) when is_struct(price, Decimal) do
    Decimal.add(price, Decimal.new("1.00"))
  end
end
