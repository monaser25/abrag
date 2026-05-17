import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/users_provider.dart';
import '../../../../core/database/database.dart';

class BrokersListScreen extends ConsumerWidget {
  const BrokersListScreen({super.key});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brokersAsync = ref.watch(brokersProvider);
    final controllerState = ref.watch(brokersControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة السماسرة'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'إضافة سمسار',
            onPressed: () => _showAddBrokerDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.visibility),
            tooltip: 'التحكم في رؤية الوسطاء',
            onPressed: () {
              context.go('/brokers/visibility');
            },
          ),
        ],
      ),
      body: brokersAsync.when(
        data: (brokers) {
          if (brokers.isEmpty) {
            return const Center(child: Text('لا يوجد سماسرة مسجلين'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: brokers.length,
            itemBuilder: (context, index) {
              final broker = brokers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () {
                    context.push('/brokers/details/${broker.id}');
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: theme.colorScheme.primaryContainer
                              .withValues(alpha: 0.2),
                          child: Icon(
                            Icons.person,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                broker.fullName ?? broker.email,
                                style: theme.textTheme.titleMedium,
                              ),
                              if (broker.phoneNumber != null &&
                                  broker.phoneNumber!.isNotEmpty)
                                Text(
                                  broker.phoneNumber!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  textDirection: TextDirection.ltr,
                                ),
                              if ((broker.phoneNumber == null ||
                                      broker.phoneNumber!.isEmpty) &&
                                  !broker.email.startsWith('broker-'))
                                Text(
                                  broker.email,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (broker.phoneNumber != null &&
                                broker.phoneNumber!.isNotEmpty)
                              IconButton(
                                icon: const Icon(
                                  Icons.call,
                                  color: Colors.green,
                                ),
                                onPressed: () =>
                                    _makePhoneCall(broker.phoneNumber!),
                              ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () =>
                                  _showAddBrokerDialog(context, ref, broker),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 16),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controllerState.isLoading
            ? null
            : () => _showAddBrokerDialog(context, ref),
        icon: const Icon(Icons.person_add),
        label: const Text('إضافة سمسار'),
      ),
    );
  }

  void _showAddBrokerDialog(
    BuildContext context,
    WidgetRef ref, [
    UserProfile? broker,
  ]) {
    final nameController = TextEditingController(text: broker?.fullName ?? '');
    final phoneController = TextEditingController(
      text: broker?.phoneNumber ?? '',
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(broker == null ? 'إضافة سمسار' : 'تعديل بيانات السمسار'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'اسم السمسار'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'رقم التليفون'),
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;

              if (broker == null) {
                ref
                    .read(brokersControllerProvider.notifier)
                    .addBroker(
                      fullName: nameController.text,
                      phoneNumber: phoneController.text,
                    );
              } else {
                ref
                    .read(brokersControllerProvider.notifier)
                    .updateBroker(
                      id: broker.id,
                      fullName: nameController.text,
                      phoneNumber: phoneController.text,
                    );
              }
              Navigator.pop(dialogContext);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
