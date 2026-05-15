import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/users_provider.dart';
import '../../../bookings/presentation/providers/bookings_provider.dart';
import '../../../../core/database/database.dart';
import '../../../../core/utils/currency_formatter.dart';

class BrokerDetailsScreen extends ConsumerWidget {
  final String brokerId;

  const BrokerDetailsScreen({super.key, required this.brokerId});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _showAddBrokerDialog(BuildContext context, WidgetRef ref, UserProfile broker) {
    final nameController = TextEditingController(text: broker.fullName ?? '');
    final phoneController = TextEditingController(text: broker.phoneNumber ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تعديل بيانات السمسار'),
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
              ref
                  .read(brokersControllerProvider.notifier)
                  .updateBroker(
                    id: broker.id,
                    fullName: nameController.text,
                    phoneNumber: phoneController.text,
                  );
              Navigator.pop(dialogContext);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brokersAsync = ref.watch(brokersProvider);
    final bookingsAsync = ref.watch(summerBookingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل السمسار'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/brokers'),
        ),
        actions: [
          brokersAsync.maybeWhen(
            data: (brokers) {
              final broker = brokers.firstWhere(
                (b) => b.id == brokerId,
                orElse: () => throw Exception('Broker not found'),
              );
              return IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showAddBrokerDialog(context, ref, broker),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: brokersAsync.when(
        data: (brokers) {
          final broker = brokers.firstWhere(
            (b) => b.id == brokerId,
            orElse: () => throw Exception('Broker not found'),
          );

          final brokerBookings = bookingsAsync.maybeWhen(
            data: (bookings) =>
                bookings.where((b) => b.brokerId == brokerId).toList(),
            orElse: () => const [],
          );
          final totalCommissions = brokerBookings.fold<double>(0, (
            sum,
            booking,
          ) {
            if (booking.brokerCommissionType == 'fixed') {
              return sum + booking.brokerCommissionFixedEgp;
            }
            if (booking.brokerCommissionType == 'percentage') {
              return sum +
                  (booking.totalPriceEgp *
                      booking.brokerCommissionPercentage /
                      100);
            }
            return sum + (booking.brokerCommissionAmountEgp ?? 0);
          });
          final totalSales = brokerBookings.fold<double>(
            0,
            (sum, booking) => sum + booking.totalPriceEgp,
          );
          final allBookingsCount = bookingsAsync.maybeWhen(
            data: (bookings) => bookings.length,
            orElse: () => 0,
          );
          final contributionPercent = allBookingsCount == 0
              ? 0.0
              : (brokerBookings.length / allBookingsCount) * 100;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: theme.colorScheme.primaryContainer
                            .withValues(alpha: 0.2),
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        broker.fullName ?? broker.email,
                        style: theme.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      if (broker.phoneNumber != null &&
                          broker.phoneNumber!.isNotEmpty)
                        ElevatedButton.icon(
                          onPressed: () => _makePhoneCall(broker.phoneNumber!),
                          icon: const Icon(Icons.call),
                          label: Text(broker.phoneNumber!),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                        ),
                      if ((broker.phoneNumber == null ||
                              broker.phoneNumber!.isEmpty) &&
                          !broker.email.startsWith('broker-'))
                        Text(
                          broker.email,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('الإحصائيات', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.green),
                  title: const Text('عدد الحجوزات الناجحة'),
                  trailing: Text(
                    '${brokerBookings.length}',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(
                    Icons.percent,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('نسبة الزباين من خلاله'),
                  subtitle: const Text('من إجمالي حجوزات الصيف'),
                  trailing: Text(
                    '${contributionPercent.toStringAsFixed(1)}%',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.money, color: theme.colorScheme.primary),
                  title: const Text('إجمالي العمولات'),
                  trailing: Text(
                    '${totalCommissions.toCurrencyFormat()} ج.م',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(
                    Icons.payments,
                    color: theme.colorScheme.secondary,
                  ),
                  title: const Text('إجمالي حجوزاته'),
                  trailing: Text(
                    '${totalSales.toCurrencyFormat()} ج.م',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
