# Deployment auf sirius

nginx (Host, Port 80/443) -> `127.0.0.1:3012` -> Container `web` (Thruster/Puma, Solid Queue in Puma) -> Container `db` (Postgres 16).
Gebaut wird auf dem Server, Dateien liegen in `~/kos-events` (`.env` mit Secrets, nicht im Git).

## Deploy
    bin/deploy-sirius      # deployt HEAD, baut, startet, prüft /up

## Einmalig / nach DNS
1. DNS: A-Record `devel.ice-cross.at` -> `185.164.5.30`
2. Zertifikat: `sudo certbot --nginx -d devel.ice-cross.at`
3. Erster Staff-Zugang:
   `ssh sirius 'cd ~/kos-events && docker compose exec web bin/rails runner "User.create!(email_address: %q(...), password: %q(...), role: :staff)"'`
4. Mail: `SMTP_ADDRESS/PORT/USERNAME/PASSWORD` in `~/kos-events/.env`, dann `docker compose up -d`.
   Ohne SMTP werden keine Mails (Einladungen, Passwort-Reset) verschickt.
5. Inhalte: `docker compose exec web bin/rails db:seed` (legt nur Fehlendes an).

## Nützlich
    ssh sirius 'cd ~/kos-events && docker compose logs -f web'
    ssh sirius 'cd ~/kos-events && docker compose exec web bin/rails console'
    ssh sirius 'cd ~/kos-events && docker compose exec db pg_dump -U kos_events kos_events_production' > backup.sql
