import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/users_provider.dart';
import '../../../bookings/presentation/providers/bookings_provider.dart';
import '../../../../core/database/database.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/widgets.dart';

class BrokerDetailsScreen extends ConsumerWidget {
  final String brokerId;

  const BrokerDetailsScreen({super.key, required this.brokerId});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _showAddBrokerDialog(
    BuildContext context,
    WidgetRef ref,
    UserProfile broker,
  ) {
    final nameController = TextEditingController(text: broker.fullName ?? '');
    final phoneController = TextEditingController(
      text: broker.phoneNumber ?? '',
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        final colors = dialogContext.colors;
        return AlertDialog(
          backgroundColor: colors.surface,
          title: const Text('تعديل بيانات السمسار'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  controller: nameController,
                  label: 'اسم السمسار',
                  prefixIcon: Icons.person_outline,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: phoneController,
                  label: 'رقم التليفون',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  validator: (value) {
                    final phone = value?.trim() ?? '';
                    if (phone.isEmpty) return null;
                    return RegExp(r'^01\d{9}$').hasMatch(phone)
                        ? null
                        : 'رقم التليفون يجب أن يكون 11 رقم ويبدأ بـ 01';
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            AppButton(
              label: 'حفظ',
              small: true,
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                ref
                    .read(brokersControllerProvider.notifier)
                    .updateBroker(
                      id: broker.id,
                      fullName: nameController.text,
                      phoneNumber: phoneController.text,
                      secondaryPhone: broker.secondaryPhone,
                    );
                Navigator.pop(dialogContext);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brokersAsync = ref.watch(brokersProvider);
    final bookingsAsync = ref.watch(allSummerBookingsProvider);
    final colors = context.colors;

    return AppScaffold(
      appBar: AbragAppBar(
        title: 'تفاصيل السمسار',
        showBack: true,
        onBack: () => context.go('/brokers'),
        actions: [
          brokersAsync.maybeWhen(
            data: (brokers) {
              final broker = brokers.firstWhere(
                (b) => b.id == brokerId,
                orElse: () => throw Exception('Broker not found'),
              );
              return AppIconButton(
                icon: Icons.edit_outlined,
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

          final hasPhone =
              broker.phoneNumber != null && broker.phoneNumber!.isNotEmpty;
          final showEmail = !hasPhone && !broker.email.startsWith('broker-');
          final name = broker.fullName ?? broker.email;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              AppCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    AppAvatar(name: name, size: 80),
                    const SizedBox(height: 14),
                    Text(
                      name,
                      style: AppTextStyles.h2.copyWith(color: colors.ink),
                      textAlign: TextAlign.center,
                    ),
                    if (hasPhone) ...[
                      const SizedBox(height: 16),
                      AppButton(
                        label: broker.phoneNumber!,
                        icon: Icons.call,
                        onPressed: () => _makePhoneCall(broker.phoneNumber!),
                      ),
                    ],
                    if (showEmail) ...[
                      const SizedBox(height: 10),
                      Text(
                        broker.email,
                        style: AppTextStyles.bodyS.copyWith(color: colors.ink2),
                      ),
                    ],
                  ],
                ),
              ),
              const SectionTitle(title: 'الإحصائيات'),
              _StatTile(
                icon: Icons.check_circle,
                tint: colors.ok,
                title: 'عدد الحجوزات الناجحة',
                value: '${brokerBookings.length}',
              ),
              _StatTile(
                icon: Icons.percent,
                tint: colors.brand,
                title: 'نسبة الزباين من خلاله',
                subtitle: 'من إجمالي حجوزات الصيف',
                value: '${contributionPercent.toStringAsFixed(1)}%',
              ),
              _StatTile(
                icon: Icons.savings_outlined,
                tint: colors.brand,
                title: 'إجمالي العمولات',
                value: '${totalCommissions.toCurrencyFormat()} ج.م',
              ),
              _StatTile(
                icon: Icons.payments,
                tint: colors.accent,
                title: 'إجمالي حجوزاته',
                value: '${totalSales.toCurrencyFormat()} ج.م',
              ),
            ],
          );
        },
        loading: () => const LoadingSkeleton(),
        error: (error, stack) => ErrorState(
          title: 'تعذّر تحميل بيانات السمسار',
          message: 'Error: $error',
          retryLabel: 'إعادة المحاولة',
          onRetry: () => ref.invalidate(brokersProvider),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.tint,
    required this.title,
    required this.value,
    this.subtitle,
  });

  final IconData icon;
  final Color tint;
  final String title;
  final String value;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          IconTile(icon: icon, tint: tint),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(color: colors.ink),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTextStyles.caption.copyWith(color: colors.ink3),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: AppTextStyles.tabular(
              AppTextStyles.h3.copyWith(color: colors.ink),
            ),
          ),
        ],
      ),
    );
  }
}
