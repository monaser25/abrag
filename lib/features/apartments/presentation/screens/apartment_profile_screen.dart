import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/apartment_profile_provider.dart';

class ApartmentProfileScreen extends ConsumerWidget {
  final String apartmentId;

  const ApartmentProfileScreen({super.key, required this.apartmentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(apartmentProfileProvider(apartmentId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ملف الشقة'),
      ),
      body: profileAsync.when(
        data: (data) {
          final isCleaning = data.apartment.cleaningStatus == 'needs_cleaning';
          final isOccupied = data.isOccupied;

          Color statusColor = Colors.green;
          String statusText = 'متاحة';
          if (isCleaning) {
            statusColor = Colors.orange;
            statusText = 'تحتاج نظافة';
          } else if (isOccupied) {
            statusColor = theme.colorScheme.error;
            statusText = 'مؤجرة';
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: CustomScrollView(
              slivers: [
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.colorScheme.primaryContainer, width: 3),
                          color: theme.colorScheme.surface,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          data.apartment.apartmentNumber,
                          style: theme.textTheme.headlineLarge?.copyWith(color: theme.colorScheme.primary),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor),
                            ),
                            const SizedBox(width: 8),
                            Text(statusText, style: theme.textTheme.labelLarge?.copyWith(color: statusColor)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildMiniStat(theme, 'المبنى', data.building?.name ?? 'غير محدد'),
                          Container(width: 1, height: 40, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                          _buildMiniStat(theme, 'الطابق', data.apartment.floorNumber?.toString() ?? '-'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        theme, 
                        'الإيرادات', 
                        '${data.totalRevenue} ج.م', 
                        Icons.account_balance_wallet,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        theme, 
                        'المصروفات', 
                        '${data.totalExpenses} ج.م', 
                        Icons.money_off,
                        isError: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              SliverToBoxAdapter(
                child: _buildStatCard(
                  theme, 
                  'صافي الربح', 
                  '${data.totalRevenue - data.totalExpenses} ج.م', 
                  Icons.assessment,
                  isPrimary: true,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverToBoxAdapter(
                child: Text('سجل الحجوزات', style: theme.textTheme.titleLarge),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              if (data.bookings.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(child: Text('لا يوجد سجل حجوزات', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final booking = data.bookings[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                            child: Icon(Icons.person, color: theme.colorScheme.primary),
                          ),
                          title: Text(booking.guestName),
                          subtitle: Text('${booking.checkInDate.toLocal().toString().split(' ')[0]} - ${booking.checkOutDate.toLocal().toString().split(' ')[0]}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(booking.status, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary)),
                              Text('${booking.totalPriceEgp} ج.م', style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: data.bookings.length,
                  ),
                ),
            ],
          ),
        );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildMiniStat(ThemeData theme, String label, String value) {
    return Column(
      children: [
        Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.titleMedium),
      ],
    );
  }

  Widget _buildStatCard(ThemeData theme, String title, String value, IconData icon, {bool isPrimary = false, bool isError = false}) {
    Color color = theme.colorScheme.onSurfaceVariant;
    if (isPrimary) color = theme.colorScheme.primary;
    if (isError) color = theme.colorScheme.error;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                Icon(icon, size: 20, color: color),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
