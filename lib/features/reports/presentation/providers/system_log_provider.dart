import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';

import '../../../dashboard/presentation/providers/database_provider.dart';

class SystemLogEntry {
  final DateTime date;
  final String title;
  final String description;
  final String type;
  final String? route;
  final String actorName;
  final String action;
  final String? oldValuesJson;
  final String? newValuesJson;

  SystemLogEntry({
    required this.date,
    required this.title,
    required this.description,
    required this.type,
    this.route,
    required this.actorName,
    required this.action,
    this.oldValuesJson,
    this.newValuesJson,
  });
}

final systemLogsProvider = FutureProvider<List<SystemLogEntry>>((ref) async {
  final db = ref.watch(databaseProvider);
  final auditLogs = await (db.select(
    db.auditLogs,
  )..orderBy([(table) => OrderingTerm.desc(table.createdAt)])).get();

  final logs = auditLogs
      .map(
        (log) => SystemLogEntry(
          date: log.createdAt,
          title: log.title,
          description: log.description,
          type: log.entityType,
          route: log.route,
          actorName: log.actorName,
          action: log.action,
          oldValuesJson: log.oldValuesJson,
          newValuesJson: log.newValuesJson,
        ),
      )
      .toList();

  if (logs.isNotEmpty) return logs;

  // Fallback for old data before audit logging existed.
  final fallback = <SystemLogEntry>[];
  final summerBookings = await db.select(db.summerBookings).get();
  for (final booking in summerBookings) {
    fallback.add(
      SystemLogEntry(
        date: booking.createdAt,
        title: 'حجز صيفي',
        description: 'حجز باسم ${booking.guestName}',
        type: 'summer_booking',
        route: '/summer_bookings/details/${booking.id}',
        actorName: 'النظام',
        action: 'legacy',
      ),
    );
  }
  final contracts = await db.select(db.winterContracts).get();
  for (final contract in contracts) {
    fallback.add(
      SystemLogEntry(
        date: contract.createdAt,
        title: 'عقد شتوي',
        description: 'عقد باسم ${contract.studentName}',
        type: 'winter_contract',
        route: '/winter_contracts/details/${contract.id}',
        actorName: 'النظام',
        action: 'legacy',
      ),
    );
  }
  final expenses = await db.select(db.expenses).get();
  for (final expense in expenses) {
    fallback.add(
      SystemLogEntry(
        date: expense.createdAt,
        title: 'مصروف',
        description: 'مصروف ${expense.expenseType} بقيمة ${expense.amountEgp} ج.م',
        type: 'expense',
        route: '/expenses',
        actorName: 'النظام',
        action: 'legacy',
      ),
    );
  }
  final transfers = await db.select(db.financialTransfers).get();
  for (final transfer in transfers) {
    fallback.add(
      SystemLogEntry(
        date: transfer.createdAt,
        title: transfer.transferType == 'cash_deposit'
            ? 'توريد نقدية'
            : 'تحويل داخلي',
        description: 'عملية مالية بقيمة ${transfer.amountEgp} ج.م',
        type: 'financial_transfer',
        route: '/financial_transfers',
        actorName: 'النظام',
        action: 'legacy',
      ),
    );
  }
  final apartments = await db.select(db.apartments).get();
  for (final apartment in apartments) {
    fallback.add(
      SystemLogEntry(
        date: apartment.createdAt,
        title: 'شقة',
        description: 'شقة ${apartment.apartmentNumber}',
        type: 'apartment',
        route: '/apartments/profile/${apartment.id}',
        actorName: 'النظام',
        action: 'legacy',
      ),
    );
  }
  fallback.sort((a, b) => b.date.compareTo(a.date));
  return fallback;
});
