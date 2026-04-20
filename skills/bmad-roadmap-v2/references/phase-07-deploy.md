# Phase 7: Deploy (Full-Stack)

**Goal:** Deploy the full-stack application to production. Unlike the v1 roadmap (which had separate UI-only and full-stack deploy phases), this patch deploys everything together.

**Exit condition:** Application running in production at the assigned domain with passing health checks.

---

## Pattern (reference: global `~/.claude/CLAUDE.md` → "Adding a New App to the Server")

This phase follows the deployment pattern defined in the user's global CLAUDE.md, which covers:

1. **Server setup** — clone repo to `/opt/apps/<app-name>/`
2. **Caddy** — add domain to `/opt/caddy/Caddyfile` with reverse_proxy to nginx
3. **Required files** — port the canonical stack:
   - `docker-compose.prod.yml` (full stack: PHP-FPM, Nginx, Node/Next.js, DB, Redis)
   - `docker/php/Dockerfile.prod` (multi-stage, <200MB target)
   - `docker/node/Dockerfile.prod` (multi-stage with pnpm)
   - `docker/nginx/prod.conf` (routing `/api/v1/*` → PHP-FPM, `/*` → Next.js)
   - `.github/workflows/deploy.yml` (CI/CD: check → build → deploy → notify)
   - `scripts/rollback.sh`
   - `backend/phpstan.neon` + `pint.json` (if Laravel)
   - `backend/app/Http/Controllers/Api/V1/HealthController.php`
4. **GitHub setup** — secrets (`SERVER_IP`, `SSH_PRIVATE_KEY`, `TELEGRAM_BOT_TOKEN`, `TELEGRAM_CHAT_ID`), variable (`SITE_URL`), enable GHCR packages
5. **Docker network** — join `proxy` external network
6. **DNS** — point A record to server IP
7. **Update global CLAUDE.md Deployed Apps table**

---

## Pre-Deploy Checklist

Before starting deploy:
- [ ] All stories shipped to `main` (Phase 6 complete)
- [ ] All tests pass in CI
- [ ] `.env.production` secrets prepared (not committed)
- [ ] Domain registered and DNS accessible
- [ ] Docker base images match the "Standard Base Images" table in global CLAUDE.md
- [ ] Ports picked from unused allocations (see "Port allocation" in global CLAUDE.md)

---

## Post-Deploy Smoke Test

After the first deploy succeeds:
- [ ] `GET /api/v1/health` returns 200 with `{"status": "ok"}`
- [ ] Visit every journey's entry screen in the browser — all load correctly
- [ ] Trigger one full journey end-to-end (e.g., onboarding flow) with real API + DB
- [ ] Rollback script tested in staging (dry-run)

---

## Phase Completion

Before marking Phase 7 complete, verify:
- [ ] Application accessible at production domain with HTTPS
- [ ] Health endpoint returns 200
- [ ] All journeys walkable with real data (not mocks)
- [ ] CI/CD pipeline green on `main`
- [ ] Global CLAUDE.md "Deployed Apps" table updated with this app's row

Update progress file:

```yaml
7-deploy:
  status: complete
  completed: "{today}"
  domain: "https://example.com"
```

Announce completion and proceed to Phase 8.
