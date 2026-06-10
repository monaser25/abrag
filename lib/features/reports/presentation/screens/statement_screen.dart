import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/audit_log_service.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/season_utils.dart';
import '../../../../shared/widgets/widgets.dart';
import '../models/report_view_models.dart';
import '../providers/reports_provider.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';
import '../../../buildings/presentation/providers/buildings_controller.dart';
import '../../../apartments/presentation/providers/apartments_controller.dart';

class StatementScreen extends ConsumerStatefulWidget {
  final ReportFilterState initialFilters;

  const StatementScreen({
    super.key,
    this.initialFilters = const ReportFilterState(),
  });

  @override
  ConsumerState<StatementScreen> createState() => _StatementScreenState();
}

class _StatementScreenState extends ConsumerState<StatementScreen> {
  final _personController = TextEditingController();
  String? _selectedBuildingId;
  String? _selectedApartmentId;
  String _transactionType = 'all'; // all, revenue, expense
  String _paymentMethod = 'all'; // all, cash, vodafone_cash, instapay
  String _season = 'all'; // all, summer, winter
  String _expenseType = 'all';
  String _partyType = 'all'; // all, customer, broker, technician
  String _selectedPartyKey = 'all';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    final filters = widget.initialFilters;
    _selectedBuildingId = filters.buildingId;
    _selectedApartmentId = filters.apartmentId;
    _transactionType = filters.transactionType;
    _paymentMethod = filters.paymentMethod;
    _season = filters.season;
    _expenseType = filters.expenseType;
    _partyType = filters.partyType;
    _selectedPartyKey = filters.selectedPartyKey;
    _startDate = filters.startDate;
    _endDate = filters.endDate;
    _personController.text = filters.personQuery;
  }

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
      _paymentMethod = 'all';
      _season = 'all';
      _expenseType = 'all';
      _partyType = 'all';
      _selectedPartyKey = 'all';
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

  ReportFilterState _currentFilters(String selectedPartyKey) {
    return ReportFilterState(
      buildingId: _selectedBuildingId,
      apartmentId: _selectedApartmentId,
      season: _season,
      expenseType: _expenseType,
      partyType: _partyType,
      selectedPartyKey: selectedPartyKey,
      personQuery: _personController.text.trim(),
      transactionType: _transactionType,
      paymentMethod: _paymentMethod,
      startDate: _startDate,
      endDate: _endDate,
    );
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

    final colors = context.colors;

    return AppScaffold(
      appBar: AbragAppBar(
        title: 'كشف الحساب (تقرير مفصل)',
        actions: [
          AppIconButton(
            icon: Icons.filter_alt_off,
            tooltip: 'مسح الفلاتر',
            onPressed: _clearFilters,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'اختار فلاتر كشف الحساب',
                    style: AppTextStyles.h3.copyWith(color: colors.ink),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'بعد اختيار الفلاتر اضغط عرض PDF لمعاينة الكشف ومشاركته أو طباعته.',
                    style: AppTextStyles.bodyS.copyWith(color: colors.ink2),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
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
                                labelText: 'طريقة الدفع',
                                isDense: true,
                              ),
                              initialValue: _paymentMethod,
                              items: const [
                                DropdownMenuItem(
                                  value: 'all',
                                  child: Text('كل طرق الدفع'),
                                ),
                                DropdownMenuItem(
                                  value: 'cash',
                                  child: Text('نقدي'),
                                ),
                                DropdownMenuItem(
                                  value: 'vodafone_cash',
                                  child: Text('فودافون كاش'),
                                ),
                                DropdownMenuItem(
                                  value: 'instapay',
                                  child: Text('إنستاباي'),
                                ),
                              ],
                              onChanged: (val) =>
                                  setState(() => _paymentMethod = val ?? 'all'),
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
                              items: seasonOptionsAround()
                                  .map(
                                    (option) => DropdownMenuItem(
                                      value: option.key,
                                      child: Text(option.label),
                                    ),
                                  )
                                  .toList(),
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
                              key: ValueKey('statement-party-$_partyType'),
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
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: AppButton(
                              label: _startDate != null
                                  ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year} - ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                  : 'اختيار الفترة الزمنية',
                              icon: Icons.date_range,
                              variant: AppButtonVariant.outline,
                              expand: true,
                              onPressed: _selectDateRange,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'عرض PDF',
            icon: Icons.picture_as_pdf,
            expand: true,
            onPressed: () async {
              final filters = _currentFilters(selectedPartyKey);
              await AuditLogService(ref.read(databaseProvider)).log(
                action: 'preview_pdf',
                entityType: 'report',
                title: 'معاينة كشف حساب',
                description: 'تم فتح معاينة كشف الحساب PDF',
                route: '/reports/statement',
                newValues: {
                  'season': filters.season,
                  'paymentMethod': filters.paymentMethod,
                  'transactionType': filters.transactionType,
                },
              );
              if (context.mounted) {
                context.push('/reports/statement/preview', extra: filters);
              }
            },
          ),
          const SizedBox(height: 8),
          Text(
            'سيتم إنشاء كشف الحساب حسب الفلاتر المختارة.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyS.copyWith(color: colors.ink2),
          ),
        ],
      ),
    );
  }
}
