import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/tables.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';

class CustomerModel {
  final String id;
  final String name;
  final String? phone;
  final String? nationalId;
  final Set<String> types;
  final DateTime date;
  final List<CustomerActivity> activities;
  final bool isCurrentlyStaying;

  CustomerModel({
    required this.id,
    required this.name,
    this.phone,
    this.nationalId,
    required this.types,
    required this.date,
    required this.activities,
    required this.isCurrentlyStaying,
  });

  bool get hasSummer => types.contains('summer');
  bool get hasWinter => types.contains('winter');
  bool get isMixed => hasSummer && hasWinter;
  String get type => isMixed
      ? 'all'
      : hasSummer
      ? 'summer'
      : 'winter';
}

class CustomerActivity {
  final String id;
  final String source; // summer, winter, roommate
  final String title;
  final DateTime date;
  final String route;

  CustomerActivity({
    required this.id,
    required this.source,
    required this.title,
    required this.date,
    required this.route,
  });
}

class _CustomerAccumulator {
  String id;
  String name;
  String? phone;
  String? nationalId;
  DateTime date;
  final Set<String> types = {};
  final List<CustomerActivity> activities = [];
  bool isCurrentlyStaying = false;

  _CustomerAccumulator({
    required this.id,
    required this.name,
    this.phone,
    this.nationalId,
    required this.date,
  });

  CustomerModel toModel() => CustomerModel(
    id: id,
    name: name,
    phone: phone,
    nationalId: nationalId,
    types: types,
    date: date,
    activities: activities..sort((a, b) => b.date.compareTo(a.date)),
    isCurrentlyStaying: isCurrentlyStaying,
  );
}

final customersProvider = StreamProvider<List<CustomerModel>>((ref) {
  final db = ref.watch(databaseProvider);
  final summerStream = db.select(db.summerBookings).watch();

  return summerStream.asyncMap((summerBookings) async {
    final winterContracts = await db.select(db.winterContracts).get();
    final customers = <String, _CustomerAccumulator>{};

    String keyFor({String? nationalId, String? phone, required String name}) {
      final cleanNationalId = nationalId?.trim();
      if (cleanNationalId != null && cleanNationalId.isNotEmpty) {
        return 'id:$cleanNationalId';
      }
      final cleanPhone = phone?.trim();
      if (cleanPhone != null && cleanPhone.isNotEmpty) {
        return 'phone:$cleanPhone';
      }
      return 'name:${name.trim().toLowerCase()}';
    }

    void addCustomer({
      required String rawId,
      required String name,
      String? phone,
      String? nationalId,
      required String type,
      required DateTime date,
      required CustomerActivity activity,
      bool isCurrentlyStaying = false,
    }) {
      final key = keyFor(nationalId: nationalId, phone: phone, name: name);
      final existing = customers[key];
      if (existing == null) {
        customers[key] =
            _CustomerAccumulator(
                id: rawId,
                name: name,
                phone: phone,
                nationalId: nationalId,
                date: date,
              )
              ..types.add(type)
              ..activities.add(activity)
              ..isCurrentlyStaying = isCurrentlyStaying;
        return;
      }
      existing.types.add(type);
      existing.activities.add(activity);
      existing.isCurrentlyStaying =
          existing.isCurrentlyStaying || isCurrentlyStaying;
      if ((existing.phone ?? '').isEmpty && (phone ?? '').isNotEmpty) {
        existing.phone = phone;
      }
      if ((existing.nationalId ?? '').isEmpty &&
          (nationalId ?? '').isNotEmpty) {
        existing.nationalId = nationalId;
      }
      if (date.isAfter(existing.date)) existing.date = date;
    }

    final activeSummerBookings = summerBookings.where(
      (booking) =>
          booking.status != 'deleted' &&
          booking.syncStatus != SyncStatus.pendingDelete,
    );

    for (final booking in activeSummerBookings) {
      final now = DateTime.now();
      final checkout = booking.earlyCheckoutDate ?? booking.checkOutDate;
      final isStaying =
          booking.status != 'checked_out' &&
          booking.status != 'cancelled' &&
          !now.isBefore(booking.checkInDate) &&
          now.isBefore(checkout);
      addCustomer(
        rawId: booking.id,
        name: booking.guestName,
        phone: booking.guestPhone,
        nationalId: booking.nationalId,
        type: 'summer',
        date: booking.checkInDate,
        activity: CustomerActivity(
          id: booking.id,
          source: 'summer',
          title: 'حجز صيفي',
          date: booking.checkInDate,
          route: '/summer_bookings/details/${booking.id}',
        ),
        isCurrentlyStaying: isStaying,
      );
    }

    for (final contract in winterContracts) {
      final now = DateTime.now();
      final isStaying =
          contract.isActive &&
          !now.isBefore(contract.startDate) &&
          now.isBefore(contract.endDate);
      addCustomer(
        rawId: contract.id,
        name: contract.studentName,
        phone: contract.parentPhone,
        nationalId: contract.nationalId,
        type: 'winter',
        date: contract.startDate,
        activity: CustomerActivity(
          id: contract.id,
          source: 'winter',
          title: contract.contractType == 'family' ? 'عقد عائلي' : 'عقد طالب',
          date: contract.startDate,
          route: '/winter_contracts/details/${contract.id}',
        ),
        isCurrentlyStaying: isStaying,
      );

      final roommatesJson = contract.roommates;
      if (roommatesJson == null || roommatesJson.trim().isEmpty) continue;
      try {
        final roommates = jsonDecode(roommatesJson) as List<dynamic>;
        for (final roommate in roommates) {
          if (roommate is! Map) continue;
          final roommateName = roommate['name']?.toString().trim() ?? '';
          if (roommateName.isEmpty) continue;
          addCustomer(
            rawId: '${contract.id}_$roommateName',
            name: roommateName,
            nationalId: roommate['nationalId']?.toString(),
            type: 'winter',
            date: contract.startDate,
            activity: CustomerActivity(
              id: contract.id,
              source: 'roommate',
              title: 'زميل سكن في عقد شتوي',
              date: contract.startDate,
              route: '/winter_contracts/details/${contract.id}',
            ),
            isCurrentlyStaying: isStaying,
          );
        }
      } catch (_) {
        // Ignore malformed legacy roommate data.
      }
    }

    final result = customers.values.map((item) => item.toModel()).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return result;
  });
});
