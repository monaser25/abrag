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
import '../../features/buildings/presentation/screens/building_list_screen.dart';
import '../../features/buildings/presentation/screens/add_building_screen.dart';
import '../../features/apartments/presentation/screens/apartments_grid_screen.dart';
import '../../features/apartments/presentation/screens/add_apartment_screen.dart';
import '../../features/apartments/presentation/screens/apartment_profile_screen.dart';
import '../../features/financials/presentation/screens/expenses_list_screen.dart';
import '../../features/financials/presentation/screens/add_expense_screen.dart';
import '../../features/financials/presentation/screens/meter_readings_screen.dart';
import '../../features/financials/presentation/screens/building_rent_screen.dart';
import '../../features/operations/presentation/screens/maintenance_requests_screen.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';
import '../../features/reports/presentation/screens/statement_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/admin_profile_screen.dart';
import '../../features/settings/presentation/screens/users_permissions_screen.dart';
import '../../features/settings/presentation/screens/pricing_management_screen.dart';
import '../../features/settings/presentation/screens/season_transition_screen.dart';
import '../../features/settings/presentation/screens/notifications_screen.dart';

import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/search/presentation/screens/global_search_screen.dart';
import '../../features/web_views/presentation/screens/root_screen.dart';
import '../../features/users/presentation/screens/brokers_list_screen.dart';
import '../../features/users/presentation/screens/broker_details_screen.dart';
import '../../features/users/presentation/screens/broker_visibility_control_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final routerNotifier = RouterNotifier();

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: routerNotifier,
    redirect: (context, state) {
      final isLoggedIn = Supabase.instance.client.auth.currentSession != null;
      final isLoginRoute = state.matchedLocation == '/login';
      final isSplashRoute = state.matchedLocation == '/splash';
      final isOnboardingRoute = state.matchedLocation == '/onboarding';
      final isForgotPasswordRoute = state.matchedLocation == '/forgot_password';

      if (isSplashRoute || isOnboardingRoute || isForgotPasswordRoute) return null;

      if (!isLoggedIn && !isLoginRoute) return '/login';
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
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const RootScreen(),
        routes: [
          GoRoute(
            path: 'brokers',
            builder: (context, state) => const BrokersListScreen(),
            routes: [
              GoRoute(
                path: 'details/:id',
                builder: (context, state) => BrokerDetailsScreen(brokerId: state.pathParameters['id']!),
              ),
              GoRoute(
                path: 'visibility',
                builder: (context, state) => const BrokerVisibilityControlScreen(),
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
                path: 'profile/:id',
                builder: (context, state) => ApartmentProfileScreen(apartmentId: state.pathParameters['id']!),
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
                builder: (context, state) => BookingDetailsScreen(bookingId: state.pathParameters['id']!),
              ),
              GoRoute(
                path: 'early_checkout/:id',
                builder: (context, state) => EarlyCheckoutScreen(bookingId: state.pathParameters['id']!),
              ),
              GoRoute(
                path: 'overstay/:id',
                builder: (context, state) => OverstayExtensionScreen(bookingId: state.pathParameters['id']!),
              ),
              GoRoute(
                path: 'guest/:name',
                builder: (context, state) => GuestProfileScreen(guestName: state.pathParameters['name']!),
              ),
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddSummerBookingScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'winter_contracts',
            builder: (context, state) => const WinterContractsScreen(),
            routes: [
              GoRoute(
                path: 'details/:id',
                builder: (context, state) => StudentDetailsScreen(contractId: state.pathParameters['id']!),
              ),
              GoRoute(
                path: 'payments/:id',
                builder: (context, state) => WinterPaymentHistoryScreen(contractId: state.pathParameters['id']!),
              ),
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddWinterContractScreen(),
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
            ],
          ),
          GoRoute(
            path: 'meter_readings',
            builder: (context, state) => const MeterReadingsScreen(),
          ),
          GoRoute(
            path: 'building_rent',
            builder: (context, state) => const BuildingRentScreen(),
          ),
          GoRoute(
            path: 'maintenance',
            builder: (context, state) => const MaintenanceRequestsScreen(),
          ),
          GoRoute(
            path: 'reports',
            builder: (context, state) => const ReportsScreen(),
            routes: [
              GoRoute(
                path: 'statement',
                builder: (context, state) => const StatementScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'profile',
                builder: (context, state) => const AdminProfileScreen(),
              ),
              GoRoute(
                path: 'users',
                builder: (context, state) => const UsersPermissionsScreen(),
              ),
              GoRoute(
                path: 'pricing',
                builder: (context, state) => const PricingManagementScreen(),
              ),
              GoRoute(
                path: 'season_transition',
                builder: (context, state) => const SeasonTransitionScreen(),
              ),
              GoRoute(
                path: 'notifications',
                builder: (context, state) => const NotificationsScreen(),
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
