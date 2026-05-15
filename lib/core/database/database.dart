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
    Technicians,
    CleaningSupplies,
    CleaningTransactions,
    ApartmentInspections,
    MaintenanceRequests,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 14;

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
          } catch (e) {}
        }
        if (from < 4) {
          try {
            await m.addColumn(
              winterContracts,
              winterContracts.isElectricityOnStudent,
            );
          } catch (e) {}
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
          } catch (e) {}
        }
        if (from < 6) {
          try {
            await m.addColumn(winterPayments, winterPayments.paymentMethod);
          } catch (e) {}
        }
        if (from < 7) {
          try {
            await m.addColumn(winterContracts, winterContracts.roommates);
          } catch (e) {}
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
          } catch (e) {}
        }
        if (from < 9) {
          try {
            await m.addColumn(summerBookings, summerBookings.brokerName);
          } catch (e) {}
        }
        if (from < 10) {
          try { await m.addColumn(apartments, apartments.inventory); } catch (e) {}
        }
        if (from < 11) {
          try {
            await m.addColumn(buildings, buildings.annualRentEgp);
            await m.addColumn(buildings, buildings.rentInstallmentsDates);
          } catch (e) {}
        }
        if (from < 12) {
          try {
            await m.createTable(technicians);
            await m.addColumn(maintenanceRequests, maintenanceRequests.technicianId);
          } catch (e) {}
        }
        if (from < 13) {
          try {
            await m.addColumn(winterContracts, winterContracts.contractType);
            await m.addColumn(winterContracts, winterContracts.contractFrontImage);
            await m.addColumn(winterContracts, winterContracts.contractBackImage);
          } catch (e) {}
        }
        if (from < 14) {
          try {
            await m.createTable(cleaningSupplies);
            await m.createTable(cleaningTransactions);
            await m.createTable(apartmentInspections);
          } catch (e) {}
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
