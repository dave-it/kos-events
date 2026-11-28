# Deployment auf sirius

nginx (Host, Port 80/443) -> `127.0.0.1:3012` -> Container `web` (Thruster/Puma, Solid Queue in Puma) -> Container `db` (Postgres 16).
Gebaut wird in GitHub Actions. Auf dem Server liegen in `~/kos-events` nur `docker-compose.yml`
und `.env` (Secrets, nicht im Git).

## Deploy
1. `git push` auf `main`. GitHub Actions (Workflow "CI") prüft und baut das Image nach
   `ghcr.io/dave-it/kos-events:<commit>`.
2. `bin/deploy-sirius` wartet auf das Image, probiert den Containerstart, sichert die Datenbank
   (`~/kos-events/backups/`), startet und prüft `/up`.

Zurück auf einen älteren Stand: `git checkout <commit> && bin/deploy-sirius`
(Datenbank-Migrationen werden dabei nicht zurückgenommen).

### Einmalig: Zugriff von sirius auf das Image
Auf GitHub unter Settings > Developer settings > Personal access tokens > Tokens (classic) ein
Token **nur** mit `read:packages` erstellen. Dann auf dem Server (Token bei "Password" einfügen):

    ssh sirius
    docker login ghcr.io -u dave-it

## Einmalig / nach DNS
1. DNS: A-Record `devel.ice-cross.at` -> `185.164.5.30`
2. Zertifikat: `sudo certbot --nginx -d devel.ice-cross.at`
3. Erster Staff-Zugang:
   `ssh sirius 'cd ~/kos-events && docker compose exec web bin/rails runner "User.create!(email_address: %q(...), password: %q(...), role: :staff)"'`
4. Mail: `SMTP_ADDRESS/PORT/USERNAME/PASSWORD` in `~/kos-events/.env`, dann `docker compose up -d`.
   Ohne SMTP_PASSWORD werden keine Mails (Einladungen, Passwort-Reset) verschickt.
5. Inhalte: `docker compose exec web bin/rails db:seed` (legt nur Fehlendes an).

## Nützlich
    ssh sirius 'cd ~/kos-events && docker compose logs -f web'
    ssh sirius 'cd ~/kos-events && docker compose exec web bin/rails console'
    ssh sirius 'cd ~/kos-events && docker compose exec db pg_dump -U kos_events kos_events_production' > backup.sql

## Live-Chat (Action Cable)
Der nginx-Eintrag braucht einen eigenen Block für die WebSocket-Verbindung, sonst kommen
neue Nachrichten erst beim Neuladen an:

    location /cable {
        proxy_pass http://127.0.0.1:3012;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 3600;
    }

Nach dem ersten Deploy mit Chat einmal `bin/rails db:seed` ausführen (legt die Start-Kanäle an).
