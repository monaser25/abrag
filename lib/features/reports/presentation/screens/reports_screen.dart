import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/reports_provider.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(financialReportProvider);
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
          return Padding(
            padding: const EdgeInsets.all(16),
            child: CustomScrollView(
              slivers: [
              SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        context,
                        title: 'إجمالي الإيرادات',
                        value: '${report.totalRevenue}',
                        icon: Icons.trending_up,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSummaryCard(
                        context,
                        title: 'إجمالي المصروفات',
                        value: '${report.totalExpenses}',
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
                  value: '${report.netProfit}',
                  icon: Icons.account_balance_wallet,
                  color: theme.colorScheme.primary,
                  isLarge: true,
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
                    final t = report.transactions[index];
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
                  childCount: report.transactions.length > 5 ? 5 : report.transactions.length,
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
        padding: EdgeInsets.all(isLarge ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                Icon(icon, color: color),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '$value ج.م',
              style: isLarge 
                  ? theme.textTheme.headlineMedium?.copyWith(color: color, fontWeight: FontWeight.bold)
                  : theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
