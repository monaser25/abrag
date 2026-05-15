import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/buildings_controller.dart';

class BuildingListScreen extends ConsumerWidget {
  const BuildingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final buildingsAsync = ref.watch(buildingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.buildings),
      ),
      body: buildingsAsync.when(
        data: (buildings) {
          if (buildings.isEmpty) {
            return Center(child: Text(l10n.noData));
          }
          return ListView.builder(
            itemCount: buildings.length,
            itemBuilder: (context, index) {
              final building = buildings[index];
              return Card(
                child: ListTile(
                  title: Text(building.name),
                  subtitle: Text(building.address ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${building.totalApartments} ${l10n.apartments}'),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          context.go('/buildings/edit', extra: building);
                        },
                      ),
                    ],
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
          context.go('/buildings/add');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
