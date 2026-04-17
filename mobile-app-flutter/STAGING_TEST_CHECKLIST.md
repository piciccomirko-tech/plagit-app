# Staging Test Checklist — Admin + Business

**Environment:** `EnvConfig.initialize(Environment.staging);` in `lib/main.dart`
**Backend:** `https://plagit-backend-staging.up.railway.app/v1`
**Date:** 2026-04-14

---

## LIKELY BLOCKERS (check first)

| # | Issue | Type | Detail |
|---|---|---|---|
| B1 | **super_admin role rejected by backend** | Backend auth | `requireAdmin` middleware checks `role !== 'admin'` — rejects `super_admin`. The JWT must have `role: 'admin'` to pass. Fix: update `auth.js:17` to `!['admin','super_admin'].includes(req.user.role)` |
| B2 | **No `/admin/support` endpoint** | Missing route | Flutter calls `GET /admin/support` but backend has no `adminSupport.js`. Support tickets may be part of `adminReports`. Fix: either add route alias or change Flutter to use `/admin/reports` with a type filter |
| B3 | **No `/admin/verifications` list endpoint** | Missing route | Flutter calls `GET /admin/verifications` but backend has no separate verifications list. Verifications are per-candidate via `PATCH /admin/candidates/:id/verification`. Fix: add a list endpoint or query candidates where `verification_status = 'pending'` |
| B4 | **No seed data in staging DB** | Missing data | If staging DB is empty, all lists return empty. Need to run seeds: `npx knex seed:run --knexfile knexfile.js` |
| B5 | **Response shape `resp['data']`** | Potential mismatch | Flutter repos expect `resp['data']` to contain the list/object. Backend uses `ok(res, data)` from `utils/response.js` which wraps as `{success: true, data: ...}`. Verify the wrapper is consistent |
| B6 | **Business `applicants` vs `applications`** | Naming mismatch | Flutter calls `GET /business/applicants` but backend route is `GET /business/jobs/:id/applicants` (per-job). There's no flat `/business/applicants` endpoint. The Flutter repo needs `jobId` param to construct the correct URL |

---

## ADMIN STAGING TEST CHECKLIST

### Auth

| # | Test | Endpoint | Expected | Status | Notes |
|---|---|---|---|---|---|
| A1 | Login as admin@test.com | `POST /auth/login` | Token returned, role='admin' | | Test with real staging credentials |
| A2 | Login as superadmin@plagit.com | `POST /auth/login` | Token returned, role='super_admin' | | **See B1** — will 403 on admin endpoints |
| A3 | Session restore after app restart | `GET /auth/me` | Profile returned | | |
| A4 | Admin route guard blocks non-admin | GoRouter redirect | Redirects to /admin/login | | Test with candidate token |

### Dashboard

| # | Test | Endpoint | Expected | Status | Notes |
|---|---|---|---|---|---|
| A5 | Dashboard stats load | `GET /admin/dashboard/stats` | Stats JSON with counts | | Needs seed data |
| A6 | Loading spinner shows | — | Spinner visible during fetch | | |
| A7 | Error state on failure | — | Error text + Retry button | | Test: disconnect network |
| A8 | Retry reloads data | — | Stats reload on tap | | |

### Lists

| # | Test | Endpoint | Expected | Status | Notes |
|---|---|---|---|---|---|
| A9 | Candidates list loads | `GET /admin/candidates` | List of candidates | | |
| A10 | Businesses list loads | `GET /admin/businesses` | List of businesses | | |
| A11 | Jobs list loads | `GET /admin/jobs` | List of jobs | | |
| A12 | Applications list loads | `GET /admin/applications` | List of applications | | |
| A13 | Interviews list loads | `GET /admin/interviews` | List of interviews | | |
| A14 | Verifications list loads | `GET /admin/verifications` | **WILL 404** — see B3 | | Need backend fix |
| A15 | Reports list loads | `GET /admin/reports` | List of reports | | |
| A16 | Support list loads | `GET /admin/support` | **WILL 404** — see B2 | | Need backend fix |
| A17 | Notifications load | `GET /admin/notifications` | List of notifications | | |
| A18 | Empty state for empty lists | — | "No items" message | | Test with empty DB |

### User Actions

| # | Test | Endpoint | Expected | Status | Notes |
|---|---|---|---|---|---|
| A19 | Verify user | `PATCH /admin/users/:id/verify` | User marked verified | | Confirm dialog → SnackBar |
| A20 | Unverify user | `PATCH /admin/users/:id/verify` | Verification removed | | `{is_verified: false}` |
| A21 | Suspend user | `PATCH /admin/users/:id/status` | Status → suspended | | `{status: 'suspended'}` |
| A22 | Unsuspend user | `PATCH /admin/users/:id/status` | Status → active | | `{status: 'active'}` |
| A23 | UI updates after action | — | Badge/pill reflects new status | | |
| A24 | No duplicate tap during loading | — | Button disabled while busy | | |

### Business Actions

| # | Test | Endpoint | Expected | Status | Notes |
|---|---|---|---|---|---|
| A25 | Approve business | `PATCH /admin/businesses/:id/status` | Status → active | | `{status: 'active'}` |
| A26 | Reject business | `PATCH /admin/businesses/:id/status` | Status → rejected | | |

### Moderation Actions

| # | Test | Endpoint | Expected | Status | Notes |
|---|---|---|---|---|---|
| A27 | Resolve report | `PATCH /admin/reports/:id/status` | Status → resolved | | |
| A28 | Dismiss report | `PATCH /admin/reports/:id/status` | Status → dismissed | | |
| A29 | Mark notification read | `PATCH /admin/notifications/:id/read` | Notification marked read | | |

### Content Actions

| # | Test | Endpoint | Expected | Status | Notes |
|---|---|---|---|---|---|
| A30 | Feature job | `PATCH /admin/jobs/:id/featured` | Job marked featured | | `{is_featured: true}` |
| A31 | Unfeature job | `PATCH /admin/jobs/:id/featured` | Featured removed | | |
| A32 | Remove job | `DELETE /admin/jobs/:id` | Job deleted | | |
| A33 | Override application status | `PATCH /admin/applications/:id/status` | Status changed | | |
| A34 | Cancel interview | `PATCH /admin/interviews/:id/status` | Status → cancelled | | |
| A35 | Complete interview | `PATCH /admin/interviews/:id/status` | Status → completed | | |
| A36 | Mark interview no-show | `PATCH /admin/interviews/:id/status` | Status → no_show | | |

---

## BUSINESS STAGING TEST CHECKLIST

### Auth

| # | Test | Endpoint | Expected | Status | Notes |
|---|---|---|---|---|---|
| B7 | Login as business | `POST /auth/login` | Token returned, role='business' | | |
| B8 | Candidate login rejected from business screen | — | "Please use Candidate login" | | |
| B9 | Admin login routes to admin dashboard | — | Routes to /admin/dashboard | | |

### Dashboard

| # | Test | Endpoint | Expected | Status | Notes |
|---|---|---|---|---|---|
| B10 | Dashboard loads real data | `GET /business/home` | Profile, stats, next interview | | |
| B11 | Active jobs count correct | — | Matches real job count | | |
| B12 | Applicants count correct | — | Matches real applications | | |
| B13 | Loading/error states work | — | Spinner, error+retry | | |

### Jobs

| # | Test | Endpoint | Expected | Status | Notes |
|---|---|---|---|---|---|
| B14 | Jobs list loads | `GET /business/jobs` | Business's own jobs | | |
| B15 | Job detail loads | `GET /business/jobs/:id` | Single job with applicant_count | | |
| B16 | Create job | `POST /business/jobs` | Job created, list refreshes | | Title required |
| B17 | Edit job | `PATCH /business/jobs/:id` | Job updated | | |
| B18 | Close job | `PATCH /business/jobs/:id` | Status → closed | | `{status:'closed'}` |
| B19 | Pause job | `PATCH /business/jobs/:id` | Status → paused | | `{status:'paused'}` |
| B20 | Reactivate job | `PATCH /business/jobs/:id` | Status → active | | `{status:'active'}` |
| B21 | Filter by status | `GET /business/jobs?status=active` | Filtered list | | |
| B22 | Empty state when no jobs | — | Empty message shown | | |

### Applicants

| # | Test | Endpoint | Expected | Status | Notes |
|---|---|---|---|---|---|
| B23 | Applicants list loads | `GET /business/jobs/:id/applicants` | **See B6** — path mismatch | | Flutter sends `/business/applicants`, backend expects `/business/jobs/:id/applicants` |
| B24 | Applicant detail loads | `GET /business/applicants/:id` | **No endpoint** — see B6 | | Backend has no flat applicant detail |
| B25 | Shortlist applicant | `PATCH /business/applicants/:id/status` | Status → shortlisted | | |
| B26 | Reject applicant | `PATCH /business/applicants/:id/status` | Status → rejected | | |
| B27 | Invite to interview | `POST /business/interviews` | Interview created | | |
| B28 | Filter applicants by status | — | Filtered list | | |

### Interviews

| # | Test | Endpoint | Expected | Status | Notes |
|---|---|---|---|---|---|
| B29 | Interviews list loads | `GET /business/interviews` | Business's interviews | | |
| B30 | Schedule interview | `POST /business/interviews` | Interview created | | |
| B31 | Filter by status | `GET /business/interviews?status=X` | Filtered list | | |

### Messages

| # | Test | Endpoint | Expected | Status | Notes |
|---|---|---|---|---|---|
| B32 | Conversations list loads | `GET /business/conversations` | Conversation threads | | |
| B33 | Message thread loads | `GET /business/conversations/:id/messages` | Messages in thread | | |
| B34 | Send message | `POST /business/conversations/:id/messages` | Message sent | | |

### Profile & Misc

| # | Test | Endpoint | Expected | Status | Notes |
|---|---|---|---|---|---|
| B35 | Profile loads | `GET /business/profile` | Business profile data | | |
| B36 | Subscription loads | `GET /business/subscription` | Plan details | | |
| B37 | Notifications load | `GET /business/notifications` | Notification list | | |

---

## PATH MISMATCH SUMMARY

These Flutter repo paths don't match the backend routes and will fail in staging:

| Flutter calls | Backend has | Fix needed |
|---|---|---|
| `GET /admin/support` | No route | Add `/admin/support` alias to `adminReports` or change Flutter to use `/admin/reports?type=support` |
| `GET /admin/verifications` | No route | Add list endpoint to `adminCandidates` or create `adminVerifications.js` |
| `GET /business/applicants` (flat) | `GET /business/jobs/:id/applicants` (per-job) | Flutter needs to send jobId in the URL path, not as query param |
| `GET /business/applicants/:id` | No flat route | Either add flat lookup or use candidate profile endpoint |

---

## FASTEST NEXT STEPS AFTER STAGING VALIDATION

1. **Fix B1** — Update `requireAdmin` to accept both `admin` and `super_admin` roles (1 line)
2. **Fix B6** — Update Flutter `fetchApplicants()` to use `/business/jobs/:jobId/applicants` when jobId is provided
3. **Fix B2/B3** — Either add missing backend routes or update Flutter repos to use existing routes
4. **Seed staging DB** — Run seeds so lists have data to display
5. **Test auth flow end-to-end** — Login → dashboard → list → detail → action → verify SnackBar
6. **Fix any response shape mismatches** found during testing
7. **Move to Candidate integration** once Admin + Business pass staging
