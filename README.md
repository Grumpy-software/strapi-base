# strapi-base

Vanilla Strapi 5 TypeScript app. SQLite is the default database. This repo is a Dokploy base for `https://strapi.grumpysoftware.com`. It is not a plugin and it is not a media-twins playground.

Install plugins later in this running app. Do not vendor them here.

## Local develop

Copy `.env.example` to `.env` and replace the placeholder secrets.

```
npm ci
npm run develop
```

Admin is at `http://localhost:1337/admin`.

```
npm run build
npm start
```

## How to deploy on Dokploy

David deploys this from the Dokploy UI. This repo does not SSH into the host.

1. Create a project, then a Compose service. Set Compose Type to Docker Compose.
2. Connect this GitHub repo. Set the compose path to `./docker-compose.yml`.
3. In the Dokploy environment UI, set:

   - `PUBLIC_URL=https://strapi.grumpysoftware.com`
   - `HOST=0.0.0.0`
   - `PORT=1337`
   - `DATABASE_CLIENT=sqlite`
   - `DATABASE_FILENAME=.tmp/data.db`
   - new values for `APP_KEYS`, `API_TOKEN_SALT`, `ADMIN_JWT_SECRET`, `TRANSFER_TOKEN_SALT`, `JWT_SECRET`, and `ENCRYPTION_KEY`

   Generate the secrets in the Dokploy UI. `APP_KEYS` needs at least two comma-separated values.

4. Keep the compose volumes. They persist SQLite and uploads at `/opt/app/.tmp` and `/opt/app/public/uploads`.
5. Deploy. Wait about 10 seconds after the container is up so Traefik can issue the certificate.
6. Open `https://strapi.grumpysoftware.com/admin` and create the first admin user.

The hostname is already live in Cloudflare. Do not create or change other DNS.

- `strapi.grumpysoftware.com` is an A record to the same Dokploy origin as `dokploy.grumpysoftware.com`.
- The record is proxied (orange cloud).
- Traefik in `docker-compose.yml` matches this rule:

```
traefik.http.routers.strapi.rule=Host(`strapi.grumpysoftware.com`)
```

Traefik labels live in `docker-compose.yml` (Dokploy [manual Compose method](https://docs.dokploy.com/docs/core/docker-compose/example)). The service joins the external `dokploy-network`. Do not set `container_name`. Dokploy breaks logs and metrics when that field is set.

The compose file publishes `1337` without a host-to-container port map so Traefik can own the public port.

## Docker image

The Dockerfile uses Node 20. Build runs `npm ci` then `npm run build`. The container starts with `npm start` on port 1337.

`docker-entrypoint.sh` chowns `/opt/app/.tmp` and `/opt/app/public/uploads` to `node` on boot, then runs as `node`. That is required because a first Compose deploy creates the `strapi-tmp` named volume as root after the image `chown`, and SQLite must be able to create `.tmp/data.db`.
