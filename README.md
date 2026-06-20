# BidLive

System aukcyjny czasu rzeczywistego zbudowany z użyciem [Phoenix](https://www.phoenixframework.org/) i [LiveView](https://hexdocs.pm/phoenix_live_view/).

## Technologie

- **Backend**: Elixir / Phoenix 1.8
- **Baza danych**: SQLite (via `ecto_sqlite3`)
- **Frontend**: LiveView + Tailwind CSS + daisyUI
- **Autentykacja**: `phx.gen.auth` (Accounts)

## Wymagania

- Elixir ~> 1.15
- Node.js (dla assets)

## Uruchomienie

```bash
# Instalacja zależności i konfiguracja bazy
mix setup

# Uruchom serwer
mix phx.server
```

Odwiedź [localhost:4000](http://localhost:4000).

## Funkcjonalności

### Aukcje
- **Przeglądanie**: lista wszystkich aukcji z bieżącymi cenami
- **Szczegóły**: podgląd aukcji z opisem, cenami i obrazem
- **Tworzenie/Edycja/USuwanie**: dostępne tylko dla zalogowanych adminów (`/auctions/new`, `/auctions/:id/edit`)

### Licytowanie (na żywo)
- Licytowanie w czasie rzeczywistym przez Phoenix PubSub
- Walidacja: oferta > cena bieżąca i ≤ 2× ceny bieżącej
- Pole do wpisania własnej kwoty
- Szybkie przebicia: +1 zł, +5 zł, +10 zł, +50 zł, 2×
- Aktualizacja ceny na wszystkich otwartych kartach w czasie rzeczywistym

### Autentykacja
- Rejestracja/logowanie loginem magicznym (e-mail)
- Sesje użytkowników z `current_scope`
- Dostęp do aukcji publiczny, operacje CRUD wymagają logowania

## Architektura

- **Router** (`lib/bidlive_web/router.ex`): publiczny scope dla aukcji; autentykacja sprawdzana w LiveView przez `on_mount` hook
- **Context** (`lib/bidlive/auctions.ex`): operacje CRUD + `place_bid/2` z broadcastem PubSub pod topic `"auctions"`
- **Schema** (`lib/bidlive/auctions/auction.ex`): `bid_changeset/2` z walidacją przebicia
- **LiveView** (`lib/bidlive_web/live/auction_live/`):
  - `Index` – lista aukcji (strumieniowana)
  - `Show` – szczegóły z formularzem licytacji i nasłuchem PubSub
  - `Form` – CRUD z redirectem dla niezalogowanych
- **JSON Encoder** (`lib/bidlive/json/encoder.ex`): serializacja `Decimal` dla LiveView diff

## Użycie

```bash
# Uruchom testy
mix test

# Uruchom pełną kontrolę przed commitem (kompilacja, format, testy)
mix precommit
```

## Licencja

MIT
