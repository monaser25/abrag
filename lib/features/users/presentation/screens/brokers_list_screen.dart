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
import '../../../../shared/widgets/widgets.dart';

/// Search query for the brokers list (name / phone).
final _brokerSearchProvider = StateProvider.autoDispose<String>((ref) => '');

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
    final colors = context.colors;
    final query = ref.watch(_brokerSearchProvider).trim().toLowerCase();
    final bookingsAsync = ref.watch(allSummerBookingsProvider);
    // Bookings handled per broker (most-dealt-with first).
    final dealCounts = <String, int>{};
    for (final b in bookingsAsync.asData?.value ?? const []) {
      if (b.brokerId != null) {
        dealCounts[b.brokerId!] = (dealCounts[b.brokerId!] ?? 0) + 1;
      }
    }

    return AppScaffold(
      appBar: AbragAppBar(
        title: 'إدارة السماسرة',
        showBack: true,
        onBack: () => context.go('/'),
        actions: [
          AppIconButton(
            icon: Icons.person_add,
            tooltip: 'إضافة سمسار',
            onPressed: () => _showAddBrokerDialog(context, ref),
          ),
          AppIconButton(
            icon: Icons.visibility,
            tooltip: 'التحكم في رؤية الوسطاء',
            onPressed: () => context.go('/brokers/visibility'),
          ),
        ],
      ),
      floatingActionButton: AppFab(
        onPressed: controllerState.isLoading
            ? () {}
            : () => _showAddBrokerDialog(context, ref),
        icon: Icons.person_add,
        label: 'إضافة سمسار',
      ),
      body: brokersAsync.when(
        data: (brokers) {
          if (brokers.isEmpty) {
            return const EmptyState(
              icon: Icons.handshake_outlined,
              title: 'لا يوجد سماسرة مسجلين',
            );
          }

          final filtered = brokers.where((broker) {
            if (query.isEmpty) return true;
            final name = (broker.fullName ?? broker.email).toLowerCase();
            final phone = (broker.phoneNumber ?? '').toLowerCase();
            final phone2 = (broker.secondaryPhone ?? '').toLowerCase();
            return name.contains(query) ||
                phone.contains(query) ||
                phone2.contains(query);
          }).toList()
            // Most-dealt-with first, then by name.
            ..sort((a, b) {
              final ca = dealCounts[a.id] ?? 0;
              final cb = dealCounts[b.id] ?? 0;
              if (cb != ca) return cb.compareTo(ca);
              return (a.fullName ?? a.email).compareTo(b.fullName ?? b.email);
            });

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: AppTextField(
                  hint: 'ابحث باسم السمسار أو رقم التليفون...',
                  prefixIcon: Icons.search,
                  onChanged: (value) =>
                      ref.read(_brokerSearchProvider.notifier).state = value,
                ),
              ),
              if (filtered.isEmpty)
                const Expanded(
                  child: EmptyState(
                    icon: Icons.search_off,
                    title: 'لا يوجد سمسار يطابق البحث',
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final broker = filtered[index];
                      final hasPhone = broker.phoneNumber != null &&
                          broker.phoneNumber!.isNotEmpty;
                      final showEmail =
                          !hasPhone && !broker.email.startsWith('broker-');
                      final name = broker.fullName ?? broker.email;
                      final deals = dealCounts[broker.id] ?? 0;
                      return AppCard(
                        onTap: () =>
                            context.push('/brokers/details/${broker.id}'),
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            AppAvatar(name: name),
                            const SizedBox(width: 13),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: AppTextStyles.title
                                        .copyWith(color: colors.ink),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (hasPhone)
                                    Text(
                                      broker.phoneNumber!,
                                      textDirection: TextDirection.ltr,
                                      style: AppTextStyles.caption
                                          .copyWith(color: colors.ink2),
                                    ),
                                  if (showEmail)
                                    Text(
                                      broker.email,
                                      style: AppTextStyles.caption
                                          .copyWith(color: colors.ink3),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  const SizedBox(height: 6),
                                  StatusChip(
                                    label: '$deals حجز',
                                    kind: deals > 0
                                        ? StatusChipKind.ok
                                        : StatusChipKind.neutral,
                                  ),
                                ],
                              ),
                            ),
                            if (hasPhone)
                              AppIconButton(
                                icon: Icons.call,
                                onPressed: () =>
                                    _makePhoneCall(broker.phoneNumber!),
                              ),
                            AppIconButton(
                              icon: Icons.edit_outlined,
                              onPressed: () =>
                                  _showAddBrokerDialog(context, ref, broker),
                            ),
                            AppIconButton(
                              icon: Icons.delete_outline,
                              onPressed: () =>
                                  _confirmDeleteBroker(context, ref, broker),
                            ),
                            Icon(Icons.arrow_forward_ios,
                                size: 14, color: colors.ink3),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
        loading: () => const LoadingSkeleton(),
        error: (error, stack) => ErrorState(
          title: 'تعذّر تحميل السماسرة',
          message: 'Error: $error',
          retryLabel: 'إعادة المحاولة',
          onRetry: () => ref.invalidate(brokersProvider),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteBroker(
    BuildContext context,
    WidgetRef ref,
    UserProfile broker,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final name = broker.fullName ?? broker.email;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final colors = dialogContext.colors;
        return AlertDialog(
          backgroundColor: colors.surface,
          title: const Text('حذف سمسار'),
          content: Text(
            'هل تريد حذف "$name"؟ الحجوزات القديمة هتفضل محتفظة باسم السمسار.',
            style: AppTextStyles.bodyS.copyWith(color: colors.ink2),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('إلغاء'),
            ),
            AppButton(
              label: 'حذف',
              variant: AppButtonVariant.royal,
              small: true,
              onPressed: () => Navigator.pop(dialogContext, true),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    try {
      await ref.read(brokersControllerProvider.notifier).deleteBroker(broker.id);
      messenger.showSnackBar(
        SnackBar(content: Text('تم حذف $name')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('تعذّر الحذف: $e')));
    }
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
    final secondaryController = TextEditingController(
      text: broker?.secondaryPhone ?? '',
    );
    var showSecondary = (broker?.secondaryPhone ?? '').trim().isNotEmpty;
    final formKey = GlobalKey<FormState>();

    String? phoneValidator(String? value) {
      final phone = value?.trim() ?? '';
      if (phone.isEmpty) return null;
      return RegExp(r'^01\d{9}$').hasMatch(phone)
          ? null
          : 'رقم التليفون يجب أن يكون 11 رقم ويبدأ بـ 01';
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        final colors = dialogContext.colors;
        return AlertDialog(
          backgroundColor: colors.surface,
          title: Text(broker == null ? 'إضافة سمسار' : 'تعديل بيانات السمسار'),
          content: Form(
            key: formKey,
            child: StatefulBuilder(
              builder: (context, setLocalState) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    validator: phoneValidator,
                  ),
                  if (showSecondary) ...[
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: secondaryController,
                      label: 'رقم تليفون آخر (اختياري)',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      textDirection: TextDirection.ltr,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                      ],
                      validator: phoneValidator,
                    ),
                  ] else
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton.icon(
                        onPressed: () =>
                            setLocalState(() => showSecondary = true),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('إضافة رقم آخر'),
                      ),
                    ),
                ],
              ),
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

                final secondary = showSecondary
                    ? secondaryController.text
                    : null;
                if (broker == null) {
                  ref
                      .read(brokersControllerProvider.notifier)
                      .addBroker(
                        fullName: nameController.text,
                        phoneNumber: phoneController.text,
                        secondaryPhone: secondary,
                      );
                } else {
                  ref
                      .read(brokersControllerProvider.notifier)
                      .updateBroker(
                        id: broker.id,
                        fullName: nameController.text,
                        phoneNumber: phoneController.text,
                        secondaryPhone: secondary,
                      );
                }
                Navigator.pop(dialogContext);
              },
            ),
          ],
        );
      },
    );
  }
}
