import 'dart:async';

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
  });
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
  final expenses = await db.select(db.expenses).get();
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
  final winterPayments = await db.select(db.winterPayments).get();
  final technicians = await db.select(db.technicians).get();
  final maintenanceRequests = await db.select(db.maintenanceRequests).get();
  final users = await db.select(db.userProfiles).get();
  final financialTransfers = await db.select(db.financialTransfers).get();

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

    transactions.add(
      Transaction(
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
