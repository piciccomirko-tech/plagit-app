# Plagit Flutter — Project Memory

## Stato schermate

### Admin (core)
- DONE — `admin_shell_view.dart` (tab/nav, 5 tab, header, card rows)
- DONE — `admin_dashboard_view.dart` (home admin standard)
- DONE — `super_admin_home_view.dart` (home super admin)

Il **core Admin è production-ready** al 100% per tutto ciò che è localizzabile con chiavi semplici o con placeholder `{count}`.

### Admin secondari
- DONE (Fase 1 — 2026-04-17) — index leggeri:
  - `admin_shared_widgets.dart` (+ helper `aStatusLabel(l, status)`)
  - `admin_jobs_view.dart`, `admin_users_view.dart`, `admin_messages_view.dart`
  - `admin_matches_view.dart`, `admin_reports_view.dart`, `admin_businesses_view.dart`
  - `admin_notifications_view.dart`, `admin_subscriptions_view.dart`, `admin_settings_view.dart`
  - `admin_logs_view.dart`, `admin_content_featured_view.dart`, `admin_interviews_view.dart`
- DONE (Fase 2 — 2026-04-17) — index medi:
  - `admin_candidates_view.dart`, `admin_applications_view.dart`
  - `admin_verifications_view.dart`, `admin_moderation_view.dart`
  - `admin_support_view.dart`, `admin_audit_view.dart`
  - extended `admin_shared_widgets.dart` with `aStatusLabel` cases (+9) + new `aPriorityLabel(l, p)` helper
- DONE (Fase 3 — 2026-04-17) — analytics + community:
  - `admin_analytics_view.dart`, `admin_community_view.dart`
  - 36 nuove chiavi (33 semplici + 2 ICU `{count}` + 1 ICU `{premium}/{total}`)
  - build bump 1.0.0+4 → 1.0.0+5, branch `phase3-admin-i18n`
- DONE (Fase 4 — 2026-04-17) — detail profili (scope ridotto):
  - `admin_business_detail_view.dart`, `admin_candidate_detail_view.dart`
  - Coperti: action buttons, dialog title/body (ICU `{name}`), snackbar, tabs, cancel/confirm
  - 31 nuove chiavi (26 semplici + 5 ICU `{name}`) — 7 action, 7 dialog title, 9 snackbar, 3 tab, 5 ICU body
  - build bump 1.0.0+5 → 1.0.0+6, branch `phase4-admin-i18n`
  - Rimandato a 4-bis: info-row labels, stat card labels, `Profile` completion, `Joined {date}`, `{size} employees`, `No jobs posted`, `Add a note...`, mock data/identity placeholder
- DONE (Fase 4-bis — 2026-04-17) — rifinitura 2 detail:
  - `admin_business_detail_view.dart`, `admin_candidate_detail_view.dart`
  - Coperti: 11 info-row labels × 2 file, 5 stat-card labels, `Add a note...`, `No jobs posted`, `Profile` completion (riuso `adminTabProfile`)
  - 16 nuove chiavi (12 `adminField*`, 2 `adminStat*`, 1 `adminPlaceholder*`, 1 `adminEmpty*`)
  - Riusati: `adminStatActiveJobs`, `adminMenuApplications`, `adminMenuInterviews`, `adminTabProfile`
  - build bump 1.0.0+6 → 1.0.0+7, branch `phase4bis-admin-i18n`
  - **2 detail sostanzialmente chiusi**: residui solo su dati runtime/mock esclusi per scelta (Admin User, fake phone, mock notes/activity, numero 75%, 3 ICU opzionali)
- DONE (Fase 5C — 2026-04-17) — subscription + audit detail:
  - `admin_subscription_detail_view.dart`, `admin_audit_detail_view.dart`
  - Coperti: topbar/title, empty state, section titles, info-row labels, dropdown values (plan), placeholder, action button, timeline entries, change-diff text, IP address label
  - 36 nuove chiavi (plan×4, field×9, section×6, placeholder×2, timeline×2, empty×3, action×1, audit×7, misc×2)
  - Riusati: `adminTabNotes`, `adminFieldPlan`, `adminFieldStatus`, `aStatusLabel` per Active/Suspended/Verified/Open/Resolved
  - Refactor: `_changeText` ora riceve `AppLocalizations`, nuovo helper `_actionLabel`
  - build bump 1.0.0+7 → 1.0.0+8, branch `phase5c-admin-i18n`
  - analyze: **0 issues** (no pre-esistenti)
- DONE (Fase 5A — 2026-04-17) — application + interview detail:
  - `admin_application_detail_view.dart`, `admin_interview_detail_view.dart`
  - Coperti: header title, link-card labels (Candidate/Job/Business), flagged badge, timeline section + steps (Applied/Reviewed/Shortlisted/Interview/Decision + Scheduled/Confirmed/In Progress/Completed), dropdown `Select status` + tutti i valori via `aStatusLabel`, textfield reason, confirm dialog (title + ICU body `{status}` + reason prefix + none-provided), snackbars (override/note-saved/note-added/no-show/cancelled/completed), buttons (Save Note/Add Note/Complete/Mark No-Show/Cancel), empty state `No notes yet.`, info-row labels (Date/Time/Format), notes section (Admin Notes), actions section
  - 33 nuove chiavi (status×5, section×5, field×6, badge×1, placeholder×1, dialog×3, misc×1, snackbar×6, action×4, empty×1) + 1 ICU `{status}`
  - Helper `aStatusLabel` esteso: +5 case (withdrawn/no-show/in progress/reviewed/decision)
  - Riusati: `adminActionCancel`, `adminActionConfirm`, `adminActionApplyOverride`, `adminPlaceholderReasonOverride`, `adminPlaceholderAddNote`, `adminTabNotes`, `adminSectionAdminOverride`
  - build bump 1.0.0+8 → 1.0.0+9, branch `phase5a-admin-i18n`
  - analyze: **0 issues**
- TODO — Fase 5B (verification + moderation + support detail)

### Candidate / Business
- Non toccati in questa sessione

## i18n — stato del catalogo ARB

### Locali attivi (9)
en, it, ar, es, fr, pt, de, ru, zh
(hi, tr presenti ma non tradotti — auto-fill da en via gen-l10n)

### Chiavi admin* aggiunte nel corso di 4 fasi
- **Fase A** — 42 chiavi statiche (adminMenu×20, adminAction×6, adminSection×5, adminStat×7, adminMisc×4)
- **Fase B** — 50 sostituzioni, 0 chiavi nuove
- **Fase B-bis** — 36 chiavi (adminMenu×10, adminSection×7, adminStat×5, adminAction×10, adminMisc×4)
- **Fase C** — 28 chiavi (adminSubtitle×23, adminBadge×3, adminMenuAllUsers, adminMiscSuperAdmin)
- **Fase D** — 7 chiavi con placeholder `{count}` per badge dinamici

### Totali
**113 chiavi admin × 9 locali = 1017 valori localizzati + @metadata**
(+ 28 chiavi Fase 2 + 36 chiavi Fase 3 + 31 chiavi Fase 4 + 16 chiavi Fase 4-bis + 36 chiavi Fase 5C + 33 chiavi Fase 5A → totale cumulativo 293 chiavi × 9 locali)

## Decisioni tecniche

### 2026-04-17 — i18n admin
- Tutte le stringhe UI del core admin (3 file) passate via `AppLocalizations.of(context)`
- Pattern per badge tipo "Urgent/Review/Action": helper `_badgeLabel(l, badge)` mantiene la comparazione interna sull'enum sorgente ma mostra la label localizzata
- Badge dinamici tipo "{n} today": chiavi ICU `{count}` con `placeholders: { count: int }` → metodo `l.adminBadgeNToday(n)`
- Script Python con `OrderedDict` + `json.loads(..., object_pairs_hook=OrderedDict)` per preservare l'ordine delle chiavi negli ARB e aggiungere @metadata solo in en
- Admin NON usa GetX (CLAUDE.md default) — usa Provider + ChangeNotifier

### 2026-04-17 — Fase D chiusa, pausa prima dei file secondari
- User decisione: fermarsi dopo Fase D, non aprire Fase E (`_AttentionItem.text`)
- Prossima fase sarà su **file admin secondari** in sessione separata

## Residui noti nel core admin

Esplicitamente fuori scope, non sono bug:

### BASSO — `_AttentionItem.text` non localizzato
- File: `admin_dashboard_view.dart` (3 frasi), `super_admin_home_view.dart` (5 frasi)
- Es. `'2 high-priority reports'`, `'5 jobs with no applicants'`, `'${stats['reportedContent']} reports need review'`
- Richiederebbe chiavi frase-intera con `{count}` (Fase E eventuale)

### BASSO — Identità utente nell'avatar menu
- File: `super_admin_home_view.dart`
- `'Mirko Picicco'`, `'mirko@plagit.com'` hardcoded
- Dati runtime, da leggere da `AdminAuthProvider.userName/userEmail` (refactor, non i18n)

### INFO — Drift storico negli ARB
- en = ~1395 chiavi, it/ar = ~1310, altri = ~1345 (pre-esistente da prima delle fasi A-D)
- Non causato dalle nuove fasi

## Bug noti aperti
- Nessuno introdotto nella sessione admin i18n
- Compile pulito: `flutter analyze lib/features/admin/views/*.dart` → "No issues found"

## Sessione precedente — 2026-04-17

### Fatto
- Fasi A, B, B-bis, C, D sull'i18n del core Admin (3 file)
- ~180 sostituzioni totali in 3 file Dart
- 113 chiavi admin* × 9 locali + metadati ICU
- Refactor helper `_badgeLabel` in entrambi i file home admin

### Rimasto a metà
- Niente — tutte le fasi approvate chiuse pulite

### Prossimo passo consigliato
1. **Fase successiva**: i18n sui **file admin secondari** (candidates/businesses/jobs/applications/…) — 16 schermate
2. Oppure: passare a un'altra area (Candidate, Business)
3. Fase E opzionale: `_AttentionItem.text` con ICU `{count}` su frasi-intere (solo se vuoi il 100% assoluto)

Prima di pushare: bump build nei 3 file + `plagit-push`.
