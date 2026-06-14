# UI Redesign — Progress Tracker

| Phase | Branch | Status | PR | Notes |
|---|---|---|---|---|
| 0 — Discovery & planning | — | ✅ Done (2026-06-10) | — | Plan approved by owner 2026-06-10 |
| 1 — Design system | `ui-redesign/design-system` | ✅ Merged (PR #1, `a4d475a`) | [#1](https://github.com/monaser25/abrag/pull/1) | Tokens, theme, 21-widget kit, golden gallery |
| 2 — Navigation shell / auth | `ui-redesign/navigation-shell` | ✅ Merged (PR #2, `28e120e`) | [#2](https://github.com/monaser25/abrag/pull/2) | Incl. 3 device-test review fixes |
| 3 — Dashboard & role homes | `ui-redesign/dashboard` | ✅ Merged (PR #3, `2257bf2`) | [#3](https://github.com/monaser25/abrag/pull/3) | Feature-preservation rule; meter readings restored + guarded (`_PermissionRoute`, manage_expenses) |
| 4 — Core flows | `ui-redesign/core-flows` | ✅ Merged (PR #4, `1cf6e8e`) | [#4](https://github.com/monaser25/abrag/pull/4) | 9 screens: bookings hub/list/details/calendar, contracts hub/details/payments, apartments grid/profile |
| 5 — Reports & settings | `ui-redesign/reports-settings` | ✅ Merged (PR #5, `a8c320f`) | [#5](https://github.com/monaser25/abrag/pull/5) | 12 screens: reports suite, statement + preview, system log, search, notifications, settings root |
| 6 — Forms & modals | `ui-redesign/forms-modals` | ✅ Merged (PR #6, `c98f899`) | [#6](https://github.com/monaser25/abrag/pull/6) | 12 forms redesigned to prototype anatomy (round 2); reusable form kit `form_fields.dart` added; validators + submit paths verified byte-identical |
| 7 — Missing screens | `ui-redesign/missing-screens` | 🔄 In review | (see PR) | 23 screens: buildings list, bulk inventory, landlines; financial lists (expenses/building rent/transfers/meter readings); operations (maintenance/technicians/technician details/cleaning supplies/inspections); people (brokers list/details/visibility, customers, guest profile); settings subs (admin profile/users & permissions/pricing/season transition/checkout times/data management). All providers/validators/routes preserved; pricing screen left as pre-existing placeholder |
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
