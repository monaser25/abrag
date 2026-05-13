import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/apartments_controller.dart';

class ApartmentsGridScreen extends ConsumerWidget {
  const ApartmentsGridScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final apartmentsAsync = ref.watch(apartmentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.apartments),
      ),
      body: apartmentsAsync.when(
        data: (apartments) {
          if (apartments.isEmpty) {
            return Center(child: Text(l10n.noData));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: apartments.length,
            itemBuilder: (context, index) {
              final apt = apartments[index];
              return Card(
                color: apt.cleaningStatus == 'clean' ? Colors.green.shade800 : Colors.red.shade800,
                child: Center(
                  child: Text(
                    apt.apartmentNumber,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/apartments/add');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
