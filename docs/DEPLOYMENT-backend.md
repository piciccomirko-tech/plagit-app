# Plagit Backend — Deployment Guide

## Railway Deployment (Recommended)

### Prerequisites
- Railway account at [railway.com](https://railway.com)
- Railway CLI: `npm i -g @railway/cli`
- This repo pushed to GitHub (or deploy from local)

### Services Needed
1. **Web Service** — runs the Node.js API
2. **PostgreSQL Database** — Railway's managed Postgres addon

Railway auto-provides `DATABASE_URL` and `PORT` when you add PostgreSQL.

### Env Vars to Set on Railway

| Variable | Value | How |
|----------|-------|-----|
| `NODE_ENV` | `production` | Set manually |
| `JWT_SECRET` | `openssl rand -hex 64` | Generate locally, paste into Railway |
| `JWT_EXPIRES_IN` | `7d` | Set manually |
| `CORS_ORIGIN` | `*` for now, restrict later | Set manually |
| `DATABASE_URL` | *(auto-set by Railway)* | Added when you attach PostgreSQL |
| `PORT` | *(auto-set by Railway)* | No action needed |

**Do NOT set** `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD` — production uses `DATABASE_URL` only.

### Deploy Steps (From Zero to Live)

```bash
# ─── Step 1: Login to Railway ───
railway login

# ─── Step 2: Create project ───
cd ~/Desktop/plagit-backend
railway init
# Select "Empty Project" when prompted

# ─── Step 3: Add PostgreSQL ───
# Go to Railway dashboard → your project → "New" → "Database" → "PostgreSQL"
# This auto-creates DATABASE_URL in the service env vars

# ─── Step 4: Link your service ───
railway link
# Select the service (not the database)

# ─── Step 5: Set env vars ───
railway variables set NODE_ENV=production
railway variables set JWT_SECRET=$(openssl rand -hex 64)
railway variables set JWT_EXPIRES_IN=7d
railway variables set CORS_ORIGIN=*

# ─── Step 6: Deploy ───
railway up
# Wait for build + deploy to complete (~1-2 min)

# ─── Step 7: Run migrations ───
railway run npm run migrate:prod
# This creates all 16 database tables

# ─── Step 8: Seed admin user ───
railway run npm run seed:prod
# Creates: mirko@plagit.com / admin2026
# ⚠️  CHANGE THIS PASSWORD after first login

# ─── Step 9: Get your public URL ───
railway domain
# Example output: plagit-backend-production.up.railway.app
```

### Verify Deployment

```bash
# Health check
curl https://YOUR-DOMAIN.up.railway.app/health

# Login test
curl -X POST https://YOUR-DOMAIN.up.railway.app/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"mirko@plagit.com","password":"admin2026"}'
```

### Connect iOS App

Update `APIClient.swift` line 17:
```swift
static var baseURL: String = "https://YOUR-DOMAIN.up.railway.app/v1"
```

### URL Format
Railway URLs follow: `https://<project-name>-production.up.railway.app`
Your API endpoints will be at: `https://<project-name>-production.up.railway.app/v1/...`

---

## Risk Points

### JWT Secret
- **Risk:** Weak or default secret allows token forgery
- **Mitigation:** Generate with `openssl rand -hex 64`. Never reuse the dev secret.

### Database SSL
- **Risk:** Railway Postgres requires SSL
- **Status:** Handled — knexfile production config uses `ssl: { rejectUnauthorized: false }` by default
- **Override:** Set `DB_SSL=false` env var only if connecting to a non-SSL database

### CORS
- **Risk:** `CORS_ORIGIN=*` allows any origin to call the API
- **Mitigation:** After confirming the iOS app works, restrict to your app's domain or remove CORS entirely (native apps don't need it)

### Seeding
- **Risk:** Dev seeds (`db/seeds/`) delete all data before inserting
- **Status:** Handled — production uses `db/seeds-prod/` which only inserts the admin user if it doesn't exist. Running `npm run seed:prod` is safe to run multiple times.

### Admin Credentials
- **Risk:** Default password `admin2026` is in the seed file
- **Mitigation:** Change password after first production login. The seed prints a warning.

---

## Other Hosting Platforms

### Render
1. Connect GitHub repo → New Web Service
2. Build: `npm install` / Start: `node src/server.js`
3. Add PostgreSQL addon → auto-sets `DATABASE_URL`
4. Set env vars (same as Railway)
5. Open Shell: `npm run migrate:prod && npm run seed:prod`

### Heroku
```bash
heroku create plagit-backend
heroku addons:create heroku-postgresql:essential-0
heroku config:set NODE_ENV=production JWT_SECRET=$(openssl rand -hex 64) CORS_ORIGIN=*
git push heroku main
heroku run npm run migrate:prod
heroku run npm run seed:prod
```

---

## Security Checklist

- [ ] `NODE_ENV=production` is set
- [ ] `JWT_SECRET` is a strong random value (64+ hex chars)
- [ ] `CORS_ORIGIN` is restricted to your domain (not `*`)
- [ ] Default admin password changed after first login
- [ ] `.env` is NOT committed to the repo
- [ ] HTTPS is active (Railway/Render/Heroku provide this automatically)
