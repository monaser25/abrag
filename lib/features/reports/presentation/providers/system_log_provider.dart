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

  final auditedEntities = auditLogs
      .where((log) => log.entityId != null)
      .map((log) => '${log.entityType}:${log.entityId}')
      .toSet();

  bool hasAudit(String type, String id) => auditedEntities.contains('$type:$id');

  // Backfill old or imported data that existed before audit logging was added.
  final fallback = <SystemLogEntry>[];
  final summerBookings = await db.select(db.summerBookings).get();
  for (final booking in summerBookings) {
    if (hasAudit('summer_booking', booking.id)) continue;
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
    if (hasAudit('winter_contract', contract.id)) continue;
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
    if (hasAudit('expense', expense.id)) continue;
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
    if (hasAudit('financial_transfer', transfer.id)) continue;
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
    if (apartment.apartmentNumber.trim().isEmpty ||
        hasAudit('apartment', apartment.id)) {
      continue;
    }
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
  final maintenanceRequests = await db.select(db.maintenanceRequests).get();
  for (final request in maintenanceRequests) {
    if (hasAudit('maintenance', request.id)) continue;
    fallback.add(
      SystemLogEntry(
        date: request.createdAt,
        title: 'طلب صيانة',
        description: request.issueDescription,
        type: 'maintenance',
        route: '/maintenance',
        actorName: 'النظام',
        action: 'legacy',
      ),
    );
  }
  final inspections = await db.select(db.apartmentInspections).get();
  for (final inspection in inspections) {
    if (hasAudit('inspection', inspection.id)) continue;
    fallback.add(
      SystemLogEntry(
        date: inspection.createdAt,
        title: 'فحص شقة',
        description: inspection.hasDamages
            ? 'فحص شقة به تلفيات'
            : 'فحص شقة بدون تلفيات',
        type: 'inspection',
        route: '/inspections',
        actorName: 'النظام',
        action: 'legacy',
      ),
    );
  }
  final payments = await db.select(db.winterPayments).get();
  for (final payment in payments) {
    if (hasAudit('payment', payment.id)) continue;
    fallback.add(
      SystemLogEntry(
        date: payment.createdAt,
        title: 'دفعة شتاء',
        description: 'دفعة بقيمة ${payment.amountEgp} ج.م',
        type: 'payment',
        route: '/winter_contracts/payments/${payment.contractId}',
        actorName: 'النظام',
        action: 'legacy',
      ),
    );
  }
  final meterReadings = await db.select(db.meterReadings).get();
  for (final reading in meterReadings) {
    if (hasAudit('meter_reading', reading.id)) continue;
    fallback.add(
      SystemLogEntry(
        date: reading.createdAt,
        title: 'قراءة عداد',
        description: 'قراءة عداد بقيمة ${reading.amountEgp} ج.م',
        type: 'meter_reading',
        route: null,
        actorName: 'النظام',
        action: 'legacy',
      ),
    );
  }
  final supplies = await db.select(db.cleaningSupplies).get();
  for (final supply in supplies) {
    if (hasAudit('cleaning_supply', supply.id)) continue;
    fallback.add(
      SystemLogEntry(
        date: supply.createdAt,
        title: 'أداة نظافة',
        description: '${supply.name} - الرصيد ${supply.stockQuantity} ${supply.unit}',
        type: 'cleaning_supply',
        route: '/cleaning_supplies',
        actorName: 'النظام',
        action: 'legacy',
      ),
    );
  }
  final cleaningTransactions = await db.select(db.cleaningTransactions).get();
  for (final transaction in cleaningTransactions) {
    if (hasAudit('cleaning_transaction', transaction.id)) continue;
    fallback.add(
      SystemLogEntry(
        date: transaction.createdAt,
        title: transaction.transactionType == 'purchase'
            ? 'شراء أدوات نظافة'
            : 'استهلاك أدوات نظافة',
        description:
            'كمية ${transaction.quantity} بتكلفة ${transaction.costEgp} ج.م',
        type: 'cleaning_transaction',
        route: '/cleaning_supplies',
        actorName: 'النظام',
        action: 'legacy',
      ),
    );
  }
  final users = await db.select(db.userProfiles).get();
  for (final user in users) {
    if (hasAudit('user', user.id)) continue;
    fallback.add(
      SystemLogEntry(
        date: user.createdAt,
        title: 'مستخدم',
        description: user.fullName ?? user.email,
        type: 'user',
        route: '/settings/users',
        actorName: 'النظام',
        action: 'legacy',
      ),
    );
  }
  final allLogs = [...logs, ...fallback]
    ..sort((a, b) => b.date.compareTo(a.date));
  return allLogs;
});
