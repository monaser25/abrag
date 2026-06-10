# UI Redesign — Progress Tracker

| Phase | Branch | Status | PR | Notes |
|---|---|---|---|---|
| 0 — Discovery & planning | — | ✅ Done (2026-06-10) | — | Plan approved by owner 2026-06-10 |
| 1 — Design system | `ui-redesign/design-system` | ✅ Merged (PR #1, `a4d475a`) | [#1](https://github.com/monaser25/abrag/pull/1) | Tokens, theme, 21-widget kit, golden gallery |
| 2 — Navigation shell / auth | `ui-redesign/navigation-shell` | 🔄 In review | (see PR) | Splash, onboarding, login, forgot password, RootScreen shells; native splash → #080C24; +AbragLogo/AppScaffold/SpinningIcon; screen goldens |
| 3 — Dashboard & role homes | `ui-redesign/dashboard` | ⏸ Not started | — | |
| 4 — Core flows | `ui-redesign/core-flows` | ⏸ Not started | — | |
| 5 — Reports & settings | `ui-redesign/reports-settings` | ⏸ Not started | — | |
| 6 — Forms & modals | `ui-redesign/forms-modals` | ⏸ Not started | — | |
| 7 — Missing screens | `ui-redesign/missing-screens` | ⏸ Not started | — | |
| 8 — Final QA | `ui-redesign/final-qa` | ⏸ Not started | — | |

## Decisions log (owner-approved 2026-06-10)

| Date | Decision | By |
|---|---|---|
| 2026-06-10 | Presentation-only migration; design-system-first; integration-branch workflow | owner |
| 2026-06-10 | Identity switch approved: navy/gold → indigo/royal-blue/amber across the app | owner |
| 2026-06-10 | Dark-theme-first; design system must be light-ready but no half-baked light ship | owner |
| 2026-06-10 | Android top priority; keep Windows/web building; visual QA mobile-first | owner |
| 2026-06-10 | Golden tests approved as lightweight dev-only infra; document as optional if heavy | owner |
| 2026-06-10 | Ship the elevated card style only; no tweak-panel/experimental variants | owner |

## Screen migration status

See `UI_REDESIGN_SCREEN_MAP.md` for the full list — statuses will be tracked here per screen once Phase 1 starts.
