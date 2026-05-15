import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/maintenance_provider.dart';
import '../providers/maintenance_controller.dart';
import '../providers/technicians_provider.dart';
import '../../../apartments/presentation/providers/apartments_controller.dart';

import '../../../../core/utils/currency_formatter.dart';

class MaintenanceRequestsScreen extends ConsumerStatefulWidget {
  const MaintenanceRequestsScreen({super.key});

  @override
  ConsumerState<MaintenanceRequestsScreen> createState() =>
      _MaintenanceRequestsScreenState();
}

class _MaintenanceRequestsScreenState
    extends ConsumerState<MaintenanceRequestsScreen> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final maintenanceAsync = ref.watch(maintenanceProvider);
    final apartmentsAsync = ref.watch(apartmentsProvider);
    final techniciansAsync = ref.watch(techniciansProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.maintenance)),
      body: maintenanceAsync.when(
        data: (requests) {
          if (requests.isEmpty) {
            return Center(child: Text(l10n.noData));
          }

          final now = DateTime.now();
          final filteredRequests = requests.where((req) {
            if (_selectedFilter == 'open') return req.status == 'open';
            if (_selectedFilter == 'closed') return req.status != 'open';
            if (_selectedFilter == 'this_month') {
              return req.createdAt.year == now.year &&
                  req.createdAt.month == now.month;
            }
            return true;
          }).toList();

          return Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _selectedFilter = 'all'),
                      child: _FilterChip(
                        label: 'الكل',
                        isSelected: _selectedFilter == 'all',
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() => _selectedFilter = 'open'),
                      child: _FilterChip(
                        label: 'مفتوح',
                        isSelected: _selectedFilter == 'open',
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() => _selectedFilter = 'closed'),
                      child: _FilterChip(
                        label: 'مغلق',
                        isSelected: _selectedFilter == 'closed',
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () =>
                          setState(() => _selectedFilter = 'this_month'),
                      child: _FilterChip(
                        label: 'خلال الشهر',
                        isSelected: _selectedFilter == 'this_month',
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filteredRequests.isEmpty
                    ? Center(child: Text(l10n.noData))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredRequests.length,
                        itemBuilder: (context, index) {
                          final req = filteredRequests[index];
                          final isOpen = req.status == 'open';
                          final apartmentNumber = apartmentsAsync.maybeWhen(
                            data: (apts) {
                              final matches = apts
                                  .where((a) => a.id == req.apartmentId)
                                  .toList();
                              return matches.isEmpty
                                  ? req.apartmentId
                                  : matches.first.apartmentNumber;
                            },
                            orElse: () => req.apartmentId,
                          );

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: isOpen
                                  ? () => _showResolveDialog(context, ref, req)
                                  : null,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                        Row(
                                          children: [
                                            if (isOpen)
                                              IconButton(
                                                icon: const Icon(Icons.edit, size: 20),
                                                onPressed: () {
                                                  context.go('/maintenance/edit', extra: req);
                                                },
                                              ),
                                            Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isOpen
                                                ? theme.colorScheme.error
                                                      .withValues(alpha: 0.1)
                                                : Colors.green.withValues(
                                                    alpha: 0.1,
                                                  ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            isOpen
                                                ? 'مفتوح (اضغط للإغلاق)'
                                                : 'مغلق',
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                  color: isOpen
                                                      ? theme.colorScheme.error
                                                      : Colors.green,
                                                ),
                                          ),
                                        ),
                                        Text(
                                          req.createdAt
                                              .toLocal()
                                              .toString()
                                              .split(' ')[0],
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      req.issueDescription,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    if (req.technicianId != null) ...[
                                      const SizedBox(height: 8),
                                      techniciansAsync.maybeWhen(
                                        data: (techs) {
                                          final techName = techs.where((t) => t.id == req.technicianId).map((t) => t.name).firstOrNull;
                                          if (techName != null) {
                                            return Row(
                                              children: [
                                                const Icon(Icons.engineering, size: 16, color: Colors.grey),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'الفني: $techName',
                                                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                                                ),
                                              ],
                                            );
                                          }
                                          return const SizedBox.shrink();
                                        },
                                        orElse: () => const SizedBox.shrink(),
                                      ),
                                    ],
                                    const Divider(height: 24),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.apartment,
                                              size: 16,
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'شقة $apartmentNumber',
                                              style:
                                                  theme.textTheme.labelMedium,
                                            ),
                                          ],
                                        ),
                                        if (!isOpen)
                                          Text(
                                            '${req.costEgp.toCurrencyFormat()} ج.م',
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                                  color:
                                                      theme.colorScheme.primary,
                                                ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/maintenance/add');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showResolveDialog(BuildContext context, WidgetRef ref, dynamic req) {
    final costController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إغلاق طلب الصيانة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'قم بإدخال تكلفة الصيانة (إن وجدت). سيتم تسجيلها كمصروف تلقائياً.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: costController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [CurrencyInputFormatter()],
              decoration: const InputDecoration(
                labelText: 'التكلفة (ج.م)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final cost = double.tryParse(costController.text.replaceAll(',', '')) ?? 0.0;
              ref
                  .read(maintenanceControllerProvider.notifier)
                  .updateStatus(req.id, 'resolved', cost: cost);
              Navigator.pop(ctx);
            },
            child: const Text('حفظ وإغلاق'),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _FilterChip({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? Theme.of(context).colorScheme.onPrimaryContainer
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
