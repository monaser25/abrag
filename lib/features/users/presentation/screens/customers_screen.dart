import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/customers_provider.dart';
import '../providers/customers_controller.dart';

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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('كل العملاء')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'البحث بالاسم، رقم التليفون، أو الرقم القومي...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
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
                  return const Center(
                    child: Text('لا يوجد أشخاص يطابقون بحثك'),
                  );
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'إجمالي الأشخاص: ${filtered.length}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final customer = filtered[index];
                          final latestActivity = customer.activities.isEmpty
                              ? null
                              : customer.activities.first;
                          final avatarColor = customer.isMixed
                              ? Colors.purple
                              : customer.hasSummer
                              ? Colors.orange
                              : Colors.blue;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
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
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: avatarColor.withValues(
                                        alpha: 0.18,
                                      ),
                                      child: Icon(
                                        customer.isMixed
                                            ? Icons.groups
                                            : customer.hasSummer
                                            ? Icons.wb_sunny
                                            : Icons.ac_unit,
                                        color: avatarColor,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            customer.name,
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          const SizedBox(height: 6),
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 4,
                                            children: [
                                              if (customer.hasSummer)
                                                const _TypeBadge(
                                                  label: 'مصيف',
                                                  color: Colors.orange,
                                                ),
                                              if (customer.hasWinter)
                                                const _TypeBadge(
                                                  label: 'شتوي',
                                                  color: Colors.blue,
                                                ),
                                              _TypeBadge(
                                                label:
                                                    '${customer.activities.length} نشاط',
                                                color: Colors.green,
                                              ),
                                              _TypeBadge(
                                                label:
                                                    customer.isCurrentlyStaying
                                                    ? 'ساكن حاليًا'
                                                    : 'غير ساكن',
                                                color:
                                                    customer.isCurrentlyStaying
                                                    ? Colors.teal
                                                    : Colors.grey,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          if ((customer.phone ?? '').isNotEmpty)
                                            Text(customer.phone!),
                                          if ((customer.nationalId ?? '')
                                              .isNotEmpty)
                                            Text(
                                              'الرقم القومي: ${customer.nationalId}',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: Colors.grey,
                                                  ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    if ((customer.phone ?? '').isNotEmpty)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.call,
                                          color: Colors.green,
                                        ),
                                        onPressed: () =>
                                            _makePhoneCall(customer.phone!),
                                      ),
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () =>
                                          _showEditCustomerSheet(customer),
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
              error: (error, _) => Center(child: Text('حدث خطأ: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    final theme = Theme.of(context);
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _filter = value),
      selectedColor: theme.colorScheme.primaryContainer,
    );
  }

  Future<void> _showEditCustomerSheet(CustomerModel customer) async {
    final nameController = TextEditingController(text: customer.name);
    final phoneController = TextEditingController(text: customer.phone ?? '');
    final nationalIdController = TextEditingController(
      text: customer.nationalId ?? '',
    );
    final formKey = GlobalKey<FormState>();
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
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'تعديل بيانات العميل',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'الاسم'),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                keyboardType: TextInputType.phone,
                validator: _optionalEgyptianPhoneValidator,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: nationalIdController,
                decoration: const InputDecoration(labelText: 'الرقم القومي'),
                keyboardType: TextInputType.number,
                validator: _optionalNationalIdValidator,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
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
                icon: const Icon(Icons.save),
                label: const Text('حفظ'),
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

class _TypeBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _TypeBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
