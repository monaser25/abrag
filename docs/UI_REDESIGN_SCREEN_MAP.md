# UI Redesign — Screen Map

Mapping of every Flutter screen/route to the `abrag/` prototype. Match quality: **exact** (designed in prototype), **partial** (pattern exists, details differ), **missing** (stubbed in prototype — extrapolate from design language).

Phases refer to `UI_REDESIGN_MIGRATION_PLAN.md` §5.

## Auth / Shell

| Flutter screen (route) | Prototype | Match | Notes | Risk | Phase |
|---|---|---|---|---|---|
| `splash_screen.dart` (`/splash`) | `SplashScreen` (screens_auth) | exact | Logo + glow + skyline motif | Low | 2 |
| `onboarding_screen.dart` (`/onboarding`) | `OnboardingScreen` | exact | 4 pages → prototype has 3-step + dots; keep existing page count/content, restyle | Low | 2 |
| `login_screen.dart` (`/login`) | `LoginScreen` | exact | Prototype role-picker is demo-only — keep real Supabase auth + real role routing | Med | 2 |
| `forgot_password_screen.dart` (`/forgot_password`) | — | missing | Style as login variant (field + primary button + logo) | Low | 2 |
| `root_screen.dart` (`/`) | role routing in app.jsx | partial | Keep role logic; visual shell only | Med | 3 |

## Home / Roles

| Flutter screen | Prototype | Match | Notes | Risk | Phase |
|---|---|---|---|---|---|
| `dashboard_screen.dart` | `DashboardScreen` (screens_home) | exact | StatCards, season hero, MiniNav grid, spark bars | Med | 3 |
| `broker_web_screen.dart` | `BrokerHome` | exact | Keep webview/data logic | Med | 3 |
| `cleaner_web_screen.dart` | `CleanerHome` | exact | 〃 | Med | 3 |
| `viewer_web_screen.dart` | `ViewerHome` | exact | 〃 | Med | 3 |

## Bookings (summer)

| Flutter screen | Prototype | Match | Notes | Risk | Phase |
|---|---|---|---|---|---|
| `summer_bookings_screen.dart` | `BookingsHub` | exact | Segmented tabs + BookingCard list | High | 4 |
| `booking_list_screen.dart` | `BookingsHub` list pattern | partial | Same card pattern | Med | 4 |
| `booking_details_screen.dart` | `BookingDetail` | exact | DetailRow groups, chips, action bar | High | 4 |
| `add_summer_booking_screen.dart` | `BookingAdd` | exact | **Form pattern source of truth**; keep all validation/controllers | High | 6 |
| `calendar_view_screen.dart` | — | missing | Restyle `table_calendar` with tokens; season chips | Med | 4 |
| `early_checkout_screen.dart` | — | missing | Detail + action-bar pattern | Med | 6 |
| `overstay_extension_screen.dart` | — | missing | 〃 | Med | 6 |
| `guest_profile_screen.dart` | — | missing | Avatar + DetailRow + history list pattern | Low | 7 |

## Contracts (winter)

| Flutter screen | Prototype | Match | Notes | Risk | Phase |
|---|---|---|---|---|---|
| `winter_contracts_screen.dart` | `ContractsHub` | exact | ContractCard + utilities split | High | 4 |
| `student_details_screen.dart` | `ContractDetail` | exact | | High | 4 |
| `winter_payment_history_screen.dart` | `PaymentHistory` | exact | Timeline component (paid/due nodes) | Med | 4 |
| `add_winter_contract_screen.dart` | — | missing | BookingAdd form pattern | High | 6 |
| `winter_checkout_screen.dart` | — | missing | Detail + action bar pattern | Med | 6 |

## Apartments / Buildings

| Flutter screen | Prototype | Match | Notes | Risk | Phase |
|---|---|---|---|---|---|
| `apartments_grid_screen.dart` | `ApartmentsGrid` | exact | `.apt` square cells, status dots, clean-status | Med | 4 |
| `apartment_profile_screen.dart` | `ApartmentProfile` | exact | | Med | 4 |
| `add_apartment_screen.dart` | — | missing | Form pattern | Med | 6 |
| `bulk_inventory_screen.dart` | — | missing | List + toggle pattern | Low | 7 |
| `landlines_management_screen.dart` | — | missing | NavRow list pattern | Low | 7 |
| `building_list_screen.dart` | — | missing | Card list pattern (bookings hub) | Med | 7 |
| `add_building_screen.dart` | — | missing | Form pattern | Med | 6 |

## Financials

| Flutter screen | Prototype | Match | Notes | Risk | Phase |
|---|---|---|---|---|---|
| `expenses_list_screen.dart` | — | missing | Card list + chips + FAB | Med | 7 |
| `add_expense_screen.dart` | — | missing | Form pattern | Med | 6 |
| `building_rent_screen.dart` | — | missing | List + progress (`.prog`) pattern | Med | 7 |
| `add_building_rent_screen.dart` | — | missing | Form pattern | Med | 6 |
| `financial_transfers_screen.dart` | — | missing | List + money typography (`num` tabular) | Med | 7 |
| `meter_readings_screen.dart` + add | — | missing | List + meter icon + form pattern | Low | 7 |

## Operations

| Flutter screen | Prototype | Match | Notes | Risk | Phase |
|---|---|---|---|---|---|
| `maintenance_requests_screen.dart` | — | missing | Card list + status chips | Med | 7 |
| `add_maintenance_screen.dart` | — | missing | Form pattern | Med | 6 |
| `technicians_screen.dart` / details | — | missing | Avatar list / profile pattern | Low | 7 |
| `cleaning_supplies_screen.dart` | — | missing | List + counters | Low | 7 |
| `apartment_inspections_screen.dart` / add | — | missing | List + form patterns | Med | 7 |

## Reports

| Flutter screen | Prototype | Match | Notes | Risk | Phase |
|---|---|---|---|---|---|
| `reports_screen.dart` | `ReportsScreen` | exact | Stat tiles + spark bars + filter chips | Med | 5 |
| `statement_preview_screen.dart` | `StatementPreview` | exact | `.paper` receipt styling; keep PDF export logic | Med | 5 |
| `statement_screen.dart` | StatementPreview pattern | partial | | Med | 5 |
| `report_detail_screen.dart`, `report_metric_detail_screen.dart`, `report_statistics_screen.dart`, `reports_filter_screen.dart`, `reports_menu_screen.dart` | — | missing | Extrapolate from ReportsScreen pattern | Med | 5 |
| `system_log_screen.dart` | — | missing | Timeline/list pattern | Low | 7 |

## Search / Notifications / Settings

| Flutter screen | Prototype | Match | Notes | Risk | Phase |
|---|---|---|---|---|---|
| `global_search_screen.dart` | `SearchScreen` | exact | Field + result cards | Low | 5 |
| `notifications_screen.dart` | `NotificationsScreen` | exact | | Low | 5 |
| `settings_screen.dart` | `SettingsScreen` | exact | NavRow groups + toggles | Med | 5 |
| `admin_profile_screen.dart` | — | missing | Avatar + DetailRow pattern | Low | 7 |
| `users_permissions_screen.dart` | — | missing | Avatar list + role chips + toggles | Med | 7 |
| `pricing_management_screen.dart` | — | missing | List + money fields | Med | 7 |
| `season_transition_screen.dart` | — | missing | Season hero (summer/winter gradients) | Med | 7 |
| `checkout_settings_screen.dart` | — | missing | Settings rows + time pickers | Low | 7 |
| `data_management_screen.dart` | — | missing | NavRow + destructive-action styling | Med | 7 |

## Users

| Flutter screen | Prototype | Match | Notes | Risk | Phase |
|---|---|---|---|---|---|
| `brokers_list_screen.dart` / `broker_details_screen.dart` / `broker_visibility_control_screen.dart` | — | missing | Avatar list, profile, toggle-list patterns | Med | 7 |
| `customers_screen.dart` | — | missing | Avatar list pattern | Low | 7 |

**Totals:** 20 exact · 4 partial · ~36 missing (extrapolated).
