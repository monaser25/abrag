import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../database/database.dart';
import '../database/tables.dart';

class SyncEngine {
  final AppDatabase db;
  final SupabaseClient supabase;

  SyncEngine(this.db, this.supabase);

  Future<void> syncAll() async {
    // 1. Push local pending changes to Supabase
    await _pushLocalChanges();

    // 2. Pull remote changes from Supabase to local Drift DB
    await _pullRemoteChanges();
  }

  Future<void> _pushLocalChanges() async {
    // Example: Push Apartments with pending updates
    final pendingApartments = await (db.select(
      db.apartments,
    )..where((t) => t.syncStatus.equals(SyncStatus.pendingUpdate.index))).get();

    for (final apt in pendingApartments) {
      try {
        await supabase
            .from('apartments')
            .update({
              'cleaning_status': apt.cleaningStatus,
              'broker_visibility': apt.brokerVisibility,
              'inventory': apt.inventory,
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            })
            .eq('id', apt.id);

        // Mark as synced locally
        await (db.update(
          db.apartments,
        )..where((t) => t.id.equals(apt.id))).write(
          const ApartmentsCompanion(syncStatus: Value(SyncStatus.synced)),
        );
      } catch (e) {
        // Log conflict or error
        // print('Error syncing apartment ${apt.id}: $e');
      }
    }

    final pendingBookings = await (db.select(
      db.summerBookings,
    )..where((t) => t.syncStatus.isNotIn([SyncStatus.synced.index]))).get();

    for (final booking in pendingBookings) {
      try {
        final payload = {
          'id': booking.id,
          'apartment_id': booking.apartmentId,
          'guest_name': booking.guestName,
          'guest_phone': booking.guestPhone,
          'check_in_date': booking.checkInDate.toUtc().toIso8601String(),
          'check_out_date': booking.checkOutDate.toUtc().toIso8601String(),
          'status': booking.status,
          'total_price_egp': booking.totalPriceEgp,
          'amount_paid_egp': booking.amountPaidEgp,
          'payment_method': booking.paymentMethod,
          'broker_id': booking.brokerId,
          'broker_name': booking.brokerName,
          'broker_commission_type': booking.brokerCommissionType,
          'broker_commission_percentage': booking.brokerCommissionPercentage,
          'broker_commission_fixed_egp': booking.brokerCommissionFixedEgp,
          'early_checkout_date': booking.earlyCheckoutDate
              ?.toUtc()
              .toIso8601String(),
          'overstay_days': booking.overstayDays,
          'overstay_fee_egp': booking.overstayFeeEgp,
          'national_id': booking.nationalId,
          'id_front_image': booking.idFrontImage,
          'id_back_image': booking.idBackImage,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        };

        if (booking.syncStatus == SyncStatus.pendingDelete) {
          await supabase.from('summer_bookings').delete().eq('id', booking.id);
          await (db.delete(
            db.summerBookings,
          )..where((t) => t.id.equals(booking.id))).go();
        } else {
          await supabase.from('summer_bookings').upsert(payload);
          await (db.update(
            db.summerBookings,
          )..where((t) => t.id.equals(booking.id))).write(
            const SummerBookingsCompanion(syncStatus: Value(SyncStatus.synced)),
          );
        }
      } catch (e) {
        // Keep the booking pending for the next sync attempt.
      }
    }
  }

  Future<void> _pullRemoteChanges() async {
    try {
      // Sync UserProfiles
      final userProfilesData = await supabase.from('user_profiles').select();
      for (final row in userProfilesData) {
        await db
            .into(db.userProfiles)
            .insertOnConflictUpdate(
              UserProfilesCompanion(
                id: Value(row['id']),
                email: Value(row['email']),
                fullName: Value(row['full_name'] as String?),
                phoneNumber: Value(row['phone_number'] as String?),
                role: Value(row['role']),
                createdAt: Value(DateTime.parse(row['created_at'])),
                updatedAt: Value(DateTime.parse(row['updated_at'])),
                syncStatus: const Value(SyncStatus.synced),
              ),
            );
      }

      // Sync Buildings
      final buildingsData = await supabase.from('buildings').select();
      for (final row in buildingsData) {
        await db
            .into(db.buildings)
            .insertOnConflictUpdate(
              BuildingsCompanion(
                id: Value(row['id']),
                name: Value(row['name']),
                address: Value(row['address'] as String?),
                annualRentEgp: Value((row['annual_rent_egp'] as num?)?.toDouble() ?? 0.0),
                rentInstallmentsDates: Value(row['rent_installments_dates'] as String?),
                totalApartments: Value(row['total_apartments']),
                createdAt: Value(DateTime.parse(row['created_at'])),
                syncStatus: const Value(SyncStatus.synced),
              ),
            );
      }

      // Sync Apartments
      final apartmentsData = await supabase.from('apartments').select();
      for (final row in apartmentsData) {
        await db
            .into(db.apartments)
            .insertOnConflictUpdate(
              ApartmentsCompanion(
                id: Value(row['id']),
                buildingId: Value(row['building_id']),
                apartmentNumber: Value(row['apartment_number']),
                floorNumber: Value(row['floor_number'] as int?),
                cleaningStatus: Value(row['cleaning_status']),
                inventory: Value(row['inventory'] as String?),
                brokerVisibility: Value(row['broker_visibility']),
                createdAt: Value(DateTime.parse(row['created_at'])),
                updatedAt: Value(DateTime.parse(row['updated_at'])),
                syncStatus: const Value(SyncStatus.synced),
              ),
            );
      }
    } catch (e) {
      // print('Error pulling remote changes: $e');
      rethrow;
    }
  }
}
