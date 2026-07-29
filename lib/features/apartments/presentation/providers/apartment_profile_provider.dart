import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database.dart';
import '../../../../core/database/tables.dart';
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
    final today = DateTime(now.year, now.month, now.day);
    final hasActiveBooking = bookings.any((b) {
      final checkInDay = DateTime(
        b.checkInDate.year,
        b.checkInDate.month,
        b.checkInDate.day,
      );
      return !checkInDay.isAfter(today) &&
          b.status != 'cancelled' &&
          b.status != 'checked_out' &&
          b.status != 'deleted' &&
          b.syncStatus != SyncStatus.pendingDelete;
    });
    final hasActiveContract = contracts.any(
      (c) => c.isActive && c.startDate.isBefore(now) && c.endDate.isAfter(now),
    );
    return hasActiveBooking || hasActiveContract;
  }

  bool get isCheckingOutToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return bookings.any((b) {
      final checkInDay = DateTime(
        b.checkInDate.year,
        b.checkInDate.month,
        b.checkInDate.day,
      );
      final end = b.earlyCheckoutDate ?? b.checkOutDate;
      return !checkInDay.isAfter(today) &&
          b.status != 'cancelled' &&
          b.status != 'checked_out' &&
          b.status != 'deleted' &&
          b.syncStatus != SyncStatus.pendingDelete &&
          !DateTime(end.year, end.month, end.day).isAfter(today);
    });
  }

  double get totalRevenue {
    return bookings.fold(0.0, (sum, b) => sum + b.totalPriceEgp) +
        contracts.fold(
          0.0,
          (sum, c) => sum + c.monthlyRentEgp,
        ); // Approximate, should use payments
  }

  double get totalExpenses {
    return expenses.fold(0.0, (sum, e) => sum + e.amountEgp);
  }
}

final apartmentProfileProvider =
    StreamProvider.family<ApartmentProfileData, String>((ref, id) {
      final db = ref.watch(databaseProvider);
      late final StreamController<ApartmentProfileData> controller;
      final subscriptions = <StreamSubscription<dynamic>>[];
      Timer? debounce;

      Future<void> emitProfile() async {
        try {
          final profile = await _buildApartmentProfile(db, id);
          if (!controller.isClosed) {
            controller.add(profile);
          }
        } catch (error, stackTrace) {
          if (!controller.isClosed) {
            controller.addError(error, stackTrace);
          }
        }
      }

      void scheduleEmit() {
        debounce?.cancel();
        debounce = Timer(const Duration(milliseconds: 80), emitProfile);
      }

      controller = StreamController<ApartmentProfileData>(
        onListen: () {
          subscriptions.add(
            db.select(db.apartments).watch().listen((_) => scheduleEmit()),
          );
          subscriptions.add(
            db.select(db.buildings).watch().listen((_) => scheduleEmit()),
          );
          subscriptions.add(
            db.select(db.summerBookings).watch().listen((_) => scheduleEmit()),
          );
          subscriptions.add(
            db.select(db.winterContracts).watch().listen((_) => scheduleEmit()),
          );
          subscriptions.add(
            db.select(db.expenses).watch().listen((_) => scheduleEmit()),
          );
          unawaited(emitProfile());
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

Future<ApartmentProfileData> _buildApartmentProfile(
  AppDatabase db,
  String id,
) async {
  final apt = await (db.select(
    db.apartments,
  )..where((t) => t.id.equals(id))).getSingle();

  Building? building;
  try {
    building = await (db.select(
      db.buildings,
    )..where((t) => t.id.equals(apt.buildingId))).getSingle();
  } catch (_) {}

  final bookings =
      await (db.select(db.summerBookings)
            ..where((t) => t.apartmentId.equals(id))
            ..where((t) => t.status.isNotIn(['deleted']))
            ..where(
              (t) => t.syncStatus.isNotIn([SyncStatus.pendingDelete.index]),
            ))
          .get();
  final contracts = await (db.select(
    db.winterContracts,
  )..where((t) => t.apartmentId.equals(id))).get();
  final expenses = await (db.select(
    db.expenses,
  )..where((t) => t.apartmentId.equals(id))).get();

  return ApartmentProfileData(
    apartment: apt,
    building: building,
    bookings: bookings,
    contracts: contracts,
    expenses: expenses,
  );
}
