# Umschalten von der alten Webseite auf die neue App (ice-cross.at)

Stand der Prüfung: 28.11.2026. Reihenfolge einhalten.

## Vorher
- [ ] Aktueller Stand läuft auf devel.ice-cross.at (`bin/deploy-sirius`) und ist durchgeklickt.
- [ ] Datenschutz vom Verband geprüft; danach im Team-Bereich unter "Seiten" die Zeile "Entwurf: …" (DE und EN) entfernen.
- [ ] Impressum geprüft (Namen, Funktionen, Vereinszweck, Telefonnummer).
- [ ] Bestätigt: Hosting und E-Mail liegen bei IONOS SE, Auftragsverarbeitungsvertrag abgeschlossen.
- [ ] Bildrechte der Fotos auf Start- und Umbau-Seite geklärt.
- [ ] Event 2027: ATSX-Lizenzpflicht, Besucher-Zeiten, Trainingspreise der Rennwoche ergänzt (falls gültig).
- [ ] Alte WordPress-Seite komplett gesichert (Dateien und Datenbank). Sie enthält vermutlich eingeschleuste Casino-Werbung: Zugänge ändern.
- [ ] Server entschieden. Docker auf sirius (OpenVZ) ist wiederholt hängen geblieben.
- [ ] Regelmäßige Datensicherung eingerichtet (bisher nur vor jedem Deploy).
- [ ] Einen Tag vorher bei IONOS die TTL der DNS-Einträge auf 60 Sekunden stellen.

## Umschalten
1. In `~/kos-events/.env` auf dem Server:

       APP_HOST=ice-cross.at
       APP_EXTRA_HOSTS=www.ice-cross.at,devel.ice-cross.at

   dann `docker compose up -d`.
2. nginx-Eintrag aktivieren:

       scp deploy/nginx/ice-cross.at.conf sirius:/tmp/
       ssh -t sirius 'sudo cp /tmp/ice-cross.at.conf /etc/nginx/sites-available/ && sudo ln -s /etc/nginx/sites-available/ice-cross.at.conf /etc/nginx/sites-enabled/ && sudo nginx -t && sudo systemctl reload nginx'

3. DNS bei IONOS ändern:

   | Name | Typ | alt | neu |
   |---|---|---|---|
   | ice-cross.at | A | 217.160.0.227 | 185.164.5.30 |
   | www | A | 217.160.0.227 | 185.164.5.30 |
   | ice-cross.at, www | AAAA | 2001:8d8:100f:f000::282 | **löschen** |
   | ice-cross.at | MX | mx00/mx01.ionos.de | **nicht ändern** (sonst fällt E-Mail aus) |

4. Zertifikat, sobald `dig +short ice-cross.at` die neue Adresse zeigt:

       ssh -t sirius 'sudo certbot --nginx -d ice-cross.at -d www.ice-cross.at --redirect'

## Prüfen
- [ ] https://ice-cross.at, `/impressum`, `/datenschutz`, `/cookies`
- [ ] Alte Adressen: `/winterleiten_27`, `/prices`, `/art-hotel-spielberg`, `/en/home`
- [ ] Unbekannte Adresse zeigt die Umbau-Seite
- [ ] Login, Chat (Nachricht erscheint live auf zweitem Gerät), Einladungs-Mail kommt an
- [ ] E-Mail an info@ice-cross.at kommt weiterhin an

## Zurück
DNS-Einträge auf die alten Werte setzen. Die alte Seite deshalb mindestens zwei Wochen weiterlaufen lassen.
