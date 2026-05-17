import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/season_utils.dart';
import '../models/report_view_models.dart';
import '../providers/reports_provider.dart';
import '../../../apartments/presentation/providers/apartments_controller.dart';
import '../../../buildings/presentation/providers/buildings_controller.dart';

class ReportsFilterScreen extends ConsumerStatefulWidget {
  final ReportFilterState initialFilters;

  const ReportsFilterScreen({
    super.key,
    this.initialFilters = const ReportFilterState(),
  });

  @override
  ConsumerState<ReportsFilterScreen> createState() =>
      _ReportsFilterScreenState();
}

class _ReportsFilterScreenState extends ConsumerState<ReportsFilterScreen> {
  late final TextEditingController _personController;
  String? _selectedBuildingId;
  String? _selectedApartmentId;
  String _season = 'all';
  String _expenseType = 'all';
  String _partyType = 'all';
  String _selectedPartyKey = 'all';
  String _transactionType = 'all';
  String _paymentMethod = 'all';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    final filters = widget.initialFilters;
    _selectedBuildingId = filters.buildingId;
    _selectedApartmentId = filters.apartmentId;
    _season = filters.season;
    _expenseType = filters.expenseType;
    _partyType = filters.partyType;
    _selectedPartyKey = filters.selectedPartyKey;
    _transactionType = filters.transactionType;
    _paymentMethod = filters.paymentMethod;
    _startDate = filters.startDate;
    _endDate = filters.endDate;
    _personController = TextEditingController(text: filters.personQuery);
  }

  @override
  void dispose() {
    _personController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  ReportFilterState get _filters => ReportFilterState(
    buildingId: _selectedBuildingId,
    apartmentId: _selectedApartmentId,
    season: _season,
    expenseType: _expenseType,
    partyType: _partyType,
    selectedPartyKey: _selectedPartyKey,
    transactionType: _transactionType,
    paymentMethod: _paymentMethod,
    personQuery: _personController.text.trim(),
    startDate: _startDate,
    endDate: _endDate,
  );

  void _clear() {
    _personController.clear();
    setState(() {
      _selectedBuildingId = null;
      _selectedApartmentId = null;
      _season = 'all';
      _expenseType = 'all';
      _partyType = 'all';
      _selectedPartyKey = 'all';
      _transactionType = 'all';
      _paymentMethod = 'all';
      _startDate = null;
      _endDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(financialReportProvider);
    final buildingsAsync = ref.watch(buildingsProvider);
    final apartmentsAsync = ref.watch(apartmentsProvider);
    final partyOptions = reportAsync.maybeWhen(
      data: (report) => ReportCalculator.partyOptions(report, _partyType),
      orElse: () => <String, String>{'all': 'كل الحسابات'},
    );
    final selectedPartyKey = partyOptions.containsKey(_selectedPartyKey)
        ? _selectedPartyKey
        : 'all';

    return Scaffold(
      appBar: AppBar(
        title: const Text('فلاتر وتحكم'),
        actions: [
          IconButton(
            onPressed: _clear,
            icon: const Icon(Icons.filter_alt_off),
            tooltip: 'مسح الفلاتر',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  buildingsAsync.when(
                    data: (buildings) => DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'المبنى'),
                      initialValue: _selectedBuildingId,
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('جميع المباني'),
                        ),
                        ...buildings.map(
                          (building) => DropdownMenuItem(
                            value: building.id,
                            child: Text(building.name),
                          ),
                        ),
                      ],
                      onChanged: (value) => setState(() {
                        _selectedBuildingId = value;
                        _selectedApartmentId = null;
                      }),
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (error, stack) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 12),
                  apartmentsAsync.when(
                    data: (apartments) {
                      var filteredApartments = apartments;
                      if (_selectedBuildingId != null) {
                        filteredApartments = apartments
                            .where(
                              (apartment) =>
                                  apartment.buildingId == _selectedBuildingId,
                            )
                            .toList();
                      }
                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'الشقة'),
                        initialValue: _selectedApartmentId,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('جميع الشقق'),
                          ),
                          ...filteredApartments.map(
                            (apartment) => DropdownMenuItem(
                              value: apartment.id,
                              child: Text('شقة ${apartment.apartmentNumber}'),
                            ),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => _selectedApartmentId = value),
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (error, stack) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'النوع'),
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
                    onChanged: (value) =>
                        setState(() => _transactionType = value ?? 'all'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'طريقة الدفع'),
                    initialValue: _paymentMethod,
                    items: const [
                      DropdownMenuItem(
                        value: 'all',
                        child: Text('كل طرق الدفع'),
                      ),
                      DropdownMenuItem(value: 'cash', child: Text('نقدي')),
                      DropdownMenuItem(
                        value: 'vodafone_cash',
                        child: Text('فودافون كاش'),
                      ),
                      DropdownMenuItem(
                        value: 'instapay',
                        child: Text('إنستاباي'),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _paymentMethod = value ?? 'all'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'الموسم'),
                    initialValue: _season,
                    items: seasonOptionsAround()
                        .map(
                          (option) => DropdownMenuItem(
                            value: option.key,
                            child: Text(option.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _season = value ?? 'all'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'نوع المصروف'),
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
                      DropdownMenuItem(value: 'water', child: Text('مياه')),
                      DropdownMenuItem(
                        value: 'electricity',
                        child: Text('كهرباء'),
                      ),
                      DropdownMenuItem(value: 'gas', child: Text('غاز')),
                      DropdownMenuItem(value: 'cleaning', child: Text('نظافة')),
                      DropdownMenuItem(value: 'other', child: Text('أخرى')),
                    ],
                    onChanged: (value) =>
                        setState(() => _expenseType = value ?? 'all'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'نوع الحساب'),
                    initialValue: _partyType,
                    items: const [
                      DropdownMenuItem(
                        value: 'all',
                        child: Text('كل الحسابات'),
                      ),
                      DropdownMenuItem(value: 'customer', child: Text('عميل')),
                      DropdownMenuItem(value: 'broker', child: Text('سمسار')),
                      DropdownMenuItem(
                        value: 'technician',
                        child: Text('عامل'),
                      ),
                    ],
                    onChanged: (value) => setState(() {
                      _partyType = value ?? 'all';
                      _selectedPartyKey = 'all';
                    }),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    key: ValueKey('filter-party-$_partyType'),
                    decoration: const InputDecoration(labelText: 'اختر الحساب'),
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
                        : (value) => setState(
                            () => _selectedPartyKey = value ?? 'all',
                          ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _personController,
                    decoration: const InputDecoration(
                      labelText: 'بحث في العملاء/السماسرة/العمال',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _selectDateRange,
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      _startDate == null
                          ? 'اختيار الفترة'
                          : '${_startDate!.month}/${_startDate!.year} - ${_endDate!.month}/${_endDate!.year}',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.push(
              '/reports/statement/preview',
              extra: _filters.copyWith(selectedPartyKey: selectedPartyKey),
            ),
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('تطبيق الفلاتر وعرض PDF'),
          ),
        ],
      ),
    );
  }
}
