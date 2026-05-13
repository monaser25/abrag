import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/apartments_controller.dart';
import '../providers/apartment_profile_provider.dart';

class ApartmentsGridScreen extends ConsumerWidget {
  const ApartmentsGridScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final apartmentsAsync = ref.watch(apartmentsProvider);
    final theme = Theme.of(context);

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
              return Consumer(
                builder: (context, ref, child) {
                  final profileAsync = ref.watch(apartmentProfileProvider(apt.id));
                  
                  return profileAsync.when(
                    data: (data) {
                      final isCleaning = data.apartment.cleaningStatus == 'needs_cleaning';
                      final isOccupied = data.isOccupied;

                      Color statusColor = Colors.green;
                      String statusText = 'متاحة';
                      if (isCleaning) {
                        statusColor = Colors.orange;
                        statusText = 'نظافة';
                      } else if (isOccupied) {
                        statusColor = theme.colorScheme.error;
                        statusText = 'مشغولة';
                      }

                      return InkWell(
                        onTap: () => context.go('/apartments/profile/${apt.id}'),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                            boxShadow: [
                              BoxShadow(
                                color: statusColor.withValues(alpha: 0.05),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      apt.apartmentNumber,
                                      style: theme.textTheme.headlineMedium?.copyWith(
                                        color: isOccupied ? theme.colorScheme.onSurface.withValues(alpha: 0.6) : theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      statusText,
                                      style: theme.textTheme.labelSmall?.copyWith(color: statusColor),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    loading: () => const Card(child: Center(child: CircularProgressIndicator())),
                    error: (err, stack) => const Card(child: Center(child: Icon(Icons.error))),
                  );
                },
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
