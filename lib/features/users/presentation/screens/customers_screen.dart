import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/customers_provider.dart';
import '../providers/customers_controller.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/widgets.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  String _searchQuery = '';
  String _filter = 'all'; // all, summer, winter, mixed, staying

  Future<void> _makePhoneCall(String phoneNumber) async {
    final launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersProvider);
    final colors = context.colors;

    return AppScaffold(
      appBar: const AbragAppBar(title: 'كل العملاء'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: AppTextField(
              hint: 'البحث بالاسم، رقم التليفون، أو الرقم القومي...',
              prefixIcon: Icons.search,
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase().trim());
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('الكل', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('مصيفين', 'summer'),
                const SizedBox(width: 8),
                _buildFilterChip('طلبة/شتوي', 'winter'),
                const SizedBox(width: 8),
                _buildFilterChip('صيف وشتاء', 'mixed'),
                const SizedBox(width: 8),
                _buildFilterChip('ساكن حاليًا', 'staying'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: customersAsync.when(
              data: (customers) {
                var filtered = customers;
                if (_filter == 'summer') {
                  filtered = filtered.where((c) => c.hasSummer).toList();
                } else if (_filter == 'winter') {
                  filtered = filtered.where((c) => c.hasWinter).toList();
                } else if (_filter == 'mixed') {
                  filtered = filtered.where((c) => c.isMixed).toList();
                } else if (_filter == 'staying') {
                  filtered = filtered
                      .where((c) => c.isCurrentlyStaying)
                      .toList();
                }

                if (_searchQuery.isNotEmpty) {
                  filtered = filtered.where((customer) {
                    final nameMatch = customer.name.toLowerCase().contains(
                      _searchQuery,
                    );
                    final phoneMatch = (customer.phone ?? '')
                        .toLowerCase()
                        .contains(_searchQuery);
                    final idMatch = (customer.nationalId ?? '')
                        .toLowerCase()
                        .contains(_searchQuery);
                    return nameMatch || phoneMatch || idMatch;
                  }).toList();
                }

                if (filtered.isEmpty) {
                  return const EmptyState(
                    icon: Icons.people_outline,
                    title: 'لا يوجد أشخاص يطابقون بحثك',
                  );
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      child: Row(
                        children: [
                          Text(
                            'إجمالي الأشخاص: ${filtered.length}',
                            style: AppTextStyles.title
                                .copyWith(color: colors.brand),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final customer = filtered[index];
                          final latestActivity = customer.activities.isEmpty
                              ? null
                              : customer.activities.first;
                          final avatarTint = customer.isMixed
                              ? colors.brand
                              : customer.hasSummer
                                  ? colors.summer
                                  : colors.winter;

                          return AppCard(
                            onTap: () {
                              if (customer.hasSummer) {
                                context.push(
                                  '/summer_bookings/guest/${Uri.encodeComponent(customer.name)}',
                                );
                                return;
                              }
                              if (latestActivity != null) {
                                context.push(latestActivity.route);
                              }
                            },
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                AppAvatar(name: customer.name, tint: avatarTint),
                                const SizedBox(width: 13),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        customer.name,
                                        style: AppTextStyles.title
                                            .copyWith(color: colors.ink),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: [
                                          if (customer.hasSummer)
                                            const StatusChip(
                                              label: 'مصيف',
                                              kind: StatusChipKind.summer,
                                            ),
                                          if (customer.hasWinter)
                                            const StatusChip(
                                              label: 'شتوي',
                                              kind: StatusChipKind.winter,
                                            ),
                                          StatusChip(
                                            label:
                                                '${customer.activities.length} نشاط',
                                            kind: StatusChipKind.ok,
                                          ),
                                          StatusChip(
                                            label: customer.isCurrentlyStaying
                                                ? 'ساكن حاليًا'
                                                : 'غير ساكن',
                                            kind: customer.isCurrentlyStaying
                                                ? StatusChipKind.brand
                                                : StatusChipKind.neutral,
                                          ),
                                        ],
                                      ),
                                      if ((customer.phone ?? '').isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          customer.phone!,
                                          textDirection: TextDirection.ltr,
                                          style: AppTextStyles.caption
                                              .copyWith(color: colors.ink2),
                                        ),
                                      ],
                                      if ((customer.nationalId ?? '')
                                          .isNotEmpty)
                                        Text(
                                          'الرقم القومي: ${customer.nationalId}',
                                          style: AppTextStyles.caption
                                              .copyWith(color: colors.ink3),
                                        ),
                                    ],
                                  ),
                                ),
                                if ((customer.phone ?? '').isNotEmpty)
                                  AppIconButton(
                                    icon: Icons.call,
                                    onPressed: () =>
                                        _makePhoneCall(customer.phone!),
                                  ),
                                AppIconButton(
                                  icon: Icons.edit_outlined,
                                  onPressed: () =>
                                      _showEditCustomerSheet(customer),
                                ),
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
              error: (error, _) => ErrorState(
                title: 'تعذّر تحميل العملاء',
                message: 'حدث خطأ: $error',
                retryLabel: 'إعادة المحاولة',
                onRetry: () => ref.invalidate(customersProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final colors = context.colors;
    final isSelected = _filter == value;
    return Tappable(
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? colors.brandSoft : colors.surface,
          borderRadius: AppRadius.rPill,
          border: Border.all(
            color: isSelected ? colors.brand : colors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: isSelected ? colors.brand : colors.ink2,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _showEditCustomerSheet(CustomerModel customer) async {
    final colors = context.colors;
    final nameController = TextEditingController(text: customer.name);
    final phoneController = TextEditingController(text: customer.phone ?? '');
    final nationalIdController = TextEditingController(
      text: customer.nationalId ?? '',
    );
    final formKey = GlobalKey<FormState>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: colors.border2,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'تعديل بيانات العميل',
                style: AppTextStyles.h3.copyWith(color: colors.ink),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: nameController,
                label: 'الاسم',
                prefixIcon: Icons.person_outline,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: phoneController,
                label: 'رقم الهاتف',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: _optionalEgyptianPhoneValidator,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: nationalIdController,
                label: 'الرقم القومي',
                prefixIcon: Icons.badge_outlined,
                keyboardType: TextInputType.number,
                validator: _optionalNationalIdValidator,
              ),
              const SizedBox(height: 20),
              AppButton(
                label: 'حفظ',
                icon: Icons.save_outlined,
                expand: true,
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  ref
                      .read(customersControllerProvider.notifier)
                      .updateCustomer(
                        customer,
                        name: nameController.text,
                        phone: phoneController.text,
                        nationalId: nationalIdController.text,
                      );
                  Navigator.pop(sheetContext);
                },
              ),
            ],
          ),
        ),
      ),
    );
    nameController.dispose();
    phoneController.dispose();
    nationalIdController.dispose();
  }

  String? _optionalEgyptianPhoneValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    if (!RegExp(r'^\d{11}$').hasMatch(text)) {
      return 'رقم الهاتف لازم يكون 11 رقم';
    }
    return null;
  }

  String? _optionalNationalIdValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    if (!RegExp(r'^\d{14}$').hasMatch(text)) {
      return 'الرقم القومي لازم يكون 14 رقم';
    }
    return null;
  }
}
