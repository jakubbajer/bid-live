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

      <.form for={@form} id="auction-form" phx-change="validate" phx-submit="save" multipart>
        <.input field={@form[:title]} type="text" label="Tytuł" />
        <.input field={@form[:description]} type="textarea" label="Opis" />
        <.input field={@form[:starting_price]} type="number" label="Cena wywoławcza" step="any" />
        <.input field={@form[:end_time]} type="datetime-local" label="Koniec" />
        <div class="space-y-2">
          <label class="block text-sm font-medium leading-6">Obraz</label>
          <%= if @auction.image_url && @live_action == :edit do %>
            <img src={@auction.image_url} class="h-32 w-auto rounded object-cover mb-2" />
          <% end %>
          <.live_file_input upload={@uploads.image} class="file-input file-input-bordered w-full" />
          <div :for={entry <- @uploads.image.entries} class="text-xs text-base-content/60">
            {entry.client_name} ({entry_size(entry)})
          </div>
          <div :for={err <- @uploads.image.errors} class="text-xs text-error">
            {error_to_string(err)}
          </div>
        </div>
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
        |> allow_upload(:image,
          accept: ~w(.jpg .jpeg .png .gif .webp),
          max_entries: 1,
          max_file_size: 10_000_000
        )
      else
        socket
        |> put_flash(:error, "Musisz się zalogować, aby uzyskać dostęp do tej strony.")
        |> redirect(to: ~p"/users/log-in")
      end

    {:ok, socket}
  end

  defp entry_size(entry) do
    size = entry.client_size

    if size > 1_000_000 do
      "#{Float.round(size / 1_000_000, 1)} MB"
    else
      "#{Float.round(size / 1_000, 0)} KB"
    end
  end

  defp error_to_string(:too_large), do: "Plik jest za duży (maks. 10 MB)"

  defp error_to_string(:not_accepted),
    do: "Niedozwolony typ pliku (dozwolone: .jpg, .png, .gif, .webp)"

  defp error_to_string(_), do: "Nieprawidłowy plik"

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
    auction_params = maybe_consume_image(socket, auction_params)

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
    auction_params = maybe_consume_image(socket, auction_params, false)

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

  defp maybe_consume_image(socket, params, keep_existing? \\ true) do
    uploaded_url =
      case consume_uploaded_entries(socket, :image, fn %{path: tmp_path}, entry ->
             upload_image(tmp_path, entry)
           end) do
        [url] -> url
        _ -> nil
      end

    cond do
      uploaded_url -> Map.put(params, "image_url", uploaded_url)
      keep_existing? -> params
      true -> params
    end
  end

  defp upload_image(tmp_path, entry) do
    ext = entry.client_type |> ext_from_mime()
    filename = "#{Ecto.UUID.generate()}.#{ext}"
    dest = Path.join(Application.app_dir(:bidlive, "priv/static/uploads"), filename)

    File.mkdir_p!(Path.dirname(dest))
    File.cp!(tmp_path, dest)

    "/uploads/#{filename}"
  end

  defp ext_from_mime("image/jpeg"), do: "jpg"
  defp ext_from_mime("image/png"), do: "png"
  defp ext_from_mime("image/gif"), do: "gif"
  defp ext_from_mime("image/webp"), do: "webp"
  defp ext_from_mime(_), do: "jpg"

  defp return_path("index", _auction), do: ~p"/auctions"
  defp return_path("show", auction), do: ~p"/auctions/#{auction}"
end
