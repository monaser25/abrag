import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';

class ApartmentProfileData {
  final Apartment apartment;
  final Building? building;
  final List<SummerBooking> bookings;
  final List<WinterContract> contracts;
  final List<Expense> expenses;

  ApartmentProfileData({
    required this.apartment,
    this.building,
    required this.bookings,
    required this.contracts,
    required this.expenses,
  });

  bool get isOccupied {
    final now = DateTime.now();
    final hasActiveBooking = bookings.any((b) => b.checkInDate.isBefore(now) && b.checkOutDate.isAfter(now) && b.status != 'cancelled');
    final hasActiveContract = contracts.any((c) => c.isActive && c.startDate.isBefore(now) && c.endDate.isAfter(now));
    return hasActiveBooking || hasActiveContract;
  }

  double get totalRevenue {
    return bookings.fold(0.0, (sum, b) => sum + b.totalPriceEgp) + 
           contracts.fold(0.0, (sum, c) => sum + c.monthlyRentEgp); // Approximate, should use payments
  }

  double get totalExpenses {
    return expenses.fold(0.0, (sum, e) => sum + e.amountEgp);
  }
}

final apartmentProfileProvider = StreamProvider.family<ApartmentProfileData, String>((ref, id) {
  final db = ref.watch(databaseProvider);

  return Stream.periodic(const Duration(milliseconds: 500)).asyncMap((_) async {
    final apt = await (db.select(db.apartments)..where((t) => t.id.equals(id))).getSingle();
    
    Building? building;
    try {
      building = await (db.select(db.buildings)..where((t) => t.id.equals(apt.buildingId))).getSingle();
    } catch (_) {}

    final bookings = await (db.select(db.summerBookings)..where((t) => t.apartmentId.equals(id))).get();
    final contracts = await (db.select(db.winterContracts)..where((t) => t.apartmentId.equals(id))).get();
    final expenses = await (db.select(db.expenses)..where((t) => t.apartmentId.equals(id))).get();

    return ApartmentProfileData(
      apartment: apt,
      building: building,
      bookings: bookings,
      contracts: contracts,
      expenses: expenses,
    );
  });
});
