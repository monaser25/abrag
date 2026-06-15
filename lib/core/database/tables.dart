import 'package:drift/drift.dart';

enum SyncStatus { synced, pendingInsert, pendingUpdate, pendingDelete }

mixin SyncableTable on Table {
  IntColumn get syncStatus =>
      intEnum<SyncStatus>().withDefault(const Constant(0))();
  DateTimeColumn get lastModifiedLocal =>
      dateTime().withDefault(currentDateAndTime)();
}

class UserProfiles extends Table with SyncableTable {
  TextColumn get id => text()();
  TextColumn get email => text()();
  TextColumn get fullName => text().nullable()();
  TextColumn get phoneNumber => text().nullable()();
  TextColumn get secondaryPhone => text().nullable()();
  TextColumn get role => text().withDefault(const Constant('viewer'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Buildings extends Table with SyncableTable {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get address => text().nullable()();
  RealColumn get annualRentEgp => real().withDefault(const Constant(0))();
  TextColumn get rentInstallmentsDates => text().nullable()();
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
  TextColumn get cleaningStatus =>
      text().withDefault(const Constant('clean'))();
  BoolColumn get brokerVisibility =>
      boolean().withDefault(const Constant(false))();
  TextColumn get inventory => text().nullable()();
  TextColumn get landlineNumber => text().nullable()();
  TextColumn get landlineOwnerName => text().nullable()();
  TextColumn get landlineNotes => text().nullable()();
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
  TextColumn get paymentMethod => text().withDefault(const Constant('cash'))();
  TextColumn get brokerId => text().nullable()();
  TextColumn get brokerName => text().nullable()();
  TextColumn get brokerCommissionType =>
      text().withDefault(const Constant('none'))(); // none, percentage, fixed
  RealColumn get brokerCommissionPercentage =>
      real().withDefault(const Constant(10.0))();
  RealColumn get brokerCommissionFixedEgp =>
      real().withDefault(const Constant(0))();
  RealColumn get brokerCommissionAmountEgp =>
      real().nullable()(); // Computed in Supabase
  DateTimeColumn get earlyCheckoutDate => dateTime().nullable()();
  IntColumn get overstayDays => integer().withDefault(const Constant(0))();
  RealColumn get overstayFeeEgp => real().withDefault(const Constant(0))();
  TextColumn get nationalId => text().nullable()();
  TextColumn get idFrontImage => text().nullable()();
  TextColumn get idBackImage => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class WinterContracts extends Table with SyncableTable {
  TextColumn get id => text()();
  TextColumn get apartmentId => text().references(Apartments, #id)();
  TextColumn get contractType =>
      text().withDefault(const Constant('student'))(); // 'student' or 'family'
  TextColumn get studentName => text()(); // or head of family name
  TextColumn get university =>
      text().nullable()(); // stores university and faculty
  TextColumn get parentName => text().nullable()();
  TextColumn get parentPhone => text().nullable()();
  TextColumn get viewerUserId => text().nullable()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  RealColumn get monthlyRentEgp => real()();
  RealColumn get depositEgp => real().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get isElectricityOnStudent =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get isGasOnStudent =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get isWaterOnStudent =>
      boolean().withDefault(const Constant(false))();
  TextColumn get roommates =>
      text().nullable()(); // JSON string containing roommate details
  TextColumn get nationalId => text().nullable()();
  TextColumn get idFrontImage => text().nullable()();
  TextColumn get idBackImage => text().nullable()();
  TextColumn get contractFrontImage => text().nullable()();
  TextColumn get contractBackImage => text().nullable()();
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
  TextColumn get paymentMethod => text().withDefault(const Constant('cash'))();
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
  BoolColumn get isSharedExpense =>
      boolean().withDefault(const Constant(false))();
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
  TextColumn get paymentMethod => text().withDefault(const Constant('cash'))();
  TextColumn get season => text().withDefault(const Constant('all'))();
  RealColumn get discountEgp => real().withDefault(const Constant(0))();
  TextColumn get discountReason => text().nullable()();
  DateTimeColumn get expenseDate => dateTime()();
  IntColumn get installmentNumber => integer().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get receiptUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class FinancialTransfers extends Table with SyncableTable {
  TextColumn get id => text()();
  TextColumn get fromAccount => text()();
  TextColumn get toAccount => text()();
  TextColumn get transferType => text().withDefault(const Constant('internal'))();
  TextColumn get season => text().withDefault(const Constant('all'))();
  RealColumn get amountEgp => real()();
  DateTimeColumn get transferDate => dateTime()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Technicians extends Table with SyncableTable {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get specialty => text()(); // e.g., سباكة, نجارة, كهرباء
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class CleaningSupplies extends Table with SyncableTable {
  TextColumn get id => text()();
  TextColumn get name => text()(); // اسم المنتج (كلور، معطر، صابون)
  RealColumn get stockQuantity => real().withDefault(const Constant(0))();
  TextColumn get unit =>
      text().withDefault(const Constant('عبوة'))(); // لتر، كيلو، عبوة
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class CleaningTransactions extends Table with SyncableTable {
  TextColumn get id => text()();
  TextColumn get supplyId => text().references(CleaningSupplies, #id)();
  TextColumn get transactionType => text()(); // 'purchase' or 'consumption'
  RealColumn get quantity => real()();
  RealColumn get costEgp =>
      real().withDefault(const Constant(0))(); // for purchases
  DateTimeColumn get transactionDate => dateTime()();
  TextColumn get notes => text().nullable()(); // شقة 5, أو اسم المحل
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class ApartmentInspections extends Table with SyncableTable {
  TextColumn get id => text()();
  TextColumn get apartmentId => text().references(Apartments, #id)();
  DateTimeColumn get inspectionDate => dateTime()();
  BoolColumn get isClean => boolean().withDefault(const Constant(true))();
  BoolColumn get hasDamages => boolean().withDefault(const Constant(false))();
  TextColumn get damagesDescription => text().nullable()(); // تفاصيل التلفيات
  RealColumn get tenantFineEgp =>
      real().withDefault(const Constant(0))(); // ما يدفعه المستأجر
  RealColumn get ownerRepairCostEgp =>
      real().withDefault(const Constant(0))(); // ما نتحمله نحن
  TextColumn get inspectorName => text()(); // الشخص اللي عمل التشيك
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class MaintenanceRequests extends Table with SyncableTable {
  TextColumn get id => text()();
  TextColumn get apartmentId => text().references(Apartments, #id)();
  TextColumn get technicianId =>
      text().nullable().references(Technicians, #id)();
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

class AuditLogs extends Table with SyncableTable {
  TextColumn get id => text()();
  TextColumn get actorUserId => text().nullable()();
  TextColumn get actorName => text()();
  TextColumn get action => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get route => text().nullable()();
  TextColumn get oldValuesJson => text().nullable()();
  TextColumn get newValuesJson => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
