import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/bookings/presentation/screens/summer_bookings_screen.dart';
import '../../features/bookings/presentation/screens/calendar_view_screen.dart';
import '../../features/bookings/presentation/screens/booking_list_screen.dart';
import '../../features/bookings/presentation/screens/booking_details_screen.dart';
import '../../features/bookings/presentation/screens/add_summer_booking_screen.dart';
import '../../features/bookings/presentation/screens/early_checkout_screen.dart';
import '../../features/bookings/presentation/screens/overstay_extension_screen.dart';
import '../../features/bookings/presentation/screens/guest_profile_screen.dart';
import '../../features/contracts/presentation/screens/winter_contracts_screen.dart';
import '../../features/contracts/presentation/screens/add_winter_contract_screen.dart';
import '../../features/contracts/presentation/screens/student_details_screen.dart';
import '../../features/contracts/presentation/screens/winter_payment_history_screen.dart';
import '../../features/operations/presentation/screens/winter_checkout_screen.dart';
import '../../features/buildings/presentation/screens/building_list_screen.dart';
import '../../features/buildings/presentation/screens/add_building_screen.dart';
import '../../features/apartments/presentation/screens/apartments_grid_screen.dart';
import '../../features/apartments/presentation/screens/add_apartment_screen.dart';
import '../../features/apartments/presentation/screens/apartment_profile_screen.dart';
import '../../features/apartments/presentation/screens/bulk_inventory_screen.dart';
import '../../features/apartments/presentation/screens/landlines_management_screen.dart';
import '../../features/financials/presentation/screens/expenses_list_screen.dart';
import '../../features/financials/presentation/screens/add_expense_screen.dart';
import '../../features/financials/presentation/screens/add_building_rent_screen.dart';
import '../../features/operations/presentation/screens/add_maintenance_screen.dart';
import '../../features/financials/presentation/screens/building_rent_screen.dart';
import '../../features/financials/presentation/screens/financial_transfers_screen.dart';
import '../../features/financials/presentation/screens/meter_readings_screen.dart';
import '../../features/financials/presentation/screens/add_meter_reading_screen.dart';
import '../../features/operations/presentation/screens/maintenance_requests_screen.dart';
import '../../features/operations/presentation/screens/technicians_screen.dart';
import '../../features/operations/presentation/screens/technician_details_screen.dart';
import '../../features/operations/presentation/screens/cleaning_supplies_screen.dart';
import '../../features/operations/presentation/screens/apartment_inspections_screen.dart';
import '../../features/operations/presentation/screens/add_inspection_screen.dart';
import '../../core/database/database.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';
import '../../features/reports/presentation/models/report_view_models.dart';
import '../../features/reports/presentation/screens/report_detail_screen.dart';
import '../../features/reports/presentation/screens/report_metric_detail_screen.dart';
import '../../features/reports/presentation/screens/report_statistics_screen.dart';
import '../../features/reports/presentation/screens/reports_filter_screen.dart';
import '../../features/reports/presentation/screens/reports_menu_screen.dart';
import '../../features/reports/presentation/screens/statement_screen.dart';
import '../../features/reports/presentation/screens/statement_preview_screen.dart';
import '../../features/reports/presentation/screens/system_log_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/admin_profile_screen.dart';
import '../../features/settings/presentation/screens/users_permissions_screen.dart';
import '../../features/settings/presentation/screens/pricing_management_screen.dart';
import '../../features/settings/presentation/screens/season_transition_screen.dart';
import '../../features/settings/presentation/screens/notifications_screen.dart';
import '../../features/settings/presentation/screens/checkout_settings_screen.dart';
import '../../features/settings/presentation/screens/data_management_screen.dart';

import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/search/presentation/screens/global_search_screen.dart';
import '../../features/web_views/presentation/screens/root_screen.dart';
import '../../features/users/presentation/screens/brokers_list_screen.dart';
import '../../features/users/presentation/screens/broker_details_screen.dart';
import '../../features/users/presentation/screens/broker_visibility_control_screen.dart';
import '../../features/users/presentation/screens/customers_screen.dart';
import '../../features/users/presentation/providers/users_provider.dart';
import '../../features/settings/presentation/providers/permissions_provider.dart';
import '../config/shared_prefs_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final routerNotifier = RouterNotifier();

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: routerNotifier,
    redirect: (context, state) {
      final isLoggedIn = Supabase.instance.client.auth.currentSession != null;
      final onboardingCompleted = ref.read(onboardingCompletedProvider);
      final isLoginRoute = state.uri.path == '/login';
      final isSplashRoute = state.uri.path == '/splash';
      final isOnboardingRoute = state.uri.path == '/onboarding';
      final isForgotPasswordRoute = state.uri.path == '/forgot_password';

      if (isSplashRoute) {
        return null;
      }

      if (isForgotPasswordRoute) {
        return null;
      }

      if (!onboardingCompleted && !isOnboardingRoute) return '/onboarding';
      if (onboardingCompleted && isOnboardingRoute) {
        return isLoggedIn ? '/' : '/login';
      }

      if (!isLoggedIn && !isLoginRoute && !isOnboardingRoute) return '/login';
      if (isLoggedIn && isLoginRoute) return '/';

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/forgot_password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const GlobalSearchScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/',
        builder: (context, state) => const RootScreen(),
        routes: [
          GoRoute(
            path: 'customers',
            builder: (context, state) => const CustomersScreen(),
          ),
          GoRoute(
            path: 'brokers',
            builder: (context, state) => const BrokersListScreen(),
            routes: [
              GoRoute(
                path: 'details/:id',
                builder: (context, state) =>
                    BrokerDetailsScreen(brokerId: state.pathParameters['id']!),
              ),
              GoRoute(
                path: 'visibility',
                builder: (context, state) =>
                    const BrokerVisibilityControlScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'buildings',
            builder: (context, state) => const BuildingListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddBuildingScreen(),
              ),
              GoRoute(
                path: 'edit',
                builder: (context, state) =>
                    AddBuildingScreen(building: state.extra as Building?),
              ),
            ],
          ),
          GoRoute(
            path: 'apartments',
            builder: (context, state) => const ApartmentsGridScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddApartmentScreen(),
              ),
              GoRoute(
                path: 'edit',
                builder: (context, state) =>
                    AddApartmentScreen(apartment: state.extra as Apartment?),
              ),
              GoRoute(
                path: 'profile/:id',
                builder: (context, state) => ApartmentProfileScreen(
                  apartmentId: state.pathParameters['id']!,
                ),
              ),
              GoRoute(
                path: 'bulk_inventory',
                builder: (context, state) => const BulkInventoryScreen(),
              ),
              GoRoute(
                path: 'landlines',
                builder: (context, state) => const LandlinesManagementScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'summer_bookings',
            builder: (context, state) => const SummerBookingsScreen(),
            routes: [
              GoRoute(
                path: 'calendar',
                builder: (context, state) => const CalendarViewScreen(),
              ),
              GoRoute(
                path: 'list',
                builder: (context, state) => const BookingListScreen(),
              ),
              GoRoute(
                path: 'details/:id',
                builder: (context, state) => BookingDetailsScreen(
                  bookingId: state.pathParameters['id']!,
                ),
              ),
              GoRoute(
                path: 'early_checkout/:id',
                builder: (context, state) =>
                    EarlyCheckoutScreen(bookingId: state.pathParameters['id']!),
              ),
              GoRoute(
                path: 'overstay/:id',
                builder: (context, state) => OverstayExtensionScreen(
                  bookingId: state.pathParameters['id']!,
                ),
              ),
              GoRoute(
                path: 'guest/:name',
                builder: (context, state) => GuestProfileScreen(
                  guestName: _safeDecodePathParameter(
                    state.pathParameters['name']!,
                  ),
                ),
              ),
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddSummerBookingScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                builder: (context, state) => AddSummerBookingScreen(
                  bookingId: state.pathParameters['id'],
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'winter_contracts',
            builder: (context, state) => const WinterContractsScreen(),
            routes: [
              GoRoute(
                path: 'details/:id',
                builder: (context, state) => StudentDetailsScreen(
                  contractId: state.pathParameters['id']!,
                ),
              ),
              GoRoute(
                path: 'payments/:id',
                builder: (context, state) => WinterPaymentHistoryScreen(
                  contractId: state.pathParameters['id']!,
                ),
              ),
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddWinterContractScreen(),
              ),
              GoRoute(
                path: 'edit',
                builder: (context, state) => AddWinterContractScreen(
                  contract: state.extra as WinterContract?,
                ),
              ),
              GoRoute(
                path: 'checkout/:id',
                builder: (context, state) => WinterCheckoutScreen(
                  winterContractId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'expenses',
            builder: (context, state) => const ExpensesListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddExpenseScreen(),
              ),
              GoRoute(
                path: 'edit',
                builder: (context, state) =>
                    AddExpenseScreen(expense: state.extra as Expense?),
              ),
            ],
          ),
          GoRoute(
            path: 'building_rent',
            builder: (context, state) => const BuildingRentScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddBuildingRentScreen(),
              ),
              GoRoute(
                path: 'edit',
                builder: (context, state) =>
                    AddBuildingRentScreen(expense: state.extra as Expense?),
              ),
            ],
          ),
          GoRoute(
            path: 'financial_transfers',
            builder: (context, state) => const FinancialTransfersScreen(),
          ),
          // Restores reachability of the meter readings feature: the screen,
          // providers, DB table, and sync support all exist, but no route or
          // dashboard entry pointed to it (screen was orphaned). Guarded to
          // match the dashboard entry's gate (admin or manage_expenses).
          GoRoute(
            path: 'meter_readings',
            builder: (context, state) => const _PermissionRoute(
              permission: 'manage_expenses',
              child: MeterReadingsScreen(),
            ),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const _PermissionRoute(
                  permission: 'manage_expenses',
                  child: AddMeterReadingScreen(),
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'maintenance',
            builder: (context, state) => const MaintenanceRequestsScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddMaintenanceScreen(),
              ),
              GoRoute(
                path: 'edit',
                builder: (context, state) {
                  return AddMaintenanceScreen(
                    request: state.extra as MaintenanceRequest?,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: 'technicians',
            builder: (context, state) => const TechniciansScreen(),
            routes: [
              GoRoute(
                path: 'details/:id',
                builder: (context, state) => TechnicianDetailsScreen(
                  technicianId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'cleaning_supplies',
            builder: (context, state) => const CleaningSuppliesScreen(),
          ),
          GoRoute(
            path: 'inspections',
            builder: (context, state) => const ApartmentInspectionsScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => AddInspectionScreen(
                  apartmentId: state.uri.queryParameters['apartmentId'],
                  checkoutBookingId:
                      state.uri.queryParameters['checkoutBookingId'],
                  earlyCheckoutBookingId:
                      state.uri.queryParameters['earlyCheckoutBookingId'],
                  newCheckoutDate: state.uri.queryParameters['newCheckoutDate'],
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'reports',
            builder: (context, state) => ReportsScreen(
              initialFilters: state.extra is ReportFilterState
                  ? state.extra as ReportFilterState
                  : null,
            ),
            routes: [
              GoRoute(
                path: 'filters',
                builder: (context, state) => ReportsFilterScreen(
                  initialFilters: state.extra is ReportFilterState
                      ? state.extra as ReportFilterState
                      : const ReportFilterState(),
                ),
              ),
              GoRoute(
                path: 'statistics',
                builder: (context, state) => ReportStatisticsScreen(
                  filters: state.extra is ReportFilterState
                      ? state.extra as ReportFilterState
                      : const ReportFilterState(),
                ),
              ),
              GoRoute(
                path: 'menu',
                builder: (context, state) => ReportsMenuScreen(
                  filters: state.extra is ReportFilterState
                      ? state.extra as ReportFilterState
                      : const ReportFilterState(),
                ),
              ),
              GoRoute(
                path: 'statement',
                builder: (context, state) => StatementScreen(
                  initialFilters: state.extra is ReportFilterState
                      ? state.extra as ReportFilterState
                      : const ReportFilterState(),
                ),
                routes: [
                  GoRoute(
                    path: 'preview',
                    builder: (context, state) => StatementPreviewScreen(
                      filters: state.extra is ReportFilterState
                          ? state.extra as ReportFilterState
                          : const ReportFilterState(),
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: 'details/:type',
                builder: (context, state) => ReportDetailScreen(
                  kind: ReportDetailKindX.fromKey(
                    state.pathParameters['type'] ?? 'apartments',
                  ),
                  filters: state.extra is ReportFilterState
                      ? state.extra as ReportFilterState
                      : const ReportFilterState(),
                ),
                routes: [
                  GoRoute(
                    path: 'item/:key',
                    builder: (context, state) => ReportMetricDetailScreen(
                      kind: ReportDetailKindX.fromKey(
                        state.pathParameters['type'] ?? 'apartments',
                      ),
                      metricKey: _decodeReportMetricKey(
                        state.pathParameters['key'],
                      ),
                      filters: state.extra is ReportFilterState
                          ? state.extra as ReportFilterState
                          : const ReportFilterState(),
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: 'log',
                builder: (context, state) => const SystemLogScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) =>
                const _AdminOnlyRoute(child: SettingsScreen()),
            routes: [
              GoRoute(
                path: 'profile',
                builder: (context, state) =>
                    const _AdminOnlyRoute(child: AdminProfileScreen()),
              ),
              GoRoute(
                path: 'users',
                builder: (context, state) =>
                    const _AdminOnlyRoute(child: UsersPermissionsScreen()),
              ),
              GoRoute(
                path: 'pricing',
                builder: (context, state) =>
                    const _AdminOnlyRoute(child: PricingManagementScreen()),
              ),
              GoRoute(
                path: 'season_transition',
                builder: (context, state) =>
                    const _AdminOnlyRoute(child: SeasonTransitionScreen()),
              ),
              GoRoute(
                path: 'notifications',
                builder: (context, state) =>
                    const _AdminOnlyRoute(child: NotificationsScreen()),
              ),
              GoRoute(
                path: 'checkout_times',
                builder: (context, state) =>
                    const _AdminOnlyRoute(child: CheckoutSettingsScreen()),
              ),
              GoRoute(
                path: 'data_management',
                builder: (context, state) =>
                    const _AdminOnlyRoute(child: DataManagementScreen()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class RouterNotifier extends ChangeNotifier {
  RouterNotifier() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      notifyListeners();
    });
  }
}

String _decodeReportMetricKey(String? key) {
  if (key == null || key.isEmpty) return '';
  try {
    return utf8.decode(base64Url.decode(key));
  } catch (_) {
    return key;
  }
}

String _safeDecodePathParameter(String value) {
  try {
    return Uri.decodeComponent(value);
  } on FormatException {
    return value;
  } on ArgumentError {
    return value;
  }
}

class _AdminOnlyRoute extends ConsumerWidget {
  final Widget child;

  const _AdminOnlyRoute({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleAsync = ref.watch(currentUserRoleProvider);

    if (roleAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (roleAsync.valueOrNull != 'admin') {
      return Scaffold(
        appBar: AppBar(title: const Text('غير مصرح')),
        body: const Center(child: Text('غير مصرح لك بفتح الإعدادات')),
      );
    }

    return child;
  }
}

/// Screen-level guard mirroring [_AdminOnlyRoute]: admins pass; other users
/// pass only if their role template grants [permission] (same resolution as
/// the dashboard's hasPerm — rolesConfigProvider + current session user id).
class _PermissionRoute extends ConsumerWidget {
  final String permission;
  final Widget child;

  const _PermissionRoute({required this.permission, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleAsync = ref.watch(currentUserRoleProvider);

    if (roleAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (roleAsync.valueOrNull == 'admin') return child;

    final userId = Supabase.instance.client.auth.currentSession?.user.id;
    final rolesConfig = ref.watch(rolesConfigProvider);
    final customRoleName = userId == null
        ? null
        : rolesConfig.userRoles[userId];
    final perms = customRoleName == null
        ? const <String>[]
        : (rolesConfig.roleTemplates[customRoleName] ?? const <String>[]);

    if (perms.contains(permission)) return child;

    return Scaffold(
      appBar: AppBar(title: const Text('غير مصرح')),
      body: const Center(child: Text('غير مصرح لك بفتح هذه الصفحة')),
    );
  }
}
