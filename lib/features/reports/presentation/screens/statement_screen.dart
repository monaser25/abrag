import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import '../providers/reports_provider.dart';
import '../../domain/services/pdf_export_service.dart';
import '../../../buildings/presentation/providers/buildings_controller.dart';
import '../../../apartments/presentation/providers/apartments_controller.dart';
import '../../../../core/utils/currency_formatter.dart';

class StatementScreen extends ConsumerStatefulWidget {
  const StatementScreen({super.key});

  @override
  ConsumerState<StatementScreen> createState() => _StatementScreenState();
}

class _StatementScreenState extends ConsumerState<StatementScreen> {
  final _personController = TextEditingController();
  String? _selectedBuildingId;
  String? _selectedApartmentId;
  String _transactionType = 'all'; // all, revenue, expense
  String _season = 'all'; // all, summer, winter
  String _expenseType = 'all';
  String _partyType = 'all'; // all, customer, broker, technician
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
      _selectedBuildingId = null;
      _selectedApartmentId = null;
      _transactionType = 'all';
      _season = 'all';
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

  Map<String, String> _partyOptions(FinancialSummary? report) {
    final options = <String, String>{'all': 'كل الحسابات'};
    if (report == null || _partyType == 'all') return options;

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
      for (final transaction in report.transactions) {
        final name = transaction.technicianName;
        if (name != null && name.isNotEmpty) {
          options['technician:${transaction.technicianId ?? name}'] = name;
        }
      }
    }

    return options;
  }

  bool _matchesParty(Transaction transaction) {
    final query = _personQuery.trim();

    bool matchesSelected(String type, String? id, String? name) {
      if (_selectedPartyKey == 'all') return true;
      return _selectedPartyKey == '$type:${id ?? name}';
    }

    bool contains(String? value) {
      return query.isEmpty || (value?.contains(query) ?? false);
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

    if (query.isEmpty) return true;
    return contains(transaction.customerName) ||
        contains(transaction.brokerName) ||
        contains(transaction.technicianName);
  }

  bool _matchesWorkRecord(WorkRecord work) {
    if (_selectedBuildingId != null && work.buildingId != _selectedBuildingId) {
      return false;
    }
    if (_selectedApartmentId != null &&
        work.apartmentId != _selectedApartmentId) {
      return false;
    }
    if (_season != 'all' && work.season != _season) {
      return false;
    }
    if (_expenseType != 'all' && _expenseType != 'maintenance') {
      return false;
    }
    if (_selectedPartyKey != 'all' &&
        _selectedPartyKey != 'technician:${work.technicianId}') {
      return false;
    }
    if (_personQuery.isNotEmpty &&
        !work.technicianName.contains(_personQuery)) {
      return false;
    }
    if (_startDate != null && _endDate != null) {
      return work.date.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
          work.date.isBefore(_endDate!.add(const Duration(days: 1)));
    }
    return true;
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

  String _selectedPartyLabel(FinancialSummary? report) {
    return _partyOptions(report)[_selectedPartyKey] ?? 'كل الحسابات';
  }

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(financialReportProvider);
    final buildingsAsync = ref.watch(buildingsProvider);
    final apartmentsAsync = ref.watch(apartmentsProvider);
    final reportForOptions = reportAsync.asData?.value;
    final partyOptions = _partyOptions(reportForOptions);
    final selectedPartyKey = partyOptions.containsKey(_selectedPartyKey)
        ? _selectedPartyKey
        : 'all';

    return Scaffold(
      appBar: AppBar(
        title: const Text('كشف الحساب (تقرير مفصل)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_off),
            tooltip: 'مسح الفلاتر',
            onPressed: _clearFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters Area
          Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.38,
                ),
                child: SingleChildScrollView(
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
                                      labelText: 'المبنى',
                                      isDense: true,
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
                                    onChanged: (val) => setState(() {
                                      _selectedBuildingId = val;
                                      _selectedApartmentId = null;
                                    }),
                                  ),
                              loading: () => const LinearProgressIndicator(),
                              error: (e, _) => const SizedBox.shrink(),
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
                                            a.buildingId == _selectedBuildingId,
                                      )
                                      .toList();
                                }
                                return DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: 'الشقة',
                                    isDense: true,
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
                                        child: Text('شقة ${a.apartmentNumber}'),
                                      ),
                                    ),
                                  ],
                                  onChanged: (val) => setState(
                                    () => _selectedApartmentId = val,
                                  ),
                                );
                              },
                              loading: () => const LinearProgressIndicator(),
                              error: (e, _) => const SizedBox.shrink(),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: DropdownButtonFormField<String>(
                              key: ValueKey(
                                'statement-party-account-$_partyType',
                              ),
                              decoration: const InputDecoration(
                                labelText: 'النوع',
                                isDense: true,
                              ),
                              initialValue: _transactionType,
                              items: const [
                                DropdownMenuItem(
                                  value: 'all',
                                  child: Text('إيرادات ومصروفات'),
                                ),
                                DropdownMenuItem(
                                  value: 'revenue',
                                  child: Text('إيرادات فقط'),
                                ),
                                DropdownMenuItem(
                                  value: 'expense',
                                  child: Text('مصروفات فقط'),
                                ),
                              ],
                              onChanged: (val) => setState(
                                () => _transactionType = val ?? 'all',
                              ),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'الموسم',
                                isDense: true,
                              ),
                              initialValue: _season,
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
                              onChanged: (val) =>
                                  setState(() => _season = val ?? 'all'),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'نوع المصروف',
                                isDense: true,
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
                              onChanged: (val) =>
                                  setState(() => _expenseType = val ?? 'all'),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'نوع الحساب',
                                isDense: true,
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
                              onChanged: (val) => setState(() {
                                _partyType = val ?? 'all';
                                _selectedPartyKey = 'all';
                              }),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'اختر الحساب',
                                isDense: true,
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
                                  : (val) => setState(
                                      () => _selectedPartyKey = val ?? 'all',
                                    ),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: TextField(
                              controller: _personController,
                              decoration: const InputDecoration(
                                labelText: 'بحث في العملاء/السماسرة/العمال',
                                isDense: true,
                                prefixIcon: Icon(Icons.search),
                              ),
                              onChanged: (val) =>
                                  setState(() => _personQuery = val.trim()),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: OutlinedButton.icon(
                              onPressed: _selectDateRange,
                              icon: const Icon(Icons.date_range, size: 18),
                              label: Text(
                                _startDate != null
                                    ? '${_startDate!.month}/${_startDate!.year} - ${_endDate!.month}/${_endDate!.year}'
                                    : 'الفترة الزمنية',
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
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

          Expanded(
            child: reportAsync.when(
              data: (report) {
                List<Transaction> filtered = _partyType == 'technician'
                    ? report.workRecords
                          .where(_matchesWorkRecord)
                          .map(_workRecordTransaction)
                          .toList()
                    : report.transactions;

                if (_partyType != 'technician') {
                  if (_selectedBuildingId != null) {
                    filtered = filtered
                        .where((t) => t.buildingId == _selectedBuildingId)
                        .toList();
                  }

                  if (_selectedApartmentId != null) {
                    filtered = filtered
                        .where((t) => t.apartmentId == _selectedApartmentId)
                        .toList();
                  }

                  if (_transactionType == 'revenue') {
                    filtered = filtered.where((t) => t.isRevenue).toList();
                  } else if (_transactionType == 'expense') {
                    filtered = filtered.where((t) => !t.isRevenue).toList();
                  }

                  if (_season != 'all') {
                    filtered = filtered
                        .where((t) => t.season == _season)
                        .toList();
                  }

                  if (_expenseType != 'all') {
                    filtered = filtered
                        .where((t) => t.expenseType == _expenseType)
                        .toList();
                  }

                  if (_partyType != 'all' ||
                      _selectedPartyKey != 'all' ||
                      _personQuery.isNotEmpty) {
                    filtered = filtered.where(_matchesParty).toList();
                  }

                  if (_startDate != null && _endDate != null) {
                    filtered = filtered.where((t) {
                      return t.date.isAfter(
                            _startDate!.subtract(const Duration(days: 1)),
                          ) &&
                          t.date.isBefore(
                            _endDate!.add(const Duration(days: 1)),
                          );
                    }).toList();
                  }
                } else if (_transactionType == 'revenue') {
                  filtered = [];
                }

                final totalRev = filtered
                    .where((t) => t.isRevenue)
                    .fold(0.0, (s, t) => s + t.amount);
                final totalExp = filtered
                    .where((t) => !t.isRevenue)
                    .fold(0.0, (s, t) => s + t.amount);
                final profit = totalRev - totalExp;

                return PdfPreview(
                  build: (format) => PdfExportService.generateStatementPdf(
                    title: _partyType == 'all'
                        ? 'كشف حساب'
                        : 'كشف حساب ${_selectedPartyLabel(report)}',
                    dateRange: _startDate != null
                        ? 'من ${_startDate!.toLocal().toString().split(' ')[0]} إلى ${_endDate!.toLocal().toString().split(' ')[0]}'
                        : 'جميع الأوقات',
                    totalRevenue: totalRev,
                    totalExpenses: totalExp,
                    netProfit: profit,
                    transactions: filtered
                        .map(
                          (t) => {
                            'date': t.date.toLocal().toString().split(' ')[0],
                            'description': [
                              t.description,
                              if (t.apartmentNumber != null)
                                'شقة ${t.apartmentNumber}',
                              if (t.buildingName != null) t.buildingName,
                              if (t.brokerName != null &&
                                  t.brokerName!.isNotEmpty)
                                'سمسار: ${t.brokerName}',
                              if (t.technicianName != null &&
                                  t.technicianName!.isNotEmpty)
                                'عامل: ${t.technicianName}',
                              if (t.brokerCommission > 0)
                                'عمولة السمسار: ${t.brokerCommission.toCurrencyFormat()} ج.م',
                            ].join(' - '),
                            'amount': t.isRevenue
                                ? '+ ${t.amount.toCurrencyFormat()}'
                                : '- ${t.amount.toCurrencyFormat()}',
                            'isRevenue': t.isRevenue,
                          },
                        )
                        .toList(),
                  ),
                  allowPrinting: true,
                  allowSharing: true,
                  canChangeOrientation: false,
                  canChangePageFormat: false,
                  canDebug: false,
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}
