import 'package:drift/drift.dart';

enum SyncStatus {
  synced,
  pendingInsert,
  pendingUpdate,
  pendingDelete,
}

mixin SyncableTable on Table {
  IntColumn get syncStatus => intEnum<SyncStatus>().withDefault(const Constant(0))();
  DateTimeColumn get lastModifiedLocal => dateTime().withDefault(currentDateAndTime)();
}

class Buildings extends Table with SyncableTable {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get address => text().nullable()();
  IntColumn get totalApartments => integer().withDefault(const Constant(15))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Apartments extends Table with SyncableTable {
  TextColumn get id => text()();
  TextColumn get buildingId => text().references(Buildings, #id)();
  TextColumn get apartmentNumber => text()();
  IntColumn get floorNumber => integer().nullable()();
  TextColumn get cleaningStatus => text().withDefault(const Constant('clean'))();
  BoolColumn get brokerVisibility => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class SummerBookings extends Table with SyncableTable {
  TextColumn get id => text()();
  TextColumn get apartmentId => text().references(Apartments, #id)();
  TextColumn get guestName => text()();
  TextColumn get guestPhone => text().nullable()();
  DateTimeColumn get checkInDate => dateTime()();
  DateTimeColumn get checkOutDate => dateTime()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  RealColumn get totalPriceEgp => real()();
  RealColumn get amountPaidEgp => real().withDefault(const Constant(0))();
  TextColumn get brokerId => text().nullable()();
  RealColumn get brokerCommissionPercentage => real().withDefault(const Constant(10.0))();
  RealColumn get brokerCommissionAmountEgp => real().nullable()(); // Computed in Supabase
  DateTimeColumn get earlyCheckoutDate => dateTime().nullable()();
  IntColumn get overstayDays => integer().withDefault(const Constant(0))();
  RealColumn get overstayFeeEgp => real().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class WinterContracts extends Table with SyncableTable {
  TextColumn get id => text()();
  TextColumn get apartmentId => text().references(Apartments, #id)();
  TextColumn get studentName => text()();
  TextColumn get university => text().nullable()();
  TextColumn get parentName => text().nullable()();
  TextColumn get parentPhone => text().nullable()();
  TextColumn get viewerUserId => text().nullable()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  RealColumn get monthlyRentEgp => real()();
  RealColumn get depositEgp => real().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class WinterPayments extends Table with SyncableTable {
  TextColumn get id => text()();
  TextColumn get contractId => text().references(WinterContracts, #id)();
  RealColumn get amountEgp => real()();
  DateTimeColumn get paymentDate => dateTime()();
  TextColumn get receiptUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class MeterReadings extends Table with SyncableTable {
  TextColumn get id => text()();
  TextColumn get apartmentId => text().nullable().references(Apartments, #id)();
  TextColumn get buildingId => text().nullable().references(Buildings, #id)();
  DateTimeColumn get readingDate => dateTime()();
  RealColumn get previousReading => real()();
  RealColumn get currentReading => real()();
  RealColumn get amountEgp => real()();
  BoolColumn get isSharedExpense => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Expenses extends Table with SyncableTable {
  TextColumn get id => text()();
  TextColumn get buildingId => text().nullable().references(Buildings, #id)();
  TextColumn get apartmentId => text().nullable().references(Apartments, #id)();
  TextColumn get expenseType => text()();
  RealColumn get amountEgp => real()();
  DateTimeColumn get expenseDate => dateTime()();
  IntColumn get installmentNumber => integer().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get receiptUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class MaintenanceRequests extends Table with SyncableTable {
  TextColumn get id => text()();
  TextColumn get apartmentId => text().references(Apartments, #id)();
  TextColumn get reportedBy => text()();
  TextColumn get issueDescription => text()();
  TextColumn get status => text().withDefault(const Constant('open'))();
  RealColumn get costEgp => real().withDefault(const Constant(0))();
  DateTimeColumn get resolvedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
