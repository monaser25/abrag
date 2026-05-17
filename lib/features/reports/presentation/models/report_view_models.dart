import '../providers/reports_provider.dart';

enum ReportDetailKind { apartments, floors, brokers, workers, expenses }

extension ReportDetailKindX on ReportDetailKind {
  String get key {
    switch (this) {
      case ReportDetailKind.apartments:
        return 'apartments';
      case ReportDetailKind.floors:
        return 'floors';
      case ReportDetailKind.brokers:
        return 'brokers';
      case ReportDetailKind.workers:
        return 'workers';
      case ReportDetailKind.expenses:
        return 'expenses';
    }
  }

  String get title {
    switch (this) {
      case ReportDetailKind.apartments:
        return 'تفاصيل الشقق';
      case ReportDetailKind.floors:
        return 'تفاصيل الأدوار';
      case ReportDetailKind.brokers:
        return 'حسابات السماسرة';
      case ReportDetailKind.workers:
        return 'حسابات العمال';
      case ReportDetailKind.expenses:
        return 'المصروفات حسب النوع';
    }
  }

  String get emptyText {
    switch (this) {
      case ReportDetailKind.apartments:
        return 'لا توجد حجوزات شقق مطابقة للفلاتر';
      case ReportDetailKind.floors:
        return 'لا توجد أدوار مطابقة للفلاتر';
      case ReportDetailKind.brokers:
        return 'لا توجد حجوزات بسماسرة مطابقة للفلاتر';
      case ReportDetailKind.workers:
        return 'لا توجد أعمال عمال مطابقة للفلاتر';
      case ReportDetailKind.expenses:
        return 'لا توجد مصروفات مطابقة للفلاتر';
    }
  }

  static ReportDetailKind fromKey(String key) {
    return ReportDetailKind.values.firstWhere(
      (kind) => kind.key == key,
      orElse: () => ReportDetailKind.apartments,
    );
  }
}

class ReportFilterState {
  final String? buildingId;
  final String? apartmentId;
  final String season;
  final String expenseType;
  final String partyType;
  final String selectedPartyKey;
  final String personQuery;
  final String transactionType;
  final String paymentMethod;
  final DateTime? startDate;
  final DateTime? endDate;

  const ReportFilterState({
    this.buildingId,
    this.apartmentId,
    this.season = 'all',
    this.expenseType = 'all',
    this.partyType = 'all',
    this.selectedPartyKey = 'all',
    this.personQuery = '',
    this.transactionType = 'all',
    this.paymentMethod = 'all',
    this.startDate,
    this.endDate,
  });

  ReportFilterState copyWith({
    String? buildingId,
    String? apartmentId,
    String? season,
    String? expenseType,
    String? partyType,
    String? selectedPartyKey,
    String? personQuery,
    String? transactionType,
    String? paymentMethod,
    DateTime? startDate,
    DateTime? endDate,
    bool clearApartment = false,
    bool clearDates = false,
  }) {
    return ReportFilterState(
      buildingId: buildingId ?? this.buildingId,
      apartmentId: clearApartment ? null : apartmentId ?? this.apartmentId,
      season: season ?? this.season,
      expenseType: expenseType ?? this.expenseType,
      partyType: partyType ?? this.partyType,
      selectedPartyKey: selectedPartyKey ?? this.selectedPartyKey,
      personQuery: personQuery ?? this.personQuery,
      transactionType: transactionType ?? this.transactionType,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      startDate: clearDates ? null : startDate ?? this.startDate,
      endDate: clearDates ? null : endDate ?? this.endDate,
    );
  }

  String get dateRangeLabel {
    if (startDate == null || endDate == null) return 'جميع الفترات';
    return '${startDate!.toLocal().toString().split(' ')[0]} - ${endDate!.toLocal().toString().split(' ')[0]}';
  }
}

class ReportMetric {
  final String key;
  final String label;
  int count;
  double paidRevenue;
  double rentalValue;
  double cost;
  double commission;

  ReportMetric({
    required this.key,
    required this.label,
    this.count = 0,
    this.paidRevenue = 0,
    this.rentalValue = 0,
    this.cost = 0,
    this.commission = 0,
  });
}

class ReportCalculator {
  static Map<String, String> partyOptions(
    FinancialSummary report,
    String partyType,
  ) {
    final options = <String, String>{'all': 'كل الحسابات'};
    if (partyType == 'all') return options;

    if (partyType == 'customer') {
      for (final transaction in report.transactions) {
        final name = transaction.customerName;
        if (name != null && name.isNotEmpty) {
          options['customer:$name'] = name;
        }
      }
    } else if (partyType == 'broker') {
      for (final transaction in report.transactions) {
        final name = transaction.brokerName;
        if (name != null && name.isNotEmpty) {
          options['broker:${transaction.brokerId ?? name}'] = name;
        }
      }
    } else if (partyType == 'technician') {
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

  static List<Transaction> filteredTransactions(
    FinancialSummary report,
    ReportFilterState filters, {
    bool technicianWorkAsTransactions = false,
  }) {
    if (filters.partyType == 'technician' && technicianWorkAsTransactions) {
      return filteredWorkRecords(
        report,
        filters,
      ).map(workRecordTransaction).toList();
    }

    var transactions = report.transactions;

    if (filters.buildingId != null) {
      transactions = transactions
          .where((t) => t.buildingId == filters.buildingId)
          .toList();
    }
    if (filters.apartmentId != null) {
      transactions = transactions
          .where((t) => t.apartmentId == filters.apartmentId)
          .toList();
    }
    if (filters.transactionType == 'revenue') {
      transactions = transactions.where((t) => t.isRevenue).toList();
    } else if (filters.transactionType == 'expense') {
      transactions = transactions.where((t) => !t.isRevenue).toList();
    }
    if (filters.paymentMethod != 'all') {
      transactions = transactions
          .where((t) => t.paymentMethod == filters.paymentMethod)
          .toList();
    }
    if (filters.season != 'all') {
      transactions = transactions
          .where((t) => t.season == filters.season)
          .toList();
    }
    if (filters.expenseType != 'all') {
      transactions = transactions
          .where((t) => t.expenseType == filters.expenseType)
          .toList();
    }
    if (filters.partyType != 'all' ||
        filters.selectedPartyKey != 'all' ||
        filters.personQuery.isNotEmpty) {
      transactions = transactions
          .where((t) => _matchesParty(t, filters))
          .toList();
    }
    if (filters.startDate != null && filters.endDate != null) {
      transactions = transactions
          .where((t) => _inDateRange(t.date, filters))
          .toList();
    }

    return transactions;
  }

  static List<RentalRecord> filteredRentals(
    FinancialSummary report,
    ReportFilterState filters,
  ) {
    if (filters.expenseType != 'all') return [];

    var rentals = report.rentals;

    if (filters.buildingId != null) {
      rentals = rentals
          .where((r) => r.buildingId == filters.buildingId)
          .toList();
    }
    if (filters.apartmentId != null) {
      rentals = rentals
          .where((r) => r.apartmentId == filters.apartmentId)
          .toList();
    }
    if (filters.season != 'all') {
      rentals = rentals.where((r) => r.season == filters.season).toList();
    }
    if (filters.partyType == 'customer') {
      rentals = rentals.where((r) {
        final selected =
            filters.selectedPartyKey == 'all' ||
            filters.selectedPartyKey == 'customer:${r.customerName}';
        final search =
            filters.personQuery.isEmpty ||
            r.customerName.contains(filters.personQuery);
        return selected && search;
      }).toList();
    } else if (filters.partyType == 'broker') {
      rentals = rentals.where((r) {
        if (r.brokerName == null) return false;
        final selected =
            filters.selectedPartyKey == 'all' ||
            filters.selectedPartyKey == 'broker:${r.brokerId ?? r.brokerName}';
        final search =
            filters.personQuery.isEmpty ||
            r.brokerName!.contains(filters.personQuery);
        return selected && search;
      }).toList();
    } else if (filters.partyType == 'technician') {
      rentals = [];
    } else if (filters.personQuery.isNotEmpty) {
      rentals = rentals.where((r) {
        return r.customerName.contains(filters.personQuery) ||
            (r.brokerName?.contains(filters.personQuery) ?? false);
      }).toList();
    }
    if (filters.startDate != null && filters.endDate != null) {
      rentals = rentals.where((r) => _inDateRange(r.date, filters)).toList();
    }

    return rentals;
  }

  static List<WorkRecord> filteredWorkRecords(
    FinancialSummary report,
    ReportFilterState filters,
  ) {
    var records = report.workRecords;

    if (filters.buildingId != null) {
      records = records
          .where((r) => r.buildingId == filters.buildingId)
          .toList();
    }
    if (filters.apartmentId != null) {
      records = records
          .where((r) => r.apartmentId == filters.apartmentId)
          .toList();
    }
    if (filters.season != 'all') {
      records = records.where((r) => r.season == filters.season).toList();
    }
    if (filters.expenseType != 'all' && filters.expenseType != 'maintenance') {
      records = [];
    }
    if (filters.partyType == 'technician') {
      records = records.where((r) {
        final selected =
            filters.selectedPartyKey == 'all' ||
            filters.selectedPartyKey == 'technician:${r.technicianId}';
        final search =
            filters.personQuery.isEmpty ||
            r.technicianName.contains(filters.personQuery);
        return selected && search;
      }).toList();
    } else if (filters.partyType == 'broker' ||
        filters.partyType == 'customer') {
      records = [];
    } else if (filters.personQuery.isNotEmpty) {
      records = records
          .where((r) => r.technicianName.contains(filters.personQuery))
          .toList();
    }
    if (filters.startDate != null && filters.endDate != null) {
      records = records.where((r) => _inDateRange(r.date, filters)).toList();
    }

    return records;
  }

  static Transaction workRecordTransaction(WorkRecord work) {
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

  static List<ReportMetric> metricsFor(
    ReportDetailKind kind,
    FinancialSummary report,
    ReportFilterState filters,
  ) {
    switch (kind) {
      case ReportDetailKind.apartments:
        return apartmentMetrics(filteredRentals(report, filters));
      case ReportDetailKind.floors:
        return floorMetrics(filteredRentals(report, filters));
      case ReportDetailKind.brokers:
        return brokerMetrics(filteredRentals(report, filters));
      case ReportDetailKind.workers:
        return workerMetrics(filteredWorkRecords(report, filters));
      case ReportDetailKind.expenses:
        return expenseMetrics(filteredTransactions(report, filters));
    }
  }

  static List<ReportMetric> apartmentMetrics(List<RentalRecord> rentals) {
    final metrics = <String, ReportMetric>{};
    for (final rental in rentals) {
      final metric = metrics.putIfAbsent(
        rental.apartmentId,
        () => ReportMetric(
          key: rental.apartmentId,
          label: 'شقة ${rental.apartmentNumber}',
        ),
      );
      _addRental(metric, rental);
    }
    return _sortByRentalValue(metrics.values.toList());
  }

  static List<ReportMetric> floorMetrics(List<RentalRecord> rentals) {
    final metrics = <String, ReportMetric>{};
    for (final rental in rentals) {
      final label = rental.floorNumber == null
          ? 'دور غير محدد'
          : 'الدور ${rental.floorNumber}';
      final metric = metrics.putIfAbsent(
        label,
        () => ReportMetric(key: label, label: label),
      );
      _addRental(metric, rental);
    }
    return _sortByRentalValue(metrics.values.toList());
  }

  static List<ReportMetric> brokerMetrics(List<RentalRecord> rentals) {
    final metrics = <String, ReportMetric>{};
    for (final rental in rentals.where((r) => r.brokerName != null)) {
      final key = rental.brokerId ?? rental.brokerName!;
      final metric = metrics.putIfAbsent(
        key,
        () => ReportMetric(key: key, label: rental.brokerName!),
      );
      _addRental(metric, rental);
    }
    final list = metrics.values.toList();
    list.sort((a, b) => b.commission.compareTo(a.commission));
    return list;
  }

  static List<ReportMetric> workerMetrics(List<WorkRecord> records) {
    final metrics = <String, ReportMetric>{};
    for (final record in records) {
      final metric = metrics.putIfAbsent(
        record.technicianId,
        () => ReportMetric(
          key: record.technicianId,
          label: record.technicianName,
        ),
      );
      metric.count += 1;
      metric.cost += record.cost;
    }
    final list = metrics.values.toList();
    list.sort((a, b) => b.cost.compareTo(a.cost));
    return list;
  }

  static List<ReportMetric> expenseMetrics(List<Transaction> transactions) {
    final metrics = <String, ReportMetric>{};
    for (final transaction in transactions.where((t) => !t.isRevenue)) {
      final key = transaction.expenseType ?? 'other';
      final metric = metrics.putIfAbsent(
        key,
        () => ReportMetric(key: key, label: expenseTypeLabel(key)),
      );
      metric.count += 1;
      metric.cost += transaction.amount;
    }
    final list = metrics.values.toList();
    list.sort((a, b) => b.cost.compareTo(a.cost));
    return list;
  }

  static ReportMetric? topByCount(List<ReportMetric> metrics) {
    if (metrics.isEmpty) return null;
    final list = [...metrics]..sort((a, b) => b.count.compareTo(a.count));
    return list.first;
  }

  static ReportMetric? topByRentalValue(List<ReportMetric> metrics) {
    if (metrics.isEmpty) return null;
    return _sortByRentalValue([...metrics]).first;
  }

  static ReportMetric? lowByRentalValue(List<ReportMetric> metrics) {
    final positiveMetrics = metrics.where((m) => m.rentalValue > 0).toList();
    if (positiveMetrics.isEmpty) return null;
    positiveMetrics.sort((a, b) => a.rentalValue.compareTo(b.rentalValue));
    return positiveMetrics.first;
  }

  static void _addRental(ReportMetric metric, RentalRecord rental) {
    metric.count += 1;
    metric.paidRevenue += rental.paidRevenue;
    metric.rentalValue += rental.rentalValue > 0
        ? rental.rentalValue
        : rental.paidRevenue;
    metric.commission += rental.brokerCommission;
  }

  static List<ReportMetric> _sortByRentalValue(List<ReportMetric> metrics) {
    metrics.sort((a, b) => b.rentalValue.compareTo(a.rentalValue));
    return metrics;
  }

  static bool _matchesParty(
    Transaction transaction,
    ReportFilterState filters,
  ) {
    bool matchesSelected(String type, String? id, String? name) {
      if (filters.selectedPartyKey == 'all') return true;
      return filters.selectedPartyKey == '$type:${id ?? name}';
    }

    bool contains(String? value) {
      return filters.personQuery.isEmpty ||
          (value?.contains(filters.personQuery) ?? false);
    }

    if (filters.partyType == 'customer') {
      return transaction.customerName != null &&
          matchesSelected('customer', null, transaction.customerName) &&
          contains(transaction.customerName);
    }
    if (filters.partyType == 'broker') {
      return transaction.brokerName != null &&
          matchesSelected(
            'broker',
            transaction.brokerId,
            transaction.brokerName,
          ) &&
          contains(transaction.brokerName);
    }
    if (filters.partyType == 'technician') {
      return transaction.technicianName != null &&
          matchesSelected(
            'technician',
            transaction.technicianId,
            transaction.technicianName,
          ) &&
          contains(transaction.technicianName);
    }
    if (filters.personQuery.isEmpty) return true;
    return contains(transaction.customerName) ||
        contains(transaction.brokerName) ||
        contains(transaction.technicianName);
  }

  static bool _inDateRange(DateTime date, ReportFilterState filters) {
    return date.isAfter(filters.startDate!.subtract(const Duration(days: 1))) &&
        date.isBefore(filters.endDate!.add(const Duration(days: 1)));
  }
}
