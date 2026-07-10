import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'dart:io';
import 'package:uuid/uuid.dart';
import '../database/database.dart';
import '../database/tables.dart';

class SyncEngine {
  final AppDatabase db;
  final SupabaseClient supabase;

  SyncEngine(this.db, this.supabase);

  Future<String?> _uploadFileIfLocal(
    String? path,
    String bucket,
    String folder,
  ) async {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;

    try {
      final file = File(path);
      if (!await file.exists()) return path;

      final ext = path.split('.').last;
      final fileName = '${const Uuid().v4()}.$ext';
      final storagePath = '$folder/$fileName';

      await supabase.storage.from(bucket).upload(storagePath, file);
      final publicUrl = supabase.storage.from(bucket).getPublicUrl(storagePath);
      return publicUrl;
    } catch (e) {
      throw Exception('فشل رفع الملف للسيرفر: $e');
    }
  }

  Future<void> syncAll() async {
    await _runWithNetworkRetry(() async {
      // Media upload is best-effort: a failure must never abort the data sync.
      try {
        await _uploadLocalMediaBeforeSync();
      } catch (e) {
        debugPrint('Media upload skipped (will retry next sync): $e');
      }
      await _pushLocalChanges();
      await _pullRemoteChanges();
    });
  }

  Future<void> _runWithNetworkRetry(Future<void> Function() action) async {
    Object? lastError;
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        await action();
        return;
      } catch (error) {
        lastError = error;
        if (!_isTemporaryNetworkError(error) || attempt == 2) rethrow;
        await Future.delayed(Duration(seconds: 2 * (attempt + 1)));
      }
    }
    throw lastError ?? Exception('فشل الاتصال بالسيرفر');
  }

  bool _isTemporaryNetworkError(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('failed host lookup') ||
        message.contains('socketexception') ||
        message.contains('connection refused') ||
        message.contains('connection reset') ||
        message.contains('network is unreachable') ||
        message.contains('connection timed out');
  }

  Future<void> _uploadLocalMediaBeforeSync() async {
    // Media upload must NEVER abort a data sync. It runs before push/pull, so a
    // transient storage/upload hiccup used to fail the whole refresh (and show a
    // misleading "check your internet" message) even though the data itself would
    // sync fine. Each step is now non-fatal: failures are logged and the file is
    // retried on the next sync, while push/pull still run.
    await _uploadMediaStep(_uploadSummerBookingImages, 'summer booking images');
    await _uploadMediaStep(
      _uploadWinterContractImages,
      'winter contract images',
    );
    await _uploadMediaStep(
      _uploadWinterPaymentReceipts,
      'winter payment receipts',
    );
    await _uploadMediaStep(_uploadExpenseReceipts, 'expense receipts');
  }

  Future<void> _uploadMediaStep(
    Future<void> Function() step,
    String label,
  ) async {
    try {
      await step();
    } catch (e) {
      debugPrint('Media upload "$label" failed (non-fatal, will retry): $e');
    }
  }

  bool _isRemotePath(String? path) {
    if (path == null || path.isEmpty) return true;
    return path.startsWith('http://') || path.startsWith('https://');
  }

  Future<void> _uploadSummerBookingImages() async {
    final bookings = await db.select(db.summerBookings).get();
    for (final item in bookings) {
      if (item.syncStatus == SyncStatus.pendingDelete ||
          item.status == 'deleted') {
        continue;
      }

      final idFront = _isRemotePath(item.idFrontImage)
          ? item.idFrontImage
          : await _uploadFileIfLocal(
              item.idFrontImage,
              'abrag_storage',
              'summer_bookings',
            );
      final idBack = _isRemotePath(item.idBackImage)
          ? item.idBackImage
          : await _uploadFileIfLocal(
              item.idBackImage,
              'abrag_storage',
              'summer_bookings',
            );
      if (idFront != item.idFrontImage || idBack != item.idBackImage) {
        await (db.update(
          db.summerBookings,
        )..where((t) => t.id.equals(item.id))).write(
          SummerBookingsCompanion(
            idFrontImage: Value(idFront),
            idBackImage: Value(idBack),
            syncStatus: const Value(SyncStatus.pendingUpdate),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
    }
  }

  Future<void> _uploadWinterContractImages() async {
    final contracts = await db.select(db.winterContracts).get();
    for (final item in contracts) {
      final idFront = _isRemotePath(item.idFrontImage)
          ? item.idFrontImage
          : await _uploadFileIfLocal(
              item.idFrontImage,
              'abrag_storage',
              'winter_contracts',
            );
      final idBack = _isRemotePath(item.idBackImage)
          ? item.idBackImage
          : await _uploadFileIfLocal(
              item.idBackImage,
              'abrag_storage',
              'winter_contracts',
            );
      final contractFront = _isRemotePath(item.contractFrontImage)
          ? item.contractFrontImage
          : await _uploadFileIfLocal(
              item.contractFrontImage,
              'abrag_storage',
              'winter_contracts',
            );
      final contractBack = _isRemotePath(item.contractBackImage)
          ? item.contractBackImage
          : await _uploadFileIfLocal(
              item.contractBackImage,
              'abrag_storage',
              'winter_contracts',
            );
      final roommates = await _uploadRoommateImages(item.roommates);
      if (idFront != item.idFrontImage ||
          idBack != item.idBackImage ||
          contractFront != item.contractFrontImage ||
          contractBack != item.contractBackImage ||
          roommates != item.roommates) {
        await (db.update(
          db.winterContracts,
        )..where((t) => t.id.equals(item.id))).write(
          WinterContractsCompanion(
            idFrontImage: Value(idFront),
            idBackImage: Value(idBack),
            contractFrontImage: Value(contractFront),
            contractBackImage: Value(contractBack),
            roommates: Value(roommates),
            syncStatus: const Value(SyncStatus.pendingUpdate),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
    }
  }

  Future<String?> _uploadRoommateImages(String? roommatesJson) async {
    if (roommatesJson == null || roommatesJson.trim().isEmpty) {
      return roommatesJson;
    }

    try {
      final decoded = jsonDecode(roommatesJson);
      if (decoded is! List) return roommatesJson;

      var changed = false;
      final updated = <dynamic>[];

      for (final item in decoded) {
        if (item is! Map) {
          updated.add(item);
          continue;
        }

        final next = Map<String, dynamic>.from(item);
        for (final key in ['idFrontImage', 'idBackImage']) {
          final value = next[key]?.toString();
          if (value == null || value.isEmpty || _isRemotePath(value)) continue;

          final uploaded = await _uploadFileIfLocal(
            value,
            'abrag_storage',
            'winter_contracts',
          );
          if (uploaded != value) {
            next[key] = uploaded;
            changed = true;
          }
        }
        updated.add(next);
      }

      return changed ? jsonEncode(updated) : roommatesJson;
    } catch (_) {
      return roommatesJson;
    }
  }

  Future<void> _uploadWinterPaymentReceipts() async {
    final payments = await db.select(db.winterPayments).get();
    for (final item in payments) {
      final receipt = _isRemotePath(item.receiptUrl)
          ? item.receiptUrl
          : await _uploadFileIfLocal(
              item.receiptUrl,
              'abrag_storage',
              'winter_payments',
            );
      if (receipt != item.receiptUrl) {
        await (db.update(
          db.winterPayments,
        )..where((t) => t.id.equals(item.id))).write(
          WinterPaymentsCompanion(
            receiptUrl: Value(receipt),
            syncStatus: const Value(SyncStatus.pendingUpdate),
          ),
        );
      }
    }
  }

  Future<void> _uploadExpenseReceipts() async {
    final expenses = await db.select(db.expenses).get();
    for (final item in expenses) {
      final receipt = _isRemotePath(item.receiptUrl)
          ? item.receiptUrl
          : await _uploadFileIfLocal(
              item.receiptUrl,
              'abrag_storage',
              'expenses',
            );
      if (receipt != item.receiptUrl) {
        await (db.update(
          db.expenses,
        )..where((t) => t.id.equals(item.id))).write(
          ExpensesCompanion(
            receiptUrl: Value(receipt),
            syncStatus: const Value(SyncStatus.pendingUpdate),
          ),
        );
      }
    }
  }

  Future<void> _pushLocalChanges() async {
    final pendingUserProfiles = await (db.select(
      db.userProfiles,
    )..where((t) => t.syncStatus.isNotIn([SyncStatus.synced.index]))).get();

    for (final item in pendingUserProfiles) {
      try {
        if (!_isUuid(item.id)) {
          await (db.delete(
            db.userProfiles,
          )..where((t) => t.id.equals(item.id))).go();
          continue;
        }
        final payload = {
          'id': item.id,
          'email': item.email,
          'full_name': item.fullName,
          'phone_number': item.phoneNumber,
          'secondary_phone': item.secondaryPhone,
          'role': item.role,
          'created_at': item.createdAt.toUtc().toIso8601String(),
          'updated_at': item.updatedAt.toUtc().toIso8601String(),
        };

        if (item.syncStatus == SyncStatus.pendingDelete) {
          await supabase.from('user_profiles').delete().eq('id', item.id);
          await (db.delete(
            db.userProfiles,
          )..where((t) => t.id.equals(item.id))).go();
        } else {
          await supabase.from('user_profiles').upsert(payload);
          await (db.update(
            db.userProfiles,
          )..where((t) => t.id.equals(item.id))).write(
            const UserProfilesCompanion(syncStatus: Value(SyncStatus.synced)),
          );
        }
      } catch (e) {
        throw Exception('Error syncing user_profiles (push): $e\nItem: $item');
      }
    }

    final pendingBuildings = await (db.select(
      db.buildings,
    )..where((t) => t.syncStatus.isNotIn([SyncStatus.synced.index]))).get();

    for (final item in pendingBuildings) {
      try {
        final payload = {
          'id': item.id,
          'name': item.name,
          'address': item.address,
          'annual_rent_egp': item.annualRentEgp,
          'rent_installments_dates': item.rentInstallmentsDates,
          'total_apartments': item.totalApartments,
          'created_at': item.createdAt.toUtc().toIso8601String(),
        };

        if (item.syncStatus == SyncStatus.pendingDelete) {
          await supabase.from('buildings').delete().eq('id', item.id);
          await (db.delete(
            db.buildings,
          )..where((t) => t.id.equals(item.id))).go();
        } else {
          await supabase.from('buildings').upsert(payload);
          await (db.update(
            db.buildings,
          )..where((t) => t.id.equals(item.id))).write(
            const BuildingsCompanion(syncStatus: Value(SyncStatus.synced)),
          );
        }
      } catch (e) {
        throw Exception('Error syncing buildings (push): $e\nItem: $item');
      }
    }

    final pendingApartments = await (db.select(
      db.apartments,
    )..where((t) => t.syncStatus.isNotIn([SyncStatus.synced.index]))).get();

    for (final item in pendingApartments) {
      try {
        final payload = {
          'id': item.id,
          'building_id': item.buildingId,
          'apartment_number': item.apartmentNumber,
          'floor_number': item.floorNumber,
          'cleaning_status': item.cleaningStatus,
          'broker_visibility': item.brokerVisibility,
          'inventory': item.inventory,
          'landline_number': item.landlineNumber,
          'landline_owner_name': item.landlineOwnerName,
          'landline_notes': item.landlineNotes,
          'created_at': item.createdAt.toUtc().toIso8601String(),
          'updated_at': item.updatedAt.toUtc().toIso8601String(),
        };

        if (item.syncStatus == SyncStatus.pendingDelete) {
          await supabase.from('apartments').delete().eq('id', item.id);
          await (db.delete(
            db.apartments,
          )..where((t) => t.id.equals(item.id))).go();
        } else {
          await supabase.from('apartments').upsert(payload);
          await (db.update(
            db.apartments,
          )..where((t) => t.id.equals(item.id))).write(
            const ApartmentsCompanion(syncStatus: Value(SyncStatus.synced)),
          );
        }
      } catch (e) {
        throw Exception('Error syncing apartments (push): $e\nItem: $item');
      }
    }

    final pendingSummerBookings = await (db.select(
      db.summerBookings,
    )..where((t) => t.syncStatus.isNotIn([SyncStatus.synced.index]))).get();

    for (final item in pendingSummerBookings) {
      try {
        if (item.syncStatus == SyncStatus.pendingDelete ||
            item.status == 'deleted') {
          await supabase.from('summer_bookings').delete().eq('id', item.id);
          await (db.delete(
            db.summerBookings,
          )..where((t) => t.id.equals(item.id))).go();
          continue;
        }

        String? uploadedIdfrontimage = item.idFrontImage;
        if (uploadedIdfrontimage != null &&
            !uploadedIdfrontimage.startsWith('http')) {
          uploadedIdfrontimage = await _uploadFileIfLocal(
            uploadedIdfrontimage,
            'abrag_storage',
            'summer_bookings',
          );
        }
        String? uploadedIdbackimage = item.idBackImage;
        if (uploadedIdbackimage != null &&
            !uploadedIdbackimage.startsWith('http')) {
          uploadedIdbackimage = await _uploadFileIfLocal(
            uploadedIdbackimage,
            'abrag_storage',
            'summer_bookings',
          );
        }
        final payload = {
          'id': item.id,
          'apartment_id': item.apartmentId,
          'guest_name': item.guestName,
          'guest_phone': item.guestPhone,
          'check_in_date': item.checkInDate.toUtc().toIso8601String(),
          'check_out_date': item.checkOutDate.toUtc().toIso8601String(),
          'status': item.status,
          'total_price_egp': item.totalPriceEgp,
          'amount_paid_egp': item.amountPaidEgp,
          'payment_method': item.paymentMethod,
          'broker_id': item.brokerId,
          'broker_name': item.brokerName,
          'broker_commission_type': item.brokerCommissionType,
          'broker_commission_percentage': item.brokerCommissionPercentage,
          'broker_commission_fixed_egp': item.brokerCommissionFixedEgp,
          'early_checkout_date': item.earlyCheckoutDate
              ?.toUtc()
              .toIso8601String(),
          'overstay_days': item.overstayDays,
          'overstay_fee_egp': item.overstayFeeEgp,
          'national_id': item.nationalId,
          'id_front_image': uploadedIdfrontimage,
          'id_back_image': uploadedIdbackimage,
          'created_at': item.createdAt.toUtc().toIso8601String(),
          'updated_at': item.updatedAt.toUtc().toIso8601String(),
        };

        await supabase.from('summer_bookings').upsert(payload);
        await (db.update(
          db.summerBookings,
        )..where((t) => t.id.equals(item.id))).write(
          const SummerBookingsCompanion(syncStatus: Value(SyncStatus.synced)),
        );
      } catch (e) {
        throw Exception(
          'Error syncing summer_bookings (push): $e\nItem: $item',
        );
      }
    }

    final pendingWinterContracts = await (db.select(
      db.winterContracts,
    )..where((t) => t.syncStatus.isNotIn([SyncStatus.synced.index]))).get();

    for (final item in pendingWinterContracts) {
      try {
        String? uploadedIdfrontimage = item.idFrontImage;
        if (uploadedIdfrontimage != null &&
            !uploadedIdfrontimage.startsWith('http')) {
          uploadedIdfrontimage = await _uploadFileIfLocal(
            uploadedIdfrontimage,
            'abrag_storage',
            'winter_contracts',
          );
        }
        String? uploadedIdbackimage = item.idBackImage;
        if (uploadedIdbackimage != null &&
            !uploadedIdbackimage.startsWith('http')) {
          uploadedIdbackimage = await _uploadFileIfLocal(
            uploadedIdbackimage,
            'abrag_storage',
            'winter_contracts',
          );
        }
        String? uploadedContractfrontimage = item.contractFrontImage;
        if (uploadedContractfrontimage != null &&
            !uploadedContractfrontimage.startsWith('http')) {
          uploadedContractfrontimage = await _uploadFileIfLocal(
            uploadedContractfrontimage,
            'abrag_storage',
            'winter_contracts',
          );
        }
        String? uploadedContractbackimage = item.contractBackImage;
        if (uploadedContractbackimage != null &&
            !uploadedContractbackimage.startsWith('http')) {
          uploadedContractbackimage = await _uploadFileIfLocal(
            uploadedContractbackimage,
            'abrag_storage',
            'winter_contracts',
          );
        }
        final payload = {
          'id': item.id,
          'apartment_id': item.apartmentId,
          'contract_type': item.contractType,
          'student_name': item.studentName,
          'university': item.university,
          'parent_name': item.parentName,
          'parent_phone': item.parentPhone,
          'viewer_user_id': item.viewerUserId,
          'start_date': item.startDate.toUtc().toIso8601String(),
          'end_date': item.endDate.toUtc().toIso8601String(),
          'monthly_rent_egp': item.monthlyRentEgp,
          'deposit_egp': item.depositEgp,
          'is_active': item.isActive,
          'is_electricity_on_student': item.isElectricityOnStudent,
          'is_gas_on_student': item.isGasOnStudent,
          'is_water_on_student': item.isWaterOnStudent,
          'roommates': item.roommates,
          'national_id': item.nationalId,
          'id_front_image': uploadedIdfrontimage,
          'id_back_image': uploadedIdbackimage,
          'contract_front_image': uploadedContractfrontimage,
          'contract_back_image': uploadedContractbackimage,
          'created_at': item.createdAt.toUtc().toIso8601String(),
          'updated_at': item.updatedAt.toUtc().toIso8601String(),
        };

        if (item.syncStatus == SyncStatus.pendingDelete) {
          await supabase.from('winter_contracts').delete().eq('id', item.id);
          await (db.delete(
            db.winterContracts,
          )..where((t) => t.id.equals(item.id))).go();
        } else {
          await supabase.from('winter_contracts').upsert(payload);
          await (db.update(
            db.winterContracts,
          )..where((t) => t.id.equals(item.id))).write(
            const WinterContractsCompanion(
              syncStatus: Value(SyncStatus.synced),
            ),
          );
        }
      } catch (e) {
        throw Exception(
          'Error syncing winter_contracts (push): $e\nItem: $item',
        );
      }
    }

    final pendingWinterPayments = await (db.select(
      db.winterPayments,
    )..where((t) => t.syncStatus.isNotIn([SyncStatus.synced.index]))).get();

    for (final item in pendingWinterPayments) {
      try {
        String? uploadedReceipturl = item.receiptUrl;
        if (uploadedReceipturl != null &&
            !uploadedReceipturl.startsWith('http')) {
          uploadedReceipturl = await _uploadFileIfLocal(
            uploadedReceipturl,
            'abrag_storage',
            'winter_payments',
          );
        }
        final payload = {
          'id': item.id,
          'contract_id': item.contractId,
          'amount_egp': item.amountEgp,
          'payment_date': item.paymentDate.toUtc().toIso8601String(),
          'payment_method': item.paymentMethod,
          'receipt_url': uploadedReceipturl,
          'created_at': item.createdAt.toUtc().toIso8601String(),
        };

        if (item.syncStatus == SyncStatus.pendingDelete) {
          await supabase.from('winter_payments').delete().eq('id', item.id);
          await (db.delete(
            db.winterPayments,
          )..where((t) => t.id.equals(item.id))).go();
        } else {
          await supabase.from('winter_payments').upsert(payload);
          await (db.update(
            db.winterPayments,
          )..where((t) => t.id.equals(item.id))).write(
            const WinterPaymentsCompanion(syncStatus: Value(SyncStatus.synced)),
          );
        }
      } catch (e) {
        throw Exception(
          'Error syncing winter_payments (push): $e\nItem: $item',
        );
      }
    }

    final pendingBookingPayments = await (db.select(
      db.bookingPayments,
    )..where((t) => t.syncStatus.isNotIn([SyncStatus.synced.index]))).get();

    for (final item in pendingBookingPayments) {
      try {
        final payload = {
          'id': item.id,
          'booking_id': item.bookingId,
          'amount_egp': item.amountEgp,
          'payment_method': item.paymentMethod,
          'payment_date': item.paymentDate.toUtc().toIso8601String(),
          'notes': item.notes,
          'created_at': item.createdAt.toUtc().toIso8601String(),
        };

        if (item.syncStatus == SyncStatus.pendingDelete) {
          await supabase.from('booking_payments').delete().eq('id', item.id);
          await (db.delete(
            db.bookingPayments,
          )..where((t) => t.id.equals(item.id))).go();
        } else {
          await supabase.from('booking_payments').upsert(payload);
          await (db.update(
            db.bookingPayments,
          )..where((t) => t.id.equals(item.id))).write(
            const BookingPaymentsCompanion(
              syncStatus: Value(SyncStatus.synced),
            ),
          );
        }
      } catch (e) {
        throw Exception(
          'Error syncing booking_payments (push): $e\nItem: $item',
        );
      }
    }

    final pendingMeterReadings = await (db.select(
      db.meterReadings,
    )..where((t) => t.syncStatus.isNotIn([SyncStatus.synced.index]))).get();

    for (final item in pendingMeterReadings) {
      try {
        final payload = {
          'id': item.id,
          'apartment_id': item.apartmentId,
          'building_id': item.buildingId,
          'reading_date': item.readingDate.toUtc().toIso8601String(),
          'previous_reading': item.previousReading,
          'current_reading': item.currentReading,
          'amount_egp': item.amountEgp,
          'is_shared_expense': item.isSharedExpense,
          'created_at': item.createdAt.toUtc().toIso8601String(),
        };

        if (item.syncStatus == SyncStatus.pendingDelete) {
          await supabase.from('meter_readings').delete().eq('id', item.id);
          await (db.delete(
            db.meterReadings,
          )..where((t) => t.id.equals(item.id))).go();
        } else {
          await supabase.from('meter_readings').upsert(payload);
          await (db.update(
            db.meterReadings,
          )..where((t) => t.id.equals(item.id))).write(
            const MeterReadingsCompanion(syncStatus: Value(SyncStatus.synced)),
          );
        }
      } catch (e) {
        throw Exception('Error syncing meter_readings (push): $e\nItem: $item');
      }
    }

    final pendingExpenses = await (db.select(
      db.expenses,
    )..where((t) => t.syncStatus.isNotIn([SyncStatus.synced.index]))).get();

    for (final item in pendingExpenses) {
      try {
        String? uploadedReceipturl = item.receiptUrl;
        if (uploadedReceipturl != null &&
            !uploadedReceipturl.startsWith('http')) {
          uploadedReceipturl = await _uploadFileIfLocal(
            uploadedReceipturl,
            'abrag_storage',
            'expenses',
          );
        }
        final payload = {
          'id': item.id,
          'building_id': item.buildingId,
          'apartment_id': item.apartmentId,
          'expense_type': item.expenseType,
          'amount_egp': item.amountEgp,
          'payment_method': item.paymentMethod,
          'season': item.season,
          'discount_egp': item.discountEgp,
          'discount_reason': item.discountReason,
          'expense_date': item.expenseDate.toUtc().toIso8601String(),
          'installment_number': item.installmentNumber,
          'description': item.description,
          'receipt_url': uploadedReceipturl,
          'created_at': item.createdAt.toUtc().toIso8601String(),
        };

        if (item.syncStatus == SyncStatus.pendingDelete) {
          await supabase.from('expenses').delete().eq('id', item.id);
          await (db.delete(
            db.expenses,
          )..where((t) => t.id.equals(item.id))).go();
        } else {
          await supabase.from('expenses').upsert(payload);
          await (db.update(
            db.expenses,
          )..where((t) => t.id.equals(item.id))).write(
            const ExpensesCompanion(syncStatus: Value(SyncStatus.synced)),
          );
        }
      } catch (e) {
        throw Exception('Error syncing expenses (push): $e\nItem: $item');
      }
    }

    final pendingFinancialTransfers = await (db.select(
      db.financialTransfers,
    )..where((t) => t.syncStatus.isNotIn([SyncStatus.synced.index]))).get();

    for (final item in pendingFinancialTransfers) {
      try {
        final payload = {
          'id': item.id,
          'from_account': item.fromAccount,
          'to_account': item.toAccount,
          'transfer_type': item.transferType,
          'season': item.season,
          'amount_egp': item.amountEgp,
          'transfer_date': item.transferDate.toUtc().toIso8601String(),
          'notes': item.notes,
          'created_at': item.createdAt.toUtc().toIso8601String(),
        };

        if (item.syncStatus == SyncStatus.pendingDelete) {
          await supabase.from('financial_transfers').delete().eq('id', item.id);
          await (db.delete(
            db.financialTransfers,
          )..where((t) => t.id.equals(item.id))).go();
        } else {
          await supabase.from('financial_transfers').upsert(payload);
          await (db.update(
            db.financialTransfers,
          )..where((t) => t.id.equals(item.id))).write(
            const FinancialTransfersCompanion(
              syncStatus: Value(SyncStatus.synced),
            ),
          );
        }
      } catch (e) {
        throw Exception(
          'Error syncing financial_transfers (push): $e\nItem: $item',
        );
      }
    }

    final pendingTechnicians = await (db.select(
      db.technicians,
    )..where((t) => t.syncStatus.isNotIn([SyncStatus.synced.index]))).get();

    for (final item in pendingTechnicians) {
      try {
        final payload = {
          'id': item.id,
          'name': item.name,
          'phone': item.phone,
          'secondary_phone': item.secondaryPhone,
          'specialty': item.specialty,
          'notes': item.notes,
          'created_at': item.createdAt.toUtc().toIso8601String(),
        };

        if (item.syncStatus == SyncStatus.pendingDelete) {
          await supabase.from('technicians').delete().eq('id', item.id);
          await (db.delete(
            db.technicians,
          )..where((t) => t.id.equals(item.id))).go();
        } else {
          await supabase.from('technicians').upsert(payload);
          await (db.update(
            db.technicians,
          )..where((t) => t.id.equals(item.id))).write(
            const TechniciansCompanion(syncStatus: Value(SyncStatus.synced)),
          );
        }
      } catch (e) {
        throw Exception('Error syncing technicians (push): $e\nItem: $item');
      }
    }

    final pendingCleaningSupplies = await (db.select(
      db.cleaningSupplies,
    )..where((t) => t.syncStatus.isNotIn([SyncStatus.synced.index]))).get();

    for (final item in pendingCleaningSupplies) {
      try {
        final payload = {
          'id': item.id,
          'name': item.name,
          'stock_quantity': item.stockQuantity,
          'unit': item.unit,
          'created_at': item.createdAt.toUtc().toIso8601String(),
          'updated_at': item.updatedAt.toUtc().toIso8601String(),
        };

        if (item.syncStatus == SyncStatus.pendingDelete) {
          await supabase.from('cleaning_supplies').delete().eq('id', item.id);
          await (db.delete(
            db.cleaningSupplies,
          )..where((t) => t.id.equals(item.id))).go();
        } else {
          await supabase.from('cleaning_supplies').upsert(payload);
          await (db.update(
            db.cleaningSupplies,
          )..where((t) => t.id.equals(item.id))).write(
            const CleaningSuppliesCompanion(
              syncStatus: Value(SyncStatus.synced),
            ),
          );
        }
      } catch (e) {
        throw Exception(
          'Error syncing cleaning_supplies (push): $e\nItem: $item',
        );
      }
    }

    final pendingCleaningTransactions = await (db.select(
      db.cleaningTransactions,
    )..where((t) => t.syncStatus.isNotIn([SyncStatus.synced.index]))).get();

    for (final item in pendingCleaningTransactions) {
      try {
        final payload = {
          'id': item.id,
          'supply_id': item.supplyId,
          'transaction_type': item.transactionType,
          'quantity': item.quantity,
          'cost_egp': item.costEgp,
          'transaction_date': item.transactionDate.toUtc().toIso8601String(),
          'notes': item.notes,
          'created_at': item.createdAt.toUtc().toIso8601String(),
        };

        if (item.syncStatus == SyncStatus.pendingDelete) {
          await supabase
              .from('cleaning_transactions')
              .delete()
              .eq('id', item.id);
          await (db.delete(
            db.cleaningTransactions,
          )..where((t) => t.id.equals(item.id))).go();
        } else {
          await supabase.from('cleaning_transactions').upsert(payload);
          await (db.update(
            db.cleaningTransactions,
          )..where((t) => t.id.equals(item.id))).write(
            const CleaningTransactionsCompanion(
              syncStatus: Value(SyncStatus.synced),
            ),
          );
        }
      } catch (e) {
        throw Exception(
          'Error syncing cleaning_transactions (push): $e\nItem: $item',
        );
      }
    }

    final pendingApartmentInspections = await (db.select(
      db.apartmentInspections,
    )..where((t) => t.syncStatus.isNotIn([SyncStatus.synced.index]))).get();

    for (final item in pendingApartmentInspections) {
      try {
        final payload = {
          'id': item.id,
          'apartment_id': item.apartmentId,
          'inspection_date': item.inspectionDate.toUtc().toIso8601String(),
          'is_clean': item.isClean,
          'has_damages': item.hasDamages,
          'damages_description': item.damagesDescription,
          'tenant_fine_egp': item.tenantFineEgp,
          'owner_repair_cost_egp': item.ownerRepairCostEgp,
          'inspector_name': item.inspectorName,
          'notes': item.notes,
          'created_at': item.createdAt.toUtc().toIso8601String(),
          'updated_at': item.updatedAt.toUtc().toIso8601String(),
        };

        if (item.syncStatus == SyncStatus.pendingDelete) {
          await supabase
              .from('apartment_inspections')
              .delete()
              .eq('id', item.id);
          await (db.delete(
            db.apartmentInspections,
          )..where((t) => t.id.equals(item.id))).go();
        } else {
          await supabase.from('apartment_inspections').upsert(payload);
          await (db.update(
            db.apartmentInspections,
          )..where((t) => t.id.equals(item.id))).write(
            const ApartmentInspectionsCompanion(
              syncStatus: Value(SyncStatus.synced),
            ),
          );
        }
      } catch (e) {
        throw Exception(
          'Error syncing apartment_inspections (push): $e\nItem: $item',
        );
      }
    }

    final pendingMaintenanceRequests = await (db.select(
      db.maintenanceRequests,
    )..where((t) => t.syncStatus.isNotIn([SyncStatus.synced.index]))).get();

    for (final item in pendingMaintenanceRequests) {
      try {
        final payload = {
          'id': item.id,
          'apartment_id': item.apartmentId,
          'technician_id': item.technicianId,
          'reported_by': item.reportedBy,
          'issue_description': item.issueDescription,
          'status': item.status,
          'cost_egp': item.costEgp,
          'resolved_at': item.resolvedAt?.toUtc().toIso8601String(),
          'created_at': item.createdAt.toUtc().toIso8601String(),
          'updated_at': item.updatedAt.toUtc().toIso8601String(),
        };

        if (item.syncStatus == SyncStatus.pendingDelete) {
          await supabase
              .from('maintenance_requests')
              .delete()
              .eq('id', item.id);
          await (db.delete(
            db.maintenanceRequests,
          )..where((t) => t.id.equals(item.id))).go();
        } else {
          await supabase.from('maintenance_requests').upsert(payload);
          await (db.update(
            db.maintenanceRequests,
          )..where((t) => t.id.equals(item.id))).write(
            const MaintenanceRequestsCompanion(
              syncStatus: Value(SyncStatus.synced),
            ),
          );
        }
      } catch (e) {
        throw Exception(
          'Error syncing maintenance_requests (push): $e\nItem: $item',
        );
      }
    }

    final pendingAuditLogs = await (db.select(
      db.auditLogs,
    )..where((t) => t.syncStatus.isNotIn([SyncStatus.synced.index]))).get();

    for (final item in pendingAuditLogs) {
      try {
        final payload = {
          'id': item.id,
          'actor_user_id': item.actorUserId,
          'actor_name': item.actorName,
          'action': item.action,
          'entity_type': item.entityType,
          'entity_id': item.entityId,
          'title': item.title,
          'description': item.description,
          'route': item.route,
          'old_values_json': item.oldValuesJson,
          'new_values_json': item.newValuesJson,
          'created_at': item.createdAt.toUtc().toIso8601String(),
        };

        if (item.syncStatus == SyncStatus.pendingDelete) {
          await supabase.from('audit_logs').delete().eq('id', item.id);
          await (db.delete(
            db.auditLogs,
          )..where((t) => t.id.equals(item.id))).go();
        } else {
          await supabase.from('audit_logs').upsert(payload);
          if (item.syncStatus == SyncStatus.pendingInsert) {
            await _sendPushNotificationForAuditLog(item);
          }
          await (db.update(
            db.auditLogs,
          )..where((t) => t.id.equals(item.id))).write(
            const AuditLogsCompanion(syncStatus: Value(SyncStatus.synced)),
          );
        }
      } catch (e) {
        throw Exception('Error syncing audit_logs (push): $e\nItem: $item');
      }
    }
  }

  Future<void> _sendPushNotificationForAuditLog(AuditLog item) async {
    try {
      await supabase.functions.invoke(
        'send-push-notification',
        body: {
          'title': item.title,
          'body': item.description,
          'route': item.route,
          'actorUserId': item.actorUserId,
        },
      );
    } catch (_) {
      // Push delivery must not block offline-first data sync.
    }
  }

  bool _isUuid(String value) {
    return RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    ).hasMatch(value);
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
                id: row['id'] == null ? const Value.absent() : Value(row['id']),
                email: row['email'] == null
                    ? const Value.absent()
                    : Value(row['email']),
                fullName: row['full_name'] == null
                    ? const Value.absent()
                    : Value(row['full_name']),
                phoneNumber: row['phone_number'] == null
                    ? const Value.absent()
                    : Value(row['phone_number']),
                secondaryPhone: row['secondary_phone'] == null
                    ? const Value.absent()
                    : Value(row['secondary_phone']),
                role: row['role'] == null
                    ? const Value.absent()
                    : Value(row['role']),
                createdAt: row['created_at'] == null
                    ? const Value.absent()
                    : Value(DateTime.parse(row['created_at'])),
                updatedAt: row['updated_at'] == null
                    ? const Value.absent()
                    : Value(DateTime.parse(row['updated_at'])),
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
                id: row['id'] == null ? const Value.absent() : Value(row['id']),
                name: row['name'] == null
                    ? const Value.absent()
                    : Value(row['name']),
                address: row['address'] == null
                    ? const Value.absent()
                    : Value(row['address']),
                annualRentEgp: row['annual_rent_egp'] == null
                    ? const Value.absent()
                    : Value((row['annual_rent_egp'] as num).toDouble()),
                rentInstallmentsDates: row['rent_installments_dates'] == null
                    ? const Value.absent()
                    : Value(row['rent_installments_dates']),
                totalApartments: row['total_apartments'] == null
                    ? const Value.absent()
                    : Value((row['total_apartments'] as num).toInt()),
                createdAt: row['created_at'] == null
                    ? const Value.absent()
                    : Value(DateTime.parse(row['created_at'])),
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
                id: row['id'] == null ? const Value.absent() : Value(row['id']),
                buildingId: row['building_id'] == null
                    ? const Value.absent()
                    : Value(row['building_id']),
                apartmentNumber: row['apartment_number'] == null
                    ? const Value.absent()
                    : Value(row['apartment_number']),
                floorNumber: row['floor_number'] == null
                    ? const Value.absent()
                    : Value((row['floor_number'] as num).toInt()),
                cleaningStatus: row['cleaning_status'] == null
                    ? const Value.absent()
                    : Value(row['cleaning_status']),
                brokerVisibility: row['broker_visibility'] == null
                    ? const Value.absent()
                    : Value(row['broker_visibility']),
                inventory: row['inventory'] == null
                    ? const Value.absent()
                    : Value(row['inventory']),
                landlineNumber: row['landline_number'] == null
                    ? const Value.absent()
                    : Value(row['landline_number']),
                landlineOwnerName: row['landline_owner_name'] == null
                    ? const Value.absent()
                    : Value(row['landline_owner_name']),
                landlineNotes: row['landline_notes'] == null
                    ? const Value.absent()
                    : Value(row['landline_notes']),
                createdAt: row['created_at'] == null
                    ? const Value.absent()
                    : Value(DateTime.parse(row['created_at'])),
                updatedAt: row['updated_at'] == null
                    ? const Value.absent()
                    : Value(DateTime.parse(row['updated_at'])),
                syncStatus: const Value(SyncStatus.synced),
              ),
            );
      }

      // Sync SummerBookings
      final summerBookingsData = await supabase
          .from('summer_bookings')
          .select();
      for (final row in summerBookingsData) {
        await db
            .into(db.summerBookings)
            .insertOnConflictUpdate(
              SummerBookingsCompanion(
                id: row['id'] == null ? const Value.absent() : Value(row['id']),
                apartmentId: row['apartment_id'] == null
                    ? const Value.absent()
                    : Value(row['apartment_id']),
                guestName: row['guest_name'] == null
                    ? const Value.absent()
                    : Value(row['guest_name']),
                guestPhone: row['guest_phone'] == null
                    ? const Value.absent()
                    : Value(row['guest_phone']),
                checkInDate: row['check_in_date'] == null
                    ? const Value.absent()
                    : Value(DateTime.parse(row['check_in_date'])),
                checkOutDate: row['check_out_date'] == null
                    ? const Value.absent()
                    : Value(DateTime.parse(row['check_out_date'])),
                status: row['status'] == null
                    ? const Value.absent()
                    : Value(row['status']),
                totalPriceEgp: row['total_price_egp'] == null
                    ? const Value.absent()
                    : Value((row['total_price_egp'] as num).toDouble()),
                amountPaidEgp: row['amount_paid_egp'] == null
                    ? const Value.absent()
                    : Value((row['amount_paid_egp'] as num).toDouble()),
                paymentMethod: row['payment_method'] == null
                    ? const Value.absent()
                    : Value(row['payment_method']),
                brokerId: row['broker_id'] == null
                    ? const Value.absent()
                    : Value(row['broker_id']),
                brokerName: row['broker_name'] == null
                    ? const Value.absent()
                    : Value(row['broker_name']),
                brokerCommissionType: row['broker_commission_type'] == null
                    ? const Value.absent()
                    : Value(row['broker_commission_type']),
                brokerCommissionPercentage:
                    row['broker_commission_percentage'] == null
                    ? const Value.absent()
                    : Value(
                        (row['broker_commission_percentage'] as num).toDouble(),
                      ),
                brokerCommissionFixedEgp:
                    row['broker_commission_fixed_egp'] == null
                    ? const Value.absent()
                    : Value(
                        (row['broker_commission_fixed_egp'] as num).toDouble(),
                      ),
                brokerCommissionAmountEgp:
                    row['broker_commission_amount_egp'] == null
                    ? const Value.absent()
                    : Value(
                        (row['broker_commission_amount_egp'] as num).toDouble(),
                      ),
                earlyCheckoutDate: row['early_checkout_date'] == null
                    ? const Value.absent()
                    : Value(DateTime.parse(row['early_checkout_date'])),
                overstayDays: row['overstay_days'] == null
                    ? const Value.absent()
                    : Value((row['overstay_days'] as num).toInt()),
                overstayFeeEgp: row['overstay_fee_egp'] == null
                    ? const Value.absent()
                    : Value((row['overstay_fee_egp'] as num).toDouble()),
                nationalId: row['national_id'] == null
                    ? const Value.absent()
                    : Value(row['national_id']),
                idFrontImage: row['id_front_image'] == null
                    ? const Value.absent()
                    : Value(row['id_front_image']),
                idBackImage: row['id_back_image'] == null
                    ? const Value.absent()
                    : Value(row['id_back_image']),
                createdAt: row['created_at'] == null
                    ? const Value.absent()
                    : Value(DateTime.parse(row['created_at'])),
                updatedAt: row['updated_at'] == null
                    ? const Value.absent()
                    : Value(DateTime.parse(row['updated_at'])),
                syncStatus: const Value(SyncStatus.synced),
              ),
            );
      }

      // Sync WinterContracts
      final winterContractsData = await supabase
          .from('winter_contracts')
          .select();
      for (final row in winterContractsData) {
        await db
            .into(db.winterContracts)
            .insertOnConflictUpdate(
              WinterContractsCompanion(
                id: row['id'] == null ? const Value.absent() : Value(row['id']),
                apartmentId: row['apartment_id'] == null
                    ? const Value.absent()
                    : Value(row['apartment_id']),
                contractType: row['contract_type'] == null
                    ? const Value.absent()
                    : Value(row['contract_type']),
                studentName: row['student_name'] == null
                    ? const Value.absent()
                    : Value(row['student_name']),
                university: row['university'] == null
                    ? const Value.absent()
                    : Value(row['university']),
                parentName: row['parent_name'] == null
                    ? const Value.absent()
                    : Value(row['parent_name']),
                parentPhone: row['parent_phone'] == null
                    ? const Value.absent()
                    : Value(row['parent_phone']),
                viewerUserId: row['viewer_user_id'] == null
                    ? const Value.absent()
                    : Value(row['viewer_user_id']),
                startDate: row['start_date'] == null
                    ? const Value.absent()
                    : Value(DateTime.parse(row['start_date'])),
                endDate: row['end_date'] == null
                    ? const Value.absent()
                    : Value(DateTime.parse(row['end_date'])),
                monthlyRentEgp: row['monthly_rent_egp'] == null
                    ? const Value.absent()
                    : Value((row['monthly_rent_egp'] as num).toDouble()),
                depositEgp: row['deposit_egp'] == null
                    ? const Value.absent()
                    : Value((row['deposit_egp'] as num).toDouble()),
                isActive: row['is_active'] == null
                    ? const Value.absent()
                    : Value(row['is_active']),
                isElectricityOnStudent: row['is_electricity_on_student'] == null
                    ? const Value.absent()
                    : Value(row['is_electricity_on_student']),
                isGasOnStudent: row['is_gas_on_student'] == null
                    ? const Value.absent()
                    : Value(row['is_gas_on_student']),
                isWaterOnStudent: row['is_water_on_student'] == null
                    ? const Value.absent()
                    : Value(row['is_water_on_student']),
                roommates: row['roommates'] == null
                    ? const Value.absent()
                    : Value(row['roommates']),
                nationalId: row['national_id'] == null
                    ? const Value.absent()
                    : Value(row['national_id']),
                idFrontImage: row['id_front_image'] == null
                    ? const Value.absent()
                    : Value(row['id_front_image']),
                idBackImage: row['id_back_image'] == null
                    ? const Value.absent()
                    : Value(row['id_back_image']),
                contractFrontImage: row['contract_front_image'] == null
                    ? const Value.absent()
                    : Value(row['contract_front_image']),
                contractBackImage: row['contract_back_image'] == null
                    ? const Value.absent()
                    : Value(row['contract_back_image']),
                createdAt: row['created_at'] == null
                    ? const Value.absent()
                    : Value(DateTime.parse(row['created_at'])),
                updatedAt: row['updated_at'] == null
                    ? const Value.absent()
                    : Value(DateTime.parse(row['updated_at'])),
                syncStatus: const Value(SyncStatus.synced),
              ),
            );
      }

      // Sync WinterPayments
      final winterPaymentsData = await supabase
          .from('winter_payments')
          .select();
      for (final row in winterPaymentsData) {
        await db
            .into(db.winterPayments)
            .insertOnConflictUpdate(
              WinterPaymentsCompanion(
                id: row['id'] == null ? const Value.absent() : Value(row['id']),
                contractId: row['contract_id'] == null
                    ? const Value.absent()
                    : Value(row['contract_id']),
                amountEgp: row['amount_egp'] == null
                    ? const Value.absent()
                    : Value((row['amount_egp'] as num).toDouble()),
                paymentDate: row['payment_date'] == null
                    ? const Value.absent()
                    : Value(DateTime.parse(row['payment_date'])),
                paymentMethod: row['payment_method'] == null
                    ? const Value.absent()
                    : Value(row['payment_method']),
                receiptUrl: row['receipt_url'] == null
                    ? const Value.absent()
                    : Value(row['receipt_url']),
                createdAt: row['created_at'] == null
                    ? const Value.absent()
                    : Value(DateTime.parse(row['created_at'])),
                syncStatus: const Value(SyncStatus.synced),
              ),
            );
      }

      // Sync BookingPayments
      final bookingPaymentsData = await supabase
          .from('booking_payments')
          .select();
      for (final row in bookingPaymentsData) {
        await db
            .into(db.bookingPayments)
            .insertOnConflictUpdate(
              BookingPaymentsCompanion(
                id: row['id'] == null ? const Value.absent() : Value(row['id']),
                bookingId: row['booking_id'] == null
                    ? const Value.absent()
                    : Value(row['booking_id']),
                amountEgp: row['amount_egp'] == null
                    ? const Value.absent()
                    : Value((row['amount_egp'] as num).toDouble()),
                paymentMethod: row['payment_method'] == null
                    ? const Value.absent()
                    : Value(row['payment_method']),
                paymentDate: row['payment_date'] == null
                    ? const Value.absent()
                    : Value(DateTime.parse(row['payment_date'])),
                notes: row['notes'] == null
                    ? const Value.absent()
                    : Value(row['notes']),
                createdAt: row['created_at'] == null
                    ? const Value.absent()
                    : Value(DateTime.parse(row['created_at'])),
                syncStatus: const Value(SyncStatus.synced),
              ),
            );
      }

      // Sync MeterReadings
      final meterReadingsData = await supabase.from('meter_readings').select();
      for (final row in meterReadingsData) {
        await db
            .into(db.meterReadings)
            .insertOnConflictUpdate(
              MeterReadingsCompanion(
                id: row['id'] == null ? const Value.absent() : Value(row['id']),
                apartmentId: row['apartment_id'] == null
                    ? const Value.absent()
                    : Value(row['apartment_id']),
                buildingId: row['building_id'] == null
                    ? const Value.absent()
                    : Value(row['building_id']),
                readingDate: row['reading_date'] == null
                    ? const Value.absent()
                    : Value(DateTime.parse(row['reading_date'])),
                previousReading: row['previous_reading'] == null
                    ? const Value.absent()
                    : Value((row['previous_reading'] as num).toDouble()),
                currentReading: row['current_reading'] == null
                    ? const Value.absent()
                    : Value((row['current_reading'] as num).toDouble()),
                amountEgp: row['amount_egp'] == null
                    ? const Value.absent()
                    : Value((row['amount_egp'] as num).toDouble()),
                isSharedExpense: row['is_shared_expense'] == null
                    ? const Value.absent()
                    : Value(row['is_shared_expense']),
                createdAt: row['created_at'] == null
                    ? const Value.absent()
                    : Value(DateTime.parse(row['created_at'])),
                syncStatus: const Value(SyncStatus.synced),
              ),
            );
      }

      // Sync Expenses
      final expensesData = await supabase.from('expenses').select();
      for (final row in expensesData) {
        await db
            .into(db.expenses)
            .insertOnConflictUpdate(
              ExpensesCompanion(
                id: row['id'] == null ? const Value.absent() : Value(row['id']),
                buildingId: row['building_id'] == null
                    ? const Value.absent()
                    : Value(row['building_id']),
                apartmentId: row['apartment_id'] == null
                    ? const Value.absent()
                    : Value(row['apartment_id']),
                expenseType: row['expense_type'] == null
                    ? const Value.absent()
                    : Value(row['expense_type']),
                amountEgp: row['amount_egp'] == null
                    ? const Value.absent()
                    : Value((row['amount_egp'] as num).toDouble()),
                paymentMethod: row['payment_method'] == null
                    ? const Value.absent()
                    : Value(row['payment_method']),
                season: row['season'] == null
                    ? const Value.absent()
                    : Value(row['season']),
                discountEgp: row['discount_egp'] == null
                    ? const Value.absent()
                    : Value((row['discount_egp'] as num).toDouble()),
                discountReason: row['discount_reason'] == null
                    ? const Value.absent()
                    : Value(row['discount_reason']),
                expenseDate: row['expense_date'] == null
                    ? const Value.absent()
                    : Value(DateTime.parse(row['expense_date'])),
                installmentNumber: row['installment_number'] == null
                    ? const Value.absent()
                    : Value((row['installment_number'] as num).toInt()),
                description: row['description'] == null
                    ? const Value.absent()
                    : Value(row['description']),
                receiptUrl: row['receipt_url'] == null
                    ? const Value.absent()
                    : Value(row['receipt_url']),
                createdAt: row['created_at'] == null
                    ? const Value.absent()
                    : Value(DateTime.parse(row['created_at'])),
                syncStatus: const Value(SyncStatus.synced),
              ),
            );
      }

      // Sync FinancialTransfers
      final financialTransfersData = await supabase
          .from('financial_transfers')
          .select();
      for (final row in financialTransfersData) {
        await db
            .into(db.financialTransfers)
            .insertOnConflictUpdate(
              FinancialTransfersCompanion(
                id: row['id'] == null ? const Value.absent() : Value(row['id']),
                fromAccount: row['from_account'] == null
                    ? const Value.absent()
                    : Value(row['from_account']),
                toAccount: row['to_account'] == null
                    ? const Value.absent()
                    : Value(row['to_account']),
                transferType: row['transfer_type'] == null
                    ? const Value.absent()
                    : Value(row['transfer_type']),
                season: row['season'] == null
                    ? const Value.absent()
                    : Value(row['season']),
                amountEgp: row['amount_egp'] == null
                    ? const Value.absent()
                    : Value((row['amount_egp'] as num).toDouble()),
                transferDate: row['transfer_date'] == null
                    ? const Value.absent()
                    : Value(DateTime.parse(row['transfer_date'])),
                notes: row['notes'] == null
                    ? const Value.absent()
                    : Value(row['notes']),
                createdAt: row['created_at'] == null
                    ? const Value.absent()
                    : Value(DateTime.parse(row['created_at'])),
                syncStatus: const Value(SyncStatus.synced),
              ),
            );
      }

      // Sync Technicians
      final techniciansData = await supabase.from('technicians').select();
      for (final row in techniciansData) {
        await db
            .into(db.technicians)
            .insertOnConflictUpdate(
              TechniciansCompanion(
                id: row['id'] == null ? const Value.absent() : Value(row['id']),
                name: row['name'] == null
                    ? const Value.absent()
                    : Value(row['name']),
                phone: row['phone'] == null
                    ? const Value.absent()
                    : Value(row['phone']),
                secondaryPhone: row['secondary_phone'] == null
                    ? const Value.absent()
                    : Value(row['secondary_phone']),
                specialty: row['specialty'] == null
                    ? const Value.absent()
                    : Value(row['specialty']),
                notes: row['notes'] == null
                    ? const Value.absent()
                    : Value(row['notes']),
                createdAt: row['created_at'] == null
                    ? const Value.absent()
                    : Value(DateTime.parse(row['created_at'])),
                syncStatus: const Value(SyncStatus.synced),
              ),
            );
      }

      // Sync CleaningSupplies
      final cleaningSuppliesData = await supabase
          .from('cleaning_supplies')
          .select();
      for (final row in cleaningSuppliesData) {
        await db
            .into(db.cleaningSupplies)
            .insertOnConflictUpdate(
              CleaningSuppliesCompanion(
                id: row['id'] == null ? const Value.absent() : Value(row['id']),
                name: row['name'] == null
                    ? const Value.absent()
                    : Value(row['name']),
                stockQuantity: row['stock_quantity'] == null
                    ? const Value.absent()
                    : Value((row['stock_quantity'] as num).toDouble()),
                unit: row['unit'] == null
                    ? const Value.absent()
                    : Value(row['unit']),
                createdAt: row['created_at'] == null
                    ? const Value.absent()
                    : Value(DateTime.parse(row['created_at'])),
                updatedAt: row['updated_at'] == null
                    ? const Value.absent()
                    : Value(DateTime.parse(row['updated_at'])),
                syncStatus: const Value(SyncStatus.synced),
              ),
            );
      }

      // Sync CleaningTransactions
      final cleaningTransactionsData = await supabase
          .from('cleaning_transactions')
          .select();
      for (final row in cleaningTransactionsData) {
        await db
            .into(db.cleaningTransactions)
            .insertOnConflictUpdate(
              CleaningTransactionsCompanion(
                id: row['id'] == null ? const Value.absent() : Value(row['id']),
                supplyId: row['supply_id'] == null
                    ? const Value.absent()
                    : Value(row['supply_id']),
                transactionType: row['transaction_type'] == null
                    ? const Value.absent()
                    : Value(row['transaction_type']),
                quantity: row['quantity'] == null
                    ? const Value.absent()
                    : Value((row['quantity'] as num).toDouble()),
                costEgp: row['cost_egp'] == null
                    ? const Value.absent()
                    : Value((row['cost_egp'] as num).toDouble()),
                transactionDate: row['transaction_date'] == null
                    ? const Value.absent()
                    : Value(DateTime.parse(row['transaction_date'])),
                notes: row['notes'] == null
                    ? const Value.absent()
                    : Value(row['notes']),
                createdAt: row['created_at'] == null
                    ? const Value.absent()
                    : Value(DateTime.parse(row['created_at'])),
                syncStatus: const Value(SyncStatus.synced),
              ),
            );
      }

      // Sync ApartmentInspections
      final apartmentInspectionsData = await supabase
          .from('apartment_inspections')
          .select();
      for (final row in apartmentInspectionsData) {
        await db
            .into(db.apartmentInspections)
            .insertOnConflictUpdate(
              ApartmentInspectionsCompanion(
                id: row['id'] == null ? const Value.absent() : Value(row['id']),
                apartmentId: row['apartment_id'] == null
                    ? const Value.absent()
                    : Value(row['apartment_id']),
                inspectionDate: row['inspection_date'] == null
                    ? const Value.absent()
                    : Value(DateTime.parse(row['inspection_date'])),
                isClean: row['is_clean'] == null
                    ? const Value.absent()
                    : Value(row['is_clean']),
                hasDamages: row['has_damages'] == null
                    ? const Value.absent()
                    : Value(row['has_damages']),
                damagesDescription: row['damages_description'] == null
                    ? const Value.absent()
                    : Value(row['damages_description']),
                tenantFineEgp: row['tenant_fine_egp'] == null
                    ? const Value.absent()
                    : Value((row['tenant_fine_egp'] as num).toDouble()),
                ownerRepairCostEgp: row['owner_repair_cost_egp'] == null
                    ? const Value.absent()
                    : Value((row['owner_repair_cost_egp'] as num).toDouble()),
                inspectorName: row['inspector_name'] == null
                    ? const Value.absent()
                    : Value(row['inspector_name']),
                notes: row['notes'] == null
                    ? const Value.absent()
                    : Value(row['notes']),
                createdAt: row['created_at'] == null
                    ? const Value.absent()
                    : Value(DateTime.parse(row['created_at'])),
                updatedAt: row['updated_at'] == null
                    ? const Value.absent()
                    : Value(DateTime.parse(row['updated_at'])),
                syncStatus: const Value(SyncStatus.synced),
              ),
            );
      }

      // Sync MaintenanceRequests
      final maintenanceRequestsData = await supabase
          .from('maintenance_requests')
          .select();
      for (final row in maintenanceRequestsData) {
        await db
            .into(db.maintenanceRequests)
            .insertOnConflictUpdate(
              MaintenanceRequestsCompanion(
                id: row['id'] == null ? const Value.absent() : Value(row['id']),
                apartmentId: row['apartment_id'] == null
                    ? const Value.absent()
                    : Value(row['apartment_id']),
                technicianId: row['technician_id'] == null
                    ? const Value.absent()
                    : Value(row['technician_id']),
                reportedBy: row['reported_by'] == null
                    ? const Value.absent()
                    : Value(row['reported_by']),
                issueDescription: row['issue_description'] == null
                    ? const Value.absent()
                    : Value(row['issue_description']),
                status: row['status'] == null
                    ? const Value.absent()
                    : Value(row['status']),
                costEgp: row['cost_egp'] == null
                    ? const Value.absent()
                    : Value((row['cost_egp'] as num).toDouble()),
                resolvedAt: row['resolved_at'] == null
                    ? const Value.absent()
                    : Value(DateTime.parse(row['resolved_at'])),
                createdAt: row['created_at'] == null
                    ? const Value.absent()
                    : Value(DateTime.parse(row['created_at'])),
                updatedAt: row['updated_at'] == null
                    ? const Value.absent()
                    : Value(DateTime.parse(row['updated_at'])),
                syncStatus: const Value(SyncStatus.synced),
              ),
            );
      }

      // Sync AuditLogs
      final auditLogsData = await supabase.from('audit_logs').select();
      for (final row in auditLogsData) {
        await db
            .into(db.auditLogs)
            .insertOnConflictUpdate(
              AuditLogsCompanion(
                id: row['id'] == null ? const Value.absent() : Value(row['id']),
                actorUserId: row['actor_user_id'] == null
                    ? const Value.absent()
                    : Value(row['actor_user_id']),
                actorName: row['actor_name'] == null
                    ? const Value.absent()
                    : Value(row['actor_name']),
                action: row['action'] == null
                    ? const Value.absent()
                    : Value(row['action']),
                entityType: row['entity_type'] == null
                    ? const Value.absent()
                    : Value(row['entity_type']),
                entityId: row['entity_id'] == null
                    ? const Value.absent()
                    : Value(row['entity_id']),
                title: row['title'] == null
                    ? const Value.absent()
                    : Value(row['title']),
                description: row['description'] == null
                    ? const Value.absent()
                    : Value(row['description']),
                route: row['route'] == null
                    ? const Value.absent()
                    : Value(row['route']),
                oldValuesJson: row['old_values_json'] == null
                    ? const Value.absent()
                    : Value(row['old_values_json']),
                newValuesJson: row['new_values_json'] == null
                    ? const Value.absent()
                    : Value(row['new_values_json']),
                createdAt: row['created_at'] == null
                    ? const Value.absent()
                    : Value(DateTime.parse(row['created_at'])),
                syncStatus: const Value(SyncStatus.synced),
              ),
            );
      }
    } catch (e) {
      rethrow;
    }
  }
}
