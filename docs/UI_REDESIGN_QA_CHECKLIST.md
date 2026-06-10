# UI Redesign — QA & Regression Checklist

Run the **per-phase** section after every phase PR; run the **full** checklist before the final merge to `main`.

## Per-phase gates (every PR)

- [ ] `flutter analyze` — zero issues
- [ ] `flutter test` — all green (including pre-existing: login_controller, bookings_controller, financial_transfers tests)
- [ ] `flutter build apk --debug` succeeds
- [ ] Golden tests for touched widgets/screens updated intentionally (no accidental diffs)
- [ ] Screens touched verified in **Arabic (RTL)** and **English (LTR)**
- [ ] No provider/route/validator/service file diffs except imports of presentation widgets (review the diff file list explicitly)
- [ ] No `.env`, secrets, or generated junk committed

## Functional regression (high-risk flows)

- [ ] Login → correct role landing (admin/broker/cleaner/viewer), logout, forgot password
- [ ] Onboarding completes once and never re-appears; splash redirect timing unchanged
- [ ] Create / edit / cancel summer booking — validation messages, date pickers, save to DB, sync
- [ ] Early checkout + overstay extension flows end-to-end
- [ ] Create / edit winter contract; record payment; payment history accurate
- [ ] Apartments grid statuses match DB; profile actions work
- [ ] Expenses / building rent / transfers: amounts formatted via `currency_formatter`, totals unchanged
- [ ] Reports numbers identical pre/post redesign (spot-check 3 metrics); statement PDF export renders & shares
- [ ] Offline mode: sync engine still syncs; offline banner/states styled but functional
- [ ] Push + local notifications still display; notifications screen lists them
- [ ] Admin-only routes still blocked for non-admins (`_AdminOnlyRoute`)
- [ ] Global search returns same results
- [ ] Data management (backup/restore/destructive actions) untouched and confirmed working

## Visual / UX

- [ ] RTL: chevrons, back buttons, FAB position (inset-inline-end), timelines, progress bars all mirror correctly (`EdgeInsetsDirectional` everywhere)
- [ ] Dark theme complete; light theme (if in scope) has no unreadable combos
- [ ] Loading / empty / error states present on every list screen (LoadingSkeleton / EmptyState / ErrorState)
- [ ] Touch targets ≥ 48dp; contrast WCAG AA (amber-on-dark and ink3 captions are the risky pairs)
- [ ] Text scale 1.3× and small-width (360dp) — no overflows on dashboard, cards, forms
- [ ] Animations honor reduced-motion; no jank scrolling 100+ item lists (profile on low-end Android)
- [ ] Tabular figures on all money/counts; Arabic numerals per existing `intl` behavior (unchanged)

## Device matrix (final)

- [ ] Android small (≈360×640), Android standard (≈390×844), Android tablet smoke
- [ ] iOS simulator smoke (if iOS shipping)
- [ ] Windows desktop smoke (window resize sanity)

## Known risk register

| # | Risk | Mitigation |
|---|---|---|
| 1 | Global ThemeData flip degrades un-migrated screens | Phase-1 full-app smoke; deprecated color aliases keep old screens coherent |
| 2 | Hard-coded colors bypass theme | Per-phase sweep + Phase-8 hex grep |
| 3 | Form regressions (validation/save) | Presentation-only diffs; Phase-6 manual regression per form |
| 4 | RTL mirroring bugs | Directional APIs only; ar+en gate per PR |
| 5 | CSS effects not portable (color-mix, blur shadows) | Token-level translation defined in DESIGN_TOKENS doc, no per-screen improvisation |
| 6 | Shadow/gradient overdraw on low-end devices | const widgets, RepaintBoundary on lists, profile in Phase 8 |
| 7 | Prototype dummy data leaking into UI | Rule: bind only to existing providers; reviewers check for literals |
| 8 | Icon mismatches (custom line set vs Material) | Map once in design system; custom painters only for skyline/meter |
| 9 | Platform differences (Windows build also ships) | Windows smoke each phase-merge |
| 10 | Pre-existing: `.env` bundled as asset in pubspec | Out of scope — flagged to owner separately |
