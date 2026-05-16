import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/customers_provider.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  String _searchQuery = '';
  String _filter = 'all'; // all, summer, winter

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة العملاء'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'البحث بالاسم، رقم التليفون، أو الرقم القومي...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildFilterChip('الكل', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('مصيفين (صيفي)', 'summer'),
                const SizedBox(width: 8),
                _buildFilterChip('طلبة وعائلات (شتوي)', 'winter'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: customersAsync.when(
              data: (customers) {
                // Apply filters
                var filtered = customers;
                if (_filter != 'all') {
                  filtered = filtered.where((c) => c.type == _filter).toList();
                }

                if (_searchQuery.isNotEmpty) {
                  filtered = filtered.where((c) {
                    final nameMatch = c.name.toLowerCase().contains(_searchQuery);
                    final phoneMatch = c.phone != null && c.phone!.contains(_searchQuery);
                    final idMatch = c.nationalId != null && c.nationalId!.contains(_searchQuery);
                    return nameMatch || phoneMatch || idMatch;
                  }).toList();
                }

                if (filtered.isEmpty) {
                  return const Center(child: Text('لا يوجد عملاء يطابقون بحثك'));
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: [
                          Text(
                            'إجمالي العملاء: ${filtered.length}',
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
                          final isSummer = customer.type == 'summer';
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: () {
                                if (isSummer) {
                                  context.push('/summer_bookings/guest/${customer.name}');
                                } else {
                                  // For winter, maybe open details? Or we can just use the guest profile as a general search for their bookings.
                                  // Currently guest profile only searches summer bookings.
                                  // For now, let's just make it call them or open their latest contract.
                                  context.push('/winter_contracts/details/${customer.id}');
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: isSummer 
                                          ? Colors.orange.withValues(alpha: 0.2) 
                                          : Colors.blue.withValues(alpha: 0.2),
                                      child: Icon(
                                        isSummer ? Icons.wb_sunny : Icons.ac_unit,
                                        color: isSummer ? Colors.orange : Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            customer.name,
                                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          if (customer.phone != null && customer.phone!.isNotEmpty)
                                            Text(
                                              customer.phone!,
                                              style: theme.textTheme.bodyMedium,
                                            ),
                                          if (customer.nationalId != null && customer.nationalId!.isNotEmpty)
                                            Text(
                                              'الرقم القومي: ${customer.nationalId}',
                                              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                                            ),
                                        ],
                                      ),
                                    ),
                                    if (customer.phone != null && customer.phone!.isNotEmpty)
                                      IconButton(
                                        icon: const Icon(Icons.call, color: Colors.green),
                                        onPressed: () => _makePhoneCall(customer.phone!),
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
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        setState(() {
          _filter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
