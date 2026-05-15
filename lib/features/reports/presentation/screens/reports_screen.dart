import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/reports_provider.dart';
import '../../../buildings/presentation/providers/buildings_controller.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  String _filter = 'all'; // all, summer, winter
  String? _selectedBuildingId;
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(financialReportProvider);
    final buildingsAsync = ref.watch(buildingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              context.go('/reports/statement');
            },
          ),
        ],
      ),
      body: reportAsync.when(
        data: (report) {
          // Client-side filtering for simplicity
          List<Transaction> filteredTransactions = report.transactions;
          double filteredRevenue = 0;
          double filteredExpenses = 0;

          if (_selectedBuildingId != null) {
            filteredTransactions = filteredTransactions.where((t) => t.buildingId == _selectedBuildingId).toList();
          }

          if (_filter == 'summer') {
            filteredTransactions = filteredTransactions.where((t) => t.description.contains('صيفي')).toList();
          } else if (_filter == 'winter') {
            filteredTransactions = filteredTransactions.where((t) => t.description.contains('شتوية')).toList();
          }

          if (_startDate != null && _endDate != null) {
            filteredTransactions = filteredTransactions.where((t) {
              return t.date.isAfter(_startDate!.subtract(const Duration(days: 1))) && 
                     t.date.isBefore(_endDate!.add(const Duration(days: 1)));
            }).toList();
          }

          filteredRevenue = filteredTransactions.where((t) => t.isRevenue).fold(0.0, (sum, t) => sum + t.amount);
          filteredExpenses = filteredTransactions.where((t) => !t.isRevenue).fold(0.0, (sum, t) => sum + t.amount);
          
          double cashRev = filteredTransactions.where((t) => t.isRevenue && t.paymentMethod == 'cash').fold(0.0, (sum, t) => sum + t.amount);
          double vfRev = filteredTransactions.where((t) => t.isRevenue && t.paymentMethod == 'vodafone_cash').fold(0.0, (sum, t) => sum + t.amount);
          double instaRev = filteredTransactions.where((t) => t.isRevenue && t.paymentMethod == 'instapay').fold(0.0, (sum, t) => sum + t.amount);

          final filteredProfit = filteredRevenue - filteredExpenses;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: buildingsAsync.when(
                      data: (buildings) {
                        return DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'اختر المبنى'),
                          initialValue: _selectedBuildingId,
                          items: [
                            const DropdownMenuItem(value: null, child: Text('جميع المباني')),
                            ...buildings.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name)))
                          ],
                          onChanged: (v) => setState(() => _selectedBuildingId = v),
                        );
                      },
                      loading: () => const LinearProgressIndicator(),
                      error: (e, st) => const SizedBox.shrink(),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(value: 'all', label: Text('الكل')),
                            ButtonSegment(value: 'summer', label: Text('صيف')),
                            ButtonSegment(value: 'winter', label: Text('شتاء')),
                          ],
                          selected: {_filter},
                          onSelectionChanged: (Set<String> newSelection) {
                            setState(() {
                              _filter = newSelection.first;
                            });
                          },
                        ),
                        OutlinedButton.icon(
                          onPressed: _selectDateRange,
                          icon: const Icon(Icons.date_range),
                          label: Text(_startDate != null 
                              ? '${_startDate!.month}/${_startDate!.year} - ${_endDate!.month}/${_endDate!.year}'
                              : 'الفترة'),
                        )
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          context,
                          title: 'إجمالي الإيرادات',
                          value: '$filteredRevenue',
                          icon: Icons.trending_up,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSummaryCard(
                          context,
                          title: 'إجمالي المصروفات',
                          value: '$filteredExpenses',
                          icon: Icons.trending_down,
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
                SliverToBoxAdapter(
                  child: _buildSummaryCard(
                    context,
                    title: 'صافي الربح',
                    value: '$filteredProfit',
                    icon: Icons.account_balance_wallet,
                    color: theme.colorScheme.primary,
                    isLarge: true,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('تفصيل الإيرادات', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildMiniStat(theme, 'نقدي', '$cashRev'),
                              Container(width: 1, height: 40, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                              _buildMiniStat(theme, 'فودافون كاش', '$vfRev'),
                              Container(width: 1, height: 40, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                              _buildMiniStat(theme, 'إنستاباي', '$instaRev'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text('أحدث العمليات', style: theme.textTheme.titleLarge),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final t = filteredTransactions[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: t.isRevenue 
                                ? Colors.green.withValues(alpha: 0.1) 
                                : theme.colorScheme.error.withValues(alpha: 0.1),
                            child: Icon(
                              t.isRevenue ? Icons.arrow_downward : Icons.arrow_upward,
                              color: t.isRevenue ? Colors.green : theme.colorScheme.error,
                            ),
                          ),
                          title: Text(t.description),
                          subtitle: Text(t.date.toLocal().toString().split(' ')[0]),
                          trailing: Text(
                            '${t.isRevenue ? "+" : "-"} ${t.amount} ج.م',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: t.isRevenue ? Colors.green : theme.colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: filteredTransactions.length > 5 ? 5 : filteredTransactions.length,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: OutlinedButton(
                      onPressed: () {
                        context.go('/reports/statement');
                      },
                      child: const Text('عرض كشف الحساب الكامل'),
                    ),
                  ),
                )
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildMiniStat(ThemeData theme, String label, String value) {
    return Column(
      children: [
        Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool isLarge = false,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: isLarge ? 4 : 1,
      child: Padding(
        padding: EdgeInsets.all(isLarge ? 16 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(title, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant), overflow: TextOverflow.ellipsis)),
                Icon(icon, color: color, size: isLarge ? 24 : 16),
              ],
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                '$value ج.م',
                style: isLarge 
                    ? theme.textTheme.headlineMedium?.copyWith(color: color, fontWeight: FontWeight.bold)
                    : theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
