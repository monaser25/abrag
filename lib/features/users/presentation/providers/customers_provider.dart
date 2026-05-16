import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';

class CustomerModel {
  final String id;
  final String name;
  final String? phone;
  final String? nationalId;
  final String type; // 'summer' or 'winter'
  final DateTime date;

  CustomerModel({
    required this.id,
    required this.name,
    this.phone,
    this.nationalId,
    required this.type,
    required this.date,
  });
}

final customersProvider = StreamProvider<List<CustomerModel>>((ref) {
  final db = ref.watch(databaseProvider);

  // Combine summer guests and winter students
  final summerStream = db.select(db.summerBookings).watch();

  return summerStream.asyncMap((summerBookings) async {
    final winterContracts = await db.select(db.winterContracts).get();
    
    final customers = <CustomerModel>[];

    for (var b in summerBookings) {
      customers.add(CustomerModel(
        id: b.id,
        name: b.guestName,
        phone: b.guestPhone,
        nationalId: b.nationalId,
        type: 'summer',
        date: b.checkInDate,
      ));
    }

    for (var c in winterContracts) {
      customers.add(CustomerModel(
        id: c.id,
        name: c.studentName,
        phone: c.parentPhone,
        nationalId: c.nationalId,
        type: 'winter',
        date: c.startDate,
      ));
    }

    // Sort by most recent
    customers.sort((a, b) => b.date.compareTo(a.date));

    // Deduplicate by name and phone if needed, but for now we list all their transactions 
    // or we group by them. Let's group them to have unique customers based on phone or name.
    final Map<String, CustomerModel> uniqueCustomers = {};
    for (var c in customers) {
      final key = c.phone?.isNotEmpty == true ? c.phone! : c.name;
      if (!uniqueCustomers.containsKey(key)) {
        uniqueCustomers[key] = c;
      }
    }

    return uniqueCustomers.values.toList();
  });
});
