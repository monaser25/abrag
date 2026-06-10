# UI Redesign Migration Plan — Abrag

**Status:** Phase 0 (Discovery) complete — awaiting approval before any implementation.
**Date:** 2026-06-10
**Design source of truth:** `abrag/` prototype (HTML/CSS/JSX, "ابراج" redesign — royal-blue indigo + amber identity).
**Production code:** Flutter app at repo root. Must keep all business logic, routing, data flows, auth, and validations intact.

---

## 1. Current Flutter App (as-is)

| Aspect | Finding |
|---|---|
| SDK | Dart `^3.11.5` (Flutter stable ~3.38.x era), Material 3 enabled |
| State management | Riverpod 2.x (`flutter_riverpod`, `riverpod_annotation`) |
| Routing | GoRouter 17.x — single `routerProvider` in `lib/core/routes/app_router.dart`, auth/onboarding redirect logic, `_AdminOnlyRoute` guard |
| Theme | `lib/core/theme/` — `AppColors` (navy `#0D1B2A` + gold `#F4A225`), `AppTypography` (IBM Plex Sans Arabic), `AppTheme.darkTheme` only (no light theme) |
| Backend | Supabase (auth + data) + Drift/SQLite local DB + custom `sync_engine.dart` (offline-first) + Firebase Messaging push |
| Localization | `flutter_localizations` + ARB (`lib/l10n/app_ar.arb`, `app_en.arb`), `localeProvider`, full RTL support |
| Fonts | IBM Plex Sans Arabic (Regular/Medium/Bold) in `assets/fonts/` — **same family as prototype** |
| Assets | `.env` bundled as asset (see Risks), app icon `assets/icons/abrag_icon.png`, splash via `flutter_native_splash` (navy) |
| Features | auth, onboarding, splash, dashboard, bookings (summer), contracts (winter), apartments, buildings, financials, operations, reports, settings, users/brokers/customers, search, web_views (role-based homes: broker/cleaner/viewer) |
| Shared widgets | **None** — no `lib/shared/widgets/`; each screen builds its own UI (this is the biggest migration surface) |
| Flavors | None |
| Tests | 3 provider unit tests + 1 widget test |
| Commands | `flutter pub get`, `flutter analyze`, `flutter test`, `flutter build apk`, `dart run build_runner build` (drift/freezed codegen) |

The legacy `screens/` folder contains the *old* HTML exports (navy/gold design the current app was built from) — input-only reference, not the new design.

## 2. Prototype (`abrag/` folder)

Files: `Abrag Redesign.html` (entry), `app.jsx` (screen registry + tweaks), `components.jsx` (shared UI kit), `styles.css` (design tokens), `frame.css` (component chrome), `bits.css`, `screens_{auth,home,bookings,contracts,apartments,reports,data}.jsx`, `tweaks-panel.jsx`, `assets/abrag_logo.png`.

- **Identity:** royal blue `#1B5CF0` brand + amber `#FCBC15` accent on deep indigo background — a **deliberate departure** from the current navy/gold.
- **Themes:** dark (default) **and** light, via CSS vars.
- **Layout assumptions:** 390×844 phone frame, mobile-first, RTL default with ar/en toggle.
- **Screens designed (20):** splash, onboarding, login, dashboard, broker/cleaner/viewer role homes, bookings hub, booking detail, booking add, contracts hub, contract detail, payment history, apartments grid, apartment profile, reports, statement preview, notifications, search, settings.
- **Screens deliberately stubbed** (`stub:` navigation in prototype): everything else — forms, buildings, financials, operations, users management, settings sub-screens.
- Full token + component inventory: see `UI_REDESIGN_DESIGN_TOKENS.md`. Screen-by-screen mapping: `UI_REDESIGN_SCREEN_MAP.md`.

## 3. Strategy

1. **Design system first.** Translate CSS tokens into `AppColors`/`AppTextStyles`/`AppSpacing`/`AppRadius`/`AppShadows` + a shared widget kit under `lib/shared/widgets/` mirroring the prototype component kit (StatCard, NavRow, Chip, EmptyState, …). No screen rewrites in this phase; global `ThemeData` swap re-skins Material primitives app-wide consistently.
2. **Presentation-only screen migration, phase by phase.** Each screen keeps its providers, controllers, routes, and validation; only `build()` trees and local presentation widgets change. Prototype dummy data is never copied — screens keep binding to real providers.
3. **Missing screens are extrapolated**, never invented: each unmapped screen is assembled from the shared kit + the closest designed pattern (e.g. all "Add X" forms follow the `BookingAdd` form pattern; all list screens follow the bookings-hub card/list pattern).
4. **No route, provider, or schema changes.** GoRouter tree in `app_router.dart` stays untouched except for purely visual transition polish if approved.

## 4. Branch / PR strategy

```
main (protected — no direct work, no direct pushes)
└── ui-redesign/prototype-migration        ← integration branch (created from main)
    ├── ui-redesign/design-system          ← Phase 1
    ├── ui-redesign/navigation-shell       ← Phase 2 (splash/onboarding/auth + app shell)
    ├── ui-redesign/dashboard              ← Phase 3 (dashboard + role homes)
    ├── ui-redesign/core-flows             ← Phase 4 (bookings, contracts, apartments)
    ├── ui-redesign/reports-settings       ← Phase 5 (reports, statement, search, notifications, settings)
    ├── ui-redesign/forms-modals           ← Phase 6 (all add/edit forms, dialogs)
    ├── ui-redesign/missing-screens        ← Phase 7 (financials, operations, users, settings sub-screens)
    └── ui-redesign/final-qa               ← Phase 8 (polish, regression sweep, goldens)
```

- Each phase branch is cut **from the integration branch**, gets its own PR **into the integration branch**, and must pass `flutter analyze` (0 issues) + `flutter test` + a debug APK build before merge.
- Phase PRs are merged by the owner after review — never self-merged.
- One **final PR** `ui-redesign/prototype-migration → main` after Phase 8 QA sign-off. Production stays on `main`/current behavior until that single reviewed merge.
- Rollback: every phase is independently revertable; the integration branch can be abandoned at any time with zero impact on `main`.
- Conventional commits (`feat(ui): …`, `refactor(ui): …`); no secrets/`.env` ever committed.

## 5. Implementation phases

| Phase | Branch | Scope | Risk |
|---|---|---|---|
| 1 | `design-system` | Tokens, `ThemeData` (dark + light scaffold), shared widget kit, no screen rewrites | Medium (global re-skin) |
| 2 | `navigation-shell` | Splash, onboarding, login, forgot-password; app-bar/scaffold conventions | Low |
| 3 | `dashboard` | Dashboard + broker/cleaner/viewer role homes | Medium |
| 4 | `core-flows` | Bookings (hub/list/detail/calendar), contracts (hub/detail/payments), apartments (grid/profile) | High (most-used flows) |
| 5 | `reports-settings` | Reports suite, statement, search, notifications, settings root | Medium |
| 6 | `forms-modals` | All add/edit forms, dialogs, confirmation sheets (extrapolated from BookingAdd pattern) | High (stateful forms/validation) |
| 7 | `missing-screens` | Buildings, financials, operations, users/brokers/customers, settings sub-screens | Medium |
| 8 | `final-qa` | RTL/LTR sweep, dark/light sweep, device matrix, regression checklist, goldens | Low |

Task-level breakdown: `UI_REDESIGN_TASKS.md`. Progress tracking: `UI_REDESIGN_PROGRESS.md`.

## 6. Verification per phase

- `flutter analyze` → zero issues
- `flutter test` → all green (existing 4 tests must keep passing untouched)
- `flutter build apk --debug` (primary target); `flutter build appbundle` at final QA
- Manual QA on the screens touched in that phase, in **both ar (RTL) and en (LTR)**, per `UI_REDESIGN_QA_CHECKLIST.md`
- Golden tests: introduced in Phase 1 for the shared kit (one golden per shared widget, ar+en), extended per phase for migrated screens — feasible since the kit is pure presentation
- Device matrix: small Android phone (≈360 dp), standard (≈390 dp), tablet smoke test; Windows desktop smoke test (app currently builds for Windows)

## 7. Key risks (summary — details in QA checklist)

1. **Global theme flip** re-skins un-migrated screens too: un-migrated screens must stay *legible* under new ThemeData; Phase 1 QA includes a full-app smoke pass.
2. **Hard-coded old colors inside screens** won't follow the theme — they get swept per phase, not in Phase 1.
3. **RTL:** prototype is RTL-first; Flutter work must use `EdgeInsetsDirectional`/`AlignmentDirectional` everywhere.
4. **Stateful forms** (booking/contract add-edit) are the highest regression risk — presentation-only edits, validators and controllers untouched, manual regression after each form.
5. **CSS → Flutter differences:** `color-mix()` soft tints → `Color.withValues()`; CSS shadows → `BoxShadow` lists; shimmer/`screenIn` animations → explicit Flutter animations (respect `MediaQuery.disableAnimations`).
6. **Light theme** exists in prototype but not in app — scope decision needed (see Open Questions).
7. **`.env` is bundled as a Flutter asset** (pre-existing; out of scope but flagged): secrets ship inside the APK.
8. **Performance:** soft-tint + shadow heavy lists must reuse const widgets; avoid per-row `BoxShadow` overdraw on low-end devices.

## 8. Open questions (blocking implementation start)

1. **Identity switch confirmed?** Prototype replaces navy/gold with indigo/royal-blue/amber. App icon + native splash are currently navy/gold — should they be updated too (new logo asset exists in prototype)?
2. **Light theme:** in scope (prototype supports it) or dark-only for now?
3. **Platform priority:** Android-first? (iOS/web/Windows folders all exist.)
4. **Brand font:** keep IBM Plex Sans Arabic (prototype default — zero font work) — confirm.
5. **Golden tests:** acceptable to add as dev-only infrastructure?
