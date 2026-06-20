# Instrukcja obsługi — BidLive

System aukcyjny czasu rzeczywistego. Składaj oferty, przeglądaj aukcje i obserwuj aktualizacje cen na żywo.

---

## 1. Strona główna

Po wejściu na **http://localhost:4000** widzisz stronę powitalną z przyciskiem "Przeglądaj aukcje".

![image-20260620233803405](/home/tram/.config/Typora/typora-user-images/image-20260620233803405.png)

Kliknij **"Przeglądaj aukcje"**, aby przejść do listy aukcji.

---

## 2. Lista aukcji

Na liście widzisz wszystkie dostępne aukcje wraz z ich tytułem, ceną i czasem zakończenia.

![image-20260620233820961](/home/tram/.config/Typora/typora-user-images/image-20260620233820961.png)

- Kliknij w **wiersz aukcji**, aby zobaczyć jej szczegóły.
- Jeśli jesteś zalogowany, zobaczysz przyciski **"Edytuj"** i **"Usuń"** po prawej stronie.

---

## 3. Rejestracja i logowanie

### Rejestracja nowego konta

1. Kliknij **"Rejestracja"** w prawym górnym rogu.
2. Wpisz swój adres e-mail i hasło.
3. Kliknij **"Zarejestruj się"**.
   ![image-20260620233846572](/home/tram/.config/Typora/typora-user-images/image-20260620233846572.png)

4. Na stronie pojawi się informacja o wysłaniu linku potwierdzającego.
5. Otwórz skrzynkę odbiorczą na **/dev/mailbox** (środowisko deweloperskie) i kliknij link potwierdzający.
   ![image-20260620233914243](/home/tram/.config/Typora/typora-user-images/image-20260620233914243.png)
   ![image-20260620233951002](/home/tram/.config/Typora/typora-user-images/image-20260620233951002.png)

### Logowanie

1. Kliknij **"Zaloguj się"** w prawym górnym rogu.
2. Wpisz swój adres e-mail.
3. Kliknij **"Wyślij link do logowania"**.
   ![image-20260620234032552](/home/tram/.config/Typora/typora-user-images/image-20260620234032552.png)

4. Otwórz skrzynkę odbiorczą i kliknij link.
5. Jesteś zalogowany — w prawym górnym rogu widzisz swój adres e-mail.
   ![image-20260620234125378](/home/tram/.config/Typora/typora-user-images/image-20260620234125378.png)

---

## 4. Tworzenie nowej aukcji (tylko dla zalogowanych)

1. Będąc na liście aukcji, kliknij **"Nowa aukcja"**.
2. Wypełnij formularz:

| Pole | Opis |
|------|------|
| **Tytuł** | Nazwa aukcji (np. "Rower górski Kross") |
| **Opis** | Szczegółowy opis przedmiotu |
| **Cena wywoławcza** | Cena początkowa (np. 100.00) |
| **Koniec** | Data i godzina zakończenia aukcji |
| **Obraz** | Kliknij "Wybierz plik" i wskaż zdjęcie (JPG, PNG do 10 MB) |

![image-20260620234206553](/home/tram/.config/Typora/typora-user-images/image-20260620234206553.png)

3. Kliknij **"Zapisz aukcję"**.

Po utworzeniu zostaniesz przeniesiony na listę aukcji z komunikatem "Aukcja utworzona pomyślnie".

---

## 5. Przeglądanie aukcji i licytowanie

1. Z listy aukcji kliknij w wybraną aukcję.
   ![image-20260620234227079](/home/tram/.config/Typora/typora-user-images/image-20260620234227079.png)

2. Widzisz:
   - **Aktualną ofertę** — najwyższą złożoną ofertę (duża, pogrubiona kwota)
   - Pole do wpisania własnej kwoty
   - Przyciski szybkiego przebicia
   - Opis przedmiotu, cenę wywoławczą, czas zakończenia, obrazek

### Licytowanie — krok po kroku

**Opcja A: Wpisz własną kwotę**
1. W polu "Twoja oferta" wpisz kwotę (np. 150.00).
2. Kwota musi być **wyższa niż aktualna cena** i **maksymalnie dwa razy większa**.
3. Kliknij **"Licytuj"**.

**Opcja B: Użyj szybkiego przebicia**
1. Kliknij jeden z przycisków: **+1 zł**, **+5 zł**, **+10 zł**, **+50 zł** lub **2x**.
2. Oferta zostanie złożona natychmiast.
   ![image-20260620234247870](/home/tram/.config/Typora/typora-user-images/image-20260620234247870.png)

### Co się dzieje po złożeniu oferty?

- Cena aktualizuje się **automatycznie** na Twoim ekranie.
- Jeśli inni użytkownicy też mają otwartą tę aukcję, **u nich także zaktualizuje się cena** — bez przeładowywania strony.
- Jeśli oferta jest za niska, zobaczysz komunikat błędu.

---

## 6. Edycja aukcji (tylko dla zalogowanych)

1. Na liście aukcji kliknij **"Edytuj"** przy wybranej aukcji.

![image-20260620234336108](/home/tram/.config/Typora/typora-user-images/image-20260620234336108.png)

2. Zmień wybrane pola w formularzu.
3. Aby wymienić obrazek, kliknij "Wybierz plik" i wskaż nowe zdjęcie.
4. Kliknij **"Zapisz aukcję"**.
   ![image-20260620234358884](/home/tram/.config/Typora/typora-user-images/image-20260620234358884.png)

---

## 7. Usuwanie aukcji (tylko dla zalogowanych)

1. Na liście aukcji kliknij **"Usuń"** przy wybranej aukcji.
2. Potwierdź operację w oknie dialogowym.

Aukcja znika z listy, a pozostali użytkownicy widzą to automatycznie.

---

## 8. Zmiana motywu (jasny/ciemny)

W prawym górnym rogu (na pasku nawigacyjnym) znajduje się przełącznik motywu.

- Kliknij ikonkę **słońca** — motyw jasny
- Kliknij ikonkę **księżyca** — motyw ciemny
- Kliknij ikonkę **komputera** — motyw systemowy (automatyczny)

---

## 9. Wylogowanie

Kliknij **"Wyloguj"** w prawym górnym rogu.

---

## 10. Rozwiązywanie problemów

| Problem | Rozwiązanie |
|---------|-------------|
| Nie mogę się zalogować | Sprawdź skrzynkę odbiorczą /dev/mailbox (środowisko deweloperskie). Link do logowania jest jednorazowy. |
| Nie widzę przycisków Edytuj/Usuń/Nowa aukcja | Musisz być zalogowany. Kliknij "Zaloguj się" i podaj swój e-mail. |
| Oferta odrzucona | Kwota musi być większa niż aktualna cena i nie większa niż 2× aktualnej ceny. |
| Obrazek nie wyświetla się | Sprawdź, czy plik ma dozwolony format (JPG, PNG, GIF, WebP) i rozmiar poniżej 10 MB. |
| Strona nie odpowiada | Spróbuj odświeżyć przeglądarkę (F5). |
