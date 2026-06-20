# Dokumentacja techniczna — BidLive

## 1. Opis projektu

BidLive to system aukcyjny czasu rzeczywistego zbudowany w oparciu o framework **Phoenix 1.8** z **LiveView**. Umożliwia przeglądanie aukcji, składanie ofert i obserwowanie aktualizacji cen na żywo bez przeładowywania strony. Panel administracyjny (CRUD aukcji) dostępny jest dla zalogowanych użytkowników.

## 2. Architektura

### 2.1 Warstwy aplikacji

1. Warstwa prezentacji (LiveView + HEEx + Tailwind)
2. Warstwa routera (BidliveWeb.Router)
3. Warstwa kontekstu (Bidlive.Auctions)
4. Warstwa schematu (Bidlive.Auctions.Auction)
5. Baza Danych (SQLite przy użyciu Ecto)

### 2.2 Komunikacja w czasie rzeczywistym

Aktualizacje aukcji (tworzenie, edycja, licytacja, usunięcie) są rozgłaszane przez **Phoenix PubSub** pod topic `"auctions"`. Każdy LiveView subskrybuje ten topic w momencie montowania i aktualizuje swój stan po otrzymaniu broadcastu.

## 3. Baza danych

### 3.1 Tabela `users`

Wygenerowana przez `mix phx.gen.auth`. Zawiera pola:

| Pole           | Typ         | Opis                    |
|----------------|-------------|-------------------------|
| id             | integer     | Klucz główny            |
| email          | string      | Adres e-mail (unikalny) |
| hashed_password| string      | Hash bcrypt             |
| confirmed_at   | utc_datetime| Potwierdzenie konta     |
| inserted_at    | utc_datetime| Znacznik czasowy        |
| updated_at     | utc_datetime| Znacznik czasowy        |

### 3.2 Tabela `auctions`

| Pole           | Typ            | Opis                             |
|----------------|----------------|----------------------------------|
| id             | integer        | Klucz główny                     |
| title          | string         | Tytuł aukcji                     |
| description    | text           | Opis aukcji                      |
| starting_price | decimal        | Cena wywoławcza                  |
| current_price  | decimal        | Aktualna cena (domyślnie = starting_price) |
| end_time       | naive_datetime | Czas zakończenia aukcji          |
| image_url      | string         | Ścieżka do obrazka lub URL       |
| user_id        | integer (FK)   | Referencja do `users` (admin)    |
| inserted_at    | utc_datetime   | Znacznik czasowy                 |
| updated_at     | utc_datetime   | Znacznik czasowy                 |

Relacja: `users` 1:N `auctions` (admin tworzy wiele aukcji).

## 4. Kluczowe funkcjonalności

### 4.1 Autentykacja i autoryzacja

- System logowania oparty na **magic link** (e-mail z linkiem jednorazowym)
- `on_mount` hook `:assign_current_scope` wczyta aktualnego użytkownika do socket assigns (`@current_scope`)
- Trzy pipeline'y w routerze:
  - `:browser` — publiczny, wczytuje `current_scope` jeśli token w sesji
  - `:redirect_if_user_is_authenticated` — dla stron logowania/rejestracji
  - `:require_authenticated_user` — dla ustawień konta
- CRUD aukcji sprawdza `@current_scope` w LiveView (warunkowe renderowanie przycisków, redirect w form mount)

### 4.2 Licytowanie w czasie rzeczywistym

- Funkcja `place_bid/2` w kontekście `Auctions`:
  1. Wywołuje `bid_changeset/2` na schema Auction
  2. Waliduje: oferta > `current_price` i ≤ `current_price * 2`
  3. Zapisuje do bazy
  4. Broadcastuje `{:updated, auction}` przez PubSub
- Show LiveView nasłuchuje `{:updated, auction}` i aktualizuje:
  - cenę bieżącą
  - kwoty szybkich przebić
  - min/max dla formularza
- Formularz licytacji:
  - Pole number z walidacją min/max, krok 0.01
  - Szybkie przebicia: +1, +5, +10, +50 złotych oraz 2× ceny bieżącej
  - Komunikaty błędów (flash) dla nieprawidłowych kwot

### 4.3 Upload obrazków

- Pliki przesyłane przez `<.live_file_input>` (LiveView upload)
- Akceptowane formaty: `.jpg`, `.jpeg`, `.png`, `.gif`, `.webp`
- Maksymalny rozmiar: 10 MB
- Zapis do `priv/static/uploads/` z nazwą UUID
- Serwowane przez Phoenix Plug.Static z `static_paths` rozszerzonym o `uploads`
- Walidacja typu i rozmiaru po stronie klienta

### 4.4 LiveView streams

- Lista aukcji używa `stream/3` z `phx-update="stream"` dla wydajnego zarządzania kolekcją
- Po każdym broadcastcie lista jest odświeżana (`stream/4` z `reset: true`)

## 7. Uruchomienie lokalne

Wymagania: Elixir ~> 1.15, Node.js (dla assetów)

```bash
# Klonowanie
git clone git@github.com:jakubbajer/bid-live.git
cd bid-live

# Instalacja zależności i konfiguracja bazy
mix setup

# Uruchomienie serwera
mix phx.server
# → http://localhost:4000

# Testy
mix test

# Pełna kontrola (kompilacja, format, testy)
mix precommit
```

Aby utworzyć konto administratora:
1. Wejdź na `/users/register`
2. Zarejestruj się adresem e-mail
3. Otwórz `/dev/mailbox` i kliknij link potwierdzający
4. Po zalogowaniu dostępne będą funkcje CRUD aukcji

## 8. Testy

Testy jednostkowe i integracyjne w `test/`:
- `test/bidlive_web/live/auction_live_test.exs` — testy LiveView (lista, tworzenie, edycja, usuwanie, podgląd aukcji)
- `test/bidlive/auctions_test.exs` — testy kontekstu (CRUD, walidacje)
- `test/bidlive_web/controllers/` — testy kontrolerów (strona główna, autentykacja)

Uruchomienie: `mix test` (109 testów).
