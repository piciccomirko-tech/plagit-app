# Plagit — Premium Hospitality Recruitment Platform

Monorepo for the Plagit platform: connecting hospitality talent with premium businesses worldwide.

## Project Structure

```
Plagit-new-project/
├── mobile-app-flutter/    Mobile app (iOS + Android)
├── web-app-react/         Public web app
├── admin-panel-react/     Admin dashboard (separate from public web)
├── backend-node/          REST API
├── docs/                  Documentation
├── assets/                Shared brand assets
├── env/                   Environment variable templates
└── archive/               Legacy code (reference only)
```

## Folder Breakdown

### `mobile-app-flutter/` — Mobile App
- **Stack**: Flutter (Dart), Material 3, go_router, provider
- **Targets**: iOS (App Store) + Android (Play Store)
- **Features**: Candidate job search, business hiring tools, messaging, interviews, CV upload, social feed
- **Run**: `cd mobile-app-flutter && flutter pub get && flutter run`

### `web-app-react/` — Public Web App
- **Stack**: React 19, Vite 8, react-router-dom 7
- **Purpose**: Public-facing website — job listings, candidate/business signup, company profiles
- **Not for**: Admin operations (those are in `admin-panel-react`)
- **Run**: `cd web-app-react && npm install && npm run dev`

### `admin-panel-react/` — Admin Dashboard
- **Stack**: React 19, Vite 8, react-router-dom 7
- **Purpose**: Internal admin panel — user management, reports, moderation, subscriptions, settings
- **Screens**: Dashboard, Users, Businesses, Candidates, Jobs, Applications, Interviews, Messages, Notifications, Reports, Subscriptions, Community, Featured, Matches, Logs, Settings
- **Fully separated** from the public web app (different codebase, different auth, different deployment)
- **Run**: `cd admin-panel-react && npm install && npm run dev`

### `backend-node/` — REST API
- **Stack**: Node.js 20+, Express 5, PostgreSQL, Knex, JWT
- **Serves**: All clients (mobile, web, admin)
- **API prefix**: `/v1`
- **Run**: `cd backend-node && cp .env.example .env && npm install && npx knex migrate:latest && npm start`

### `docs/` — Documentation
Deployment guides, architecture notes, API documentation.

### `assets/` — Shared Brand Assets
Logos, app icons, fonts, and brand guidelines used across all platforms.

### `env/` — Environment Templates
`.env.example` files for each service. Copy to `.env` and fill in real values.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile | Flutter 3.41+ (Dart) |
| Web | React 19 + Vite 8 |
| Admin | React 19 + Vite 8 |
| Backend | Node.js 20+ / Express 5 |
| Database | PostgreSQL (Knex migrations) |
| Auth | JWT (bcrypt password hashing) |
| Email | Resend |
| AI | Claude API (CV parsing) |
| Cloud | AWS (planned) |
| Deployment | Railway (backend), App Store + Play Store (mobile) |

## Environments

| Environment | Purpose | Database | API URL |
|-------------|---------|----------|---------|
| **Development** | Local coding and testing | Local PostgreSQL | `http://localhost:3000/v1` |
| **Staging** | Pre-release testing, QA review | Staging PostgreSQL on AWS | TBD |
| **Production** | Live users, real data | Production PostgreSQL on AWS | `https://api.plagit.com/v1` |

### Key differences

- **Development**: Uses local database, CORS allows all origins, debug logging enabled, email codes logged to console
- **Staging**: Mirrors production config but with test data, used for QA before releases
- **Production**: SSL enforced, strict CORS, real email delivery, monitoring enabled, no debug output

## Setup Instructions

### Prerequisites
- Node.js 20+ (`node --version`)
- Flutter 3.41+ (`flutter --version`)
- PostgreSQL 15+ running locally
- Git

### 1. Clone and install
```bash
git clone <repo-url> Plagit-new-project
cd Plagit-new-project
```

### 2. Start the backend
```bash
cd backend-node
cp .env.example .env          # fill in DB credentials and JWT secret
npm install
npx knex migrate:latest       # create all database tables
npx knex seed:run             # seed development data
npm run dev                   # starts on http://localhost:3000
```

### 3. Start the mobile app
```bash
cd mobile-app-flutter
flutter pub get
flutter run                   # launches on connected device or simulator
```

### 4. Start the web app
```bash
cd web-app-react
npm install
npm run dev                   # starts on http://localhost:5173
```

### 5. Start the admin panel
```bash
cd admin-panel-react
npm install
npm run dev                   # starts on http://localhost:5174
```

## Environment Variables

See `env/.env.backend.example` for the complete list. Required variables:

| Variable | Required | Description |
|----------|----------|-------------|
| `PORT` | Yes | Backend server port |
| `NODE_ENV` | Yes | `development` or `production` |
| `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD` | Dev | Local PostgreSQL connection |
| `DATABASE_URL` | Prod | Production connection string |
| `JWT_SECRET` | Yes | Token signing key (generate with `openssl rand -hex 64`) |
| `CORS_ORIGIN` | Yes | Allowed origins (comma-separated) |
| `RESEND_API_KEY` | No | Email delivery (falls back to console logging) |
| `ANTHROPIC_API_KEY` | No | AI-powered CV extraction (falls back to manual entry) |
