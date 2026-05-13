import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/bookings/presentation/screens/summer_bookings_screen.dart';
import '../../features/bookings/presentation/screens/calendar_view_screen.dart';
import '../../features/bookings/presentation/screens/booking_list_screen.dart';
import '../../features/bookings/presentation/screens/booking_details_screen.dart';
import '../../features/bookings/presentation/screens/add_summer_booking_screen.dart';
import '../../features/contracts/presentation/screens/winter_contracts_screen.dart';
import '../../features/contracts/presentation/screens/add_winter_contract_screen.dart';
import '../../features/contracts/presentation/screens/student_details_screen.dart';
import '../../features/contracts/presentation/screens/winter_payment_history_screen.dart';
import '../../features/buildings/presentation/screens/building_list_screen.dart';
import '../../features/buildings/presentation/screens/add_building_screen.dart';
import '../../features/apartments/presentation/screens/apartments_grid_screen.dart';
import '../../features/apartments/presentation/screens/add_apartment_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final routerNotifier = RouterNotifier();

  return GoRouter(
    initialLocation: '/',
    refreshListenable: routerNotifier,
    redirect: (context, state) {
      final isLoggedIn = Supabase.instance.client.auth.currentSession != null;
      final isLoginRoute = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoginRoute) return '/login';
      if (isLoggedIn && isLoginRoute) return '/';

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const DashboardScreen(),
        routes: [
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
