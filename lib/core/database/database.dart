import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    UserProfiles,
    Buildings,
    Apartments,
    SummerBookings,
    WinterContracts,
    WinterPayments,
    MeterReadings,
    Expenses,
    FinancialTransfers,
    Technicians,
    CleaningSupplies,
    CleaningTransactions,
    ApartmentInspections,
    MaintenanceRequests,
    AuditLogs,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 21;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 3) {
          try {
            await m.createTable(userProfiles);
          } catch (_) {
            // Ignore if this legacy migration was already applied.
          }
        }
        if (from < 4) {
          try {
            await m.addColumn(
              winterContracts,
              winterContracts.isElectricityOnStudent,
            );
          } catch (_) {
            // Ignore if this legacy migration was already applied.
          }
        }
        if (from < 5) {
          try {
            await m.addColumn(summerBookings, summerBookings.paymentMethod);
            await m.addColumn(
              summerBookings,
              summerBookings.brokerCommissionType,
            );
            await m.addColumn(
              summerBookings,
              summerBookings.brokerCommissionFixedEgp,
            );
            await m.addColumn(expenses, expenses.discountEgp);
            await m.addColumn(expenses, expenses.discountReason);
          } catch (_) {
            // Ignore if this legacy migration was already applied.
          }
        }
        if (from < 6) {
          try {
            await m.addColumn(winterPayments, winterPayments.paymentMethod);
          } catch (_) {
            // Ignore if this legacy migration was already applied.
          }
        }
        if (from < 7) {
          try {
            await m.addColumn(winterContracts, winterContracts.roommates);
          } catch (_) {
            // Ignore if this legacy migration was already applied.
          }
        }
        if (from < 8) {
          try {
            await m.addColumn(summerBookings, summerBookings.nationalId);
            await m.addColumn(summerBookings, summerBookings.idFrontImage);
            await m.addColumn(summerBookings, summerBookings.idBackImage);
            await m.addColumn(winterContracts, winterContracts.isGasOnStudent);
            await m.addColumn(
              winterContracts,
              winterContracts.isWaterOnStudent,
            );
            await m.addColumn(winterContracts, winterContracts.nationalId);
            await m.addColumn(winterContracts, winterContracts.idFrontImage);
            await m.addColumn(winterContracts, winterContracts.idBackImage);
          } catch (_) {
            // Ignore if this legacy migration was already applied.
          }
        }
        if (from < 9) {
          try {
            await m.addColumn(summerBookings, summerBookings.brokerName);
          } catch (_) {
            // Ignore if this legacy migration was already applied.
          }
        }
        if (from < 10) {
          try {
            await m.addColumn(apartments, apartments.inventory);
          } catch (_) {
            // Ignore if this legacy migration was already applied.
          }
        }
        if (from < 11) {
          try {
            await m.addColumn(buildings, buildings.annualRentEgp);
            await m.addColumn(buildings, buildings.rentInstallmentsDates);
          } catch (_) {
            // Ignore if this legacy migration was already applied.
          }
        }
        if (from < 12) {
          try {
            await m.createTable(technicians);
            await m.addColumn(
              maintenanceRequests,
              maintenanceRequests.technicianId,
            );
          } catch (_) {
            // Ignore if this legacy migration was already applied.
          }
        }
        if (from < 13) {
          try {
            await m.addColumn(winterContracts, winterContracts.contractType);
            await m.addColumn(
              winterContracts,
              winterContracts.contractFrontImage,
            );
            await m.addColumn(
              winterContracts,
              winterContracts.contractBackImage,
            );
          } catch (_) {
            // Ignore if this legacy migration was already applied.
          }
        }
        if (from < 14) {
          try {
            await m.createTable(cleaningSupplies);
            await m.createTable(cleaningTransactions);
            await m.createTable(apartmentInspections);
          } catch (_) {
            // Ignore if this legacy migration was already applied.
          }
        }
        if (from < 15) {
          try {
            await m.addColumn(apartments, apartments.landlineNumber);
            await m.addColumn(apartments, apartments.landlineOwnerName);
            await m.addColumn(apartments, apartments.landlineNotes);
          } catch (_) {
            // Ignore if this legacy migration was already applied.
          }
        }
        if (from < 16) {
          try {
            await m.createTable(auditLogs);
          } catch (_) {
            // Ignore if this legacy migration was already applied.
          }
        }
        if (from < 17) {
          try {
            await m.addColumn(expenses, expenses.paymentMethod);
            await m.createTable(financialTransfers);
          } catch (_) {
            // Ignore if this legacy migration was already applied.
          }
        }
        if (from < 18) {
          try {
            await m.addColumn(financialTransfers, financialTransfers.transferType);
            await m.addColumn(financialTransfers, financialTransfers.season);
          } catch (_) {
            // Ignore if this legacy migration was already applied.
          }
        }
        if (from < 19) {
          try {
            await m.addColumn(expenses, expenses.season);
          } catch (_) {
            // Ignore if this legacy migration was already applied.
          }
        }
        if (from < 20) {
          try {
            await m.addColumn(userProfiles, userProfiles.secondaryPhone);
          } catch (_) {
            // Ignore if this legacy migration was already applied.
          }
        }
        if (from < 21) {
          try {
            await m.addColumn(technicians, technicians.secondaryPhone);
          } catch (_) {
            // Ignore if this legacy migration was already applied.
          }
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'abrag_local_v4.sqlite'));

    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file);
  });
}
