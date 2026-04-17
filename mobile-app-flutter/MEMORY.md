# Plagit Flutter — Project Memory

## Ultima sessione

- **2026-04-17 — Fase 10 RTL & Overflow Hardening**
  - Scope: fix meccanici visivi/layout emersi dalla review i18n/RTL finale. Zero nuove chiavi ARB, zero business logic.
  - **Nuovo helper**: `core/widgets/directional_chevron.dart` → `BackChevron` + `ForwardChevron` che auto-mirror `chevron_left`/`chevron_right` in RTL via `Directionality.of(context)`.
  - **Sweep meccanico**: 59 file — `Icon(Icons.chevron_left|right, ...)` → `BackChevron`/`ForwardChevron`, import auto-iniettato dove mancante.
  - **status_badge**: padding orizzontale 10 → 12, `maxLines: 1` + `TextOverflow.ellipsis` per evitare overflow su DE/RU/AR.
  - **TabBar admin detail**: `admin_business_detail_view` + `admin_candidate_detail_view` → `isScrollable: true`, `tabAlignment: TabAlignment.start` per evitare clipping su locali lunghe.
  - build bump 1.0.0+17 → 1.0.0+18, branch `phase10-rtl-overflow-hardening` (base: phase9a), **pushed to remote**
  - analyze: **0 errori** sui file toccati da phase10. Errori pre-esistenti su WIP main (EmploymentType/BusinessProfile/etc.) fuori scope.
  - Residui non affrontati: sweep `EdgeInsets.only(left/right)` → `EdgeInsetsDirectional.only(start/end)` (83 occorrenze/61 file) e `Alignment.centerRight/Left` funzionali (4-5 casi) rinviati per mantenere scope contenuto.

- **2026-04-17 — Fase 9A Services + Shared Widgets i18n closure**
  - Scope: `role_switcher.dart`, `post_insights_premium_sheet.dart`, `service_notifications_view.dart`, `service_company_profile_view.dart`
  - **9 chiavi riusate** dal catalogo: `candidate`, `businessLabel`, `admin`, `browseServices`, `cancel`, `about`, `messages`, `filterAll`, `allCaughtUp`, `validUntilDate`
  - **7 chiavi nuove** × 11 locali: `switchRoleTitle`, `postsTab`, `galleryTab`, `promotionsTab`, `filterUpdates`, `badgePro`, `badgeAdmin`
  - 11 sostituzioni totali: 6 in role_switcher + 2 badges in post_insights + 5 in service views (filter+empty+4 tabs+validUntil)
  - build bump 1.0.0+11 → 1.0.0+17, branch `phase9a-services-widgets-i18n`
  - analyze: **0 issues** sui file modificati (31 pre-esistenti altrove)
  - Cumulativo dopo 9A: **406 chiavi × 9 locali nativi** (399 + 7)
  - **App sostanzialmente chiusa lato i18n user-facing al 100%** — Admin + Business + Candidate + Auth + Services + Shared Widgets tutti coperti

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
### Candidate

- DONE (Fase 7C — 2026-04-17) — quick plug badge + profile setup divider (chiusura Candidate):
  - `candidate_quick_plug_view.dart`, `candidate_profile_setup_view.dart`
  - Coperti: `{count} new` pendingCount badge (quick_plug header), `Looking for: {jobTitle}` context label (InterestCard), `or` divider (profile_setup tra upload CV e fill manually)
  - **1 chiave riusata** dal catalogo esistente (`lookingFor({role})`)
  - **2 chiavi nuove** × 11 locali (`quickPlugNewBadge({count}, plural)`, `orLabel`)
  - Tutti i 9 locali con forme native (en/it/ar/es/fr/pt/de/ru/zh) + fallback en per hi/tr
  - build bump 1.0.0+11 → 1.0.0+15, branch `phase7c-candidate-i18n`
  - analyze: **0 errors/warnings** (30 info-level pre-esistenti)
  - **Candidate i18n sostanzialmente chiuso.** Dopo 7A+7B+7C i file principali dell'area candidate (`candidate_chat_view`, `candidate_messages_tab`, `candidate_quick_plug_view`, `candidate_profile_setup_view`) non hanno più residui user-facing semplici. Residui puntuali rimasti sono runtime/mock data e helper interni classificati fuori scope

- DONE (Fase 7B — 2026-04-17) — messages tab summary + delete flows:
  - `candidate_messages_tab.dart`
  - Coperti: conversation count (ICU plural), unread count (ICU), Retry action, empty state (title + subtitle), selection bar (Select items / N selected / Clear / Select all), swipe background Delete, dialog single delete (title + body `{company}`), dialog bulk delete (title plural + body), dialog delete-all (title + body ICU count), Delete all / Cancel buttons, `Re:` prefix x2 (ICU `{context}`)
  - **12 chiavi riusate** dal catalogo esistente (`cancel`, `delete`, `retry`, `clear`, `selectAll`, `selectItems`, `countSelected`, `noMessagesYet`, `whenEmployersMessageYou`, `deleteConversation`, `deleteAllConversations`, `deleteAll`)
  - **7 chiavi nuove** con ICU placeholder (`rePrefix({context})`, `conversationCount({count}, plural)`, `unreadCount({count})`, `removeChatBody({company})`, `deleteConversationsCount({count}, plural)`, `selectedChatsBody`, `clearInboxBody({count}, plural)`)
  - Tutti i 9 locali con forme plurali native (en/it/ar/es/fr/pt/de/ru/zh) + fallback en per hi/tr
  - build bump 1.0.0+11 → 1.0.0+14, branch `phase7b-candidate-i18n`
  - analyze: **0 errors/warnings** (30 info-level pre-esistenti)
  - **File chiuso al 100%** — nessun residuo user-facing rimasto

- DONE (Fase 7A — 2026-04-17) — chat view online/business/waiting:
  - `candidate_chat_view.dart`
  - Coperti: `Online now` status indicator (header), `BUSINESS` badge (bubble sender name), `Waiting for the business to send the first message` empty state (composer banner)
  - **0 chiavi nuove** — riuso totale del catalogo esistente: `onlineNow`, `businessUpper`, `waitingForBusinessFirstMessage` (già presenti in 9 locali + hi/tr fallback)
  - build bump 1.0.0+11 → 1.0.0+13, branch `phase7a-candidate-i18n`
  - analyze: **0 errors/warnings** (30 info-level pre-esistenti)
  - Residui `candidate_chat_view.dart`: separatore decorativo `'  ·  '` (SKIP, non-testuale), `PM`/`AM` (SKIP, helper interno `_formatTime`)

### Auth

- DONE (Fase 8A — 2026-04-17) — forgot password step 2 subtitle:
  - `forgot_password_sheet.dart` (solo 1 sostituzione)
  - File scansionati senza modifiche: `business_login_view.dart`, `candidate_login_view.dart`, `entry_view.dart` (già completamente i18n)
  - Coperti: subtitle step 2 `A code has been sent to {email}` (ICU `{email}` String placeholder)
  - **1 chiave nuova** × 11 locali (`codeSentToEmail({email})`) — nessun riuso possibile dal catalogo
  - Tutti i 9 locali con traduzioni native (en/it/ar/es/fr/pt/de/ru/zh) + fallback en per hi/tr
  - build bump 1.0.0+11 → 1.0.0+16, branch `phase8a-auth-i18n`
  - analyze: **0 errors/warnings** (31 info-level pre-esistenti)
  - **Auth sostanzialmente chiuso.** Residui rimasti fuori scope per design: dev-only text dentro `kDebugMode` (`Dev Login → ...`, `Dev Skip → ...`, `Create Test Candidate → ...`), logo fallback `'P'`, brand name `'Plagit'` (line 82 entry_view), OTP hint `'000000'` (pattern numerico universale). Audit iniziale (10-12 chiavi stimate) si è rivelato sovrastimato: i 4 file erano già quasi completamente localizzati dalle fasi precedenti

### Business

- DONE (Fase 6A — 2026-04-17) — schedule interview field labels (chiusura Business):
  - `business_schedule_interview_view.dart`
  - Coperti: 2 conditional field labels (`Meeting Link` quando type=Video Call, `Location` quando type=In Person) — entrambi usati sia come `Text` label sia come `hintText` del TextField tramite helper `_field`
  - 2 nuove chiavi (`businessFieldMeetingLink`, `businessFieldLocation`) × 11 locali ARB
  - build bump 1.0.0+11 → 1.0.0+12, branch `phase6a-business-i18n`
  - analyze: **0 errors/warnings** (30 info-level pre-esistenti non introdotti da 6A)
  - **Business i18n sostanzialmente chiuso.** Audit completo su 22 view ha confermato: 19/22 file già clean, 2 residui su nearby_talent (role keys interne, già mappate a label i18n) e post_job (hint numerici placeholder non-UI) classificati FUORI SCOPE

- DONE (Fase 5D — 2026-04-17) — job detail (ultima chiusura Admin):
  - `admin_job_detail_view.dart`, `admin_shared_widgets.dart` (micro-fix)
  - Coperti (job_detail): action bar (Feature/Unfeature toggle + Pause/Close/Remove), snackbar `Job featured/unfeatured/removed`, 3 dialog confermativi (Pause/Close/Remove Job) con title+body, `View Applicants` button, job info card (Pay/Type/Location/Posted/Applicants/Views labels), badge `Featured`/`Urgent`, Compensation Review section + Moderation pill, tutti i field compensation (Employment/Summary/Salary range/Annual/Monthly/Duration/Hourly/Weekly hours/Bonus/Shift + `Not specified`), Extras subsection, 5 perks chip (Housing/Travel/Overtime/Flexible/Weekend), Applicants Summary section + 5 count chips (Total/New/Reviewed/Shortlisted/Rejected), Moderation section + flag toggle text (`Flag this job` / `This job is flagged`), flag reason placeholder, dialog helper `_showConfirmDialog` rifattorizzato per ricevere `AppLocalizations` + Cancel/Confirm via catalogo
  - Coperti (shared_widgets): `aSortRow` ora accetta `BuildContext` → label `Newest` via `adminSortNewest` (chiave già esistente)
  - 43 nuove chiavi (action×3, badge×1, field×13, misc×1, section×4, placeholder×1, snackbar×3, dialog×6, moderation×2, perk×5, stat×4)
  - Riusati: `adminActionFeature`, `adminActionUnfeature`, `adminActionRemove`, `adminActionCancel`, `adminActionConfirm`, `adminBadgeUrgent`, `adminFieldType`, `adminFieldLocation`, `adminStatApplicants`, `adminStatTotal`, `adminSortNewest`
  - build bump 1.0.0+10 → 1.0.0+11, branch `phase5d-admin-i18n`
  - analyze: **0 errors/warnings** (3 pre-esistenti `info use_build_context_synchronously` non introdotti da 5D)
  - **Admin i18n chiuso al 100% sulle views user-facing.** Residui rimanenti sono solo runtime/mock/out-of-scope documentati (Mirko Picicco identity, _AttentionItem.text Fase E opzionale, mock notes, % progress, ICU opzionali di Fase 4)

- DONE (Fase 5B — 2026-04-17) — verification + moderation + support detail:
  - `admin_verification_detail_view.dart`, `admin_moderation_detail_view.dart`, `admin_support_detail_view.dart`
  - Coperti (verification): header subtitle (Verification Review), Profile Summary section, Submitted field, Documents section, document cards (ID Document/CV/Registration titles+subtitles), View Document action, viewing-document snackbar (ICU `{title}`), Decision section (riuso `adminStatusDecision`), Approve/Reject buttons, Approve dialog (title + ICU body `{name}` + Cancel + Approve + verification approved snackbar), Reject dialog (title + ICU body `{name}` + rejection reason placeholder + Cancel + Reject + verification rejected snackbar), Notes section, Add a note placeholder, Save Note, Note saved snackbar
  - Coperti (moderation): topbar (Report Detail), Report Information section, Type/Priority/Date/Reporter/Entity field labels, Platform value, `aPriorityLabel` su priority pill, Evidence section, Admin Decision section, Status dropdown via `aStatusLabel`, Action dropdown via nuovo helper `_actionOptionLabel` (None/Warning/Content Removed/Account Suspended), Note field label, decision notes placeholder, Save Decision button, Decision saved snackbar (ICU dual `{status}/{action}`), Audit Trail section, "Report created by Platform auto-detection"
  - Coperti (support): topbar fallback (Support Issue), Issue not found empty state, Category/Priority/Created/Updated/User field labels, Support value, priority value via `aPriorityLabel`, Description section, Update Status section, status dropdown 4 valori via `aStatusLabel` (Open/In Review/Waiting/Resolved), Update button, ICU status-updated snackbar `{status}`, Notes section (riuso `adminTabNotes`), Add a note placeholder, Add Note button, Resolution section, Resolution summary placeholder, Mark Resolved button, Issue resolved snackbar
  - 51 nuove chiavi (section×12, field×8, doc×6, action×4, actionOption×4, placeholder×3, snackbarStatic×3, snackbarICU×3, dialog×4, empty×1, misc×3) + 5 ICU (ViewingDocument `{title}`, StatusUpdatedTo `{status}`, DecisionSaved `{status,action}`, ApproveVerificationBody `{name}`, RejectVerificationBody `{name}`)
  - Nuovo helper locale `_actionOptionLabel(l, option)` dentro moderation view
  - Riusati: `adminStatusDecision` (5A), `adminFieldStatus`, `adminFieldAction`, `adminFieldType`, `adminFieldDate`, `adminFieldCategory`, `adminFieldReason`, `adminTabNotes`, `adminPlaceholderAddNote`, `adminActionCancel`, `adminActionApprove`, `adminActionReject`, `adminActionAddNote` (5A), `adminActionSaveNote`, `adminSnackbarNoteSaved`, `aStatusLabel` (Open/In Review/Waiting/Resolved/Decision), `aPriorityLabel`
  - Skip volontari (fuori scope): `Admin User` (runtime identity), mock note text "Looking into this issue...", mock userName/userType nel type badge
  - build bump 1.0.0+9 → 1.0.0+10, branch `phase5b-admin-i18n`
  - analyze: **0 errors/warnings** (3 pre-esistenti `info use_build_context_synchronously` non introdotti da 5B — guardia `mounted` già presente)
  - Gruppo 5 chiuso completamente: 5C + 5A + 5B = 6 detail views admin localizzate

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
(+ 28 chiavi Fase 2 + 36 chiavi Fase 3 + 31 chiavi Fase 4 + 16 chiavi Fase 4-bis + 36 chiavi Fase 5C + 33 chiavi Fase 5A + 51 chiavi Fase 5B + 43 chiavi Fase 5D Admin + 2 chiavi Fase 6A Business + 0 chiavi Fase 7A Candidate (tutto riuso) + 7 chiavi Fase 7B Candidate + 2 chiavi Fase 7C Candidate + 1 chiave Fase 8A Auth → totale cumulativo 399 chiavi × 9 locali)

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

## Sessione 2026-04-17 — Fase 5B chiusa

### Fatto
- Fase 5B: verification + moderation + support detail (3 file Dart, 51 chiavi ARB + 5 ICU)
- Helper locale `_actionOptionLabel` per dropdown action moderation (4 opzioni)
- Riuso massimo catalogo esistente (status via `aStatusLabel`, priority via `aPriorityLabel`, field/section/action/placeholder da fasi precedenti)
- Gruppo 5 (detail views) completamente chiuso: 5C (subscription/audit) + 5A (application/interview) + 5B (verification/moderation/support)

### Rimasto a metà
- Niente — 5B approvabile con analyze pulito

## Sessione 2026-04-17 — Fase 5D chiusa (chiusura finale Admin)

### Audit finale pre-5D
- Scan 35 file `lib/features/admin/views/*.dart` → solo 2 aperti (admin_job_detail_view + micro-residuo in admin_shared_widgets `aSortRow`)
- Admin sostanzialmente chiuso al 94% prima di 5D

### Fatto
- Fase 5D: job detail + shared_widgets (1 file principale + 1 micro-fix)
- 43 chiavi nuove iniettate in 9 locali (action/badge/field/misc/section/placeholder/snackbar/dialog/moderation/perk/stat)
- Refactor helper `_showConfirmDialog` per accettare `AppLocalizations` → Cancel/Confirm via catalogo
- Refactor `aSortRow(BuildContext, int, String)` per usare `adminSortNewest` già esistente
- Riuso 11 chiavi già in catalogo

### Rimasto a metà
- Niente — Admin i18n chiuso al 100% sulle views user-facing

### Stato finale Admin i18n
- **Totale chiavi admin* cumulative:** 387 × 9 locali
- **Views coperte:** 35/35 (core + secondarie + detail)
- **Residui esclusi per scelta esplicita:** identità runtime (Mirko Picicco, email), `_AttentionItem.text` (Fase E opzionale), mock notes/fake phone, `%` progress, ICU opzionali Fase 4, model labels (Compensation/EmploymentType)
- **10 fasi admin chiuse:** core(A/B/B-bis/C/D) + 1 + 2 + 3 + 4 + 4-bis + 5C + 5A + 5B + 5D

### Prossimo passo consigliato
1. **Admin chiuso, passare ad altra area:** Candidate o Business
2. Opzionale: Fase E (`_AttentionItem.text` con ICU `{count}`) per coprire l'ultimo 1% — consigliato solo se serve il 100% assoluto
3. Opzionale: sostituire identità runtime con `AdminAuthProvider.userName/userEmail` (refactor, non i18n)
