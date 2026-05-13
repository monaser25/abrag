import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';

class SummerBookingsScreen extends ConsumerWidget {
  const SummerBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.summerBookings),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => context.go('/summer_bookings/calendar'),
              icon: const Icon(Icons.calendar_month),
              label: const Text('أجندة الحجوزات (Calendar)'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(250, 50)),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.go('/summer_bookings/list'),
              icon: const Icon(Icons.list),
              label: const Text('قائمة الحجوزات (List)'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(250, 50)),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/summer_bookings/add');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
