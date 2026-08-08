import 'dart:async';

import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_settings_provider.dart';
import '../../../../core/database/database.dart';
import '../../../../core/database/tables.dart';
import '../../../../core/utils/season_utils.dart';
import '../../../../core/utils/summer_booking_payment_utils.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';

class FinancialSummary {
  final double totalRevenue;
  final double totalExpenses;
  final double netProfit;
  final List<Transaction> transactions;
  final List<RentalRecord> rentals;
  final List<WorkRecord> workRecords;
  final List<FinancialTransfer> financialTransfers;

  FinancialSummary({
    required this.totalRevenue,
    required this.totalExpenses,
    required this.netProfit,
    required this.transactions,
    List<RentalRecord>? rentals,
    List<WorkRecord>? workRecords,
    List<FinancialTransfer>? financialTransfers,
  }) : rentals = rentals ?? const [],
       workRecords = workRecords ?? const [],
       financialTransfers = financialTransfers ?? const [];
}

class Transaction {
  final DateTime date;
  final String description;
  final double amount;
  final bool isRevenue;
  final String paymentMethod;
  final Map<String, double> paymentBreakdown;
  final Map<String, double> commissionBreakdown;
  final String? buildingId;
  final String? apartmentId;
  final String? buildingName;
  final String? apartmentNumber;
  final int? floorNumber;
  final String? season;
  final String? expenseType;
  final String? customerName;
  final String? brokerId;
  final String? brokerName;
  final String? technicianId;
  final String? technicianName;
  final double rentalValue;
  final double brokerCommission;

  /// False for the continuation slices of a stay that spans several months.
  /// Those slices carry ONLY earned revenue; all of the booking's cash and
  /// broker commission stay on the first slice (the check-in month), so the
  /// treasury/wallet figures are unchanged by the monthly split.
  final bool affectsCash;

  Transaction({
    required this.date,
    required this.description,
    required this.amount,
    required this.isRevenue,
    required this.paymentMethod,
    this.paymentBreakdown = const {},
    this.commissionBreakdown = const {},
    this.buildingId,
    this.apartmentId,
    this.buildingName,
    this.apartmentNumber,
    this.floorNumber,
    this.season,
    this.expenseType,
    this.customerName,
    this.brokerId,
    this.brokerName,
    this.technicianId,
    this.technicianName,
    this.rentalValue = 0,
    this.brokerCommission = 0,
    this.affectsCash = true,
  });
}

/// Splits a summer booking transaction by the calendar months of its nights.
///
/// The input transaction is returned unchanged when all nights are in one
/// month. This keeps the common case identical to the original report data.
List<Transaction> allocateSummerBookingTransactions(
  Transaction bookingTransaction,
  DateTime checkOutDate,
) {
  final monthlySlices = _monthlyRevenueSlices(
    checkInDate: bookingTransaction.date,
    checkOutDate: checkOutDate,
    amountPaidEgp: bookingTransaction.amount,
  );
  if (monthlySlices.length == 1) return [bookingTransaction];

  return [
    for (var index = 0; index < monthlySlices.length; index++)
      _transactionForMonthlySlice(
        bookingTransaction,
        monthlySlices[index],
        isFirstSlice: index == 0,
      ),
  ];
}

class _MonthlyRevenueSlice {
  final DateTime firstNight;
  final double amount;

  const _MonthlyRevenueSlice({required this.firstNight, required this.amount});
}

class _NightGroup {
  final DateTime firstNight;
  int nightCount = 0;

  _NightGroup(this.firstNight);
}

List<_MonthlyRevenueSlice> _monthlyRevenueSlices({
  required DateTime checkInDate,
  required DateTime checkOutDate,
  required double amountPaidEgp,
}) {
  final groups = _groupBookingNightsByMonth(checkInDate, checkOutDate);
  final nights = groups.fold<int>(0, (sum, group) => sum + group.nightCount);
  final paidCents = (amountPaidEgp * 100).round();
  var allocatedCents = 0;
  final slices = <_MonthlyRevenueSlice>[];

  for (var index = 0; index < groups.length; index++) {
    final group = groups[index];
    final sliceCents = index == groups.length - 1
        ? paidCents - allocatedCents
        : _roundDivision(paidCents * group.nightCount, nights);
    allocatedCents += sliceCents;
    slices.add(
      _MonthlyRevenueSlice(
        firstNight: group.firstNight,
        amount: sliceCents / 100,
      ),
    );
  }
  return slices;
}

List<_NightGroup> _groupBookingNightsByMonth(
  DateTime checkInDate,
  DateTime checkOutDate,
) {
  final checkInDay = _dateOnly(checkInDate);
  final checkOutDay = _dateOnly(checkOutDate);
  final nights = math.max(1, checkOutDay.difference(checkInDay).inDays);
  final nightsByMonth = <DateTime, _NightGroup>{};

  for (var index = 0; index < nights; index++) {
    final night = checkInDay.add(Duration(days: index));
    final month = _dateOnly(DateTime(night.year, night.month));
    final group = nightsByMonth.putIfAbsent(month, () => _NightGroup(night));
    group.nightCount++;
  }
  return nightsByMonth.values.toList();
}

int _roundDivision(int numerator, int denominator) {
  final magnitude = numerator.abs();
  final roundedMagnitude = (magnitude + denominator ~/ 2) ~/ denominator;
  return numerator.isNegative ? -roundedMagnitude : roundedMagnitude;
}

Transaction _transactionForMonthlySlice(
  Transaction bookingTransaction,
  _MonthlyRevenueSlice slice, {
  required bool isFirstSlice,
}) {
  return Transaction(
    date: isFirstSlice
        ? bookingTransaction.date
        : _withTimeOfDay(slice.firstNight, bookingTransaction.date),
    description: bookingTransaction.description,
    amount: slice.amount,
    isRevenue: bookingTransaction.isRevenue,
    paymentMethod: bookingTransaction.paymentMethod,
    paymentBreakdown: isFirstSlice
        ? bookingTransaction.paymentBreakdown
        : const {},
    commissionBreakdown: isFirstSlice
        ? bookingTransaction.commissionBreakdown
        : const {},
    buildingId: bookingTransaction.buildingId,
    apartmentId: bookingTransaction.apartmentId,
    buildingName: bookingTransaction.buildingName,
    apartmentNumber: bookingTransaction.apartmentNumber,
    floorNumber: bookingTransaction.floorNumber,
    season: bookingTransaction.season,
    expenseType: bookingTransaction.expenseType,
    customerName: bookingTransaction.customerName,
    brokerId: bookingTransaction.brokerId,
    brokerName: bookingTransaction.brokerName,
    technicianId: bookingTransaction.technicianId,
    technicianName: bookingTransaction.technicianName,
    rentalValue: isFirstSlice ? bookingTransaction.rentalValue : 0,
    brokerCommission: isFirstSlice ? bookingTransaction.brokerCommission : 0,
    affectsCash: isFirstSlice,
  );
}

DateTime _dateOnly(DateTime value) {
  if (value.isUtc) return DateTime.utc(value.year, value.month, value.day);
  return DateTime(value.year, value.month, value.day);
}

DateTime _withTimeOfDay(DateTime date, DateTime timeSource) {
  if (timeSource.isUtc) {
    return DateTime.utc(
      date.year,
      date.month,
      date.day,
      timeSource.hour,
      timeSource.minute,
      timeSource.second,
      timeSource.millisecond,
      timeSource.microsecond,
    );
  }
  return DateTime(
    date.year,
    date.month,
    date.day,
    timeSource.hour,
    timeSource.minute,
    timeSource.second,
    timeSource.millisecond,
    timeSource.microsecond,
  );
}

class RentalRecord {
  final DateTime date;
  final String season;
  final String apartmentId;
  final String apartmentNumber;
  final String? buildingId;
  final String? buildingName;
  final int? floorNumber;
  final String customerName;
  final String? brokerId;
  final String? brokerName;
  final double paidRevenue;
  final double rentalValue;
  final double brokerCommission;

  RentalRecord({
    required this.date,
    required this.season,
    required this.apartmentId,
    required this.apartmentNumber,
    this.buildingId,
    this.buildingName,
    this.floorNumber,
    required this.customerName,
    this.brokerId,
    this.brokerName,
    required this.paidRevenue,
    required this.rentalValue,
    this.brokerCommission = 0,
  });
}

class WorkRecord {
  final DateTime date;
  final String season;
  final String technicianId;
  final String technicianName;
  final String specialty;
  final String? apartmentId;
  final String? apartmentNumber;
  final String? buildingId;
  final String? buildingName;
  final int? floorNumber;
  final String description;
  final String status;
  final double cost;

  WorkRecord({
    required this.date,
    required this.season,
    required this.technicianId,
    required this.technicianName,
    required this.specialty,
    this.apartmentId,
    this.apartmentNumber,
    this.buildingId,
    this.buildingName,
    this.floorNumber,
    required this.description,
    required this.status,
    required this.cost,
  });
}

final financialReportProvider = StreamProvider<FinancialSummary>((ref) {
  final db = ref.watch(databaseProvider);
  late final StreamController<FinancialSummary> controller;
  final subscriptions = <StreamSubscription<dynamic>>[];
  Timer? debounce;

  Future<void> emitReport() async {
    try {
      final summary = await _buildFinancialSummary(db);
      if (!controller.isClosed) {
        controller.add(summary);
      }
    } catch (error, stackTrace) {
      if (!controller.isClosed) {
        controller.addError(error, stackTrace);
      }
    }
  }

  void scheduleEmit() {
    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 80), emitReport);
  }

  controller = StreamController<FinancialSummary>(
    onListen: () {
      subscriptions.add(
        db.select(db.expenses).watch().listen((_) => scheduleEmit()),
      );
      subscriptions.add(
        db.select(db.summerBookings).watch().listen((_) => scheduleEmit()),
      );
      subscriptions.add(
        db.select(db.bookingPayments).watch().listen((_) => scheduleEmit()),
      );
      subscriptions.add(
        db.select(db.winterContracts).watch().listen((_) => scheduleEmit()),
      );
      subscriptions.add(
        db.select(db.winterPayments).watch().listen((_) => scheduleEmit()),
      );
      subscriptions.add(
        db.select(db.buildings).watch().listen((_) => scheduleEmit()),
      );
      subscriptions.add(
        db.select(db.apartments).watch().listen((_) => scheduleEmit()),
      );
      subscriptions.add(
        db.select(db.maintenanceRequests).watch().listen((_) => scheduleEmit()),
      );
      subscriptions.add(
        db.select(db.technicians).watch().listen((_) => scheduleEmit()),
      );
      subscriptions.add(
        db.select(db.userProfiles).watch().listen((_) => scheduleEmit()),
      );
      subscriptions.add(
        db.select(db.financialTransfers).watch().listen((_) => scheduleEmit()),
      );
      scheduleEmit();
    },
    onCancel: () async {
      debounce?.cancel();
      for (final subscription in subscriptions) {
        await subscription.cancel();
      }
    },
  );

  return controller.stream;
});

Future<FinancialSummary> _buildFinancialSummary(AppDatabase db) async {
  // مصروف/تحويل متعلّم عليه pendingDelete = محذوف من وجهة نظر المستخدم؛
  // لازم يخرج من الإجماليات فورًا مش بعد ما المزامنة تلحق تمسحه.
  final expenses =
      await (db.select(db.expenses)..where(
            (t) => t.syncStatus.isNotIn([SyncStatus.pendingDelete.index]),
          ))
          .get();
  final summerBookings =
      await (db.select(db.summerBookings)
            ..where((t) => t.status.isNotIn(['deleted', 'cancelled']))
            ..where(
              (t) => t.syncStatus.isNotIn([SyncStatus.pendingDelete.index]),
            ))
          .get();
  final bookingPayments = await db.select(db.bookingPayments).get();
  final paymentsByBookingId = indexActiveBookingPayments(bookingPayments);
  final buildings = await (db.select(
    db.buildings,
  )..where((t) => t.id.isNotValue(kSettingsBuildingId))).get();
  final apartments = await db.select(db.apartments).get();
  final winterContracts = await db.select(db.winterContracts).get();
  final winterPayments =
      await (db.select(db.winterPayments)..where(
            (t) => t.syncStatus.isNotIn([SyncStatus.pendingDelete.index]),
          ))
          .get();
  final technicians = await db.select(db.technicians).get();
  final maintenanceRequests = await db.select(db.maintenanceRequests).get();
  final users = await db.select(db.userProfiles).get();
  final financialTransfers =
      await (db.select(db.financialTransfers)..where(
            (t) => t.syncStatus.isNotIn([SyncStatus.pendingDelete.index]),
          ))
          .get();

  final buildingNameById = {for (final b in buildings) b.id: b.name};
  final apartmentById = {for (final a in apartments) a.id: a};
  final apartmentNumberById = {
    for (final a in apartments) a.id: a.apartmentNumber,
  };
  final floorByApartmentId = {for (final a in apartments) a.id: a.floorNumber};
  final apartmentToBuildingId = {
    for (final a in apartments) a.id: a.buildingId,
  };
  final technicianById = {for (final t in technicians) t.id: t};
  final brokerNameById = {
    for (final user in users.where((user) => user.role == 'broker'))
      user.id: user.fullName?.isNotEmpty == true ? user.fullName! : user.email,
  };
  final contractById = {
    for (final contract in winterContracts) contract.id: contract,
  };
  final paidByContractId = <String, double>{};
  for (final payment in winterPayments) {
    paidByContractId[payment.contractId] =
        (paidByContractId[payment.contractId] ?? 0) + payment.amountEgp;
  }

  double totalRevenue = 0;
  double totalExpenses = 0;
  final transactions = <Transaction>[];
  final rentals = <RentalRecord>[];
  final workRecords = <WorkRecord>[];

  ({String? id, String? name}) technicianForExpense(Expense expense) {
    if (_normalizeExpenseType(expense.expenseType) != 'maintenance') {
      return (id: null, name: null);
    }

    final description = expense.description ?? '';
    for (final technician in technicians) {
      if (description.contains(technician.name)) {
        return (id: technician.id, name: technician.name);
      }
    }

    final actualAmount = expense.amountEgp - expense.discountEgp;
    for (final request in maintenanceRequests) {
      if (request.technicianId == null || request.costEgp <= 0) continue;
      final sameApartment = request.apartmentId == expense.apartmentId;
      final sameAmount = (request.costEgp - actualAmount).abs() < 0.01;
      final sameDescription =
          description.contains(request.issueDescription) ||
          request.issueDescription.contains(
            description.replaceFirst('صيانة:', '').trim(),
          );
      if (sameApartment && sameAmount && sameDescription) {
        final technician = technicianById[request.technicianId];
        return (id: request.technicianId, name: technician?.name);
      }
    }

    return (id: null, name: null);
  }

  for (final request in maintenanceRequests) {
    if (request.technicianId == null) continue;
    final technician = technicianById[request.technicianId];
    final apartment = apartmentById[request.apartmentId];
    final buildingId = apartment?.buildingId;
    final date = request.resolvedAt ?? request.createdAt;

    workRecords.add(
      WorkRecord(
        date: date,
        season: seasonKeyForDate(date),
        technicianId: request.technicianId!,
        technicianName: technician?.name ?? 'عامل غير معروف',
        specialty: technician?.specialty ?? '',
        apartmentId: request.apartmentId,
        apartmentNumber: apartment?.apartmentNumber,
        buildingId: buildingId,
        buildingName: buildingId == null ? null : buildingNameById[buildingId],
        floorNumber: apartment?.floorNumber,
        description: request.issueDescription,
        status: request.status,
        cost: request.costEgp,
      ),
    );
  }

  for (final expense in expenses) {
    final actualAmount = expense.amountEgp - expense.discountEgp;
    totalExpenses += actualAmount;
    final apartment = expense.apartmentId == null
        ? null
        : apartmentById[expense.apartmentId];
    final buildingId = expense.buildingId ?? apartment?.buildingId;
    final expenseType = _normalizeExpenseType(expense.expenseType);
    final technician = technicianForExpense(expense);

    transactions.add(
      Transaction(
        date: expense.expenseDate,
        description:
            'مصروف: ${expenseTypeLabel(expenseType)}${expense.description != null && expense.description!.isNotEmpty ? ' - ${expense.description}' : ''}',
        amount: actualAmount,
        isRevenue: false,
        paymentMethod: expense.paymentMethod,
        buildingId: buildingId,
        apartmentId: expense.apartmentId,
        buildingName: buildingId == null ? null : buildingNameById[buildingId],
        apartmentNumber: expense.apartmentId == null
            ? null
            : apartmentNumberById[expense.apartmentId],
        floorNumber: expense.apartmentId == null
            ? null
            : floorByApartmentId[expense.apartmentId],
        season: normalizeStoredSeason(expense.season, expense.expenseDate),
        expenseType: expenseType,
        technicianId: technician.id,
        technicianName: technician.name,
      ),
    );
  }

  for (final booking in summerBookings) {
    totalRevenue += booking.amountPaidEgp;
    final apartment = apartmentById[booking.apartmentId];
    final buildingId = apartmentToBuildingId[booking.apartmentId];
    final brokerName = booking.brokerName?.isNotEmpty == true
        ? booking.brokerName
        : booking.brokerId == null
        ? null
        : brokerNameById[booking.brokerId];
    final brokerCommission = _bookingCommission(booking);
    final paymentBreakdown = summerBookingPaymentBreakdown(
      booking,
      paymentsByBookingId[booking.id] ?? const <BookingPayment>[],
    );

    final bookingTransaction = Transaction(
      date: booking.checkInDate,
      description: 'حجز صيفي: ${booking.guestName}',
      amount: booking.amountPaidEgp,
      isRevenue: true,
      paymentMethod: booking.paymentMethod,
      paymentBreakdown: paymentBreakdown,
      commissionBreakdown: summerBookingCommissionDeductions(
        booking,
        brokerCommission,
      ),
      buildingId: buildingId,
      apartmentId: booking.apartmentId,
      buildingName: buildingId == null ? null : buildingNameById[buildingId],
      apartmentNumber: apartmentNumberById[booking.apartmentId],
      floorNumber: apartment?.floorNumber,
      season: seasonKeyForDate(booking.checkInDate),
      customerName: booking.guestName,
      brokerId: booking.brokerId,
      brokerName: brokerName,
      rentalValue: booking.totalPriceEgp,
      brokerCommission: brokerCommission,
      affectsCash: true,
    );
    transactions.addAll(
      allocateSummerBookingTransactions(
        bookingTransaction,
        booking.checkOutDate,
      ),
    );

    rentals.add(
      RentalRecord(
        date: booking.checkInDate,
        season: seasonKeyForDate(booking.checkInDate),
        apartmentId: booking.apartmentId,
        apartmentNumber:
            apartmentNumberById[booking.apartmentId] ?? booking.apartmentId,
        buildingId: buildingId,
        buildingName: buildingId == null ? null : buildingNameById[buildingId],
        floorNumber: apartment?.floorNumber,
        customerName: booking.guestName,
        brokerId: booking.brokerId,
        brokerName: brokerName,
        paidRevenue: booking.amountPaidEgp,
        rentalValue: booking.totalPriceEgp,
        brokerCommission: brokerCommission,
      ),
    );
  }

  for (final payment in winterPayments) {
    final contract = contractById[payment.contractId];
    final apartmentId = contract?.apartmentId;
    final apartment = apartmentId == null ? null : apartmentById[apartmentId];
    final buildingId = apartmentId == null
        ? null
        : apartmentToBuildingId[apartmentId];
    totalRevenue += payment.amountEgp;

    transactions.add(
      Transaction(
        date: payment.paymentDate,
        description: payment.paymentMethod == 'deposit_deduction'
            ? 'مصادرة تأمين${contract == null ? '' : ': ${contract.studentName}'}'
            : 'دفعة شتوية${contract == null ? '' : ': ${contract.studentName}'}',
        amount: payment.amountEgp,
        isRevenue: true,
        paymentMethod: payment.paymentMethod,
        buildingId: buildingId,
        apartmentId: apartmentId,
        buildingName: buildingId == null ? null : buildingNameById[buildingId],
        apartmentNumber: apartmentId == null
            ? null
            : apartmentNumberById[apartmentId],
        floorNumber: apartment?.floorNumber,
        season: seasonKeyForDate(payment.paymentDate),
        customerName: contract?.studentName,
      ),
    );
  }

  for (final contract in winterContracts) {
    final apartment = apartmentById[contract.apartmentId];
    final buildingId = apartmentToBuildingId[contract.apartmentId];
    rentals.add(
      RentalRecord(
        date: contract.startDate,
        season: seasonKeyForDate(contract.startDate),
        apartmentId: contract.apartmentId,
        apartmentNumber:
            apartmentNumberById[contract.apartmentId] ?? contract.apartmentId,
        buildingId: buildingId,
        buildingName: buildingId == null ? null : buildingNameById[buildingId],
        floorNumber: apartment?.floorNumber,
        customerName: contract.studentName,
        paidRevenue: paidByContractId[contract.id] ?? 0,
        rentalValue:
            contract.monthlyRentEgp *
            _contractMonths(contract.startDate, contract.endDate),
      ),
    );
  }

  transactions.sort((a, b) => b.date.compareTo(a.date));
  rentals.sort((a, b) => b.date.compareTo(a.date));
  workRecords.sort((a, b) => b.date.compareTo(a.date));

  return FinancialSummary(
    totalRevenue: totalRevenue,
    totalExpenses: totalExpenses,
    netProfit: totalRevenue - totalExpenses,
    transactions: transactions,
    rentals: rentals,
    workRecords: workRecords,
    financialTransfers: financialTransfers,
  );
}

String expenseTypeLabel(String type) {
  switch (_normalizeExpenseType(type)) {
    case 'maintenance':
      return 'صيانة / إصلاحات';
    case 'building_rent':
      return 'إيجار المبنى';
    case 'water':
      return 'مياه';
    case 'electricity':
      return 'كهرباء';
    case 'gas':
      return 'غاز (أنبوبة)';
    case 'cleaning':
      return 'نظافة';
    default:
      return 'أخرى';
  }
}

String _normalizeExpenseType(String type) {
  const knownTypes = {
    'maintenance',
    'building_rent',
    'water',
    'electricity',
    'gas',
    'cleaning',
    'other',
  };
  return knownTypes.contains(type) ? type : 'other';
}

double _bookingCommission(SummerBooking booking) {
  if (booking.brokerCommissionType == 'fixed') {
    return booking.brokerCommissionFixedEgp;
  }
  if (booking.brokerCommissionType == 'percentage') {
    return booking.totalPriceEgp * booking.brokerCommissionPercentage / 100;
  }
  // 'none' => the broker took no commission at all.
  return 0;
}

double _contractMonths(DateTime start, DateTime end) {
  final days = end.difference(start).inDays + 1;
  if (days <= 0) return 0;
  return days / 30;
}
