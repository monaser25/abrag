import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/shared_prefs_provider.dart';
import '../../../../core/database/database.dart';
import '../models/report_view_models.dart';
import '../providers/reports_provider.dart';
import '../../../../core/utils/currency_formatter.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  final ReportFilterState? initialFilters;

  const ReportsScreen({super.key, this.initialFilters});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  final _personController = TextEditingController();
  bool _hideNumbers = false;
  String _filter = 'all'; // all, summer, winter
  String? _selectedBuildingId;
  String? _selectedApartmentId;
  String _expenseType = 'all';
  String _partyType = 'all';
  String _selectedPartyKey = 'all';
  String _transactionType = 'all';
  String _paymentMethod = 'all';
  String _personQuery = '';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _applyFilters(widget.initialFilters ?? const ReportFilterState());
    _hideNumbers =
        ref.read(sharedPreferencesProvider).getBool('reports_hide_numbers') ??
        false;
  }

  @override
  void didUpdateWidget(covariant ReportsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialFilters != widget.initialFilters) {
      _applyFilters(widget.initialFilters ?? const ReportFilterState());
    }
  }

  void _applyFilters(ReportFilterState filters) {
    _filter = filters.season;
    _selectedBuildingId = filters.buildingId;
    _selectedApartmentId = filters.apartmentId;
    _expenseType = filters.expenseType;
    _partyType = filters.partyType;
    _selectedPartyKey = filters.selectedPartyKey;
    _transactionType = filters.transactionType;
    _paymentMethod = filters.paymentMethod;
    _personQuery = filters.personQuery;
    _startDate = filters.startDate;
    _endDate = filters.endDate;
    _personController.text = filters.personQuery;
  }

  Future<void> _toggleHideNumbers() async {
    final nextValue = !_hideNumbers;
    setState(() => _hideNumbers = nextValue);
    await ref
        .read(sharedPreferencesProvider)
        .setBool('reports_hide_numbers', nextValue);
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
      _transactionType = 'all';
      _paymentMethod = 'all';
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
              context.push('/reports/statement', extra: _currentFilters());
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

          final apartmentMetrics = _apartmentMetrics(filteredRentals);
          final floorMetrics = _floorMetrics(filteredRentals);
          final brokerMetrics = _brokerMetrics(filteredRentals);
          final workerMetrics = _workerMetrics(filteredWorkRecords);
          final expenseMetrics = _expenseMetrics(filteredTransactions);

          final partyOptions = _partyOptions(report);
          final selectedPartyKey = partyOptions.containsKey(_selectedPartyKey)
              ? _selectedPartyKey
              : 'all';
          final activeFilters = ReportFilterState(
            buildingId: _selectedBuildingId,
            apartmentId: _selectedApartmentId,
            season: _filter,
            expenseType: _expenseType,
            partyType: _partyType,
            selectedPartyKey: selectedPartyKey,
            transactionType: _transactionType,
            paymentMethod: _paymentMethod,
            personQuery: _personQuery,
            startDate: _startDate,
            endDate: _endDate,
          );

          final walletBalances = _walletBalances(
            filteredTransactions,
            _filteredFinancialTransfers(report, activeFilters),
          );
          final cashRev = walletBalances['cash'] ?? 0;
          final vfRev = walletBalances['vodafone_cash'] ?? 0;
          final instaRev = walletBalances['instapay'] ?? 0;
          final companyVault = walletBalances['company_vault'] ?? 0;
          final totalMoney = walletBalances.values.fold<double>(
            0,
            (sum, value) => sum + value,
          );

          final filteredProfit = filteredRevenue - filteredExpenses;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildFinancialOverview(
                    context,
                    revenue: filteredRevenue,
                    expenses: filteredExpenses,
                    profit: filteredProfit,
                    cash: cashRev,
                    vodafoneCash: vfRev,
                    instapay: instaRev,
                    companyVault: companyVault,
                    totalMoney: totalMoney,
                    activeFilters: activeFilters,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                SliverToBoxAdapter(
                  child: _buildShortcutGrid(
                    context,
                    activeFilters,
                    selectedPartyKey,
                    apartmentMetrics.length,
                    floorMetrics.length,
                    brokerMetrics.length,
                    workerMetrics.length,
                    expenseMetrics.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push(
                      '/reports/statement',
                      extra: activeFilters,
                    ),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('إنشاء كشف حساب PDF'),
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

  void _openStatement(BuildContext context, ReportFilterState filters) {
    context.push('/reports/statement', extra: filters);
  }

  ReportFilterState _currentFilters({String? selectedPartyKey}) {
    return ReportFilterState(
      buildingId: _selectedBuildingId,
      apartmentId: _selectedApartmentId,
      season: _filter,
      expenseType: _expenseType,
      partyType: _partyType,
      selectedPartyKey: selectedPartyKey ?? _selectedPartyKey,
      transactionType: _transactionType,
      paymentMethod: _paymentMethod,
      personQuery: _personQuery,
      startDate: _startDate,
      endDate: _endDate,
    );
  }

  Widget _buildMiniStat(
    ThemeData theme,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Column(
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ReportFilterState _statementFilters(
    ReportFilterState base, {
    String transactionType = 'all',
    String paymentMethod = 'all',
  }) {
    return base.copyWith(
      transactionType: transactionType,
      paymentMethod: paymentMethod,
    );
  }

  Widget _buildTapHint(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.touch_app,
            size: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            'اضغط للتفاصيل',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _privateValue(String value) => _hideNumbers ? '••••' : value;

  Widget _buildShortcutGrid(
    BuildContext context,
    ReportFilterState activeFilters,
    String selectedPartyKey,
    int apartmentsCount,
    int floorsCount,
    int brokersCount,
    int workersCount,
    int expensesCount,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = constraints.maxWidth < 720
            ? constraints.maxWidth
            : (constraints.maxWidth - 16) / 3;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            SizedBox(
              width: itemWidth,
              child: _buildFiltersCard(context, selectedPartyKey),
            ),
            SizedBox(
              width: itemWidth,
              child: _buildStatisticsSummary(context, activeFilters),
            ),
            SizedBox(
              width: itemWidth,
              child: _buildReportsMenu(
                context,
                activeFilters,
                apartmentsCount,
                floorsCount,
                brokersCount,
                workersCount,
                expensesCount,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFinancialOverview(
    BuildContext context, {
    required double revenue,
    required double expenses,
    required double profit,
    required double cash,
    required double vodafoneCash,
    required double instapay,
    required double companyVault,
    required double totalMoney,
    required ReportFilterState activeFilters,
  }) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'الملخص المالي',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: 'فتح الخزنة',
                  onPressed: () => context.push('/financial_transfers'),
                  icon: const Icon(Icons.account_balance_wallet),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: _hideNumbers ? 'إظهار الأرقام' : 'إخفاء الأرقام',
                  onPressed: _toggleHideNumbers,
                  icon: Icon(
                    _hideNumbers ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MoneyTile(
                    title: 'الإيرادات',
                    value: _privateValue('${revenue.toCurrencyFormat()} ج.م'),
                    icon: Icons.trending_up,
                    color: Colors.green,
                    onTap: () => _openStatement(
                      context,
                      _statementFilters(
                        activeFilters,
                        transactionType: 'revenue',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MoneyTile(
                    title: 'المصروفات',
                    value: _privateValue('${expenses.toCurrencyFormat()} ج.م'),
                    icon: Icons.trending_down,
                    color: theme.colorScheme.error,
                    onTap: () => _openStatement(
                      context,
                      _statementFilters(
                        activeFilters,
                        transactionType: 'expense',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _MoneyTile(
              title: 'صافي الربح',
              value: _privateValue('${profit.toCurrencyFormat()} ج.م'),
              icon: Icons.account_balance_wallet,
              color: theme.colorScheme.primary,
              onTap: () => _openStatement(context, activeFilters),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: _buildTapHint(theme),
            ),
            const SizedBox(height: 16),
            Text(
              'تفاصيل الإيرادات والخزنة الحالية',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildMiniStat(
                    theme,
                    'إجمالي الفلوس',
                    _privateValue('${totalMoney.toCurrencyFormat()} ج.م'),
                    onTap: () => context.push('/financial_transfers'),
                  ),
                _buildMiniStat(
                    theme,
                    'نقدية حالية',
                    _privateValue('${cash.toCurrencyFormat()} ج.م'),
                    onTap: () => _openStatement(
                      context,
                      _statementFilters(
                        activeFilters,
                        transactionType: 'revenue',
                        paymentMethod: 'cash',
                      ),
                    ),
                  ),
                _buildMiniStat(
                    theme,
                    'فودافون كاش',
                    _privateValue('${vodafoneCash.toCurrencyFormat()} ج.م'),
                    onTap: () => _openStatement(
                      context,
                      _statementFilters(
                        activeFilters,
                        transactionType: 'revenue',
                        paymentMethod: 'vodafone_cash',
                      ),
                    ),
                  ),
                _buildMiniStat(
                    theme,
                    'إنستاباي',
                    _privateValue('${instapay.toCurrencyFormat()} ج.م'),
                    onTap: () => _openStatement(
                      context,
                      _statementFilters(
                        activeFilters,
                        transactionType: 'revenue',
                        paymentMethod: 'instapay',
                      ),
                    ),
                  ),
                _buildMiniStat(
                  theme,
                  'نقدية في خزنة الشركة',
                  _privateValue('${companyVault.toCurrencyFormat()} ج.م'),
                  onTap: () => context.push('/financial_transfers'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersCard(BuildContext context, String selectedPartyKey) {
    return _DashboardShortcutCard(
      icon: Icons.tune,
      title: 'فلاتر وتحكم',
      description:
          'افتح صفحة الفلاتر الكاملة لاختيار الشقة، الموسم، الحساب أو الفترة.',
      onTap: () => context.push(
        '/reports/filters',
        extra: ReportFilterState(
          buildingId: _selectedBuildingId,
          apartmentId: _selectedApartmentId,
          season: _filter,
          expenseType: _expenseType,
          partyType: _partyType,
          selectedPartyKey: selectedPartyKey,
          transactionType: _transactionType,
          paymentMethod: _paymentMethod,
          personQuery: _personQuery,
          startDate: _startDate,
          endDate: _endDate,
        ),
      ),
    );
  }

  Widget _buildStatisticsSummary(
    BuildContext context,
    ReportFilterState activeFilters,
  ) {
    return _DashboardShortcutCard(
      icon: Icons.insights,
      title: 'ملخص الإحصائيات',
      description: 'افتح مؤشرات أعلى/أقل شقة ودور وإحصائيات الموسم والإيرادات.',
      onTap: () => context.push('/reports/statistics', extra: activeFilters),
    );
  }

  Widget _buildReportsMenu(
    BuildContext context,
    ReportFilterState filters,
    int apartmentsCount,
    int floorsCount,
    int brokersCount,
    int workersCount,
    int expensesCount,
  ) {
    final count =
        apartmentsCount +
        floorsCount +
        brokersCount +
        workersCount +
        expensesCount;
    return _DashboardShortcutCard(
      icon: Icons.dashboard_customize,
      title: 'التقارير التفصيلية',
      description:
          'افتح قائمة التقارير التفصيلية وكشف الحساب. ($count عنصر متاح)',
      onTap: () => context.push('/reports/menu', extra: filters),
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
    if (_transactionType == 'revenue') {
      transactions = transactions.where((t) => t.isRevenue).toList();
    } else if (_transactionType == 'expense') {
      transactions = transactions.where((t) => !t.isRevenue).toList();
    }
    if (_paymentMethod != 'all') {
      transactions = transactions
          .where((t) => t.paymentMethod == _paymentMethod)
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

  List<FinancialTransfer> _filteredFinancialTransfers(
    FinancialSummary report,
    ReportFilterState filters,
  ) {
    var transfers = report.financialTransfers;
    if (filters.season != 'all') {
      transfers = transfers.where((t) => t.season == filters.season).toList();
    }
    if (filters.startDate != null && filters.endDate != null) {
      final start = DateTime(
        filters.startDate!.year,
        filters.startDate!.month,
        filters.startDate!.day,
      );
      final end = DateTime(
        filters.endDate!.year,
        filters.endDate!.month,
        filters.endDate!.day,
        23,
        59,
        59,
      );
      transfers = transfers.where((t) {
        return !t.transferDate.isBefore(start) && !t.transferDate.isAfter(end);
      }).toList();
    }
    return transfers;
  }

  Map<String, double> _walletBalances(
    List<Transaction> transactions,
    List<FinancialTransfer> transfers,
  ) {
    final balances = <String, double>{
      'cash': 0,
      'vodafone_cash': 0,
      'instapay': 0,
      'company_vault': 0,
    };

    void add(String account, double amount) {
      if (balances.containsKey(account)) {
        balances[account] = (balances[account] ?? 0) + amount;
      }
    }

    for (final transaction in transactions) {
      add(
        transaction.paymentMethod,
        transaction.isRevenue ? transaction.amount : -transaction.amount,
      );
    }

    for (final transfer in transfers) {
      add(transfer.fromAccount, -transfer.amountEgp);
      if (transfer.transferType == 'internal') {
        add(transfer.toAccount, transfer.amountEgp);
      } else if (transfer.transferType == 'cash_deposit') {
        add('company_vault', transfer.amountEgp);
      }
    }

    return balances;
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

  List<_ReportMetric> _sortByRentalValue(List<_ReportMetric> metrics) {
    metrics.sort((a, b) => b.rentalValue.compareTo(a.rentalValue));
    return metrics;
  }
}

class _DashboardShortcutCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _DashboardShortcutCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_left),
        onTap: onTap,
        textColor: theme.colorScheme.onSurface,
      ),
    );
  }
}

class _MoneyTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _MoneyTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = BorderRadius.circular(16);
    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: borderRadius,
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      value,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportMetric {
  final String label;
  int count = 0;
  double paidRevenue = 0;
  double rentalValue = 0;
  double cost = 0;
  double commission = 0;

  _ReportMetric({required this.label});
}
