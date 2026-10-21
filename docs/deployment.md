# Homeserver deployment

This repository deploys D&D Tools as a LAN-only service at `https://dnd-tools.home.arpa`.
It owns the Compose application runtime and application commands. The homelab owns Docker
installation, Caddy, private DNS, certificates, firewall policy, root-owned secret files,
and backups.

Follow the [ATLAS Compose example](https://github.com/segfaultsoftware/ATLAS/blob/main/compose.yaml)
and the [homelab application guide](https://github.com/segfaultsoftware/homelab-manual/blob/main/docs/apps/adding-an-app.md)
for the host-managed parts.

## Before first deployment

On the homeserver, create a dedicated checkout at `/srv/apps/dnd-tools` and run every
repository command from that directory. Confirm Docker Compose and the shared Caddy network
exist without creating or exposing anything:

```bash
docker compose version
docker network inspect web
df -h /srv/apps
```

Create `storage/` for Active Storage uploads. It is bind-mounted into the web container.
Ensure the checkout owner can write it and that its filesystem has enough capacity. SQLite
database files and application uploads both live under `storage/`, so they survive ordinary
container and image replacement.

As root, create the external secret files (do not paste their values into shell history or
this repository):

```bash
sudo install -d -m 0700 /srv/platform/secrets/dnd-tools
sudo install -m 0400 -o root -g root /dev/null /srv/platform/secrets/dnd-tools/rails_master_key
sudo stat -c '%a %U %G %n' /srv/platform/secrets/dnd-tools/rails_master_key
```

Populate those files through the approved secret-management procedure, then copy
`.env.deploy.example` to `.env.deploy`. Keep `.env.deploy` ignored and record only the secret
*path* there. The Compose validator requires the file to be readable by Docker; it never
prints its value.

```bash
cp .env.deploy.example .env.deploy
sudo bin/deploy validate
```

`validate` first runs the repository's non-destructive topology check, then asks Docker
Compose to render the configuration. It does not start containers.

## Deploy and operate

```bash
sudo bin/deploy deploy       # first deploy; builds, waits for health, and runs Rails db:prepare
sudo bin/deploy update       # ordinary update after pulling the desired revision
sudo bin/deploy restart
sudo bin/deploy status
sudo bin/deploy logs 200     # bounded logs; use another limit if needed
sudo bin/deploy health       # Compose status and an in-container /up request
```

The web health check sends `Host: dnd-tools.home.arpa` to `/up`. The web container is the
only service attached to the external `web` network, using the stable alias `dnd-tools-web`.
It also joins the application-private internal network and publishes no host port.

The application boot command reads `RAILS_MASTER_KEY` from its mounted secret file and stops
with a path-only error if it is missing or empty. SQLite needs no database credential. Secrets
are absent from tracked configuration and image layers; do not use diagnostics or logs to copy
their values.

## Host-owned routing and LAN verification

An operator must make these manual host changes; do not place them in this repository:

1. Add the Caddy route `dnd-tools.home.arpa` with `tls internal` and
   `reverse_proxy dnd-tools-web:80`, then validate and reload Caddy according to the homelab
   manual.
2. Add private LAN DNS for `dnd-tools.home.arpa`; do not create a public DNS record.
3. From a LAN client that trusts the homelab CA, verify
   `https://dnd-tools.home.arpa/up` returns success with a trusted certificate and that
   normal application URLs redirect HTTP requests to HTTPS.
4. Confirm firewall policy and router configuration permit no public inbound route or
   port-forwarding rule for this application. Docker Compose must show no published ports for
   either service.

These checks confirm the service is LAN-only. Caddy certificate lifecycle, private DNS,
firewall configuration, and Docker provisioning remain host responsibilities.

## Backup and recovery prerequisite

SQLite database files live alongside uploads in the backed-up `/srv/apps/dnd-tools/storage`
tree. Before using this service for live production data, the homelab backup workflow must
include those files, document a restore procedure, and prove it with a restore test as required
by the [homelab backup guidance](https://github.com/segfaultsoftware/homelab-manual/blob/main/docs/operations/backups.md).
Until that prerequisite is complete, this deployment is **not production-ready** and its data
must not be treated as recoverable.
