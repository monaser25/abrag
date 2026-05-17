import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/apartments_controller.dart';

class LandlinesManagementScreen extends ConsumerStatefulWidget {
  const LandlinesManagementScreen({super.key});

  @override
  ConsumerState<LandlinesManagementScreen> createState() =>
      _LandlinesManagementScreenState();
}

class _LandlinesManagementScreenState
    extends ConsumerState<LandlinesManagementScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final apartmentsAsync = ref.watch(apartmentsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('إدارة الخطوط الأرضية')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'ابحث برقم الشقة، رقم الخط، أو اسم صاحب الخط',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _search = value.trim()),
            ),
          ),
          Expanded(
            child: apartmentsAsync.when(
              data: (apartments) {
                final filtered =
                    apartments.where((apartment) {
                      if (_search.isEmpty) return true;
                      final query = _search.toLowerCase();
                      return apartment.apartmentNumber.toLowerCase().contains(
                            query,
                          ) ||
                          (apartment.landlineNumber ?? '')
                              .toLowerCase()
                              .contains(query) ||
                          (apartment.landlineOwnerName ?? '')
                              .toLowerCase()
                              .contains(query);
                    }).toList()..sort(
                      (a, b) => a.apartmentNumber.compareTo(b.apartmentNumber),
                    );

                final registered = apartments
                    .where(
                      (apartment) =>
                          (apartment.landlineNumber ?? '').trim().isNotEmpty,
                    )
                    .length;

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: _MiniCounter(
                                label: 'خطوط مسجلة',
                                value: '$registered',
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _MiniCounter(
                                label: 'بدون خط',
                                value: '${apartments.length - registered}',
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (filtered.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: Text('لا توجد نتائج')),
                      )
                    else
                      ...filtered.map(
                        (apartment) => Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.primary
                                  .withValues(alpha: 0.14),
                              child: const Icon(Icons.phone),
                            ),
                            title: Text('شقة ${apartment.apartmentNumber}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (apartment.landlineNumber ?? '').isEmpty
                                      ? 'لا يوجد رقم أرضي مسجل'
                                      : 'رقم الخط: ${apartment.landlineNumber}',
                                ),
                                if ((apartment.landlineOwnerName ?? '')
                                    .isNotEmpty)
                                  Text(
                                    'صاحب الخط: ${apartment.landlineOwnerName}',
                                  ),
                              ],
                            ),
                            trailing: const Icon(Icons.edit),
                            onTap: () => _showEditSheet(apartment),
                          ),
                        ),
                      ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('حدث خطأ: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditSheet(dynamic apartment) async {
    final numberController = TextEditingController(
      text: apartment.landlineNumber ?? '',
    );
    final ownerController = TextEditingController(
      text: apartment.landlineOwnerName ?? '',
    );
    final notesController = TextEditingController(
      text: apartment.landlineNotes ?? '',
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'تعديل خط شقة ${apartment.apartmentNumber}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: numberController,
              decoration: const InputDecoration(labelText: 'رقم الخط الأرضي'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ownerController,
              decoration: const InputDecoration(labelText: 'اسم صاحب الخط'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'ملاحظات'),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                ref
                    .read(apartmentsControllerProvider.notifier)
                    .updateLandline(
                      id: apartment.id,
                      landlineNumber: numberController.text,
                      ownerName: ownerController.text,
                      notes: notesController.text,
                    );
                context.pop();
              },
              icon: const Icon(Icons.save),
              label: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );

    numberController.dispose();
    ownerController.dispose();
    notesController.dispose();
  }
}

class _MiniCounter extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniCounter({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Text(label),
        ],
      ),
    );
  }
}
