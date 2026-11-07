# Analyse altes kos (Stand 2026-11-07)

Altes Repo: `~/devel/kos` (Rails 6.1.4, Ruby 3.0, Webpacker, Turbolinks, SQLite dev / PG prod, Capistrano).
Umfang: 16 Models, 13 Controller, ~2.500 Zeilen Ruby, 20 Migrationen, keine nennenswerten Tests.

## Fachdomäne
Event-Management für Rennen mit Heats (Gates, Zeitfahren/Time Trials, Finals, LCQ/Last Chance Qualifier), Anbindung an ATSX (Rankings/Lizenzen) und Ticketteer (Zahlungen).

| Altes Model | Bedeutung | Neu |
|---|---|---|
| User | Admin/Veranstalter-Login (has_secure_password, `admin`, `accesslevel`) | **Ersetzen** durch Rails-8-Auth + Rollen (staff, rider) |
| Rider | Fahrerstamm (Name, Nation, Geburtstag, E-Mail, ATSX-Punkte, Lizenz) | **Übernehmen**, bekommt Login = Fahrerlager (Rider Hub) |
| Event | Veranstaltung, Live-Pointer (current/previous heat, tt pointer) | Übernehmen, Pointer als Integer-FKs statt Strings |
| Category | Klasse pro Event, Heat-Konfiguration (heatsize, lcq, small_final, …) | Übernehmen |
| Eventrider | Anmeldung Fahrer ↔ Event/Kategorie (Startnr., Zeiten, Waiver, Check-in, Zahlungen) | Übernehmen (zentral für Fahrerlager (Rider Hub): "meine Anmeldungen") |
| Heat / Heatrider | Heats und Platzierungen | Übernehmen, Logik (Heat 229 Zeilen, Eventrider 300) portieren und mit Tests absichern |
| Rundown / RundownGroup / RundownItem | Ablaufplan | Übernehmen |
| Teamevent / Team / Teamrider / Teamheat | Team-Wettbewerb | Prüfen, ob noch gebraucht |
| Series | Serienzuordnung | Übernehmen |

## Logik, die portiert werden muss (Kern des Wertes)
- `Heat`: Heats erzeugen, Platzierungen, Qualifikation für Folgerunde, LCQ, small/big final
- `Eventrider`: Zeitmessung (Time Trials), Rankings, Platzierung in Finals, Punktevergabe
- `Event#points_for_rank_250`, `assign_points`, `heatroster`, `create_default_categories`
- `Category#calculate_rounds`, `import_csv`
- Live-Ansicht / Livescreen / Heat-Pointer (`events#live`, `heats#current`, RSS)
- PDF-/XLS-Export (prawn-rails)

## Integrationen
- **ATSX** (`concerns/atsx_communication.rb`): Lineup importieren, Ergebnisse hochladen
- **Ticketteer** (`concerns/payment_sync.rb`): Zahlungen synchronisieren
- **Slack-Notifier**: Benachrichtigung bei Sync

## Probleme im Altbestand (nicht mitnehmen)
1. **Keine Zugriffskontrolle:** `require_login` in `ApplicationController` ist auskommentiert. Alle Admin-Aktionen sind ohne Login erreichbar.
2. **Zugangsdaten im Code:** Ticketteer-Login und Slack-Webhook stehen im Klartext in `payment_sync.rb`. Die Zugangsdaten müssen rotiert werden und gehören in Rails Credentials.
3. **GET für schreibende Aktionen** (`check_in_all`, `delete_all_times`, `assign_random_times`, …) → neu als POST/PATCH/DELETE.
4. Fat Controller: `EventsController` hat 560 Zeilen und ~36 Actions → in kleine Controller/Service-Objekte aufteilen.
5. Fehlende Foreign Keys und Indizes bei mehreren Tabellen, Pointer als Strings.
6. Frontend: 12 Webpacker-Packs, jQuery-lastige `.js.erb`-Views → Hotwire (Turbo Streams für Live/Heat-Updates).

## Assets zum Übernehmen
Schriften (Exo 2, Lato, Bebas Neue) und Logos aus `app/assets`. Das Design wird neu gebaut.

## Vorgeschlagene Reihenfolge im neuen Projekt
1. Auth (Rails 8 Generator) + Rollen: `staff`, `rider`; Rider ↔ User verknüpfen
2. Datenmodell: Rider, Event, Category, Eventrider, Series (mit FKs/Indizes)
3. **Fahrerlager (Rider Hub)** (Login für Fahrer): Profil, eigene Anmeldungen, Zeiten/Ergebnisse, Check-in/Waiver
4. Staff-Backend: Events, Kategorien, Anmeldungen, Rundown
5. Heats/Zeitfahren/Finals-Logik portieren (mit Tests) + Live-Ansicht per Turbo Streams
6. Öffentlicher Bereich ohne Login: Eventübersicht, Ergebnisse und Fahrerprofile (Live-Ansicht ebenfalls öffentlich)
   - Öffentlich sichtbar nur Name/Nickname, Nation, Team und Ergebnisse. Nie E-Mail oder Geburtstag, höchstens das Geburtsjahr.
   - Entschieden: Profile sind nur öffentlich, wenn der Fahrer im Fahrerlager (Rider Hub) zustimmt (Opt-in, Zeitpunkt wird gespeichert, jederzeit widerrufbar). Umgesetzt als `riders.public_profile`.
   - Ergebnisse: Name und Nation sind immer öffentlich, auch ohne Profil-Zustimmung (werden für Ergebnisse gebraucht). Ausnahme unter 18: ohne Zustimmung nur Initialen, keine Nation. Ohne bekannten Geburtstag gilt ein Fahrer als minderjährig. Umgesetzt in `Rider#public_name` / `#public_nation`.
   - Offen: Zustimmung bei Minderjährigen müsste eigentlich von den Erziehungsberechtigten kommen.
7. Integrationen ATSX/Ticketteer als Jobs (Solid Queue)
8. Datenimport aus der Produktion, Umschalttermin

## Offene Fragen
- Sollen Fahrer sich selbst registrieren dürfen oder nur per Einladung vom Team?
- Team-Wettbewerb (Teamevent/Teamheat) weiterhin nötig?
- ATSX und Ticketteer: beide beibehalten?
- Welche Sprache: Deutsch, Englisch oder beides?
