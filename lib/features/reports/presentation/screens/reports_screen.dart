import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/reports_provider.dart';
import '../../../buildings/presentation/providers/buildings_controller.dart';
import '../../../apartments/presentation/providers/apartments_controller.dart';
import '../../../../core/utils/currency_formatter.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  final _personController = TextEditingController();
  String _filter = 'all'; // all, summer, winter
  String? _selectedBuildingId;
  String? _selectedApartmentId;
  String _expenseType = 'all';
  String _partyType = 'all';
  String _selectedPartyKey = 'all';
  String _personQuery = '';
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

  void _clearFilters() {
    _personController.clear();
    setState(() {
      _filter = 'all';
      _selectedBuildingId = null;
      _selectedApartmentId = null;
      _expenseType = 'all';
      _partyType = 'all';
      _selectedPartyKey = 'all';
      _personQuery = '';
      _startDate = null;
      _endDate = null;
    });
  }

  @override
  void dispose() {
    _personController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(financialReportProvider);
    final buildingsAsync = ref.watch(buildingsProvider);
    final apartmentsAsync = ref.watch(apartmentsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_off),
            tooltip: 'مسح الفلاتر',
            onPressed: _clearFilters,
          ),
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
          final filteredTransactions = _partyType == 'technician'
              ? _filteredWorkRecords(
                  report,
                ).map(_workRecordTransaction).toList()
              : _filteredTransactions(report);
          final filteredRentals = _filteredRentals(report);
          final filteredWorkRecords = _filteredWorkRecords(report);
          double filteredRevenue = 0;
          double filteredExpenses = 0;

          filteredRevenue = filteredTransactions
              .where((t) => t.isRevenue)
              .fold(0.0, (sum, t) => sum + t.amount);
          filteredExpenses = filteredTransactions
              .where((t) => !t.isRevenue)
              .fold(0.0, (sum, t) => sum + t.amount);

          double cashRev = filteredTransactions
              .where((t) => t.isRevenue && t.paymentMethod == 'cash')
              .fold(0.0, (sum, t) => sum + t.amount);
          double vfRev = filteredTransactions
              .where((t) => t.isRevenue && t.paymentMethod == 'vodafone_cash')
              .fold(0.0, (sum, t) => sum + t.amount);
          double instaRev = filteredTransactions
              .where((t) => t.isRevenue && t.paymentMethod == 'instapay')
              .fold(0.0, (sum, t) => sum + t.amount);

          final apartmentMetrics = _apartmentMetrics(filteredRentals);
          final summerApartmentMetrics = _apartmentMetrics(
            filteredRentals.where((r) => r.season == 'summer').toList(),
          );
          final floorMetrics = _floorMetrics(filteredRentals);
          final brokerMetrics = _brokerMetrics(filteredRentals);
          final workerMetrics = _workerMetrics(filteredWorkRecords);
          final expenseMetrics = _expenseMetrics(filteredTransactions);

          final topSummerApartment = _topByCount(summerApartmentMetrics);
          final topRentalValueApartment = _topByRentalValue(apartmentMetrics);
          final lowRentalValueApartment = _lowByRentalValue(apartmentMetrics);
          final topFloor = _topByRentalValue(floorMetrics);
          final lowFloor = _lowByRentalValue(floorMetrics);
          final partyOptions = _partyOptions(report);
          final selectedPartyKey = partyOptions.containsKey(_selectedPartyKey)
              ? _selectedPartyKey
              : 'all';

          final filteredProfit = filteredRevenue - filteredExpenses;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final fieldWidth = constraints.maxWidth < 720
                                ? constraints.maxWidth
                                : (constraints.maxWidth - 24) / 3;

                            return Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                SizedBox(
                                  width: fieldWidth,
                                  child: buildingsAsync.when(
                                    data: (buildings) =>
                                        DropdownButtonFormField<String>(
                                          decoration: const InputDecoration(
                                            labelText: 'اختر المبنى',
                                          ),
                                          initialValue: _selectedBuildingId,
                                          items: [
                                            const DropdownMenuItem(
                                              value: null,
                                              child: Text('جميع المباني'),
                                            ),
                                            ...buildings.map(
                                              (b) => DropdownMenuItem(
                                                value: b.id,
                                                child: Text(b.name),
                                              ),
                                            ),
                                          ],
                                          onChanged: (v) => setState(() {
                                            _selectedBuildingId = v;
                                            _selectedApartmentId = null;
                                          }),
                                        ),
                                    loading: () =>
                                        const LinearProgressIndicator(),
                                    error: (e, st) => const SizedBox.shrink(),
                                  ),
                                ),
                                SizedBox(
                                  width: fieldWidth,
                                  child: apartmentsAsync.when(
                                    data: (apartments) {
                                      var apts = apartments;
                                      if (_selectedBuildingId != null) {
                                        apts = apts
                                            .where(
                                              (a) =>
                                                  a.buildingId ==
                                                  _selectedBuildingId,
                                            )
                                            .toList();
                                      }
                                      return DropdownButtonFormField<String>(
                                        decoration: const InputDecoration(
                                          labelText: 'اختر الشقة',
                                        ),
                                        initialValue: _selectedApartmentId,
                                        items: [
                                          const DropdownMenuItem(
                                            value: null,
                                            child: Text('جميع الشقق'),
                                          ),
                                          ...apts.map(
                                            (a) => DropdownMenuItem(
                                              value: a.id,
                                              child: Text(
                                                'شقة ${a.apartmentNumber}',
                                              ),
                                            ),
                                          ),
                                        ],
                                        onChanged: (v) => setState(
                                          () => _selectedApartmentId = v,
                                        ),
                                      );
                                    },
                                    loading: () =>
                                        const LinearProgressIndicator(),
                                    error: (e, st) => const SizedBox.shrink(),
                                  ),
                                ),
                                SizedBox(
                                  width: fieldWidth,
                                  child: DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                      labelText: 'الموسم',
                                    ),
                                    initialValue: _filter,
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'all',
                                        child: Text('كل المواسم'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'summer',
                                        child: Text('صيف'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'winter',
                                        child: Text('شتاء'),
                                      ),
                                    ],
                                    onChanged: (v) =>
                                        setState(() => _filter = v ?? 'all'),
                                  ),
                                ),
                                SizedBox(
                                  width: fieldWidth,
                                  child: DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                      labelText: 'نوع المصروف',
                                    ),
                                    initialValue: _expenseType,
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'all',
                                        child: Text('كل المصروفات'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'maintenance',
                                        child: Text('صيانة / إصلاحات'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'building_rent',
                                        child: Text('إيجار المبنى'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'water',
                                        child: Text('مياه'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'electricity',
                                        child: Text('كهرباء'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'gas',
                                        child: Text('غاز'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'cleaning',
                                        child: Text('نظافة'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'other',
                                        child: Text('أخرى'),
                                      ),
                                    ],
                                    onChanged: (v) => setState(
                                      () => _expenseType = v ?? 'all',
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: fieldWidth,
                                  child: DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                      labelText: 'نوع الحساب',
                                    ),
                                    initialValue: _partyType,
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'all',
                                        child: Text('كل الحسابات'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'customer',
                                        child: Text('عميل'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'broker',
                                        child: Text('سمسار'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'technician',
                                        child: Text('عامل'),
                                      ),
                                    ],
                                    onChanged: (v) => setState(() {
                                      _partyType = v ?? 'all';
                                      _selectedPartyKey = 'all';
                                    }),
                                  ),
                                ),
                                SizedBox(
                                  width: fieldWidth,
                                  child: DropdownButtonFormField<String>(
                                    key: ValueKey('party-account-$_partyType'),
                                    decoration: const InputDecoration(
                                      labelText: 'اختر الحساب',
                                    ),
                                    initialValue: selectedPartyKey,
                                    items: partyOptions.entries
                                        .map(
                                          (entry) => DropdownMenuItem(
                                            value: entry.key,
                                            child: Text(entry.value),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: _partyType == 'all'
                                        ? null
                                        : (v) => setState(
                                            () =>
                                                _selectedPartyKey = v ?? 'all',
                                          ),
                                  ),
                                ),
                                SizedBox(
                                  width: fieldWidth,
                                  child: TextField(
                                    controller: _personController,
                                    decoration: const InputDecoration(
                                      labelText:
                                          'بحث في العملاء/السماسرة/العمال',
                                      prefixIcon: Icon(Icons.search),
                                    ),
                                    onChanged: (v) =>
                                        setState(() => _personQuery = v.trim()),
                                  ),
                                ),
                                SizedBox(
                                  width: fieldWidth,
                                  child: OutlinedButton.icon(
                                    onPressed: _selectDateRange,
                                    icon: const Icon(Icons.date_range),
                                    label: Text(
                                      _startDate != null
                                          ? '${_startDate!.month}/${_startDate!.year} - ${_endDate!.month}/${_endDate!.year}'
                                          : 'الفترة',
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
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
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          context,
                          title: 'أكثر شقة سكنت صيفاً',
                          value: topSummerApartment == null
                              ? '0'
                              : '${topSummerApartment.count} حجز - ${topSummerApartment.label}',
                          icon: Icons.beach_access,
                          color: Colors.orange,
                          showCurrency: false,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSummaryCard(
                          context,
                          title: 'أعلى شقة إيراداً',
                          value: topRentalValueApartment == null
                              ? '0'
                              : '${topRentalValueApartment.rentalValue.toCurrencyFormat()} - ${topRentalValueApartment.label}',
                          icon: Icons.apartment,
                          color: Colors.blue,
                          showCurrency: false,
                        ),
                      ),
                    ],
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          context,
                          title: 'أقل شقة إيراداً',
                          value: lowRentalValueApartment == null
                              ? '0'
                              : '${lowRentalValueApartment.rentalValue.toCurrencyFormat()} - ${lowRentalValueApartment.label}',
                          icon: Icons.trending_down,
                          color: theme.colorScheme.error,
                          showCurrency: false,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSummaryCard(
                          context,
                          title: 'أعلى دور إيراداً',
                          value: topFloor == null
                              ? '0'
                              : '${topFloor.rentalValue.toCurrencyFormat()} - ${topFloor.label}',
                          icon: Icons.layers,
                          color: Colors.teal,
                          showCurrency: false,
                        ),
                      ),
                    ],
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: _buildSummaryCard(
                    context,
                    title: 'أقل دور إيراداً',
                    value: lowFloor == null
                        ? '0'
                        : '${lowFloor.rentalValue.toCurrencyFormat()} - ${lowFloor.label}',
                    icon: Icons.layers_clear,
                    color: Colors.brown,
                    showCurrency: false,
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
                          Text(
                            'تفصيل الإيرادات',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildMiniStat(theme, 'نقدي', '$cashRev'),
                              Container(
                                width: 1,
                                height: 40,
                                color: theme.colorScheme.outlineVariant
                                    .withValues(alpha: 0.3),
                              ),
                              _buildMiniStat(theme, 'فودافون كاش', '$vfRev'),
                              Container(
                                width: 1,
                                height: 40,
                                color: theme.colorScheme.outlineVariant
                                    .withValues(alpha: 0.3),
                              ),
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
                  child: _buildMetricsSection(
                    title: 'تفاصيل الشقق',
                    emptyText: 'لا توجد حجوزات مطابقة للفلاتر',
                    metrics: apartmentMetrics,
                    icon: Icons.apartment,
                    trailingMode: _MetricTrailingMode.rental,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildMetricsSection(
                    title: 'تفاصيل الأدوار',
                    emptyText: 'لا توجد أدوار مطابقة للفلاتر',
                    metrics: floorMetrics,
                    icon: Icons.layers,
                    trailingMode: _MetricTrailingMode.rental,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildMetricsSection(
                    title: 'حسابات السماسرة',
                    emptyText: 'لا توجد حجوزات بسماسرة مطابقة للفلاتر',
                    metrics: brokerMetrics,
                    icon: Icons.handshake,
                    trailingMode: _MetricTrailingMode.commission,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildMetricsSection(
                    title: 'حسابات العمال',
                    emptyText: 'لا توجد أعمال صيانة مطابقة للفلاتر',
                    metrics: workerMetrics,
                    icon: Icons.engineering,
                    trailingMode: _MetricTrailingMode.cost,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildMetricsSection(
                    title: 'المصروفات حسب النوع',
                    emptyText: 'لا توجد مصروفات مطابقة للفلاتر',
                    metrics: expenseMetrics,
                    icon: Icons.receipt_long,
                    trailingMode: _MetricTrailingMode.cost,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'أحدث العمليات',
                      style: theme.textTheme.titleLarge,
                    ),
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
                                : theme.colorScheme.error.withValues(
                                    alpha: 0.1,
                                  ),
                            child: Icon(
                              t.isRevenue
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: t.isRevenue
                                  ? Colors.green
                                  : theme.colorScheme.error,
                            ),
                          ),
                          title: Text(t.description),
                          subtitle: Text(
                            t.date.toLocal().toString().split(' ')[0],
                          ),
                          trailing: Text(
                            '${t.isRevenue ? "+" : "-"} ${t.amount} ج.م',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: t.isRevenue
                                  ? Colors.green
                                  : theme.colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: filteredTransactions.length > 5
                        ? 5
                        : filteredTransactions.length,
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
                ),
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
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool isLarge = false,
    bool showCurrency = true,
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
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(icon, color: color, size: isLarge ? 24 : 16),
              ],
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                showCurrency ? '$value ج.م' : value,
                style: isLarge
                    ? theme.textTheme.headlineMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      )
                    : theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, String> _partyOptions(FinancialSummary report) {
    final options = <String, String>{'all': 'كل الحسابات'};
    if (_partyType == 'all') return options;

    if (_partyType == 'customer') {
      for (final transaction in report.transactions) {
        final name = transaction.customerName;
        if (name != null && name.isNotEmpty) {
          options['customer:$name'] = name;
        }
      }
    } else if (_partyType == 'broker') {
      for (final transaction in report.transactions) {
        final name = transaction.brokerName;
        if (name != null && name.isNotEmpty) {
          options['broker:${transaction.brokerId ?? name}'] = name;
        }
      }
    } else if (_partyType == 'technician') {
      for (final work in report.workRecords) {
        options['technician:${work.technicianId}'] = work.technicianName;
      }
    }

    return options;
  }

  List<Transaction> _filteredTransactions(FinancialSummary report) {
    var transactions = report.transactions;

    if (_selectedBuildingId != null) {
      transactions = transactions
          .where((t) => t.buildingId == _selectedBuildingId)
          .toList();
    }
    if (_selectedApartmentId != null) {
      transactions = transactions
          .where((t) => t.apartmentId == _selectedApartmentId)
          .toList();
    }
    if (_filter != 'all') {
      transactions = transactions.where((t) => t.season == _filter).toList();
    }
    if (_expenseType != 'all') {
      transactions = transactions
          .where((t) => t.expenseType == _expenseType)
          .toList();
    }
    if (_partyType != 'all' ||
        _selectedPartyKey != 'all' ||
        _personQuery.isNotEmpty) {
      transactions = transactions.where(_matchesParty).toList();
    }
    if (_startDate != null && _endDate != null) {
      transactions = transactions.where((t) => _inDateRange(t.date)).toList();
    }

    return transactions;
  }

  bool _matchesParty(Transaction transaction) {
    bool matchesSelected(String type, String? id, String? name) {
      if (_selectedPartyKey == 'all') return true;
      return _selectedPartyKey == '$type:${id ?? name}';
    }

    bool contains(String? value) {
      return _personQuery.isEmpty || (value?.contains(_personQuery) ?? false);
    }

    if (_partyType == 'customer') {
      return transaction.customerName != null &&
          matchesSelected('customer', null, transaction.customerName) &&
          contains(transaction.customerName);
    }
    if (_partyType == 'broker') {
      return transaction.brokerName != null &&
          matchesSelected(
            'broker',
            transaction.brokerId,
            transaction.brokerName,
          ) &&
          contains(transaction.brokerName);
    }
    if (_partyType == 'technician') {
      return transaction.technicianName != null &&
          matchesSelected(
            'technician',
            transaction.technicianId,
            transaction.technicianName,
          ) &&
          contains(transaction.technicianName);
    }
    if (_personQuery.isEmpty) return true;
    return contains(transaction.customerName) ||
        contains(transaction.brokerName) ||
        contains(transaction.technicianName);
  }

  List<RentalRecord> _filteredRentals(FinancialSummary report) {
    var rentals = report.rentals;

    if (_expenseType != 'all') {
      return [];
    }

    if (_selectedBuildingId != null) {
      rentals = rentals
          .where((r) => r.buildingId == _selectedBuildingId)
          .toList();
    }
    if (_selectedApartmentId != null) {
      rentals = rentals
          .where((r) => r.apartmentId == _selectedApartmentId)
          .toList();
    }
    if (_filter != 'all') {
      rentals = rentals.where((r) => r.season == _filter).toList();
    }
    if (_partyType == 'customer') {
      rentals = rentals.where((r) {
        final selected =
            _selectedPartyKey == 'all' ||
            _selectedPartyKey == 'customer:${r.customerName}';
        final search =
            _personQuery.isEmpty || r.customerName.contains(_personQuery);
        return selected && search;
      }).toList();
    } else if (_partyType == 'broker') {
      rentals = rentals.where((r) {
        if (r.brokerName == null) return false;
        final selected =
            _selectedPartyKey == 'all' ||
            _selectedPartyKey == 'broker:${r.brokerId ?? r.brokerName}';
        final search =
            _personQuery.isEmpty || r.brokerName!.contains(_personQuery);
        return selected && search;
      }).toList();
    } else if (_partyType == 'technician') {
      rentals = [];
    } else if (_personQuery.isNotEmpty) {
      rentals = rentals.where((r) {
        return r.customerName.contains(_personQuery) ||
            (r.brokerName?.contains(_personQuery) ?? false);
      }).toList();
    }
    if (_startDate != null && _endDate != null) {
      rentals = rentals.where((r) => _inDateRange(r.date)).toList();
    }

    return rentals;
  }

  List<WorkRecord> _filteredWorkRecords(FinancialSummary report) {
    var records = report.workRecords;

    if (_selectedBuildingId != null) {
      records = records
          .where((r) => r.buildingId == _selectedBuildingId)
          .toList();
    }
    if (_selectedApartmentId != null) {
      records = records
          .where((r) => r.apartmentId == _selectedApartmentId)
          .toList();
    }
    if (_filter != 'all') {
      records = records.where((r) => r.season == _filter).toList();
    }
    if (_expenseType != 'all' && _expenseType != 'maintenance') {
      records = [];
    }
    if (_partyType == 'technician') {
      records = records.where((r) {
        final selected =
            _selectedPartyKey == 'all' ||
            _selectedPartyKey == 'technician:${r.technicianId}';
        final search =
            _personQuery.isEmpty || r.technicianName.contains(_personQuery);
        return selected && search;
      }).toList();
    } else if (_partyType == 'broker' || _partyType == 'customer') {
      records = [];
    } else if (_personQuery.isNotEmpty) {
      records = records
          .where((r) => r.technicianName.contains(_personQuery))
          .toList();
    }
    if (_startDate != null && _endDate != null) {
      records = records.where((r) => _inDateRange(r.date)).toList();
    }

    return records;
  }

  bool _inDateRange(DateTime date) {
    return date.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
        date.isBefore(_endDate!.add(const Duration(days: 1)));
  }

  Transaction _workRecordTransaction(WorkRecord work) {
    return Transaction(
      date: work.date,
      description:
          'شغل عامل: ${work.technicianName} - ${work.description}${work.status == 'resolved' ? ' - مكتمل' : ' - مفتوح'}',
      amount: work.cost,
      isRevenue: false,
      paymentMethod: 'cash',
      buildingId: work.buildingId,
      apartmentId: work.apartmentId,
      buildingName: work.buildingName,
      apartmentNumber: work.apartmentNumber,
      floorNumber: work.floorNumber,
      season: work.season,
      expenseType: 'maintenance',
      technicianId: work.technicianId,
      technicianName: work.technicianName,
    );
  }

  List<_ReportMetric> _apartmentMetrics(List<RentalRecord> rentals) {
    final metrics = <String, _ReportMetric>{};
    for (final rental in rentals) {
      final metric = metrics.putIfAbsent(
        rental.apartmentId,
        () => _ReportMetric(label: 'شقة ${rental.apartmentNumber}'),
      );
      metric.count += 1;
      metric.paidRevenue += rental.paidRevenue;
      metric.rentalValue += rental.rentalValue > 0
          ? rental.rentalValue
          : rental.paidRevenue;
      metric.commission += rental.brokerCommission;
    }
    return _sortByRentalValue(metrics.values.toList());
  }

  List<_ReportMetric> _floorMetrics(List<RentalRecord> rentals) {
    final metrics = <String, _ReportMetric>{};
    for (final rental in rentals) {
      final floorLabel = rental.floorNumber == null
          ? 'دور غير محدد'
          : 'الدور ${rental.floorNumber}';
      final metric = metrics.putIfAbsent(
        floorLabel,
        () => _ReportMetric(label: floorLabel),
      );
      metric.count += 1;
      metric.paidRevenue += rental.paidRevenue;
      metric.rentalValue += rental.rentalValue > 0
          ? rental.rentalValue
          : rental.paidRevenue;
      metric.commission += rental.brokerCommission;
    }
    return _sortByRentalValue(metrics.values.toList());
  }

  List<_ReportMetric> _brokerMetrics(List<RentalRecord> rentals) {
    final metrics = <String, _ReportMetric>{};
    for (final rental in rentals.where((r) => r.brokerName != null)) {
      final key = rental.brokerId ?? rental.brokerName!;
      final metric = metrics.putIfAbsent(
        key,
        () => _ReportMetric(label: rental.brokerName!),
      );
      metric.count += 1;
      metric.paidRevenue += rental.paidRevenue;
      metric.rentalValue += rental.rentalValue > 0
          ? rental.rentalValue
          : rental.paidRevenue;
      metric.commission += rental.brokerCommission;
    }
    final list = metrics.values.toList();
    list.sort((a, b) => b.commission.compareTo(a.commission));
    return list;
  }

  List<_ReportMetric> _workerMetrics(List<WorkRecord> records) {
    final metrics = <String, _ReportMetric>{};
    for (final record in records) {
      final metric = metrics.putIfAbsent(
        record.technicianId,
        () => _ReportMetric(label: record.technicianName),
      );
      metric.count += 1;
      metric.cost += record.cost;
    }
    final list = metrics.values.toList();
    list.sort((a, b) => b.cost.compareTo(a.cost));
    return list;
  }

  List<_ReportMetric> _expenseMetrics(List<Transaction> transactions) {
    final metrics = <String, _ReportMetric>{};
    for (final transaction in transactions.where((t) => !t.isRevenue)) {
      final key = transaction.expenseType ?? 'other';
      final metric = metrics.putIfAbsent(
        key,
        () => _ReportMetric(label: expenseTypeLabel(key)),
      );
      metric.count += 1;
      metric.cost += transaction.amount;
    }
    final list = metrics.values.toList();
    list.sort((a, b) => b.cost.compareTo(a.cost));
    return list;
  }

  _ReportMetric? _topByCount(List<_ReportMetric> metrics) {
    if (metrics.isEmpty) return null;
    final list = [...metrics]..sort((a, b) => b.count.compareTo(a.count));
    return list.first;
  }

  _ReportMetric? _topByRentalValue(List<_ReportMetric> metrics) {
    if (metrics.isEmpty) return null;
    return _sortByRentalValue([...metrics]).first;
  }

  _ReportMetric? _lowByRentalValue(List<_ReportMetric> metrics) {
    final positiveMetrics = metrics.where((m) => m.rentalValue > 0).toList();
    if (positiveMetrics.isEmpty) return null;
    positiveMetrics.sort((a, b) => a.rentalValue.compareTo(b.rentalValue));
    return positiveMetrics.first;
  }

  List<_ReportMetric> _sortByRentalValue(List<_ReportMetric> metrics) {
    metrics.sort((a, b) => b.rentalValue.compareTo(a.rentalValue));
    return metrics;
  }

  Widget _buildMetricsSection({
    required String title,
    required String emptyText,
    required List<_ReportMetric> metrics,
    required IconData icon,
    required _MetricTrailingMode trailingMode,
  }) {
    final theme = Theme.of(context);
    return Card(
      child: ExpansionTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(metrics.isEmpty ? emptyText : '${metrics.length} عنصر'),
        children: metrics.isEmpty
            ? [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(emptyText),
                ),
              ]
            : metrics.map((metric) {
                return ListTile(
                  title: Text(metric.label),
                  subtitle: Text(_metricSubtitle(metric, trailingMode)),
                  trailing: Text(
                    _metricTrailingText(metric, trailingMode),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
      ),
    );
  }

  String _metricTrailingText(
    _ReportMetric metric,
    _MetricTrailingMode trailingMode,
  ) {
    switch (trailingMode) {
      case _MetricTrailingMode.cost:
        return '${metric.cost.toCurrencyFormat()} ج.م';
      case _MetricTrailingMode.commission:
        return '${metric.commission.toCurrencyFormat()} ج.م';
      case _MetricTrailingMode.rental:
        return '${metric.rentalValue.toCurrencyFormat()} ج.م';
    }
  }

  String _metricSubtitle(
    _ReportMetric metric,
    _MetricTrailingMode trailingMode,
  ) {
    switch (trailingMode) {
      case _MetricTrailingMode.cost:
        return 'عدد: ${metric.count} | تكلفة: ${metric.cost.toCurrencyFormat()} ج.م';
      case _MetricTrailingMode.commission:
        return 'حجوزات: ${metric.count} | إيراد: ${metric.rentalValue.toCurrencyFormat()} ج.م | عمولة: ${metric.commission.toCurrencyFormat()} ج.م';
      case _MetricTrailingMode.rental:
        return 'حجوزات: ${metric.count} | مدفوع: ${metric.paidRevenue.toCurrencyFormat()} ج.م | قيمة إيجارية: ${metric.rentalValue.toCurrencyFormat()} ج.م';
    }
  }
}

enum _MetricTrailingMode { rental, cost, commission }

class _ReportMetric {
  final String label;
  int count = 0;
  double paidRevenue = 0;
  double rentalValue = 0;
  double cost = 0;
  double commission = 0;

  _ReportMetric({required this.label});
}
