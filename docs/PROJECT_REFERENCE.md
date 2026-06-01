# Abrag — Project Reference & Redesign Foundation

> **Purpose of this document.** A single, authoritative reference that captures *everything* about
> the Abrag app as it exists today — the product concept, every workflow, all ~65 screens, the data
> model, the technical architecture, and an audit of the current design system. It is the source of
> truth on which the upcoming **full UI redesign** (aligning the app with the company's logo-based
> visual identity, consistently across all screens) is built. Nothing functional here should be lost
> in the redesign; every screen must be accounted for.
>
> Scope note: this is a **documentation deliverable** only — no application code, theme, or config is
> changed by it.
>
> Grounded in the actual source (`SPEC.md`, `lib/core/**`, `lib/features/**`, `pubspec.yaml`,
> `assets/icons/*`). The product spec lives in [`SPEC.md`](../SPEC.md) and remains the contractual
> source of truth; `PROJECT_CONTEXT.md` describes the *AI agent system that generated the app*, not
> the product itself.

---

## Table of Contents

1. [Project at a Glance](#1-project-at-a-glance)
2. [Product Concept & Business Domain](#2-product-concept--business-domain)
3. [User Roles & Permissions](#3-user-roles--permissions)
4. [Information Architecture & Navigation](#4-information-architecture--navigation)
5. [Complete Screen Inventory (65 screens)](#5-complete-screen-inventory-65-screens)
6. [Core Workflows (end-to-end)](#6-core-workflows-end-to-end)
7. [Data Model & Domain Vocabulary](#7-data-model--domain-vocabulary)
8. [Technical Architecture](#8-technical-architecture)
9. [Current Design System Audit](#9-current-design-system-audit)
10. [Visual Identity Foundation (for the redesign)](#10-visual-identity-foundation-for-the-redesign)
11. [Redesign Readiness & Recommendations](#11-redesign-readiness--recommendations)
12. [Appendix](#12-appendix)

---

## 1. Project at a Glance

**Abrag (أبراج — "Towers")** is an offline-first real-estate management app for a single, ~15-apartment
residential building that runs **two seasonal business models** in one product: short-term **summer
daily bookings** (holiday/tourist rentals) and long-term **winter monthly contracts** (students &
families). It centralizes bookings, contracts, financials, utilities, maintenance/cleaning, broker
commissions, reporting, and role-based access — and works fully offline, syncing to Supabase when a
connection is available.

| Fact | Value |
|---|---|
| Product type | SaaS / dashboard / property management |
| Platforms | Android, iOS (+ simplified role-specific screens usable on web) |
| Primary language | **Arabic**, RTL-first (English localization scaffolded) |
| Screens | **65** across **16 feature modules** |
| User roles | **5** — admin, staff, cleaner, broker, viewer/parent |
| State management | Riverpod |
| Navigation | GoRouter (declarative, nested, deep-link ready) |
| Backend | Supabase (Auth + Postgres + Storage + Realtime) + Firebase Cloud Messaging |
| Local DB | Drift / SQLite (offline-first; 15 tables, all sync-tracked) |
| Theme today | Material 3, **dark-only**, Navy `#0D1B2A` + Gold `#F4A225` |
| Brand font | IBM Plex Sans Arabic |
| Currency / region | EGP (`ج.م`), country code +20 |
| Domain entities | 15 (Buildings, Apartments, Bookings, Contracts, Payments, Expenses, …) |

---

## 2. Product Concept & Business Domain

### The problem it solves
A landlord/operator runs one building under **two completely different rental models depending on the
season**, plus all the financial and operational overhead (utilities, shared building costs, broker
commissions, maintenance, cleaning, inspections, reporting). Abrag unifies all of this in one
offline-capable app with strict role-based access.

### The dual-season model
- **Summer season (≈ May–Sept):** daily/short-stay **bookings** (hotel-like). Guests, check-in/out
  dates, partial payments, early checkout, overstay extensions, optional broker + commission, guest
  ID capture.
- **Winter season (≈ Oct–April):** monthly **contracts** for students or families. Monthly rent,
  deposit, installment payments, utility-responsibility split (electricity/gas/water on tenant or
  owner), roommates, contract documents, checkout with deposit deductions.

The app maintains a **business year of May → April**, and derives a season key per date:
`summer_YYYY` or `winter_YYYY_YYYY+1` (see `lib/core/utils/season_utils.dart`). An **active season**
setting drives what the dashboard and lists show (e.g., the dashboard surfaces *Summer Bookings* vs
*Winter Contracts* based on the active season; admins see both).

### What the app manages
- **Property:** building(s) → apartments (number, floor, cleaning status, broker visibility,
  inventory, landline info).
- **Revenue:** summer bookings, winter contracts + installment payments.
- **Costs & utilities:** expenses (with season + discounts + receipts), 4-installment annual building
  rent, electricity/water/gas meter readings (individual & shared), internal financial transfers
  (treasury/wallet).
- **Operations:** maintenance requests + technicians, cleaning supplies inventory + consumption,
  apartment inspections (damage, tenant fines vs owner repair cost), winter checkout.
- **People:** brokers (commission tracking + admin-controlled apartment visibility), customers
  (summer guests + winter tenants), app users & their permissions.
- **Insight:** financial reports, statistics, PDF statements, and a full audit/system log.

### Offline-first rationale
Operations happen on-site where connectivity may be poor. Every write goes to the **local Drift DB
first** and is later reconciled with Supabase by the sync engine. The UI always reads local data, so
the app is fully usable offline; sync is eventual.

---

## 3. User Roles & Permissions

Abrag uses **role-based access control** with two layers:

1. **Fixed account role** (`UserProfiles.role`): `admin`, `staff`, `cleaner`, `broker`, `viewer`
   (default `viewer`). This decides **which "home" experience** a user lands in (see `RootScreen`).
2. **Flexible permission templates** (for staff): a configurable map of *role template → permission
   keys*, plus a *user → template* assignment, stored in app settings
   (`lib/features/settings/presentation/providers/permissions_provider.dart`). The dashboard and
   feature visibility are gated by these permission keys.

### Role → experience

| Role | Lands on | Capability summary |
|---|---|---|
| **admin** | `DashboardScreen` (full) | Everything; only role allowed into `/settings/*` (guarded by `_AdminOnlyRoute`). `hasPerm()` returns true for all. |
| **staff** | `DashboardScreen` (gated) | Sees only the dashboard sections their assigned permission template grants. |
| **broker** | `BrokerWebScreen` | Read-only grid of apartments where `brokerVisibility == true` (apartment numbers only — no prices/booking). |
| **cleaner** | `CleanerWebScreen` | List of apartments with `cleaningStatus == 'needs_cleaning'`; one-tap "تم التنظيف" marks them clean. |
| **viewer / parent** | `ViewerWebScreen` | Read-only view of the winter contract(s) linked to their `viewerUserId` (unit, university, monthly rent). |

### Permission keys (used by `hasPerm()` gating)
`view_dashboard`, `view_search`, `view_notifications`, `manage_bookings`, `manage_contracts`,
`checkout_winter`, `manage_apartments`, `view_apartments`, `manage_cleaning_status`,
`manage_cleaning_supplies`, `manage_maintenance`, `view_maintenance`, `view_customers`,
`manage_customers`, `view_brokers`, `manage_brokers`, `view_contract_documents`, `view_reports`,
`export_reports`, `view_system_log`, `manage_expenses`, `manage_building_rent`,
`manage_financial_transfers`, `manage_users`, `manage_settings`, `manage_data`.

### Default role templates (Arabic-named, configurable)
- **موظف استقبال (Receptionist):** dashboard, bookings, contracts, customers, apartments view, search,
  notifications.
- **محاسب (Accountant):** dashboard, reports + export, expenses, building rent, financial transfers,
  notifications.
- **مسؤول صيانة (Maintenance manager):** dashboard, cleaning status, winter checkout, maintenance,
  cleaning supplies, apartments/maintenance view, notifications.
- **مراقب قراءة فقط (Read-only monitor):** dashboard, search, customers, apartments, reports, brokers,
  maintenance (all view-only).

> **Redesign implication:** the dashboard is **composed dynamically from permissions** — the redesign
> must keep section/card visibility driven by `hasPerm()` and the active-season logic, not hard-code a
> fixed menu.

---

## 4. Information Architecture & Navigation

**Router:** `lib/core/routes/app_router.dart` (GoRouter). **Initial route:** `/splash`.
Auth state is observed via a `RouterNotifier` listening to Supabase `onAuthStateChange`.

### Entry / redirect flow
```
/splash  ──(2s brand delay)──▶  onboarding not done? ──▶ /onboarding ──▶ /login
                                  └ logged in? ──▶ / (RootScreen)   else ──▶ /login
```
Redirect rules (in `redirect:`):
- `/splash` and `/forgot_password` are always allowed through.
- If onboarding not completed → force `/onboarding`.
- If not logged in (and not on login/onboarding) → `/login`.
- If logged in and on `/login` → `/`.

### Role-based home (`/` → `RootScreen`)
`RootScreen` watches `currentUserRoleProvider` and renders:
`admin|staff → DashboardScreen`, `broker → BrokerWebScreen`, `cleaner → CleanerWebScreen`,
`viewer → ViewerWebScreen`. On mount it registers the FCM device and triggers a sync.

### Navigation model
- **No bottom navigation bar / no drawer.** Navigation is **hub-and-spoke**: the dashboard is a
  scrollable list of stat cards + grouped `ListTile` "feature cards"; tapping a card `go`/`push`es
  into a feature, which then uses nested child routes for its add/edit/detail screens.
- **Top-level routes:** `/splash`, `/onboarding`, `/login`, `/forgot_password`, `/search`,
  `/notifications`, and `/` (with all feature routes nested under it).
- **Admin-only subtree:** `/settings` and all its children are wrapped in `_AdminOnlyRoute` (shows
  "غير مصرح" / unauthorized for non-admins).
- **Parameter passing:** path params (`details/:id`), query params (`/inspections/add?apartmentId=…`),
  and `state.extra` for passing typed objects (e.g., editing a `Building`, `Expense`, `WinterContract`).

### Full route tree (under `/`)
```
/                                   RootScreen (role switch)
├─ customers                        CustomersScreen
├─ brokers                          BrokersListScreen
│  ├─ details/:id                   BrokerDetailsScreen
│  └─ visibility                    BrokerVisibilityControlScreen
├─ buildings                        BuildingListScreen
│  ├─ add                           AddBuildingScreen
│  └─ edit (extra: Building)        AddBuildingScreen
├─ apartments                       ApartmentsGridScreen
│  ├─ add / edit (extra: Apartment) AddApartmentScreen
│  ├─ profile/:id                   ApartmentProfileScreen
│  ├─ bulk_inventory                BulkInventoryScreen
│  └─ landlines                     LandlinesManagementScreen
├─ summer_bookings                  SummerBookingsScreen
│  ├─ calendar                      CalendarViewScreen
│  ├─ list                          BookingListScreen
│  ├─ details/:id                   BookingDetailsScreen
│  ├─ early_checkout/:id            EarlyCheckoutScreen
│  ├─ overstay/:id                  OverstayExtensionScreen
│  ├─ guest/:name                   GuestProfileScreen
│  └─ add / edit/:id                AddSummerBookingScreen
├─ winter_contracts                 WinterContractsScreen
│  ├─ details/:id                   StudentDetailsScreen
│  ├─ payments/:id                  WinterPaymentHistoryScreen
│  ├─ add / edit (extra: Contract)  AddWinterContractScreen
│  └─ checkout/:id                  WinterCheckoutScreen
├─ expenses                         ExpensesListScreen
│  └─ add / edit (extra: Expense)   AddExpenseScreen
├─ building_rent                    BuildingRentScreen
│  └─ add / edit (extra: Expense)   AddBuildingRentScreen
├─ financial_transfers              FinancialTransfersScreen
├─ maintenance                      MaintenanceRequestsScreen
│  └─ add / edit (extra: Request)   AddMaintenanceScreen
├─ technicians                      TechniciansScreen
│  └─ details/:id                   TechnicianDetailsScreen
├─ cleaning_supplies                CleaningSuppliesScreen
├─ inspections                      ApartmentInspectionsScreen
│  └─ add (?apartmentId&checkoutBookingId&…)  AddInspectionScreen
├─ reports                          ReportsScreen
│  ├─ filters                       ReportsFilterScreen
│  ├─ statistics                    ReportStatisticsScreen
│  ├─ menu                          ReportsMenuScreen
│  ├─ statement → statement/preview StatementScreen → StatementPreviewScreen
│  ├─ details/:type                 ReportDetailScreen
│  │  └─ item/:key                  ReportMetricDetailScreen
│  └─ log                           SystemLogScreen
└─ settings  (admin only)           SettingsScreen
   ├─ profile                       AdminProfileScreen
   ├─ users                         UsersPermissionsScreen
   ├─ pricing                       PricingManagementScreen
   ├─ season_transition             SeasonTransitionScreen
   ├─ notifications                 NotificationsScreen
   ├─ checkout_times                CheckoutSettingsScreen
   └─ data_management               DataManagementScreen
```
> **Note:** `MeterReadingsScreen` and `AddMeterReadingScreen` exist as files but are **not** in the
> named route tree — they are reached contextually (e.g., from apartment/financial flows), so the
> redesign should confirm their entry points.

---

## 5. Complete Screen Inventory (65 screens)

Conventions used below — **States**: nearly every data screen uses Riverpod `AsyncValue.when(data /
loading / error)` → loading = centered `CircularProgressIndicator`, error = centered text, plus
explicit **empty states**. **Primary action** is typically a `FilledButton`/`ElevatedButton` (FAB-like
in a `bottomNavigationBar`) or an AppBar action. (Patterns confirmed by reading representative screens;
see §9 for the consistency issues these patterns expose.)

### 5.1 Auth, Shell & Role Homes (9)

| Screen | Route | Purpose & key UI |
|---|---|---|
| `SplashScreen` | `/splash` | 2s brand screen: `Icons.domain` (generic, **not the logo**) + "أبراج" + tagline "إدارة الأملاك الذكية" + spinner; routes onward. |
| `OnboardingScreen` | `/onboarding` | 4-page `PageView` (welcome, summer bookings, winter contracts, reports) with dot indicators + Skip/Next/Start; generic Material icons. Sets `onboarding_completed`. |
| `LoginScreen` | `/login` | Email + password form, "تذكر بيانات الدخول" (remember-me via secure storage), forgot-password link, gold `Icons.apartment` header; loading + error-snackbar states. |
| `ForgotPasswordScreen` | `/forgot_password` | Password recovery via Supabase. |
| `RootScreen` | `/` | Role switch → Dashboard or one of the web screens; auto sync + FCM register on mount; "جاري إعداد بيئة العمل…" while role loads. |
| `DashboardScreen` | (admin/staff home) | Permission-gated hub: 2× stat cards (`_StatCard`: buildings, apartments), grouped feature `ListTile` cards under "العمليات والمالية" / "الحجوزات والعقود" / "التقارير المالية"; AppBar actions = notifications (with `Badge` count), search, settings (admin), sync (spinner), logout; `RefreshIndicator` pull-to-sync; season-aware (summer vs winter cards). |
| `BrokerWebScreen` | (broker home) | Read-only 2-col grid of apartments with `brokerVisibility==true` (number only); empty "لا توجد شقق متاحة حالياً"; logout. |
| `CleanerWebScreen` | (cleaner home) | List of `needs_cleaning` apartments; large "تم التنظيف" button marks clean; empty "لا توجد مهام تنظيف حالياً"; logout. |
| `ViewerWebScreen` | (viewer home) | Read-only card(s) of the contract(s) linked to the user (`viewerUserId`): unit, university, monthly rent; empty "لا توجد بيانات مرتبطة بحسابك"; logout. |

### 5.2 Buildings (2)

| Screen | Route | Purpose & key UI |
|---|---|---|
| `BuildingListScreen` | `/buildings` | List of buildings (name, address, annual rent); tap to edit. |
| `AddBuildingScreen` | `/buildings/add`, `/buildings/edit` | Add/edit building: name, address, `annualRentEgp`, rent-installment dates, total apartments. |

### 5.3 Apartments (5)

| Screen | Route | Purpose & key UI |
|---|---|---|
| `ApartmentsGridScreen` | `/apartments` | Grid of apartments with status indicators (cleaning status, occupancy, broker visibility). |
| `AddApartmentScreen` | `/apartments/add`, `/apartments/edit` | Add/edit apartment: number, floor, inventory, landline info, broker visibility. |
| `ApartmentProfileScreen` | `/apartments/profile/:id` | Detailed apartment profile: current/upcoming occupancy, inventory, landline, history. |
| `BulkInventoryScreen` | `/apartments/bulk_inventory` | Bulk-edit inventory across apartments (grouped item lists). |
| `LandlinesManagementScreen` | `/apartments/landlines` | Manage apartment landline numbers/owners/notes. |

### 5.4 Summer Bookings (8)

| Screen | Route | Purpose & key UI |
|---|---|---|
| `SummerBookingsScreen` | `/summer_bookings` | Hub: gradient hero + season label, 2×2 metric grid (`_MetricCard`: occupied today / available today / upcoming checkouts / upcoming), nav cards (`_NavigationCard`: smart calendar, bookings list); "حجز جديد" FAB. |
| `CalendarViewScreen` | `/summer_bookings/calendar` | Monthly `table_calendar` view with filters (occupied/available/upcoming/checkouts via `?filter=`); per-day occupancy. |
| `BookingListScreen` | `/summer_bookings/list` | Searchable/filterable list of detailed booking cards. |
| `BookingDetailsScreen` | `/summer_bookings/details/:id` | Full booking detail: guest, dates, pricing, payments, broker + computed commission, ID images; actions → checkout / early checkout / overstay / edit. |
| `AddSummerBookingScreen` | `/summer_bookings/add`, `/edit/:id` | **Booking capture** form (see §6): apartment, guest, ID + images, dates/times, pricing & partial payment, payment method, broker + commission; draft save/restore. |
| `EarlyCheckoutScreen` | `/summer_bookings/early_checkout/:id` | Record early departure + (potential refund) and trigger cleaning/inspection. |
| `OverstayExtensionScreen` | `/summer_bookings/overstay/:id` | Extend stay: add days + fee, recompute total & checkout date. |
| `GuestProfileScreen` | `/summer_bookings/guest/:name` | Aggregated guest history across bookings. |

### 5.5 Winter Contracts (4)

| Screen | Route | Purpose & key UI |
|---|---|---|
| `WinterContractsScreen` | `/winter_contracts` | List with filters (all / active / expired / empty units). |
| `AddWinterContractScreen` | `/winter_contracts/add`, `/edit` | Add/edit: contract type (student/family), tenant + parent, university, dates, monthly rent, deposit, utility split, roommates, ID + contract images. |
| `StudentDetailsScreen` | `/winter_contracts/details/:id` | Contract detail: tenant, documents, utility responsibility, linked payments. |
| `WinterPaymentHistoryScreen` | `/winter_contracts/payments/:id` | Installment timeline; record payments & receipts. |

### 5.6 Financials (7)

| Screen | Route | Purpose & key UI |
|---|---|---|
| `ExpensesListScreen` | `/expenses` | Expenses with type/date/season filters; totals. |
| `AddExpenseScreen` | `/expenses/add`, `/edit` | Add/edit expense: type, amount, payment method, season, discount + reason, date, receipt. |
| `BuildingRentScreen` | `/building_rent` | 4-installment annual building-rent tracking. |
| `AddBuildingRentScreen` | `/building_rent/add`, `/edit` | Add/edit a building-rent installment (uses `Expense` with `installmentNumber`). |
| `FinancialTransfersScreen` | `/financial_transfers` | Treasury/wallet internal transfers (from/to account, type, season, amount, notes). |
| `MeterReadingsScreen` | *(contextual, not in route tree)* | Electricity/water/gas readings per apartment/building, shared vs individual. |
| `AddMeterReadingScreen` | *(contextual)* | Add reading: previous/current, computed amount, shared flag. |

### 5.7 Operations (8)

| Screen | Route | Purpose & key UI |
|---|---|---|
| `MaintenanceRequestsScreen` | `/maintenance` | Repair tickets list with status (open/in_progress/completed/closed). |
| `AddMaintenanceScreen` | `/maintenance/add`, `/edit` | Add/edit request: apartment, issue, technician, status, cost. |
| `TechniciansScreen` | `/technicians` | Technician roster by specialty (سباكة/نجارة/كهرباء). |
| `TechnicianDetailsScreen` | `/technicians/details/:id` | Technician profile + work history. |
| `CleaningSuppliesScreen` | `/cleaning_supplies` | Cleaning-supply inventory + purchase/consumption transactions. |
| `ApartmentInspectionsScreen` | `/inspections` | Inspection list (clean? damages? fines?). |
| `AddInspectionScreen` | `/inspections/add?apartmentId=…&checkoutBookingId=…` | Add inspection w/ damage description, tenant fine vs owner repair cost, inspector, photos; entry from checkout flows. |
| `WinterCheckoutScreen` | `/winter_contracts/checkout/:id` | End a winter contract: damages, deposit deduction → creates deduction payment, deactivates contract. |

### 5.8 Reports & Analytics (9)

| Screen | Route | Purpose & key UI |
|---|---|---|
| `ReportsScreen` | `/reports` | Financial overview (`_MoneyTile` tiles, `_DashboardShortcutCard` shortcuts) with filter state. |
| `ReportsFilterScreen` | `/reports/filters` | Advanced filter modal (season, building, party/entity). |
| `ReportStatisticsScreen` | `/reports/statistics` | Top/bottom statistics by metric. |
| `ReportsMenuScreen` | `/reports/menu` | Reports navigation menu. |
| `StatementScreen` | `/reports/statement` | Build an account statement from filters. |
| `StatementPreviewScreen` | `/reports/statement/preview` | Preview before PDF export (via `pdf`/`printing`). |
| `ReportDetailScreen` | `/reports/details/:type` | Detailed report by `ReportDetailKind`. |
| `ReportMetricDetailScreen` | `/reports/details/:type/item/:key` | Drill-down into a single metric (base64url-encoded key). |
| `SystemLogScreen` | `/reports/log` | Audit/activity log (who did what, when). |

### 5.9 Users, Brokers & Customers (4)

| Screen | Route | Purpose & key UI |
|---|---|---|
| `CustomersScreen` | `/customers` | Combined customer registry (summer guests + winter tenants). |
| `BrokersListScreen` | `/brokers` | Broker roster (name, phone). |
| `BrokerDetailsScreen` | `/brokers/details/:id` | Broker profile + commission/sales stats + contribution %. |
| `BrokerVisibilityControlScreen` | `/brokers/visibility` | Toggle per-apartment `brokerVisibility`. |

### 5.10 Settings (8, admin-only)

| Screen | Route | Purpose & key UI |
|---|---|---|
| `SettingsScreen` | `/settings` | Settings menu hub. |
| `AdminProfileScreen` | `/settings/profile` | Admin account settings. |
| `UsersPermissionsScreen` | `/settings/users` | Manage users, assign role templates / permissions. |
| `PricingManagementScreen` | `/settings/pricing` | Season pricing configuration. |
| `SeasonTransitionScreen` | `/settings/season_transition` | Switch active season (summer ↔ winter). |
| `NotificationsScreen` | `/settings/notifications`, `/notifications` | In-app notification center. |
| `CheckoutSettingsScreen` | `/settings/checkout_times` | Configure default checkout time. |
| `DataManagementScreen` | `/settings/data_management` | Data export/import/reset. |

### 5.11 Search (1)

| Screen | Route | Purpose & key UI |
|---|---|---|
| `GlobalSearchScreen` | `/search` | Global search across guests, contracts, apartments, etc. |

---

## 6. Core Workflows (end-to-end)

> These encode the **business rules the redesign must preserve**. Logic lives in feature controllers
> (`*_controller.dart`) and providers (`*_provider.dart`).

### 6.1 Summer booking lifecycle
Source: `lib/features/bookings/presentation/providers/bookings_controller.dart`.
1. **Capture** (`AddSummerBookingScreen` → `addBooking()`): collect apartment, guest, optional
   national ID + front/back images, check-in (+ time from settings) & check-out, total price, amount
   paid (supports partial), payment method (`cash` / instapay / vodafone_cash), optional broker +
   commission. Draft can be saved/restored.
2. **Occupancy guard:** `ensureApartmentIsFreeForPeriod()` rejects overlap with any non-cancelled /
   non-checked-out summer booking **and** any active winter contract → **prevents double-booking**.
3. **Status:** `pending` (no payment) → `confirmed` (any payment). Lifecycle:
   `pending → confirmed → checked_out`; also `cancelled`, and soft-`deleted`.
4. **Edit** (`updateBooking()`): re-validates dates (excluding self), recomputes status, logs old→new.
5. **Payment** (`updateBookingPayment()`): validates `amountPaid ≤ total`, logs the transaction.
6. **Early checkout** (`earlyCheckoutBooking()`): set `checked_out` + `earlyCheckoutDate`; flows into
   cleaning/inspection.
7. **Overstay** (`extendBooking()`): add `overstayDays` + `overstayFeeEgp`, push `checkOutDate`,
   recompute total.
8. **Checkout** (`checkoutBooking()`): set `checked_out`, set apartment `cleaningStatus = needs_cleaning`.
9. **Delete:** soft delete (`status = 'deleted'`) — record kept for audit.
Every mutation writes an **audit log** and marks the row `pendingInsert/Update` for sync.

### 6.2 Broker rules & commissions
- Brokers are `UserProfiles` with `role = 'broker'` (registered, auto local email
  `broker-<uuid>@local.abrag`) **or** captured ad-hoc on a booking as `brokerName` (freelance).
- **Visibility:** each apartment has `brokerVisibility`; brokers only see visible apartments
  (`BrokerWebScreen`, controlled via `BrokerVisibilityControlScreen`).
- **Commission per booking:** `brokerCommissionType ∈ {none, percentage, fixed}`; percentage default
  **10%**; `fixed` uses `brokerCommissionFixedEgp`; computed amount may come from Supabase
  (`brokerCommissionAmountEgp`). Commission display = fixed → fixed; percentage → `total × pct/100`.
- **Broker stats** (`BrokerDetailsScreen`): total commission, total sales, booking count, contribution %.

### 6.3 Winter contract lifecycle
Source: `lib/features/contracts/presentation/providers/contracts_controller.dart`.
1. **Create** (`addContract()`): type (student/family), tenant + parent/guardian, university,
   start/end, monthly rent, deposit, **utility split** (`isElectricityOnStudent`, `isGasOnStudent`,
   `isWaterOnStudent`), roommates (JSON, optional per-roommate ID images), ID + contract images;
   same occupancy guard as bookings.
2. **Payments:** `WinterPayments` rows (amount, date, method, receipt) tracked in
   `WinterPaymentHistoryScreen`.
3. **Checkout** (`checkoutContract()`): transaction sets `isActive = false`; if a deposit deduction is
   entered, creates a `WinterPayment` with method `deposit_deduction` (damages/cleaning/refund balance).
   Contract is retained (never hard-deleted).

### 6.4 Season management
`lib/core/utils/season_utils.dart` derives the season key from a date (business year May→April):
summer months 5–9 → `summer_YYYY`; Oct+ → `winter_YYYY_YYYY+1`. An **active season** app setting
filters bookings/expenses/transfers and toggles dashboard cards. `SeasonTransitionScreen` switches it.

### 6.5 Financials & operations
- **Expenses** carry season + optional discount (+ reason) + receipt; building rent is modeled as
  expenses with `installmentNumber` (4 installments/year).
- **Meter readings** compute utility amounts (individual vs `isSharedExpense` building-wide).
- **Maintenance** tickets reference an apartment and optional technician, track status + cost.
- **Inspections** record cleanliness, damages, **tenant fine vs owner repair cost**, inspector.
- **Cleaning supplies** track stock + purchase/consumption transactions.

### 6.6 Reporting & PDF
`ReportsScreen` aggregates financials with a `ReportFilterState` (season/building/party). Statements
are generated via `lib/features/reports/domain/services/pdf_export_service.dart` using `pdf` +
`printing`, previewed before export. `SystemLogScreen` surfaces the audit trail.

### 6.7 Offline sync, audit & notifications
- **Sync engine** (`lib/core/sync/sync_engine.dart`): `syncAll()` = upload local media (image paths →
  Supabase Storage URLs) → push pending rows (15 tables, ordered) → pull remote (upsert). Network
  retry with backoff. Rows carry `syncStatus` + `lastModifiedLocal`.
- **Audit logs:** every controller action records actor, action, entity, title/description, old/new
  JSON. AuditLog inserts trigger server push notifications via a Supabase function.
- **Realtime + notifications** (`lib/features/dashboard/presentation/providers/sync_provider.dart`):
  15s periodic sync + a Supabase realtime channel on `audit_logs`; an insert by **another** user
  raises a local notification ("تحديث من <actor>"). The dashboard shows an unread **notification
  badge** count.

---

## 7. Data Model & Domain Vocabulary

Local schema: `lib/core/database/tables.dart` (Drift). **All 15 tables** mix in `SyncableTable`
(`syncStatus` enum: `synced/pendingInsert/pendingUpdate/pendingDelete`, default `synced`;
`lastModifiedLocal`). Money is `…Egp` doubles; IDs are text UUIDs.

| Table | Key fields | Notes |
|---|---|---|
| `UserProfiles` | id, email, fullName?, phoneNumber?, role(`viewer`) | role drives experience |
| `Buildings` | id, name, address?, annualRentEgp, rentInstallmentsDates?, totalApartments(15) | |
| `Apartments` | id, **buildingId→Buildings**, apartmentNumber, floorNumber?, cleaningStatus(`clean`), **brokerVisibility**(false), inventory?(JSON), landline* | |
| `SummerBookings` | id, **apartmentId→Apartments**, guestName, guestPhone?, checkInDate, checkOutDate, status(`pending`), totalPriceEgp, amountPaidEgp(0), paymentMethod(`cash`), brokerId?, brokerName?, brokerCommissionType(`none`), brokerCommissionPercentage(10), brokerCommissionFixedEgp(0), brokerCommissionAmountEgp?, earlyCheckoutDate?, overstayDays(0), overstayFeeEgp(0), nationalId?, idFront/BackImage? | core summer revenue |
| `WinterContracts` | id, **apartmentId→Apartments**, contractType(`student`), studentName, university?, parentName?, parentPhone?, **viewerUserId?**, startDate, endDate, monthlyRentEgp, depositEgp(0), isActive(true), isElectricity/Gas/WaterOnStudent, roommates?(JSON), nationalId?, id/contract images? | core winter revenue |
| `WinterPayments` | id, **contractId→WinterContracts**, amountEgp, paymentDate, paymentMethod(`cash`), receiptUrl? | incl. `deposit_deduction` |
| `MeterReadings` | id, apartmentId?, buildingId?, readingDate, previousReading, currentReading, amountEgp, isSharedExpense(false) | utilities |
| `Expenses` | id, buildingId?, apartmentId?, expenseType, amountEgp, paymentMethod(`cash`), season(`all`), discountEgp(0), discountReason?, expenseDate, installmentNumber?, description?, receiptUrl? | building rent = installments |
| `FinancialTransfers` | id, fromAccount, toAccount, transferType(`internal`), season(`all`), amountEgp, transferDate, notes? | treasury |
| `Technicians` | id, name, phone?, specialty, notes? | سباكة/نجارة/كهرباء |
| `CleaningSupplies` | id, name, stockQuantity(0), unit(`عبوة`) | لتر/كيلو/عبوة |
| `CleaningTransactions` | id, **supplyId→CleaningSupplies**, transactionType(purchase/consumption), quantity, costEgp(0), transactionDate, notes? | |
| `ApartmentInspections` | id, **apartmentId→Apartments**, inspectionDate, isClean(true), hasDamages(false), damagesDescription?, tenantFineEgp(0), ownerRepairCostEgp(0), inspectorName, notes? | |
| `MaintenanceRequests` | id, **apartmentId→Apartments**, technicianId?→Technicians, reportedBy, issueDescription, status(`open`), costEgp(0), resolvedAt? | |
| `AuditLogs` | id, actorUserId?, actorName, action, entityType, entityId?, title, description, route?, old/newValuesJson? | drives notifications |

### Status / enum vocabulary the UI must express
- **Booking status:** `pending`, `confirmed`, `checked_out`, `cancelled`, `deleted` (soft).
- **Cleaning status:** `clean`, `needs_cleaning`, (and `dirty`/`inspecting` referenced in flows).
- **Payment methods:** `cash`, `bank_transfer`/instapay, vodafone_cash, `cheque`, `deposit_deduction`.
- **Commission type:** `none`, `percentage` (10% default), `fixed`.
- **Contract type:** `student`, `family`. **Maintenance status:** `open`, `in_progress`, `completed`, `closed`.
- **Sync status:** `synced`, `pendingInsert`, `pendingUpdate`, `pendingDelete`.
- **Season:** `all`, `summer`, `winter` (+ keyed `summer_YYYY` / `winter_YYYY_YYYY+1`).

### Relationship overview
`Building 1—N Apartment`; `Apartment 1—N {SummerBooking, WinterContract, MeterReading, Expense,
MaintenanceRequest, ApartmentInspection}`; `WinterContract 1—N WinterPayment`; `CleaningSupply 1—N
CleaningTransaction`; `Technician 1—N MaintenanceRequest`; `UserProfile(broker) —< SummerBooking`
(by `brokerId`); `UserProfile(viewer) — WinterContract` (by `viewerUserId`).

---

## 8. Technical Architecture

- **Pattern:** feature-first clean architecture under `lib/features/<feature>/{data,domain,presentation}`,
  with shared infra in `lib/core/{config,database,routes,services,sync,theme,utils}`. (Most features
  are presentation + providers; domain/data are thin where Drift/Supabase suffice.)
- **State management (Riverpod):** `StreamProvider`s watch Drift tables for live reads (filtering out
  `pendingDelete`/`deleted`); `StateNotifierProvider`s expose `AsyncValue<void>` for mutations; a
  central `databaseProvider` provides the `AppDatabase`. Screens use `ref.watch(...).when(...)` and
  `ref.listen(...)` for error snackbars.
- **Navigation:** GoRouter (`routerProvider`) with a `RouterNotifier` bound to Supabase auth changes.
- **Backend:** Supabase (Auth email/password + RLS, Postgres, Storage bucket `abrag_storage`,
  Realtime). Firebase Cloud Messaging for push; tokens saved to a `device_tokens` table.
- **Local DB:** Drift/SQLite (`abrag_local_v*.sqlite`), schema versioned with migrations; offline-first.
- **Serialization/codegen:** `freezed` + `json_serializable`; Drift codegen (`database.g.dart`).
- **Localization:** `flutter_localizations` + `intl`, `lib/l10n/` (`app_ar.arb`, `app_en.arb`),
  supported locales `ar`/`en`, RTL-first.
- **Config/secrets:** `flutter_dotenv` (`.env`), `flutter_secure_storage` (credentials),
  `shared_preferences` (onboarding flag, settings).
- **Entry:** `lib/main.dart` — init env, notifications, FCM, Supabase, SharedPreferences →
  `ProviderScope` → `MaterialApp.router` (`AppTheme.darkTheme`, locale, l10n delegates).
- **Key packages:** `table_calendar`, `pdf` + `printing`, `image_picker`/`file_picker`,
  `cached_network_image`, `share_plus`, `url_launcher`, `permission_handler`, `uuid`, `dio`.

---

## 9. Current Design System Audit

**Tokens — Colors** (`lib/core/theme/app_colors.dart`):

| Token | Hex | Role |
|---|---|---|
| `navyBackground` | `#0D1B2A` | scaffold / base |
| `goldPrimary` | `#F4A225` | primary / accents |
| `cardBackground` | `#1B263B` | cards, inputs |
| `textPrimary` | `#E0E1DD` | body text |
| `textSecondary` | `#778DA9` | subtitles/hints |
| `divider` | `#415A77` | borders/dividers |
| `white` | `#FFFFFF` | — |
| `error` | `#E63946` | errors |
| `success` | `#2A9D8F` | positive |
| `warning` | `#E9C46A` | caution |
| `info` | `#457B9D` | secondary accent (`colorScheme.secondary`) |

**Tokens — Typography** (`app_typography.dart`, family `IBMPlexSansArabic`): displayLarge 32B,
displayMedium 28B, displaySmall 24B, headlineMedium 20/600, titleLarge 18/600, titleMedium 16/500,
bodyLarge 16, bodyMedium 14, bodySmall 12 (secondary), labelLarge 14/500, labelMedium 12/500
(secondary). Font weights shipped: Regular/Medium(500)/Bold(700).

**Theme** (`app_theme.dart`): Material 3, **dark only** (`ColorScheme.dark`, primary gold / secondary
info / surface navy). Component themes: AppBar (elevation 0, centered, gold icons), Card (elevation 2,
radius 12, margin v8/h16), ElevatedButton (gold bg / navy fg, radius 8, padding v14/h24), Input
(filled `cardBackground`, radius 8, focused gold 2px), Divider (`#415A77`, 1px).

### Findings (the obstacles a consistent redesign must fix)
1. **No shared component library.** There are **no `widgets/` folders** anywhere. Reusable UI is
   re-implemented as *private* classes inside individual screens — e.g. `_StatCard`
   (`dashboard_screen.dart`), `_MetricCard` & `_NavigationCard` (`summer_bookings_screen.dart`),
   `_MoneyTile` & `_DashboardShortcutCard` (`reports_screen.dart`), `_buildDetailRow`
   (`viewer_web_screen.dart`). The same "stat card", "nav row", and "metric tile" exist in multiple
   slightly-different forms. **This is the #1 reason the UI looks inconsistent and is the highest-value
   thing to fix first.**
2. **Hard-coded values bypass the tokens.** Literal `Color(0xFFF4A225)` appears in
   `dashboard_screen.dart` (every feature `ListTile` icon) and `login_screen.dart` instead of
   `AppColors.goldPrimary`; spacing/radius are magic numbers (8/12/14/16/18/24) with no spacing scale.
3. **Brand not actually used.** Splash and onboarding use generic Material icons (`Icons.domain`,
   etc.) — **not** the `abrag_icon.png` logo. The launcher/splash assets and the in-app brand diverge.
4. **Theme/typography gaps.** Screens use styles **not defined** in the theme `TextTheme` (e.g.
   `headlineSmall`, `titleSmall` in `summer_bookings_screen.dart`), so they fall back to Material
   defaults — inconsistent sizing. No `light` theme despite a "dark mode required" spec.
5. **Inconsistent primary-action patterns.** Some screens put the primary CTA in a
   `bottomNavigationBar` FilledButton (summer bookings), others as inline `ElevatedButton`, others as
   AppBar actions or `ListTile` cards.
6. **Raw error & mixed localization.** Errors render as `Text('Error: $error')` / `حدث خطأ: $error`
   to end users; many strings are hard-coded Arabic inline rather than going through `l10n` — so a
   redesign that standardizes empty/error/loading states and copy will improve consistency a lot.
7. **Strengths to keep:** empty/loading/error states *are* generally handled; navy+gold is a coherent
   palette; RTL + Arabic font are correctly wired; cards/inputs already share a base theme.

---

## 10. Visual Identity Foundation (for the redesign)

### The logo (source of the new identity)
Assets: `assets/icons/abrag_icon.png` (color) and `assets/icons/abrag_mono.png` (white line version).
The mark is **Arabic calligraphy of "أبراج" stylized as rising towers/buildings**, on a **royal-blue
gradient**, with a small **orange/gold sun accent** and a faint **city-skyline silhouette** plus
subtle ornamental detail. The name literally means **"Towers."**

### The core insight: logo ↔ app mismatch
The **logo's palette (royal blue + white + orange)** does **not** match the **app's current theme
(navy `#0D1B2A` + gold `#F4A225`)**. The redesign's central job is to **derive one unified identity
from the logo** and apply it everywhere, replacing the divergent navy/gold-by-default look and the
generic Material brand icons. (Exact tokens will be extracted from the official high-res logo the
owner provides.)

### How to derive the system from the logo (method)
- **Color:** sample the logo's royal-blue range for primary/surface families, white for on-color text,
  and the orange/gold for the **accent/CTA**. Define a full ramp (primary 50–900), semantic colors
  (success/warning/error/info) harmonized to the new hue, and both **dark and light** schemes.
- **Typography:** keep **IBM Plex Sans Arabic** (excellent Arabic + Latin coverage) and complete the
  scale so every used style (incl. `headlineSmall`/`titleSmall`) is defined; pair display weights with
  the calligraphic feel of the mark without imitating it in body text.
- **Shape & elevation:** standardize radius (the logo's rounded-square suggests ~12–24), spacing
  scale (4-pt based), and elevation/border tokens.
- **Brand expression:** use the real logo/mono mark in splash, onboarding, login, empty states, and
  PDF statement headers; consider the skyline motif as a subtle section accent.
- **RTL & dark-mode first:** Arabic-first layouts (directional insets/alignment), AA contrast on the
  new blue, and verified light + dark variants.

---

## 11. Redesign Readiness & Recommendations

### Must preserve (do not regress)
- All **business rules** (occupancy guard, commission math, soft deletes, season filtering, deposit
  deductions, sync/audit).
- The **route structure** and parameter contracts (path/query/`extra`) — redesign the *views*, not the
  navigation graph, unless intentionally improving IA.
- **Permission/role gating** and **active-season** conditional rendering on the dashboard and lists.
- **Offline-first** behavior and every **loading / empty / error** state.

### Recommended approach (phased)
1. **Design tokens first.** Replace `AppColors`/`AppTypography`/`AppTheme` with a logo-derived token
   set (color ramps, full type scale, spacing/radius/elevation), add a **light** theme, and remove all
   hard-coded `Color(0xFF…)`/magic numbers. This alone re-skins most screens via the shared theme.
2. **Build a shared component library** (new `lib/core/widgets/` or `lib/shared/widgets/`): extract and
   unify the duplicated inline widgets into canonical components — `AppStatCard`, `AppMetricCard`,
   `AppNavCard`, `AppMoneyTile`, `AppSectionHeader`, `AppListCard`, `AppEmptyState`, `AppErrorState`,
   `AppLoading`, `AppPrimaryButton`, form fields, status `Chip`s/`Badge`s, and a standard
   detail-row. Standardize the **primary-action pattern** (one convention app-wide).
3. **Migrate screen-by-screen, grouped by feature**, in this suggested order (high traffic / high
   visibility first): Shell & role homes (splash, onboarding, login, dashboard, broker/cleaner/viewer)
   → Summer bookings → Winter contracts → Apartments/Buildings → Financials → Operations → Reports →
   Settings/Users → Search. Use the screen inventory in §5 as the checklist (65/65).
4. **Polish cross-cutting concerns:** brand the splash/onboarding/empty states with the real logo,
   route all user-facing text through `l10n` (and add friendly error/empty copy), confirm AA contrast,
   touch-target sizes, and RTL correctness.

### Quality bar (from `SPEC.md`)
`flutter analyze` clean; every feature handles loading/error/empty/offline; responsive mobile + tablet
+ the role web views; RTL verified; offline-first preserved. Add: dark **and** light verified, WCAG AA.

---

## 12. Appendix

### A. Screen → file index
All screens live under `lib/features/<feature>/presentation/screens/`:
- **auth:** `login_screen.dart`, `forgot_password_screen.dart`
- **splash / onboarding:** `splash/…/splash_screen.dart`, `onboarding/…/onboarding_screen.dart`
- **dashboard:** `dashboard/…/dashboard_screen.dart`
- **web_views:** `root_screen.dart`, `broker_web_screen.dart`, `cleaner_web_screen.dart`, `viewer_web_screen.dart`
- **buildings:** `building_list_screen.dart`, `add_building_screen.dart`
- **apartments:** `apartments_grid_screen.dart`, `add_apartment_screen.dart`, `apartment_profile_screen.dart`, `bulk_inventory_screen.dart`, `landlines_management_screen.dart`
- **bookings:** `summer_bookings_screen.dart`, `calendar_view_screen.dart`, `booking_list_screen.dart`, `booking_details_screen.dart`, `add_summer_booking_screen.dart`, `early_checkout_screen.dart`, `overstay_extension_screen.dart`, `guest_profile_screen.dart`
- **contracts:** `winter_contracts_screen.dart`, `add_winter_contract_screen.dart`, `student_details_screen.dart`, `winter_payment_history_screen.dart`
- **financials:** `expenses_list_screen.dart`, `add_expense_screen.dart`, `building_rent_screen.dart`, `add_building_rent_screen.dart`, `financial_transfers_screen.dart`, `meter_readings_screen.dart`, `add_meter_reading_screen.dart`
- **operations:** `maintenance_requests_screen.dart`, `add_maintenance_screen.dart`, `technicians_screen.dart`, `technician_details_screen.dart`, `cleaning_supplies_screen.dart`, `apartment_inspections_screen.dart`, `add_inspection_screen.dart`, `winter_checkout_screen.dart`
- **reports:** `reports_screen.dart`, `reports_filter_screen.dart`, `report_statistics_screen.dart`, `reports_menu_screen.dart`, `statement_screen.dart`, `statement_preview_screen.dart`, `report_detail_screen.dart`, `report_metric_detail_screen.dart`, `system_log_screen.dart`
- **users:** `brokers_list_screen.dart`, `broker_details_screen.dart`, `broker_visibility_control_screen.dart`, `customers_screen.dart`
- **settings:** `settings_screen.dart`, `admin_profile_screen.dart`, `users_permissions_screen.dart`, `pricing_management_screen.dart`, `season_transition_screen.dart`, `notifications_screen.dart`, `checkout_settings_screen.dart`, `data_management_screen.dart`
- **search:** `global_search_screen.dart`

### B. Glossary of Arabic domain terms
| Arabic | Meaning |
|---|---|
| أبراج | Towers (the app/brand name) |
| المصيف / الصيفي | summer (holiday) season |
| الشتوي | winter season (student/family contracts) |
| حجز / حجوزات | booking(s) |
| عقد / عقود | contract(s) |
| سمسار / سماسرة | broker(s) |
| عمولة | commission |
| خروج مبكر | early checkout |
| تمديد / إقامة إضافية | overstay extension |
| الخزنة والتحويلات | treasury & transfers |
| إيجار المبنى | building rent |
| عداد / قراءات العداد | meter / meter readings |
| صيانة | maintenance |
| سباكة / نجارة / كهرباء | plumbing / carpentry / electrical |
| نظافة / تم التنظيف | cleaning / cleaned |
| فحص / استلام الشقق | inspection / apartment handover |
| تلفيات / غرامة | damages / fine |
| عبوة / لتر / كيلو | unit / liter / kilo (supply units) |
| الشقق المتاحة | available apartments |
| غير مصرح | unauthorized |

### C. Key source files
- Spec: `SPEC.md`
- Theme: `lib/core/theme/{app_colors,app_typography,app_theme}.dart`
- Router: `lib/core/routes/app_router.dart`
- Data model: `lib/core/database/{tables,database}.dart`
- Sync / services: `lib/core/sync/sync_engine.dart`, `lib/core/services/*.dart`
- Season logic: `lib/core/utils/season_utils.dart`
- Workflows: `lib/features/{bookings,contracts,users,settings}/presentation/providers/*`
- Brand: `assets/icons/{abrag_icon,abrag_mono}.png`; fonts in `assets/fonts/`
- Entry/deps: `lib/main.dart`, `pubspec.yaml`
