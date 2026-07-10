import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database.dart';
import '../../../../core/database/tables.dart';
import '../../../bookings/presentation/providers/bookings_provider.dart';
import '../../../buildings/presentation/providers/buildings_controller.dart';
import '../../../contracts/presentation/providers/contracts_provider.dart';
import 'apartments_controller.dart';

class ApartmentStatus {
  final Apartment apartment;
  final String buildingId;
  final String buildingName;
  final bool isOccupied;
  final bool needsCleaning;
  final bool isCheckingOutToday;

  const ApartmentStatus({
    required this.apartment,
    required this.buildingId,
    required this.buildingName,
    required this.isOccupied,
    required this.needsCleaning,
    required this.isCheckingOutToday,
  });
}

final apartmentsWithStatusProvider =
    Provider<AsyncValue<List<ApartmentStatus>>>((ref) {
      final apartmentsAsync = ref.watch(apartmentsProvider);
      final buildingsAsync = ref.watch(buildingsProvider);
      final bookingsAsync = ref.watch(allSummerBookingsProvider);
      final contractsAsync = ref.watch(allWinterContractsProvider);

      if (apartmentsAsync is AsyncLoading ||
          buildingsAsync is AsyncLoading ||
          bookingsAsync is AsyncLoading ||
          contractsAsync is AsyncLoading) {
        return const AsyncValue.loading();
      }

      if (apartmentsAsync.hasError) {
        return AsyncValue.error(
          apartmentsAsync.error!,
          apartmentsAsync.stackTrace ?? StackTrace.current,
        );
      }
      if (buildingsAsync.hasError) {
        return AsyncValue.error(
          buildingsAsync.error!,
          buildingsAsync.stackTrace ?? StackTrace.current,
        );
      }
      if (bookingsAsync.hasError) {
        return AsyncValue.error(
          bookingsAsync.error!,
          bookingsAsync.stackTrace ?? StackTrace.current,
        );
      }
      if (contractsAsync.hasError) {
        return AsyncValue.error(
          contractsAsync.error!,
          contractsAsync.stackTrace ?? StackTrace.current,
        );
      }

      final apartments = apartmentsAsync.value ?? [];
      final buildings = buildingsAsync.value ?? [];
      final bookings = bookingsAsync.value ?? [];
      final contracts = contractsAsync.value ?? [];

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final buildingMap = {for (var b in buildings) b.id: b.name};

      final summerBookingsByApt = <String, List<SummerBooking>>{};
      for (var b in bookings) {
        summerBookingsByApt.putIfAbsent(b.apartmentId, () => []).add(b);
      }

      final winterContractsByApt = <String, List<WinterContract>>{};
      for (var c in contracts) {
        winterContractsByApt.putIfAbsent(c.apartmentId, () => []).add(c);
      }

      final statuses = apartments.map((apt) {
        final buildingName = buildingMap[apt.buildingId] ?? 'مبنى غير معروف';
        final aptBookings = summerBookingsByApt[apt.id] ?? [];
        final aptContracts = winterContractsByApt[apt.id] ?? [];

        bool isOccupied = false;
        bool isCheckingOutToday = false;

        // Check SummerBookings
        for (var b in aptBookings) {
          final end = b.earlyCheckoutDate ?? b.checkOutDate;
          final checkInDay = _dateOnly(b.checkInDate);
          if (!checkInDay.isAfter(today) &&
              b.status != 'cancelled' &&
              b.status != 'checked_out' &&
              b.status != 'deleted' &&
              b.syncStatus != SyncStatus.pendingDelete) {
            isOccupied = true;
            if (!_dateOnly(end).isAfter(today)) {
              isCheckingOutToday = true;
            }
          }
        }

        // Check WinterContracts
        if (!isOccupied) {
          for (var c in aptContracts) {
            final startDay = DateTime(
              c.startDate.year,
              c.startDate.month,
              c.startDate.day,
            );
            if (c.isActive &&
                !startDay.isAfter(today) &&
                c.endDate.isAfter(now)) {
              isOccupied = true;
              break;
            }
          }
        }

        final needsCleaning = apt.cleaningStatus == 'needs_cleaning';

        return ApartmentStatus(
          apartment: apt,
          buildingId: apt.buildingId,
          buildingName: buildingName,
          isOccupied: isOccupied,
          needsCleaning: needsCleaning,
          isCheckingOutToday: isCheckingOutToday,
        );
      }).toList();

      return AsyncValue.data(statuses);
    });

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
