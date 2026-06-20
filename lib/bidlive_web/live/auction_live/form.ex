defmodule BidliveWeb.AuctionLive.Form do
  use BidliveWeb, :live_view

  alias Bidlive.Auctions
  alias Bidlive.Auctions.Auction

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Użyj tego formularza do zarządzania aukcjami.</:subtitle>
      </.header>

      <.form for={@form} id="auction-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:title]} type="text" label="Tytuł" />
        <.input field={@form[:description]} type="textarea" label="Opis" />
        <.input field={@form[:starting_price]} type="number" label="Cena wywoławcza" step="any" />
        <.input field={@form[:end_time]} type="datetime-local" label="Koniec" />
        <.input field={@form[:image_url]} type="text" label="URL obrazu" />
        <footer>
          <.button phx-disable-with="Zapisywanie..." variant="primary">Zapisz aukcję</.button>
          <.button navigate={return_path(@return_to, @auction)}>Anuluj</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    socket =
      if socket.assigns.current_scope do
        socket
        |> assign(:return_to, return_to(params["return_to"]))
        |> apply_action(socket.assigns.live_action, params)
      else
        socket
        |> put_flash(:error, "Musisz się zalogować, aby uzyskać dostęp do tej strony.")
        |> redirect(to: ~p"/users/log-in")
      end

    {:ok, socket}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    auction = Auctions.get_auction!(id)

    socket
    |> assign(:page_title, "Edycja aukcji")
    |> assign(:auction, auction)
    |> assign(:form, to_form(Auctions.change_auction(auction)))
  end

  defp apply_action(socket, :new, _params) do
    auction = %Auction{}

    socket
    |> assign(:page_title, "Nowa aukcja")
    |> assign(:auction, auction)
    |> assign(:form, to_form(Auctions.change_auction(auction)))
  end

  @impl true
  def handle_event("validate", %{"auction" => auction_params}, socket) do
    changeset = Auctions.change_auction(socket.assigns.auction, auction_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"auction" => auction_params}, socket) do
    save_auction(socket, socket.assigns.live_action, auction_params)
  end

  defp save_auction(socket, :edit, auction_params) do
    case Auctions.update_auction(
           socket.assigns.current_scope,
           socket.assigns.auction,
           auction_params
         ) do
      {:ok, auction} ->
        {:noreply,
         socket
         |> put_flash(:info, "Aukcja zaktualizowana pomyślnie")
         |> push_navigate(to: return_path(socket.assigns.return_to, auction))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_auction(socket, :new, auction_params) do
    case Auctions.create_auction(socket.assigns.current_scope, auction_params) do
      {:ok, auction} ->
        {:noreply,
         socket
         |> put_flash(:info, "Aukcja utworzona pomyślnie")
         |> push_navigate(to: return_path(socket.assigns.return_to, auction))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _auction), do: ~p"/auctions"
  defp return_path("show", auction), do: ~p"/auctions/#{auction}"
end
