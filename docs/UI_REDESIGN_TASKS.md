# UI Redesign — Task Breakdown

Each phase = one branch = one PR into `ui-redesign/prototype-migration`. Definition of done for every task: analyze clean, tests green, debug APK builds, both ar/en verified, no logic/provider/route changes.

## Phase 1 — `ui-redesign/design-system`

- [ ] `lib/core/theme/app_colors.dart`: new token set + `ThemeExtension<AbragColors>`; keep old constants as deprecated aliases
- [ ] `lib/core/theme/app_typography.dart`: `AppTextStyles` per token table; tabular-figures `num` style
- [ ] `lib/core/theme/app_spacing.dart`, `app_radius.dart`, `app_shadows.dart`
- [ ] `lib/core/theme/app_theme.dart`: rebuild dark `ThemeData` (color scheme, appbar, card r18, buttons h48, inputs h50 + focus ring, chips, segmented, switch, divider, snackbar, dialog, bottom sheet); light `ThemeData` scaffold (if approved)
- [ ] `lib/shared/widgets/`: AppBackground, AbragAppBar, AppButton, AppTextField, StatusChip, StatCard, NavRow, SectionTitle, DetailRow, LoadingSkeleton, EmptyState, ErrorState, AppFab, AppAvatar, MiniMetric, MiniNavCard, SegmentedTabs, AppProgressBar, BottomActionBar, SeasonHero, PaymentTimeline, StatementPaper, ApartmentCell, SkylineAccent
- [ ] Golden test harness + one golden per shared widget (ar + en)
- [ ] Full-app smoke pass: every screen still legible under new ThemeData (screens not yet migrated may look hybrid — record in PROGRESS doc, must not be broken/unreadable)

## Phase 2 — `ui-redesign/navigation-shell`

- [ ] Splash: logo glow + skyline + gradient field (preserve existing init/redirect timing)
- [ ] Onboarding: illus frame, dots indicator, accent CTA (keep `onboardingCompletedProvider` flow)
- [ ] Login: restyle fields/buttons/logo; **keep Supabase auth + role redirect exactly**
- [ ] Forgot password (extrapolated)
- [ ] Decide + apply screen-enter transition convention (slide-up 9px fade)
- [ ] Native splash color update to `#080C24` (if identity switch approved)

## Phase 3 — `ui-redesign/dashboard`

- [ ] Dashboard: StatCard grid, SeasonHero, MiniNav grid, spark bars — bind to existing providers
- [ ] RootScreen shell + Broker/Cleaner/Viewer homes (RoleBar pattern)

## Phase 4 — `ui-redesign/core-flows`

- [ ] Bookings hub (segmented tabs + BookingCard), booking list, booking details, calendar restyle
- [ ] Contracts hub (ContractCard + utilities split), student details, payment history (timeline)
- [ ] Apartments grid (ApartmentCell + status dots), apartment profile
- [ ] Per-screen hard-coded color sweep

## Phase 5 — `ui-redesign/reports-settings`

- [ ] Reports root, statistics, detail, metric detail, filters, menu (extrapolated from ReportsScreen pattern)
- [ ] Statement + preview (`StatementPaper`); PDF export logic untouched
- [ ] Global search, notifications, settings root

## Phase 6 — `ui-redesign/forms-modals`

- [ ] Form kit conventions from `BookingAdd`: field groups, section titles, bottom action bar
- [ ] Add/edit: summer booking, winter contract, apartment, building, expense, building rent, maintenance, inspection, meter reading
- [ ] Early checkout, overstay extension, winter checkout
- [ ] Dialogs/sheets: confirmations, destructive (err styling), date/time pickers themed
- [ ] **Regression: every validator, controller, save path manually re-tested**

## Phase 7 — `ui-redesign/missing-screens`

- [ ] Buildings list, bulk inventory, landlines
- [ ] Expenses list, building rent, financial transfers, meter readings
- [ ] Maintenance list, technicians (+details), cleaning supplies, inspections
- [ ] Brokers (list/details/visibility), customers, guest profile
- [ ] Settings sub-screens: admin profile, users & permissions, pricing, season transition (SeasonHero), checkout settings, data management, system log

## Phase 8 — `ui-redesign/final-qa`

- [ ] Delete deprecated color aliases; grep-sweep for old hex values (`0xFF0D1B2A`, `0xFFF4A225`, …)
- [ ] Full QA checklist (`UI_REDESIGN_QA_CHECKLIST.md`) on device matrix, ar+en, dark(+light)
- [ ] Golden suite green; `flutter build appbundle` + Windows build smoke
- [ ] Final PR `ui-redesign/prototype-migration → main` with screenshots per screen
