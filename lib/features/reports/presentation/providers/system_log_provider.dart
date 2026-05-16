import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';

class SystemLogEntry {
  final DateTime date;
  final String title;
  final String description;
  final String type;

  SystemLogEntry({
    required this.date,
    required this.title,
    required this.description,
    required this.type,
  });
}

final systemLogsProvider = FutureProvider<List<SystemLogEntry>>((ref) async {
  final db = ref.watch(databaseProvider);
  final List<SystemLogEntry> logs = [];

  // Fetch recent data from various tables
  // We'll just fetch all or a limited amount and sort in memory
  // For production with massive data, a raw SQL UNION query is better, but this works well for standard usage.

  final expenses = await db.select(db.expenses).get();
  for (var e in expenses) {
    logs.add(SystemLogEntry(
      date: e.createdAt,
      title: 'مصروف جديد',
      description: 'تم تسجيل مصروف (نوع: ${e.expenseType}) بقيمة ${e.amountEgp} ج.م',
      type: 'expense',
    ));
  }

  final summerBookings = await db.select(db.summerBookings).get();
  for (var b in summerBookings) {
    logs.add(SystemLogEntry(
      date: b.createdAt,
      title: 'حجز صيفي جديد',
      description: 'تم حجز شقة للنزيل ${b.guestName} بقيمة ${b.totalPriceEgp} ج.م',
      type: 'summer_booking',
    ));
  }

  final winterContracts = await db.select(db.winterContracts).get();
  for (var c in winterContracts) {
    logs.add(SystemLogEntry(
      date: c.createdAt,
      title: 'عقد شتوي جديد',
      description: 'تم إبرام عقد لـ ${c.studentName} بإيجار شهري ${c.monthlyRentEgp} ج.م',
      type: 'winter_contract',
    ));
  }

  final winterPayments = await db.select(db.winterPayments).get();
  for (var p in winterPayments) {
    logs.add(SystemLogEntry(
      date: p.createdAt,
      title: 'دفعة عقد شتوي',
      description: 'تم تحصيل دفعة إيجار بقيمة ${p.amountEgp} ج.م',
      type: 'payment',
    ));
  }

  final maintenanceReqs = await db.select(db.maintenanceRequests).get();
  for (var m in maintenanceReqs) {
    logs.add(SystemLogEntry(
      date: m.createdAt,
      title: 'طلب صيانة',
      description: 'تم فتح طلب صيانة: ${m.issueDescription}',
      type: 'maintenance',
    ));
    if (m.resolvedAt != null) {
      logs.add(SystemLogEntry(
        date: m.resolvedAt!,
        title: 'إغلاق طلب صيانة',
        description: 'تم إغلاق طلب الصيانة بتكلفة ${m.costEgp} ج.م',
        type: 'maintenance_resolved',
      ));
    }
  }

  final inspections = await db.select(db.apartmentInspections).get();
  for (var i in inspections) {
    logs.add(SystemLogEntry(
      date: i.createdAt,
      title: 'فحص شقة',
      description: 'تم فحص شقة بواسطة ${i.inspectorName}. النظافة: ${i.isClean ? "نظيفة" : "تحتاج نظافة"}',
      type: 'inspection',
    ));
  }

  final cleaningTrans = await db.select(db.cleaningTransactions).get();
  for (var t in cleaningTrans) {
    logs.add(SystemLogEntry(
      date: t.createdAt,
      title: t.transactionType == 'purchase' ? 'شراء منظفات' : 'سحب منظفات',
      description: 'الكمية: ${t.quantity}. الملاحظات: ${t.notes ?? ""}',
      type: 'cleaning',
    ));
  }

  final buildings = await db.select(db.buildings).get();
  for (var b in buildings) {
    logs.add(SystemLogEntry(
      date: b.createdAt,
      title: 'مبنى جديد',
      description: 'تم إضافة المبنى: ${b.name}',
      type: 'building',
    ));
  }

  final apartments = await db.select(db.apartments).get();
  for (var a in apartments) {
    logs.add(SystemLogEntry(
      date: a.createdAt,
      title: 'شقة جديدة',
      description: 'تمت إضافة شقة ${a.apartmentNumber}',
      type: 'apartment',
    ));
  }

  // Sort newest first
  logs.sort((a, b) => b.date.compareTo(a.date));

  return logs;
});
