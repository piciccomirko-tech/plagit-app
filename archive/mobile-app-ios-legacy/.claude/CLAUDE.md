# Plagit — Claude Code Context

## App Info
- **Name**: Plagit — premium hospitality recruitment app
- **Bundle ID**: `com.invain.mh`
- **Stack**: SwiftUI (iOS 17+, no Flutter)
- **Backend**: Node/Express on Railway — `https://plagit-backend-production.up.railway.app/v1`
- **Backend repo**: `~/Desktop/Plagit new project/plagit-backend`
- **Source files**: 128 Swift files in `Plagit/Plagit/`

## Priorities (in order)
1. Functional bugs
2. Navigation speed
3. Login / logout stability
4. Registration flow
5. Uploads (photo / CV)
6. Language logic
7. Search / filters
8. UI polish
9. Dark mode (later, only when core is stable)

Do not prioritize visual polish over broken functionality.

---

## Project Structure
```
Plagit/
  Plagit.xcodeproj
  Plagit/
    PlagitApp.swift          ← entry point (debugAutoLogin toggle)
    EntryView.swift          ← role selection: Candidate or Business
    Theme.swift              ← brand colors, fonts, spacing, radius, shadows
    APIClient.swift          ← shared HTTP client
    AppLocaleManager.swift   ← language detection, persistence, override
    L10n.swift               ← runtime localization strings
    Models.swift             ← shared DTOs
    LoadingState.swift       ← .idle / .loading / .loaded / .error enum

    # Candidate flow
    CandidateRootView.swift         ← auth gate (AuthView or HomeView)
    CandidateAuthService.swift      ← login, register, logout, session restore
    CandidateAuthView.swift         ← login screen
    CandidateSignUpView.swift       ← registration
    CandidateProfileSetupView.swift ← onboarding profile completion
    CandidateAPIService.swift       ← all /candidate/* API calls
    HomeView.swift                  ← candidate home dashboard
    CandidateRealProfileView.swift  ← profile edit (photo, details)
    CandidateJobsView.swift         ← job search & browse
    CandidateJobDetailView.swift    ← single job detail
    MyApplicationsView.swift        ← application tracker
    CandidateMessagesView.swift     ← conversations list
    CandidateChatView.swift         ← single chat thread
    CandidateInterviewsListView.swift
    CandidateNearbyRealView.swift   ← map-based nearby jobs
    CandidateCommunityView.swift    ← community feed

    # Business flow
    BusinessRootView.swift          ← auth gate
    BusinessAuthService.swift       ← login, logout, session restore
    BusinessAuthView.swift / BusinessSignUpView.swift
    BusinessAPIService.swift        ← all /business/* API calls
    BusinessHomeView.swift          ← business dashboard
    BusinessRealProfileView.swift   ← company profile edit
    BusinessRealJobsView.swift      ← manage listings
    BusinessRealPostJobView.swift   ← create new job
    BusinessRealMessagesView.swift  ← conversations
    BusinessRealInterviewsView.swift
    BusinessNearbyTalentView.swift  ← map-based nearby candidates
    BusinessShortlistView.swift

    # Admin panel (17 screens)
    AdminRootView / AdminLoginView / AdminDashboardView
    Admin*View.swift         ← screen views
    Admin*ViewModel.swift    ← @Observable view models
    Admin*APIService.swift   ← real API calls to /admin/*
    Admin*Service.swift      ← mock data (being replaced)

    # Shared
    ActivityView.swift       ← notifications (both flows)
    FeedService.swift        ← community feed
    LanguagePickerView.swift ← spoken language multi-select
    ProfileAvatarView.swift  ← reusable avatar
    LocationManager.swift    ← CLLocationManager wrapper
    CountryFlag.swift        ← emoji flag from country code
```

---

## Architecture
- **State**: `@Observable` classes (not ObservableObject/Combine)
- **Singletons**: `CandidateAuthService.shared`, `BusinessAuthService.shared`, `APIClient.shared`
- **Auth**: JWT access + refresh tokens in iOS Keychain (separate namespaces per role)
- **Navigation**: single `NavigationStack` in PlagitApp + `navigationDestination(isPresented:)`
- **API**: all calls through `APIClient.request()` — handles auth headers, JSON encode/decode
- **Loading**: `LoadingState` enum across all views

---

## User Types

### Candidate
Create account, complete profile, upload photo, upload CV, browse jobs, apply, messages, notifications, interviews, logout.

### Business
Create account, complete business profile, post jobs, browse candidates, messages, notifications, applicants, interviews, logout.

**Rule**: any UX fix must be checked on BOTH flows. Do not fix one side and forget the other.

---

## Brand Colors (Theme.swift)
| Token | Usage |
|-------|-------|
| `.plagitTeal` | Primary brand, buttons, links |
| `.plagitTealDark` | Gradient end, pressed states |
| `.plagitCharcoal` | Primary text |
| `.plagitSecondary` | Secondary text |
| `.plagitTertiary` | Hint text, icons |
| `.plagitBackground` | Page background (light gray) |
| `.plagitCardBackground` | Card background (white) |
| `.plagitOnline` | Success/online (green) |
| `.plagitUrgent` | Error/destructive (red) |
| `.plagitAmber` | Warning, gold accents |
| `.plagitIndigo` | Secondary accent |

### UI Rules
- No pure black backgrounds — use `.plagitBackground` or `.plagitSurface`
- Use Theme.swift tokens — never hardcode colors, fonts, or spacing
- Keep UI clean, premium, modern, soft: teal tones, rounded cards, clear typography
- Consistent spacing and button styles across both flows
- Do not redesign unrelated screens during bug fixes

---

## Auth Flow
1. `PlagitApp` → `EntryView` (role selection)
2. User picks Candidate or Business → pushes root view
3. Root view checks `auth.isAuthenticated`: false → login, true → home
4. `.task { await auth.restoreSession() }` attempts token refresh
5. Logout clears: APIConfig.authToken, keychain tokens, user state, locale

### Logout Must Always
- Clear token and refresh token
- Clear saved session (keychain)
- Clear in-memory user state
- Reset locale to device language
- **dismiss() before clearing auth** — otherwise nav stack blocks transition
- Return to correct public screen

### Registration Must
- Create account successfully
- Route to correct next step (profile setup)
- Not mix candidate and business logic

---

## Navigation Rules
- Back navigation must be immediate
- No duplicate pushes, no unnecessary reloads
- No nested NavigationStacks — only PlagitApp wraps in NavigationStack
- Logout must always return to correct entry screen
- User must not re-enter private area without logging in
- `debugAutoLogin` in PlagitApp.swift — set `false` for real testing

---

## Localization
- **Supported**: en, it, fr, es, de, ar, pt, ru, tr, hi, zh
- **System**: `AppLocaleManager` detects device language, persists to UserDefaults
- **Strings**: `L10n.swift` → `L10n.propertyName`
- **Post-login sync**: HomeView syncs `appLanguageCode` from server
- **On logout**: resets to device language

### Language Defaults
- UK / London → English
- Italy → Italian
- Arabic region → Arabic
- Do not use stale cached language incorrectly
- Do not force Arabic for non-Arabic registration

RTL support must be correct for Arabic.

---

## Forms Rules
- Clear validation, good placeholders, working back behavior
- No frozen buttons, no dead taps
- Password: hidden by default, eye icon to toggle
- Photo picker and document picker must open correctly

### Profile Completion (Candidate)
Photo, role, location, availability, languages, CV upload — each tap must work.

### Profile Completion (Business)
Same quality standard as candidate.

---

## Development Rules
1. **Read before writing** — inspect existing files before any change
2. **Smallest safe fix** — do not refactor surrounding code
3. **Do not break the other flow** — candidate and business are independent
4. **Do not duplicate logic** — reuse shared services
5. **Admin screens**: ViewModel + APIService pattern, @Observable
6. **Test both flows** when changing shared code (APIClient, Theme, L10n, Models)
7. **Fix warnings only when safe** — do not risk app logic for cosmetic cleanup

### For large tasks
1. Inspect
2. Explain plan briefly
3. Implement
4. Summarize files changed

---

## Testing Order
1. Candidate registration
2. Candidate login
3. Candidate profile completion
4. Candidate logout
5. Business registration
6. Business login
7. Business actions
8. Business logout

Prefer simulator for fast iteration. Real device for final validation.

---

## Required Output Format
After every implementation, respond with:

### Root cause
Short explanation.

### Files changed
List of files.

### What I changed
Short bullet list.

### Anything to test now
Short bullet list.

Keep responses practical and short.
