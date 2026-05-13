// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $BuildingsTable extends Buildings
    with TableInfo<$BuildingsTable, Building> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BuildingsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<SyncStatus>($BuildingsTable.$convertersyncStatus);
  static const VerificationMeta _lastModifiedLocalMeta = const VerificationMeta(
    'lastModifiedLocal',
  );
  @override
  late final GeneratedColumn<DateTime> lastModifiedLocal =
      GeneratedColumn<DateTime>(
        'last_modified_local',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalApartmentsMeta = const VerificationMeta(
    'totalApartments',
  );
  @override
  late final GeneratedColumn<int> totalApartments = GeneratedColumn<int>(
    'total_apartments',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(15),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    syncStatus,
    lastModifiedLocal,
    id,
    name,
    address,
    totalApartments,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'buildings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Building> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('last_modified_local')) {
      context.handle(
        _lastModifiedLocalMeta,
        lastModifiedLocal.isAcceptableOrUnknown(
          data['last_modified_local']!,
          _lastModifiedLocalMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('total_apartments')) {
      context.handle(
        _totalApartmentsMeta,
        totalApartments.isAcceptableOrUnknown(
          data['total_apartments']!,
          _totalApartmentsMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Building map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Building(
      syncStatus: $BuildingsTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      lastModifiedLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified_local'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      totalApartments: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_apartments'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BuildingsTable createAlias(String alias) {
    return $BuildingsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class Building extends DataClass implements Insertable<Building> {
  final SyncStatus syncStatus;
  final DateTime lastModifiedLocal;
  final String id;
  final String name;
  final String? address;
  final int totalApartments;
  final DateTime createdAt;
  const Building({
    required this.syncStatus,
    required this.lastModifiedLocal,
    required this.id,
    required this.name,
    this.address,
    required this.totalApartments,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['sync_status'] = Variable<int>(
        $BuildingsTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['last_modified_local'] = Variable<DateTime>(lastModifiedLocal);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    map['total_apartments'] = Variable<int>(totalApartments);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BuildingsCompanion toCompanion(bool nullToAbsent) {
    return BuildingsCompanion(
      syncStatus: Value(syncStatus),
      lastModifiedLocal: Value(lastModifiedLocal),
      id: Value(id),
      name: Value(name),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      totalApartments: Value(totalApartments),
      createdAt: Value(createdAt),
    );
  }

  factory Building.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Building(
      syncStatus: $BuildingsTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
      lastModifiedLocal: serializer.fromJson<DateTime>(
        json['lastModifiedLocal'],
      ),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      address: serializer.fromJson<String?>(json['address']),
      totalApartments: serializer.fromJson<int>(json['totalApartments']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncStatus': serializer.toJson<int>(
        $BuildingsTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'lastModifiedLocal': serializer.toJson<DateTime>(lastModifiedLocal),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'address': serializer.toJson<String?>(address),
      'totalApartments': serializer.toJson<int>(totalApartments),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Building copyWith({
    SyncStatus? syncStatus,
    DateTime? lastModifiedLocal,
    String? id,
    String? name,
    Value<String?> address = const Value.absent(),
    int? totalApartments,
    DateTime? createdAt,
  }) => Building(
    syncStatus: syncStatus ?? this.syncStatus,
    lastModifiedLocal: lastModifiedLocal ?? this.lastModifiedLocal,
    id: id ?? this.id,
    name: name ?? this.name,
    address: address.present ? address.value : this.address,
    totalApartments: totalApartments ?? this.totalApartments,
    createdAt: createdAt ?? this.createdAt,
  );
  Building copyWithCompanion(BuildingsCompanion data) {
    return Building(
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastModifiedLocal: data.lastModifiedLocal.present
          ? data.lastModifiedLocal.value
          : this.lastModifiedLocal,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      address: data.address.present ? data.address.value : this.address,
      totalApartments: data.totalApartments.present
          ? data.totalApartments.value
          : this.totalApartments,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Building(')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedLocal: $lastModifiedLocal, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('totalApartments: $totalApartments, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    syncStatus,
    lastModifiedLocal,
    id,
    name,
    address,
    totalApartments,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Building &&
          other.syncStatus == this.syncStatus &&
          other.lastModifiedLocal == this.lastModifiedLocal &&
          other.id == this.id &&
          other.name == this.name &&
          other.address == this.address &&
          other.totalApartments == this.totalApartments &&
          other.createdAt == this.createdAt);
}

class BuildingsCompanion extends UpdateCompanion<Building> {
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> lastModifiedLocal;
  final Value<String> id;
  final Value<String> name;
  final Value<String?> address;
  final Value<int> totalApartments;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BuildingsCompanion({
    this.syncStatus = const Value.absent(),
    this.lastModifiedLocal = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.address = const Value.absent(),
    this.totalApartments = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BuildingsCompanion.insert({
    this.syncStatus = const Value.absent(),
    this.lastModifiedLocal = const Value.absent(),
    required String id,
    required String name,
    this.address = const Value.absent(),
    this.totalApartments = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<Building> custom({
    Expression<int>? syncStatus,
    Expression<DateTime>? lastModifiedLocal,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? address,
    Expression<int>? totalApartments,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastModifiedLocal != null) 'last_modified_local': lastModifiedLocal,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (address != null) 'address': address,
      if (totalApartments != null) 'total_apartments': totalApartments,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BuildingsCompanion copyWith({
    Value<SyncStatus>? syncStatus,
    Value<DateTime>? lastModifiedLocal,
    Value<String>? id,
    Value<String>? name,
    Value<String?>? address,
    Value<int>? totalApartments,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return BuildingsCompanion(
      syncStatus: syncStatus ?? this.syncStatus,
      lastModifiedLocal: lastModifiedLocal ?? this.lastModifiedLocal,
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      totalApartments: totalApartments ?? this.totalApartments,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $BuildingsTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (lastModifiedLocal.present) {
      map['last_modified_local'] = Variable<DateTime>(lastModifiedLocal.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (totalApartments.present) {
      map['total_apartments'] = Variable<int>(totalApartments.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BuildingsCompanion(')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedLocal: $lastModifiedLocal, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('totalApartments: $totalApartments, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ApartmentsTable extends Apartments
    with TableInfo<$ApartmentsTable, Apartment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ApartmentsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<SyncStatus>($ApartmentsTable.$convertersyncStatus);
  static const VerificationMeta _lastModifiedLocalMeta = const VerificationMeta(
    'lastModifiedLocal',
  );
  @override
  late final GeneratedColumn<DateTime> lastModifiedLocal =
      GeneratedColumn<DateTime>(
        'last_modified_local',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _buildingIdMeta = const VerificationMeta(
    'buildingId',
  );
  @override
  late final GeneratedColumn<String> buildingId = GeneratedColumn<String>(
    'building_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES buildings (id)',
    ),
  );
  static const VerificationMeta _apartmentNumberMeta = const VerificationMeta(
    'apartmentNumber',
  );
  @override
  late final GeneratedColumn<String> apartmentNumber = GeneratedColumn<String>(
    'apartment_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _floorNumberMeta = const VerificationMeta(
    'floorNumber',
  );
  @override
  late final GeneratedColumn<int> floorNumber = GeneratedColumn<int>(
    'floor_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cleaningStatusMeta = const VerificationMeta(
    'cleaningStatus',
  );
  @override
  late final GeneratedColumn<String> cleaningStatus = GeneratedColumn<String>(
    'cleaning_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('clean'),
  );
  static const VerificationMeta _brokerVisibilityMeta = const VerificationMeta(
    'brokerVisibility',
  );
  @override
  late final GeneratedColumn<bool> brokerVisibility = GeneratedColumn<bool>(
    'broker_visibility',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("broker_visibility" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    syncStatus,
    lastModifiedLocal,
    id,
    buildingId,
    apartmentNumber,
    floorNumber,
    cleaningStatus,
    brokerVisibility,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'apartments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Apartment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('last_modified_local')) {
      context.handle(
        _lastModifiedLocalMeta,
        lastModifiedLocal.isAcceptableOrUnknown(
          data['last_modified_local']!,
          _lastModifiedLocalMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('building_id')) {
      context.handle(
        _buildingIdMeta,
        buildingId.isAcceptableOrUnknown(data['building_id']!, _buildingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_buildingIdMeta);
    }
    if (data.containsKey('apartment_number')) {
      context.handle(
        _apartmentNumberMeta,
        apartmentNumber.isAcceptableOrUnknown(
          data['apartment_number']!,
          _apartmentNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_apartmentNumberMeta);
    }
    if (data.containsKey('floor_number')) {
      context.handle(
        _floorNumberMeta,
        floorNumber.isAcceptableOrUnknown(
          data['floor_number']!,
          _floorNumberMeta,
        ),
      );
    }
    if (data.containsKey('cleaning_status')) {
      context.handle(
        _cleaningStatusMeta,
        cleaningStatus.isAcceptableOrUnknown(
          data['cleaning_status']!,
          _cleaningStatusMeta,
        ),
      );
    }
    if (data.containsKey('broker_visibility')) {
      context.handle(
        _brokerVisibilityMeta,
        brokerVisibility.isAcceptableOrUnknown(
          data['broker_visibility']!,
          _brokerVisibilityMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Apartment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Apartment(
      syncStatus: $ApartmentsTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      lastModifiedLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified_local'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      buildingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}building_id'],
      )!,
      apartmentNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}apartment_number'],
      )!,
      floorNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}floor_number'],
      ),
      cleaningStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cleaning_status'],
      )!,
      brokerVisibility: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}broker_visibility'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ApartmentsTable createAlias(String alias) {
    return $ApartmentsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class Apartment extends DataClass implements Insertable<Apartment> {
  final SyncStatus syncStatus;
  final DateTime lastModifiedLocal;
  final String id;
  final String buildingId;
  final String apartmentNumber;
  final int? floorNumber;
  final String cleaningStatus;
  final bool brokerVisibility;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Apartment({
    required this.syncStatus,
    required this.lastModifiedLocal,
    required this.id,
    required this.buildingId,
    required this.apartmentNumber,
    this.floorNumber,
    required this.cleaningStatus,
    required this.brokerVisibility,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['sync_status'] = Variable<int>(
        $ApartmentsTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['last_modified_local'] = Variable<DateTime>(lastModifiedLocal);
    map['id'] = Variable<String>(id);
    map['building_id'] = Variable<String>(buildingId);
    map['apartment_number'] = Variable<String>(apartmentNumber);
    if (!nullToAbsent || floorNumber != null) {
      map['floor_number'] = Variable<int>(floorNumber);
    }
    map['cleaning_status'] = Variable<String>(cleaningStatus);
    map['broker_visibility'] = Variable<bool>(brokerVisibility);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ApartmentsCompanion toCompanion(bool nullToAbsent) {
    return ApartmentsCompanion(
      syncStatus: Value(syncStatus),
      lastModifiedLocal: Value(lastModifiedLocal),
      id: Value(id),
      buildingId: Value(buildingId),
      apartmentNumber: Value(apartmentNumber),
      floorNumber: floorNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(floorNumber),
      cleaningStatus: Value(cleaningStatus),
      brokerVisibility: Value(brokerVisibility),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Apartment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Apartment(
      syncStatus: $ApartmentsTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
      lastModifiedLocal: serializer.fromJson<DateTime>(
        json['lastModifiedLocal'],
      ),
      id: serializer.fromJson<String>(json['id']),
      buildingId: serializer.fromJson<String>(json['buildingId']),
      apartmentNumber: serializer.fromJson<String>(json['apartmentNumber']),
      floorNumber: serializer.fromJson<int?>(json['floorNumber']),
      cleaningStatus: serializer.fromJson<String>(json['cleaningStatus']),
      brokerVisibility: serializer.fromJson<bool>(json['brokerVisibility']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncStatus': serializer.toJson<int>(
        $ApartmentsTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'lastModifiedLocal': serializer.toJson<DateTime>(lastModifiedLocal),
      'id': serializer.toJson<String>(id),
      'buildingId': serializer.toJson<String>(buildingId),
      'apartmentNumber': serializer.toJson<String>(apartmentNumber),
      'floorNumber': serializer.toJson<int?>(floorNumber),
      'cleaningStatus': serializer.toJson<String>(cleaningStatus),
      'brokerVisibility': serializer.toJson<bool>(brokerVisibility),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Apartment copyWith({
    SyncStatus? syncStatus,
    DateTime? lastModifiedLocal,
    String? id,
    String? buildingId,
    String? apartmentNumber,
    Value<int?> floorNumber = const Value.absent(),
    String? cleaningStatus,
    bool? brokerVisibility,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Apartment(
    syncStatus: syncStatus ?? this.syncStatus,
    lastModifiedLocal: lastModifiedLocal ?? this.lastModifiedLocal,
    id: id ?? this.id,
    buildingId: buildingId ?? this.buildingId,
    apartmentNumber: apartmentNumber ?? this.apartmentNumber,
    floorNumber: floorNumber.present ? floorNumber.value : this.floorNumber,
    cleaningStatus: cleaningStatus ?? this.cleaningStatus,
    brokerVisibility: brokerVisibility ?? this.brokerVisibility,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Apartment copyWithCompanion(ApartmentsCompanion data) {
    return Apartment(
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastModifiedLocal: data.lastModifiedLocal.present
          ? data.lastModifiedLocal.value
          : this.lastModifiedLocal,
      id: data.id.present ? data.id.value : this.id,
      buildingId: data.buildingId.present
          ? data.buildingId.value
          : this.buildingId,
      apartmentNumber: data.apartmentNumber.present
          ? data.apartmentNumber.value
          : this.apartmentNumber,
      floorNumber: data.floorNumber.present
          ? data.floorNumber.value
          : this.floorNumber,
      cleaningStatus: data.cleaningStatus.present
          ? data.cleaningStatus.value
          : this.cleaningStatus,
      brokerVisibility: data.brokerVisibility.present
          ? data.brokerVisibility.value
          : this.brokerVisibility,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Apartment(')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedLocal: $lastModifiedLocal, ')
          ..write('id: $id, ')
          ..write('buildingId: $buildingId, ')
          ..write('apartmentNumber: $apartmentNumber, ')
          ..write('floorNumber: $floorNumber, ')
          ..write('cleaningStatus: $cleaningStatus, ')
          ..write('brokerVisibility: $brokerVisibility, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    syncStatus,
    lastModifiedLocal,
    id,
    buildingId,
    apartmentNumber,
    floorNumber,
    cleaningStatus,
    brokerVisibility,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Apartment &&
          other.syncStatus == this.syncStatus &&
          other.lastModifiedLocal == this.lastModifiedLocal &&
          other.id == this.id &&
          other.buildingId == this.buildingId &&
          other.apartmentNumber == this.apartmentNumber &&
          other.floorNumber == this.floorNumber &&
          other.cleaningStatus == this.cleaningStatus &&
          other.brokerVisibility == this.brokerVisibility &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ApartmentsCompanion extends UpdateCompanion<Apartment> {
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> lastModifiedLocal;
  final Value<String> id;
  final Value<String> buildingId;
  final Value<String> apartmentNumber;
  final Value<int?> floorNumber;
  final Value<String> cleaningStatus;
  final Value<bool> brokerVisibility;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ApartmentsCompanion({
    this.syncStatus = const Value.absent(),
    this.lastModifiedLocal = const Value.absent(),
    this.id = const Value.absent(),
    this.buildingId = const Value.absent(),
    this.apartmentNumber = const Value.absent(),
    this.floorNumber = const Value.absent(),
    this.cleaningStatus = const Value.absent(),
    this.brokerVisibility = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ApartmentsCompanion.insert({
    this.syncStatus = const Value.absent(),
    this.lastModifiedLocal = const Value.absent(),
    required String id,
    required String buildingId,
    required String apartmentNumber,
    this.floorNumber = const Value.absent(),
    this.cleaningStatus = const Value.absent(),
    this.brokerVisibility = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       buildingId = Value(buildingId),
       apartmentNumber = Value(apartmentNumber),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Apartment> custom({
    Expression<int>? syncStatus,
    Expression<DateTime>? lastModifiedLocal,
    Expression<String>? id,
    Expression<String>? buildingId,
    Expression<String>? apartmentNumber,
    Expression<int>? floorNumber,
    Expression<String>? cleaningStatus,
    Expression<bool>? brokerVisibility,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastModifiedLocal != null) 'last_modified_local': lastModifiedLocal,
      if (id != null) 'id': id,
      if (buildingId != null) 'building_id': buildingId,
      if (apartmentNumber != null) 'apartment_number': apartmentNumber,
      if (floorNumber != null) 'floor_number': floorNumber,
      if (cleaningStatus != null) 'cleaning_status': cleaningStatus,
      if (brokerVisibility != null) 'broker_visibility': brokerVisibility,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ApartmentsCompanion copyWith({
    Value<SyncStatus>? syncStatus,
    Value<DateTime>? lastModifiedLocal,
    Value<String>? id,
    Value<String>? buildingId,
    Value<String>? apartmentNumber,
    Value<int?>? floorNumber,
    Value<String>? cleaningStatus,
    Value<bool>? brokerVisibility,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ApartmentsCompanion(
      syncStatus: syncStatus ?? this.syncStatus,
      lastModifiedLocal: lastModifiedLocal ?? this.lastModifiedLocal,
      id: id ?? this.id,
      buildingId: buildingId ?? this.buildingId,
      apartmentNumber: apartmentNumber ?? this.apartmentNumber,
      floorNumber: floorNumber ?? this.floorNumber,
      cleaningStatus: cleaningStatus ?? this.cleaningStatus,
      brokerVisibility: brokerVisibility ?? this.brokerVisibility,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $ApartmentsTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (lastModifiedLocal.present) {
      map['last_modified_local'] = Variable<DateTime>(lastModifiedLocal.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (buildingId.present) {
      map['building_id'] = Variable<String>(buildingId.value);
    }
    if (apartmentNumber.present) {
      map['apartment_number'] = Variable<String>(apartmentNumber.value);
    }
    if (floorNumber.present) {
      map['floor_number'] = Variable<int>(floorNumber.value);
    }
    if (cleaningStatus.present) {
      map['cleaning_status'] = Variable<String>(cleaningStatus.value);
    }
    if (brokerVisibility.present) {
      map['broker_visibility'] = Variable<bool>(brokerVisibility.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ApartmentsCompanion(')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedLocal: $lastModifiedLocal, ')
          ..write('id: $id, ')
          ..write('buildingId: $buildingId, ')
          ..write('apartmentNumber: $apartmentNumber, ')
          ..write('floorNumber: $floorNumber, ')
          ..write('cleaningStatus: $cleaningStatus, ')
          ..write('brokerVisibility: $brokerVisibility, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SummerBookingsTable extends SummerBookings
    with TableInfo<$SummerBookingsTable, SummerBooking> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SummerBookingsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<SyncStatus>($SummerBookingsTable.$convertersyncStatus);
  static const VerificationMeta _lastModifiedLocalMeta = const VerificationMeta(
    'lastModifiedLocal',
  );
  @override
  late final GeneratedColumn<DateTime> lastModifiedLocal =
      GeneratedColumn<DateTime>(
        'last_modified_local',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _apartmentIdMeta = const VerificationMeta(
    'apartmentId',
  );
  @override
  late final GeneratedColumn<String> apartmentId = GeneratedColumn<String>(
    'apartment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES apartments (id)',
    ),
  );
  static const VerificationMeta _guestNameMeta = const VerificationMeta(
    'guestName',
  );
  @override
  late final GeneratedColumn<String> guestName = GeneratedColumn<String>(
    'guest_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _guestPhoneMeta = const VerificationMeta(
    'guestPhone',
  );
  @override
  late final GeneratedColumn<String> guestPhone = GeneratedColumn<String>(
    'guest_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _checkInDateMeta = const VerificationMeta(
    'checkInDate',
  );
  @override
  late final GeneratedColumn<DateTime> checkInDate = GeneratedColumn<DateTime>(
    'check_in_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checkOutDateMeta = const VerificationMeta(
    'checkOutDate',
  );
  @override
  late final GeneratedColumn<DateTime> checkOutDate = GeneratedColumn<DateTime>(
    'check_out_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _totalPriceEgpMeta = const VerificationMeta(
    'totalPriceEgp',
  );
  @override
  late final GeneratedColumn<double> totalPriceEgp = GeneratedColumn<double>(
    'total_price_egp',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountPaidEgpMeta = const VerificationMeta(
    'amountPaidEgp',
  );
  @override
  late final GeneratedColumn<double> amountPaidEgp = GeneratedColumn<double>(
    'amount_paid_egp',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _brokerIdMeta = const VerificationMeta(
    'brokerId',
  );
  @override
  late final GeneratedColumn<String> brokerId = GeneratedColumn<String>(
    'broker_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _brokerCommissionPercentageMeta =
      const VerificationMeta('brokerCommissionPercentage');
  @override
  late final GeneratedColumn<double> brokerCommissionPercentage =
      GeneratedColumn<double>(
        'broker_commission_percentage',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(10.0),
      );
  static const VerificationMeta _brokerCommissionAmountEgpMeta =
      const VerificationMeta('brokerCommissionAmountEgp');
  @override
  late final GeneratedColumn<double> brokerCommissionAmountEgp =
      GeneratedColumn<double>(
        'broker_commission_amount_egp',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _earlyCheckoutDateMeta = const VerificationMeta(
    'earlyCheckoutDate',
  );
  @override
  late final GeneratedColumn<DateTime> earlyCheckoutDate =
      GeneratedColumn<DateTime>(
        'early_checkout_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _overstayDaysMeta = const VerificationMeta(
    'overstayDays',
  );
  @override
  late final GeneratedColumn<int> overstayDays = GeneratedColumn<int>(
    'overstay_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _overstayFeeEgpMeta = const VerificationMeta(
    'overstayFeeEgp',
  );
  @override
  late final GeneratedColumn<double> overstayFeeEgp = GeneratedColumn<double>(
    'overstay_fee_egp',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    syncStatus,
    lastModifiedLocal,
    id,
    apartmentId,
    guestName,
    guestPhone,
    checkInDate,
    checkOutDate,
    status,
    totalPriceEgp,
    amountPaidEgp,
    brokerId,
    brokerCommissionPercentage,
    brokerCommissionAmountEgp,
    earlyCheckoutDate,
    overstayDays,
    overstayFeeEgp,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'summer_bookings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SummerBooking> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('last_modified_local')) {
      context.handle(
        _lastModifiedLocalMeta,
        lastModifiedLocal.isAcceptableOrUnknown(
          data['last_modified_local']!,
          _lastModifiedLocalMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('apartment_id')) {
      context.handle(
        _apartmentIdMeta,
        apartmentId.isAcceptableOrUnknown(
          data['apartment_id']!,
          _apartmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_apartmentIdMeta);
    }
    if (data.containsKey('guest_name')) {
      context.handle(
        _guestNameMeta,
        guestName.isAcceptableOrUnknown(data['guest_name']!, _guestNameMeta),
      );
    } else if (isInserting) {
      context.missing(_guestNameMeta);
    }
    if (data.containsKey('guest_phone')) {
      context.handle(
        _guestPhoneMeta,
        guestPhone.isAcceptableOrUnknown(data['guest_phone']!, _guestPhoneMeta),
      );
    }
    if (data.containsKey('check_in_date')) {
      context.handle(
        _checkInDateMeta,
        checkInDate.isAcceptableOrUnknown(
          data['check_in_date']!,
          _checkInDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_checkInDateMeta);
    }
    if (data.containsKey('check_out_date')) {
      context.handle(
        _checkOutDateMeta,
        checkOutDate.isAcceptableOrUnknown(
          data['check_out_date']!,
          _checkOutDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_checkOutDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('total_price_egp')) {
      context.handle(
        _totalPriceEgpMeta,
        totalPriceEgp.isAcceptableOrUnknown(
          data['total_price_egp']!,
          _totalPriceEgpMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalPriceEgpMeta);
    }
    if (data.containsKey('amount_paid_egp')) {
      context.handle(
        _amountPaidEgpMeta,
        amountPaidEgp.isAcceptableOrUnknown(
          data['amount_paid_egp']!,
          _amountPaidEgpMeta,
        ),
      );
    }
    if (data.containsKey('broker_id')) {
      context.handle(
        _brokerIdMeta,
        brokerId.isAcceptableOrUnknown(data['broker_id']!, _brokerIdMeta),
      );
    }
    if (data.containsKey('broker_commission_percentage')) {
      context.handle(
        _brokerCommissionPercentageMeta,
        brokerCommissionPercentage.isAcceptableOrUnknown(
          data['broker_commission_percentage']!,
          _brokerCommissionPercentageMeta,
        ),
      );
    }
    if (data.containsKey('broker_commission_amount_egp')) {
      context.handle(
        _brokerCommissionAmountEgpMeta,
        brokerCommissionAmountEgp.isAcceptableOrUnknown(
          data['broker_commission_amount_egp']!,
          _brokerCommissionAmountEgpMeta,
        ),
      );
    }
    if (data.containsKey('early_checkout_date')) {
      context.handle(
        _earlyCheckoutDateMeta,
        earlyCheckoutDate.isAcceptableOrUnknown(
          data['early_checkout_date']!,
          _earlyCheckoutDateMeta,
        ),
      );
    }
    if (data.containsKey('overstay_days')) {
      context.handle(
        _overstayDaysMeta,
        overstayDays.isAcceptableOrUnknown(
          data['overstay_days']!,
          _overstayDaysMeta,
        ),
      );
    }
    if (data.containsKey('overstay_fee_egp')) {
      context.handle(
        _overstayFeeEgpMeta,
        overstayFeeEgp.isAcceptableOrUnknown(
          data['overstay_fee_egp']!,
          _overstayFeeEgpMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SummerBooking map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SummerBooking(
      syncStatus: $SummerBookingsTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      lastModifiedLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified_local'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      apartmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}apartment_id'],
      )!,
      guestName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guest_name'],
      )!,
      guestPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guest_phone'],
      ),
      checkInDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}check_in_date'],
      )!,
      checkOutDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}check_out_date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      totalPriceEgp: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_price_egp'],
      )!,
      amountPaidEgp: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount_paid_egp'],
      )!,
      brokerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}broker_id'],
      ),
      brokerCommissionPercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}broker_commission_percentage'],
      )!,
      brokerCommissionAmountEgp: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}broker_commission_amount_egp'],
      ),
      earlyCheckoutDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}early_checkout_date'],
      ),
      overstayDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}overstay_days'],
      )!,
      overstayFeeEgp: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}overstay_fee_egp'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SummerBookingsTable createAlias(String alias) {
    return $SummerBookingsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class SummerBooking extends DataClass implements Insertable<SummerBooking> {
  final SyncStatus syncStatus;
  final DateTime lastModifiedLocal;
  final String id;
  final String apartmentId;
  final String guestName;
  final String? guestPhone;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final String status;
  final double totalPriceEgp;
  final double amountPaidEgp;
  final String? brokerId;
  final double brokerCommissionPercentage;
  final double? brokerCommissionAmountEgp;
  final DateTime? earlyCheckoutDate;
  final int overstayDays;
  final double overstayFeeEgp;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SummerBooking({
    required this.syncStatus,
    required this.lastModifiedLocal,
    required this.id,
    required this.apartmentId,
    required this.guestName,
    this.guestPhone,
    required this.checkInDate,
    required this.checkOutDate,
    required this.status,
    required this.totalPriceEgp,
    required this.amountPaidEgp,
    this.brokerId,
    required this.brokerCommissionPercentage,
    this.brokerCommissionAmountEgp,
    this.earlyCheckoutDate,
    required this.overstayDays,
    required this.overstayFeeEgp,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['sync_status'] = Variable<int>(
        $SummerBookingsTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['last_modified_local'] = Variable<DateTime>(lastModifiedLocal);
    map['id'] = Variable<String>(id);
    map['apartment_id'] = Variable<String>(apartmentId);
    map['guest_name'] = Variable<String>(guestName);
    if (!nullToAbsent || guestPhone != null) {
      map['guest_phone'] = Variable<String>(guestPhone);
    }
    map['check_in_date'] = Variable<DateTime>(checkInDate);
    map['check_out_date'] = Variable<DateTime>(checkOutDate);
    map['status'] = Variable<String>(status);
    map['total_price_egp'] = Variable<double>(totalPriceEgp);
    map['amount_paid_egp'] = Variable<double>(amountPaidEgp);
    if (!nullToAbsent || brokerId != null) {
      map['broker_id'] = Variable<String>(brokerId);
    }
    map['broker_commission_percentage'] = Variable<double>(
      brokerCommissionPercentage,
    );
    if (!nullToAbsent || brokerCommissionAmountEgp != null) {
      map['broker_commission_amount_egp'] = Variable<double>(
        brokerCommissionAmountEgp,
      );
    }
    if (!nullToAbsent || earlyCheckoutDate != null) {
      map['early_checkout_date'] = Variable<DateTime>(earlyCheckoutDate);
    }
    map['overstay_days'] = Variable<int>(overstayDays);
    map['overstay_fee_egp'] = Variable<double>(overstayFeeEgp);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SummerBookingsCompanion toCompanion(bool nullToAbsent) {
    return SummerBookingsCompanion(
      syncStatus: Value(syncStatus),
      lastModifiedLocal: Value(lastModifiedLocal),
      id: Value(id),
      apartmentId: Value(apartmentId),
      guestName: Value(guestName),
      guestPhone: guestPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(guestPhone),
      checkInDate: Value(checkInDate),
      checkOutDate: Value(checkOutDate),
      status: Value(status),
      totalPriceEgp: Value(totalPriceEgp),
      amountPaidEgp: Value(amountPaidEgp),
      brokerId: brokerId == null && nullToAbsent
          ? const Value.absent()
          : Value(brokerId),
      brokerCommissionPercentage: Value(brokerCommissionPercentage),
      brokerCommissionAmountEgp:
          brokerCommissionAmountEgp == null && nullToAbsent
          ? const Value.absent()
          : Value(brokerCommissionAmountEgp),
      earlyCheckoutDate: earlyCheckoutDate == null && nullToAbsent
          ? const Value.absent()
          : Value(earlyCheckoutDate),
      overstayDays: Value(overstayDays),
      overstayFeeEgp: Value(overstayFeeEgp),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SummerBooking.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SummerBooking(
      syncStatus: $SummerBookingsTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
      lastModifiedLocal: serializer.fromJson<DateTime>(
        json['lastModifiedLocal'],
      ),
      id: serializer.fromJson<String>(json['id']),
      apartmentId: serializer.fromJson<String>(json['apartmentId']),
      guestName: serializer.fromJson<String>(json['guestName']),
      guestPhone: serializer.fromJson<String?>(json['guestPhone']),
      checkInDate: serializer.fromJson<DateTime>(json['checkInDate']),
      checkOutDate: serializer.fromJson<DateTime>(json['checkOutDate']),
      status: serializer.fromJson<String>(json['status']),
      totalPriceEgp: serializer.fromJson<double>(json['totalPriceEgp']),
      amountPaidEgp: serializer.fromJson<double>(json['amountPaidEgp']),
      brokerId: serializer.fromJson<String?>(json['brokerId']),
      brokerCommissionPercentage: serializer.fromJson<double>(
        json['brokerCommissionPercentage'],
      ),
      brokerCommissionAmountEgp: serializer.fromJson<double?>(
        json['brokerCommissionAmountEgp'],
      ),
      earlyCheckoutDate: serializer.fromJson<DateTime?>(
        json['earlyCheckoutDate'],
      ),
      overstayDays: serializer.fromJson<int>(json['overstayDays']),
      overstayFeeEgp: serializer.fromJson<double>(json['overstayFeeEgp']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncStatus': serializer.toJson<int>(
        $SummerBookingsTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'lastModifiedLocal': serializer.toJson<DateTime>(lastModifiedLocal),
      'id': serializer.toJson<String>(id),
      'apartmentId': serializer.toJson<String>(apartmentId),
      'guestName': serializer.toJson<String>(guestName),
      'guestPhone': serializer.toJson<String?>(guestPhone),
      'checkInDate': serializer.toJson<DateTime>(checkInDate),
      'checkOutDate': serializer.toJson<DateTime>(checkOutDate),
      'status': serializer.toJson<String>(status),
      'totalPriceEgp': serializer.toJson<double>(totalPriceEgp),
      'amountPaidEgp': serializer.toJson<double>(amountPaidEgp),
      'brokerId': serializer.toJson<String?>(brokerId),
      'brokerCommissionPercentage': serializer.toJson<double>(
        brokerCommissionPercentage,
      ),
      'brokerCommissionAmountEgp': serializer.toJson<double?>(
        brokerCommissionAmountEgp,
      ),
      'earlyCheckoutDate': serializer.toJson<DateTime?>(earlyCheckoutDate),
      'overstayDays': serializer.toJson<int>(overstayDays),
      'overstayFeeEgp': serializer.toJson<double>(overstayFeeEgp),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SummerBooking copyWith({
    SyncStatus? syncStatus,
    DateTime? lastModifiedLocal,
    String? id,
    String? apartmentId,
    String? guestName,
    Value<String?> guestPhone = const Value.absent(),
    DateTime? checkInDate,
    DateTime? checkOutDate,
    String? status,
    double? totalPriceEgp,
    double? amountPaidEgp,
    Value<String?> brokerId = const Value.absent(),
    double? brokerCommissionPercentage,
    Value<double?> brokerCommissionAmountEgp = const Value.absent(),
    Value<DateTime?> earlyCheckoutDate = const Value.absent(),
    int? overstayDays,
    double? overstayFeeEgp,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SummerBooking(
    syncStatus: syncStatus ?? this.syncStatus,
    lastModifiedLocal: lastModifiedLocal ?? this.lastModifiedLocal,
    id: id ?? this.id,
    apartmentId: apartmentId ?? this.apartmentId,
    guestName: guestName ?? this.guestName,
    guestPhone: guestPhone.present ? guestPhone.value : this.guestPhone,
    checkInDate: checkInDate ?? this.checkInDate,
    checkOutDate: checkOutDate ?? this.checkOutDate,
    status: status ?? this.status,
    totalPriceEgp: totalPriceEgp ?? this.totalPriceEgp,
    amountPaidEgp: amountPaidEgp ?? this.amountPaidEgp,
    brokerId: brokerId.present ? brokerId.value : this.brokerId,
    brokerCommissionPercentage:
        brokerCommissionPercentage ?? this.brokerCommissionPercentage,
    brokerCommissionAmountEgp: brokerCommissionAmountEgp.present
        ? brokerCommissionAmountEgp.value
        : this.brokerCommissionAmountEgp,
    earlyCheckoutDate: earlyCheckoutDate.present
        ? earlyCheckoutDate.value
        : this.earlyCheckoutDate,
    overstayDays: overstayDays ?? this.overstayDays,
    overstayFeeEgp: overstayFeeEgp ?? this.overstayFeeEgp,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SummerBooking copyWithCompanion(SummerBookingsCompanion data) {
    return SummerBooking(
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastModifiedLocal: data.lastModifiedLocal.present
          ? data.lastModifiedLocal.value
          : this.lastModifiedLocal,
      id: data.id.present ? data.id.value : this.id,
      apartmentId: data.apartmentId.present
          ? data.apartmentId.value
          : this.apartmentId,
      guestName: data.guestName.present ? data.guestName.value : this.guestName,
      guestPhone: data.guestPhone.present
          ? data.guestPhone.value
          : this.guestPhone,
      checkInDate: data.checkInDate.present
          ? data.checkInDate.value
          : this.checkInDate,
      checkOutDate: data.checkOutDate.present
          ? data.checkOutDate.value
          : this.checkOutDate,
      status: data.status.present ? data.status.value : this.status,
      totalPriceEgp: data.totalPriceEgp.present
          ? data.totalPriceEgp.value
          : this.totalPriceEgp,
      amountPaidEgp: data.amountPaidEgp.present
          ? data.amountPaidEgp.value
          : this.amountPaidEgp,
      brokerId: data.brokerId.present ? data.brokerId.value : this.brokerId,
      brokerCommissionPercentage: data.brokerCommissionPercentage.present
          ? data.brokerCommissionPercentage.value
          : this.brokerCommissionPercentage,
      brokerCommissionAmountEgp: data.brokerCommissionAmountEgp.present
          ? data.brokerCommissionAmountEgp.value
          : this.brokerCommissionAmountEgp,
      earlyCheckoutDate: data.earlyCheckoutDate.present
          ? data.earlyCheckoutDate.value
          : this.earlyCheckoutDate,
      overstayDays: data.overstayDays.present
          ? data.overstayDays.value
          : this.overstayDays,
      overstayFeeEgp: data.overstayFeeEgp.present
          ? data.overstayFeeEgp.value
          : this.overstayFeeEgp,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SummerBooking(')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedLocal: $lastModifiedLocal, ')
          ..write('id: $id, ')
          ..write('apartmentId: $apartmentId, ')
          ..write('guestName: $guestName, ')
          ..write('guestPhone: $guestPhone, ')
          ..write('checkInDate: $checkInDate, ')
          ..write('checkOutDate: $checkOutDate, ')
          ..write('status: $status, ')
          ..write('totalPriceEgp: $totalPriceEgp, ')
          ..write('amountPaidEgp: $amountPaidEgp, ')
          ..write('brokerId: $brokerId, ')
          ..write('brokerCommissionPercentage: $brokerCommissionPercentage, ')
          ..write('brokerCommissionAmountEgp: $brokerCommissionAmountEgp, ')
          ..write('earlyCheckoutDate: $earlyCheckoutDate, ')
          ..write('overstayDays: $overstayDays, ')
          ..write('overstayFeeEgp: $overstayFeeEgp, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    syncStatus,
    lastModifiedLocal,
    id,
    apartmentId,
    guestName,
    guestPhone,
    checkInDate,
    checkOutDate,
    status,
    totalPriceEgp,
    amountPaidEgp,
    brokerId,
    brokerCommissionPercentage,
    brokerCommissionAmountEgp,
    earlyCheckoutDate,
    overstayDays,
    overstayFeeEgp,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SummerBooking &&
          other.syncStatus == this.syncStatus &&
          other.lastModifiedLocal == this.lastModifiedLocal &&
          other.id == this.id &&
          other.apartmentId == this.apartmentId &&
          other.guestName == this.guestName &&
          other.guestPhone == this.guestPhone &&
          other.checkInDate == this.checkInDate &&
          other.checkOutDate == this.checkOutDate &&
          other.status == this.status &&
          other.totalPriceEgp == this.totalPriceEgp &&
          other.amountPaidEgp == this.amountPaidEgp &&
          other.brokerId == this.brokerId &&
          other.brokerCommissionPercentage == this.brokerCommissionPercentage &&
          other.brokerCommissionAmountEgp == this.brokerCommissionAmountEgp &&
          other.earlyCheckoutDate == this.earlyCheckoutDate &&
          other.overstayDays == this.overstayDays &&
          other.overstayFeeEgp == this.overstayFeeEgp &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SummerBookingsCompanion extends UpdateCompanion<SummerBooking> {
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> lastModifiedLocal;
  final Value<String> id;
  final Value<String> apartmentId;
  final Value<String> guestName;
  final Value<String?> guestPhone;
  final Value<DateTime> checkInDate;
  final Value<DateTime> checkOutDate;
  final Value<String> status;
  final Value<double> totalPriceEgp;
  final Value<double> amountPaidEgp;
  final Value<String?> brokerId;
  final Value<double> brokerCommissionPercentage;
  final Value<double?> brokerCommissionAmountEgp;
  final Value<DateTime?> earlyCheckoutDate;
  final Value<int> overstayDays;
  final Value<double> overstayFeeEgp;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SummerBookingsCompanion({
    this.syncStatus = const Value.absent(),
    this.lastModifiedLocal = const Value.absent(),
    this.id = const Value.absent(),
    this.apartmentId = const Value.absent(),
    this.guestName = const Value.absent(),
    this.guestPhone = const Value.absent(),
    this.checkInDate = const Value.absent(),
    this.checkOutDate = const Value.absent(),
    this.status = const Value.absent(),
    this.totalPriceEgp = const Value.absent(),
    this.amountPaidEgp = const Value.absent(),
    this.brokerId = const Value.absent(),
    this.brokerCommissionPercentage = const Value.absent(),
    this.brokerCommissionAmountEgp = const Value.absent(),
    this.earlyCheckoutDate = const Value.absent(),
    this.overstayDays = const Value.absent(),
    this.overstayFeeEgp = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SummerBookingsCompanion.insert({
    this.syncStatus = const Value.absent(),
    this.lastModifiedLocal = const Value.absent(),
    required String id,
    required String apartmentId,
    required String guestName,
    this.guestPhone = const Value.absent(),
    required DateTime checkInDate,
    required DateTime checkOutDate,
    this.status = const Value.absent(),
    required double totalPriceEgp,
    this.amountPaidEgp = const Value.absent(),
    this.brokerId = const Value.absent(),
    this.brokerCommissionPercentage = const Value.absent(),
    this.brokerCommissionAmountEgp = const Value.absent(),
    this.earlyCheckoutDate = const Value.absent(),
    this.overstayDays = const Value.absent(),
    this.overstayFeeEgp = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       apartmentId = Value(apartmentId),
       guestName = Value(guestName),
       checkInDate = Value(checkInDate),
       checkOutDate = Value(checkOutDate),
       totalPriceEgp = Value(totalPriceEgp),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SummerBooking> custom({
    Expression<int>? syncStatus,
    Expression<DateTime>? lastModifiedLocal,
    Expression<String>? id,
    Expression<String>? apartmentId,
    Expression<String>? guestName,
    Expression<String>? guestPhone,
    Expression<DateTime>? checkInDate,
    Expression<DateTime>? checkOutDate,
    Expression<String>? status,
    Expression<double>? totalPriceEgp,
    Expression<double>? amountPaidEgp,
    Expression<String>? brokerId,
    Expression<double>? brokerCommissionPercentage,
    Expression<double>? brokerCommissionAmountEgp,
    Expression<DateTime>? earlyCheckoutDate,
    Expression<int>? overstayDays,
    Expression<double>? overstayFeeEgp,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastModifiedLocal != null) 'last_modified_local': lastModifiedLocal,
      if (id != null) 'id': id,
      if (apartmentId != null) 'apartment_id': apartmentId,
      if (guestName != null) 'guest_name': guestName,
      if (guestPhone != null) 'guest_phone': guestPhone,
      if (checkInDate != null) 'check_in_date': checkInDate,
      if (checkOutDate != null) 'check_out_date': checkOutDate,
      if (status != null) 'status': status,
      if (totalPriceEgp != null) 'total_price_egp': totalPriceEgp,
      if (amountPaidEgp != null) 'amount_paid_egp': amountPaidEgp,
      if (brokerId != null) 'broker_id': brokerId,
      if (brokerCommissionPercentage != null)
        'broker_commission_percentage': brokerCommissionPercentage,
      if (brokerCommissionAmountEgp != null)
        'broker_commission_amount_egp': brokerCommissionAmountEgp,
      if (earlyCheckoutDate != null) 'early_checkout_date': earlyCheckoutDate,
      if (overstayDays != null) 'overstay_days': overstayDays,
      if (overstayFeeEgp != null) 'overstay_fee_egp': overstayFeeEgp,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SummerBookingsCompanion copyWith({
    Value<SyncStatus>? syncStatus,
    Value<DateTime>? lastModifiedLocal,
    Value<String>? id,
    Value<String>? apartmentId,
    Value<String>? guestName,
    Value<String?>? guestPhone,
    Value<DateTime>? checkInDate,
    Value<DateTime>? checkOutDate,
    Value<String>? status,
    Value<double>? totalPriceEgp,
    Value<double>? amountPaidEgp,
    Value<String?>? brokerId,
    Value<double>? brokerCommissionPercentage,
    Value<double?>? brokerCommissionAmountEgp,
    Value<DateTime?>? earlyCheckoutDate,
    Value<int>? overstayDays,
    Value<double>? overstayFeeEgp,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SummerBookingsCompanion(
      syncStatus: syncStatus ?? this.syncStatus,
      lastModifiedLocal: lastModifiedLocal ?? this.lastModifiedLocal,
      id: id ?? this.id,
      apartmentId: apartmentId ?? this.apartmentId,
      guestName: guestName ?? this.guestName,
      guestPhone: guestPhone ?? this.guestPhone,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      status: status ?? this.status,
      totalPriceEgp: totalPriceEgp ?? this.totalPriceEgp,
      amountPaidEgp: amountPaidEgp ?? this.amountPaidEgp,
      brokerId: brokerId ?? this.brokerId,
      brokerCommissionPercentage:
          brokerCommissionPercentage ?? this.brokerCommissionPercentage,
      brokerCommissionAmountEgp:
          brokerCommissionAmountEgp ?? this.brokerCommissionAmountEgp,
      earlyCheckoutDate: earlyCheckoutDate ?? this.earlyCheckoutDate,
      overstayDays: overstayDays ?? this.overstayDays,
      overstayFeeEgp: overstayFeeEgp ?? this.overstayFeeEgp,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $SummerBookingsTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (lastModifiedLocal.present) {
      map['last_modified_local'] = Variable<DateTime>(lastModifiedLocal.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (apartmentId.present) {
      map['apartment_id'] = Variable<String>(apartmentId.value);
    }
    if (guestName.present) {
      map['guest_name'] = Variable<String>(guestName.value);
    }
    if (guestPhone.present) {
      map['guest_phone'] = Variable<String>(guestPhone.value);
    }
    if (checkInDate.present) {
      map['check_in_date'] = Variable<DateTime>(checkInDate.value);
    }
    if (checkOutDate.present) {
      map['check_out_date'] = Variable<DateTime>(checkOutDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (totalPriceEgp.present) {
      map['total_price_egp'] = Variable<double>(totalPriceEgp.value);
    }
    if (amountPaidEgp.present) {
      map['amount_paid_egp'] = Variable<double>(amountPaidEgp.value);
    }
    if (brokerId.present) {
      map['broker_id'] = Variable<String>(brokerId.value);
    }
    if (brokerCommissionPercentage.present) {
      map['broker_commission_percentage'] = Variable<double>(
        brokerCommissionPercentage.value,
      );
    }
    if (brokerCommissionAmountEgp.present) {
      map['broker_commission_amount_egp'] = Variable<double>(
        brokerCommissionAmountEgp.value,
      );
    }
    if (earlyCheckoutDate.present) {
      map['early_checkout_date'] = Variable<DateTime>(earlyCheckoutDate.value);
    }
    if (overstayDays.present) {
      map['overstay_days'] = Variable<int>(overstayDays.value);
    }
    if (overstayFeeEgp.present) {
      map['overstay_fee_egp'] = Variable<double>(overstayFeeEgp.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SummerBookingsCompanion(')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedLocal: $lastModifiedLocal, ')
          ..write('id: $id, ')
          ..write('apartmentId: $apartmentId, ')
          ..write('guestName: $guestName, ')
          ..write('guestPhone: $guestPhone, ')
          ..write('checkInDate: $checkInDate, ')
          ..write('checkOutDate: $checkOutDate, ')
          ..write('status: $status, ')
          ..write('totalPriceEgp: $totalPriceEgp, ')
          ..write('amountPaidEgp: $amountPaidEgp, ')
          ..write('brokerId: $brokerId, ')
          ..write('brokerCommissionPercentage: $brokerCommissionPercentage, ')
          ..write('brokerCommissionAmountEgp: $brokerCommissionAmountEgp, ')
          ..write('earlyCheckoutDate: $earlyCheckoutDate, ')
          ..write('overstayDays: $overstayDays, ')
          ..write('overstayFeeEgp: $overstayFeeEgp, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WinterContractsTable extends WinterContracts
    with TableInfo<$WinterContractsTable, WinterContract> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WinterContractsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<SyncStatus>($WinterContractsTable.$convertersyncStatus);
  static const VerificationMeta _lastModifiedLocalMeta = const VerificationMeta(
    'lastModifiedLocal',
  );
  @override
  late final GeneratedColumn<DateTime> lastModifiedLocal =
      GeneratedColumn<DateTime>(
        'last_modified_local',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _apartmentIdMeta = const VerificationMeta(
    'apartmentId',
  );
  @override
  late final GeneratedColumn<String> apartmentId = GeneratedColumn<String>(
    'apartment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES apartments (id)',
    ),
  );
  static const VerificationMeta _studentNameMeta = const VerificationMeta(
    'studentName',
  );
  @override
  late final GeneratedColumn<String> studentName = GeneratedColumn<String>(
    'student_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _universityMeta = const VerificationMeta(
    'university',
  );
  @override
  late final GeneratedColumn<String> university = GeneratedColumn<String>(
    'university',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parentNameMeta = const VerificationMeta(
    'parentName',
  );
  @override
  late final GeneratedColumn<String> parentName = GeneratedColumn<String>(
    'parent_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parentPhoneMeta = const VerificationMeta(
    'parentPhone',
  );
  @override
  late final GeneratedColumn<String> parentPhone = GeneratedColumn<String>(
    'parent_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _viewerUserIdMeta = const VerificationMeta(
    'viewerUserId',
  );
  @override
  late final GeneratedColumn<String> viewerUserId = GeneratedColumn<String>(
    'viewer_user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthlyRentEgpMeta = const VerificationMeta(
    'monthlyRentEgp',
  );
  @override
  late final GeneratedColumn<double> monthlyRentEgp = GeneratedColumn<double>(
    'monthly_rent_egp',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _depositEgpMeta = const VerificationMeta(
    'depositEgp',
  );
  @override
  late final GeneratedColumn<double> depositEgp = GeneratedColumn<double>(
    'deposit_egp',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    syncStatus,
    lastModifiedLocal,
    id,
    apartmentId,
    studentName,
    university,
    parentName,
    parentPhone,
    viewerUserId,
    startDate,
    endDate,
    monthlyRentEgp,
    depositEgp,
    isActive,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'winter_contracts';
  @override
  VerificationContext validateIntegrity(
    Insertable<WinterContract> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('last_modified_local')) {
      context.handle(
        _lastModifiedLocalMeta,
        lastModifiedLocal.isAcceptableOrUnknown(
          data['last_modified_local']!,
          _lastModifiedLocalMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('apartment_id')) {
      context.handle(
        _apartmentIdMeta,
        apartmentId.isAcceptableOrUnknown(
          data['apartment_id']!,
          _apartmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_apartmentIdMeta);
    }
    if (data.containsKey('student_name')) {
      context.handle(
        _studentNameMeta,
        studentName.isAcceptableOrUnknown(
          data['student_name']!,
          _studentNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_studentNameMeta);
    }
    if (data.containsKey('university')) {
      context.handle(
        _universityMeta,
        university.isAcceptableOrUnknown(data['university']!, _universityMeta),
      );
    }
    if (data.containsKey('parent_name')) {
      context.handle(
        _parentNameMeta,
        parentName.isAcceptableOrUnknown(data['parent_name']!, _parentNameMeta),
      );
    }
    if (data.containsKey('parent_phone')) {
      context.handle(
        _parentPhoneMeta,
        parentPhone.isAcceptableOrUnknown(
          data['parent_phone']!,
          _parentPhoneMeta,
        ),
      );
    }
    if (data.containsKey('viewer_user_id')) {
      context.handle(
        _viewerUserIdMeta,
        viewerUserId.isAcceptableOrUnknown(
          data['viewer_user_id']!,
          _viewerUserIdMeta,
        ),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    } else if (isInserting) {
      context.missing(_endDateMeta);
    }
    if (data.containsKey('monthly_rent_egp')) {
      context.handle(
        _monthlyRentEgpMeta,
        monthlyRentEgp.isAcceptableOrUnknown(
          data['monthly_rent_egp']!,
          _monthlyRentEgpMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_monthlyRentEgpMeta);
    }
    if (data.containsKey('deposit_egp')) {
      context.handle(
        _depositEgpMeta,
        depositEgp.isAcceptableOrUnknown(data['deposit_egp']!, _depositEgpMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WinterContract map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WinterContract(
      syncStatus: $WinterContractsTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      lastModifiedLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified_local'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      apartmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}apartment_id'],
      )!,
      studentName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_name'],
      )!,
      university: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}university'],
      ),
      parentName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_name'],
      ),
      parentPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_phone'],
      ),
      viewerUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}viewer_user_id'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      )!,
      monthlyRentEgp: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monthly_rent_egp'],
      )!,
      depositEgp: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}deposit_egp'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WinterContractsTable createAlias(String alias) {
    return $WinterContractsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class WinterContract extends DataClass implements Insertable<WinterContract> {
  final SyncStatus syncStatus;
  final DateTime lastModifiedLocal;
  final String id;
  final String apartmentId;
  final String studentName;
  final String? university;
  final String? parentName;
  final String? parentPhone;
  final String? viewerUserId;
  final DateTime startDate;
  final DateTime endDate;
  final double monthlyRentEgp;
  final double depositEgp;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const WinterContract({
    required this.syncStatus,
    required this.lastModifiedLocal,
    required this.id,
    required this.apartmentId,
    required this.studentName,
    this.university,
    this.parentName,
    this.parentPhone,
    this.viewerUserId,
    required this.startDate,
    required this.endDate,
    required this.monthlyRentEgp,
    required this.depositEgp,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['sync_status'] = Variable<int>(
        $WinterContractsTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['last_modified_local'] = Variable<DateTime>(lastModifiedLocal);
    map['id'] = Variable<String>(id);
    map['apartment_id'] = Variable<String>(apartmentId);
    map['student_name'] = Variable<String>(studentName);
    if (!nullToAbsent || university != null) {
      map['university'] = Variable<String>(university);
    }
    if (!nullToAbsent || parentName != null) {
      map['parent_name'] = Variable<String>(parentName);
    }
    if (!nullToAbsent || parentPhone != null) {
      map['parent_phone'] = Variable<String>(parentPhone);
    }
    if (!nullToAbsent || viewerUserId != null) {
      map['viewer_user_id'] = Variable<String>(viewerUserId);
    }
    map['start_date'] = Variable<DateTime>(startDate);
    map['end_date'] = Variable<DateTime>(endDate);
    map['monthly_rent_egp'] = Variable<double>(monthlyRentEgp);
    map['deposit_egp'] = Variable<double>(depositEgp);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WinterContractsCompanion toCompanion(bool nullToAbsent) {
    return WinterContractsCompanion(
      syncStatus: Value(syncStatus),
      lastModifiedLocal: Value(lastModifiedLocal),
      id: Value(id),
      apartmentId: Value(apartmentId),
      studentName: Value(studentName),
      university: university == null && nullToAbsent
          ? const Value.absent()
          : Value(university),
      parentName: parentName == null && nullToAbsent
          ? const Value.absent()
          : Value(parentName),
      parentPhone: parentPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(parentPhone),
      viewerUserId: viewerUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(viewerUserId),
      startDate: Value(startDate),
      endDate: Value(endDate),
      monthlyRentEgp: Value(monthlyRentEgp),
      depositEgp: Value(depositEgp),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory WinterContract.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WinterContract(
      syncStatus: $WinterContractsTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
      lastModifiedLocal: serializer.fromJson<DateTime>(
        json['lastModifiedLocal'],
      ),
      id: serializer.fromJson<String>(json['id']),
      apartmentId: serializer.fromJson<String>(json['apartmentId']),
      studentName: serializer.fromJson<String>(json['studentName']),
      university: serializer.fromJson<String?>(json['university']),
      parentName: serializer.fromJson<String?>(json['parentName']),
      parentPhone: serializer.fromJson<String?>(json['parentPhone']),
      viewerUserId: serializer.fromJson<String?>(json['viewerUserId']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime>(json['endDate']),
      monthlyRentEgp: serializer.fromJson<double>(json['monthlyRentEgp']),
      depositEgp: serializer.fromJson<double>(json['depositEgp']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncStatus': serializer.toJson<int>(
        $WinterContractsTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'lastModifiedLocal': serializer.toJson<DateTime>(lastModifiedLocal),
      'id': serializer.toJson<String>(id),
      'apartmentId': serializer.toJson<String>(apartmentId),
      'studentName': serializer.toJson<String>(studentName),
      'university': serializer.toJson<String?>(university),
      'parentName': serializer.toJson<String?>(parentName),
      'parentPhone': serializer.toJson<String?>(parentPhone),
      'viewerUserId': serializer.toJson<String?>(viewerUserId),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime>(endDate),
      'monthlyRentEgp': serializer.toJson<double>(monthlyRentEgp),
      'depositEgp': serializer.toJson<double>(depositEgp),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WinterContract copyWith({
    SyncStatus? syncStatus,
    DateTime? lastModifiedLocal,
    String? id,
    String? apartmentId,
    String? studentName,
    Value<String?> university = const Value.absent(),
    Value<String?> parentName = const Value.absent(),
    Value<String?> parentPhone = const Value.absent(),
    Value<String?> viewerUserId = const Value.absent(),
    DateTime? startDate,
    DateTime? endDate,
    double? monthlyRentEgp,
    double? depositEgp,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => WinterContract(
    syncStatus: syncStatus ?? this.syncStatus,
    lastModifiedLocal: lastModifiedLocal ?? this.lastModifiedLocal,
    id: id ?? this.id,
    apartmentId: apartmentId ?? this.apartmentId,
    studentName: studentName ?? this.studentName,
    university: university.present ? university.value : this.university,
    parentName: parentName.present ? parentName.value : this.parentName,
    parentPhone: parentPhone.present ? parentPhone.value : this.parentPhone,
    viewerUserId: viewerUserId.present ? viewerUserId.value : this.viewerUserId,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    monthlyRentEgp: monthlyRentEgp ?? this.monthlyRentEgp,
    depositEgp: depositEgp ?? this.depositEgp,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WinterContract copyWithCompanion(WinterContractsCompanion data) {
    return WinterContract(
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastModifiedLocal: data.lastModifiedLocal.present
          ? data.lastModifiedLocal.value
          : this.lastModifiedLocal,
      id: data.id.present ? data.id.value : this.id,
      apartmentId: data.apartmentId.present
          ? data.apartmentId.value
          : this.apartmentId,
      studentName: data.studentName.present
          ? data.studentName.value
          : this.studentName,
      university: data.university.present
          ? data.university.value
          : this.university,
      parentName: data.parentName.present
          ? data.parentName.value
          : this.parentName,
      parentPhone: data.parentPhone.present
          ? data.parentPhone.value
          : this.parentPhone,
      viewerUserId: data.viewerUserId.present
          ? data.viewerUserId.value
          : this.viewerUserId,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      monthlyRentEgp: data.monthlyRentEgp.present
          ? data.monthlyRentEgp.value
          : this.monthlyRentEgp,
      depositEgp: data.depositEgp.present
          ? data.depositEgp.value
          : this.depositEgp,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WinterContract(')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedLocal: $lastModifiedLocal, ')
          ..write('id: $id, ')
          ..write('apartmentId: $apartmentId, ')
          ..write('studentName: $studentName, ')
          ..write('university: $university, ')
          ..write('parentName: $parentName, ')
          ..write('parentPhone: $parentPhone, ')
          ..write('viewerUserId: $viewerUserId, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('monthlyRentEgp: $monthlyRentEgp, ')
          ..write('depositEgp: $depositEgp, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    syncStatus,
    lastModifiedLocal,
    id,
    apartmentId,
    studentName,
    university,
    parentName,
    parentPhone,
    viewerUserId,
    startDate,
    endDate,
    monthlyRentEgp,
    depositEgp,
    isActive,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WinterContract &&
          other.syncStatus == this.syncStatus &&
          other.lastModifiedLocal == this.lastModifiedLocal &&
          other.id == this.id &&
          other.apartmentId == this.apartmentId &&
          other.studentName == this.studentName &&
          other.university == this.university &&
          other.parentName == this.parentName &&
          other.parentPhone == this.parentPhone &&
          other.viewerUserId == this.viewerUserId &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.monthlyRentEgp == this.monthlyRentEgp &&
          other.depositEgp == this.depositEgp &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WinterContractsCompanion extends UpdateCompanion<WinterContract> {
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> lastModifiedLocal;
  final Value<String> id;
  final Value<String> apartmentId;
  final Value<String> studentName;
  final Value<String?> university;
  final Value<String?> parentName;
  final Value<String?> parentPhone;
  final Value<String?> viewerUserId;
  final Value<DateTime> startDate;
  final Value<DateTime> endDate;
  final Value<double> monthlyRentEgp;
  final Value<double> depositEgp;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const WinterContractsCompanion({
    this.syncStatus = const Value.absent(),
    this.lastModifiedLocal = const Value.absent(),
    this.id = const Value.absent(),
    this.apartmentId = const Value.absent(),
    this.studentName = const Value.absent(),
    this.university = const Value.absent(),
    this.parentName = const Value.absent(),
    this.parentPhone = const Value.absent(),
    this.viewerUserId = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.monthlyRentEgp = const Value.absent(),
    this.depositEgp = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WinterContractsCompanion.insert({
    this.syncStatus = const Value.absent(),
    this.lastModifiedLocal = const Value.absent(),
    required String id,
    required String apartmentId,
    required String studentName,
    this.university = const Value.absent(),
    this.parentName = const Value.absent(),
    this.parentPhone = const Value.absent(),
    this.viewerUserId = const Value.absent(),
    required DateTime startDate,
    required DateTime endDate,
    required double monthlyRentEgp,
    this.depositEgp = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       apartmentId = Value(apartmentId),
       studentName = Value(studentName),
       startDate = Value(startDate),
       endDate = Value(endDate),
       monthlyRentEgp = Value(monthlyRentEgp),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<WinterContract> custom({
    Expression<int>? syncStatus,
    Expression<DateTime>? lastModifiedLocal,
    Expression<String>? id,
    Expression<String>? apartmentId,
    Expression<String>? studentName,
    Expression<String>? university,
    Expression<String>? parentName,
    Expression<String>? parentPhone,
    Expression<String>? viewerUserId,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<double>? monthlyRentEgp,
    Expression<double>? depositEgp,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastModifiedLocal != null) 'last_modified_local': lastModifiedLocal,
      if (id != null) 'id': id,
      if (apartmentId != null) 'apartment_id': apartmentId,
      if (studentName != null) 'student_name': studentName,
      if (university != null) 'university': university,
      if (parentName != null) 'parent_name': parentName,
      if (parentPhone != null) 'parent_phone': parentPhone,
      if (viewerUserId != null) 'viewer_user_id': viewerUserId,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (monthlyRentEgp != null) 'monthly_rent_egp': monthlyRentEgp,
      if (depositEgp != null) 'deposit_egp': depositEgp,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WinterContractsCompanion copyWith({
    Value<SyncStatus>? syncStatus,
    Value<DateTime>? lastModifiedLocal,
    Value<String>? id,
    Value<String>? apartmentId,
    Value<String>? studentName,
    Value<String?>? university,
    Value<String?>? parentName,
    Value<String?>? parentPhone,
    Value<String?>? viewerUserId,
    Value<DateTime>? startDate,
    Value<DateTime>? endDate,
    Value<double>? monthlyRentEgp,
    Value<double>? depositEgp,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return WinterContractsCompanion(
      syncStatus: syncStatus ?? this.syncStatus,
      lastModifiedLocal: lastModifiedLocal ?? this.lastModifiedLocal,
      id: id ?? this.id,
      apartmentId: apartmentId ?? this.apartmentId,
      studentName: studentName ?? this.studentName,
      university: university ?? this.university,
      parentName: parentName ?? this.parentName,
      parentPhone: parentPhone ?? this.parentPhone,
      viewerUserId: viewerUserId ?? this.viewerUserId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      monthlyRentEgp: monthlyRentEgp ?? this.monthlyRentEgp,
      depositEgp: depositEgp ?? this.depositEgp,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $WinterContractsTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (lastModifiedLocal.present) {
      map['last_modified_local'] = Variable<DateTime>(lastModifiedLocal.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (apartmentId.present) {
      map['apartment_id'] = Variable<String>(apartmentId.value);
    }
    if (studentName.present) {
      map['student_name'] = Variable<String>(studentName.value);
    }
    if (university.present) {
      map['university'] = Variable<String>(university.value);
    }
    if (parentName.present) {
      map['parent_name'] = Variable<String>(parentName.value);
    }
    if (parentPhone.present) {
      map['parent_phone'] = Variable<String>(parentPhone.value);
    }
    if (viewerUserId.present) {
      map['viewer_user_id'] = Variable<String>(viewerUserId.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (monthlyRentEgp.present) {
      map['monthly_rent_egp'] = Variable<double>(monthlyRentEgp.value);
    }
    if (depositEgp.present) {
      map['deposit_egp'] = Variable<double>(depositEgp.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WinterContractsCompanion(')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedLocal: $lastModifiedLocal, ')
          ..write('id: $id, ')
          ..write('apartmentId: $apartmentId, ')
          ..write('studentName: $studentName, ')
          ..write('university: $university, ')
          ..write('parentName: $parentName, ')
          ..write('parentPhone: $parentPhone, ')
          ..write('viewerUserId: $viewerUserId, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('monthlyRentEgp: $monthlyRentEgp, ')
          ..write('depositEgp: $depositEgp, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WinterPaymentsTable extends WinterPayments
    with TableInfo<$WinterPaymentsTable, WinterPayment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WinterPaymentsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<SyncStatus>($WinterPaymentsTable.$convertersyncStatus);
  static const VerificationMeta _lastModifiedLocalMeta = const VerificationMeta(
    'lastModifiedLocal',
  );
  @override
  late final GeneratedColumn<DateTime> lastModifiedLocal =
      GeneratedColumn<DateTime>(
        'last_modified_local',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contractIdMeta = const VerificationMeta(
    'contractId',
  );
  @override
  late final GeneratedColumn<String> contractId = GeneratedColumn<String>(
    'contract_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES winter_contracts (id)',
    ),
  );
  static const VerificationMeta _amountEgpMeta = const VerificationMeta(
    'amountEgp',
  );
  @override
  late final GeneratedColumn<double> amountEgp = GeneratedColumn<double>(
    'amount_egp',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentDateMeta = const VerificationMeta(
    'paymentDate',
  );
  @override
  late final GeneratedColumn<DateTime> paymentDate = GeneratedColumn<DateTime>(
    'payment_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receiptUrlMeta = const VerificationMeta(
    'receiptUrl',
  );
  @override
  late final GeneratedColumn<String> receiptUrl = GeneratedColumn<String>(
    'receipt_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    syncStatus,
    lastModifiedLocal,
    id,
    contractId,
    amountEgp,
    paymentDate,
    receiptUrl,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'winter_payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<WinterPayment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('last_modified_local')) {
      context.handle(
        _lastModifiedLocalMeta,
        lastModifiedLocal.isAcceptableOrUnknown(
          data['last_modified_local']!,
          _lastModifiedLocalMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('contract_id')) {
      context.handle(
        _contractIdMeta,
        contractId.isAcceptableOrUnknown(data['contract_id']!, _contractIdMeta),
      );
    } else if (isInserting) {
      context.missing(_contractIdMeta);
    }
    if (data.containsKey('amount_egp')) {
      context.handle(
        _amountEgpMeta,
        amountEgp.isAcceptableOrUnknown(data['amount_egp']!, _amountEgpMeta),
      );
    } else if (isInserting) {
      context.missing(_amountEgpMeta);
    }
    if (data.containsKey('payment_date')) {
      context.handle(
        _paymentDateMeta,
        paymentDate.isAcceptableOrUnknown(
          data['payment_date']!,
          _paymentDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentDateMeta);
    }
    if (data.containsKey('receipt_url')) {
      context.handle(
        _receiptUrlMeta,
        receiptUrl.isAcceptableOrUnknown(data['receipt_url']!, _receiptUrlMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WinterPayment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WinterPayment(
      syncStatus: $WinterPaymentsTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      lastModifiedLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified_local'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      contractId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contract_id'],
      )!,
      amountEgp: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount_egp'],
      )!,
      paymentDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}payment_date'],
      )!,
      receiptUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_url'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $WinterPaymentsTable createAlias(String alias) {
    return $WinterPaymentsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class WinterPayment extends DataClass implements Insertable<WinterPayment> {
  final SyncStatus syncStatus;
  final DateTime lastModifiedLocal;
  final String id;
  final String contractId;
  final double amountEgp;
  final DateTime paymentDate;
  final String? receiptUrl;
  final DateTime createdAt;
  const WinterPayment({
    required this.syncStatus,
    required this.lastModifiedLocal,
    required this.id,
    required this.contractId,
    required this.amountEgp,
    required this.paymentDate,
    this.receiptUrl,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['sync_status'] = Variable<int>(
        $WinterPaymentsTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['last_modified_local'] = Variable<DateTime>(lastModifiedLocal);
    map['id'] = Variable<String>(id);
    map['contract_id'] = Variable<String>(contractId);
    map['amount_egp'] = Variable<double>(amountEgp);
    map['payment_date'] = Variable<DateTime>(paymentDate);
    if (!nullToAbsent || receiptUrl != null) {
      map['receipt_url'] = Variable<String>(receiptUrl);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WinterPaymentsCompanion toCompanion(bool nullToAbsent) {
    return WinterPaymentsCompanion(
      syncStatus: Value(syncStatus),
      lastModifiedLocal: Value(lastModifiedLocal),
      id: Value(id),
      contractId: Value(contractId),
      amountEgp: Value(amountEgp),
      paymentDate: Value(paymentDate),
      receiptUrl: receiptUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptUrl),
      createdAt: Value(createdAt),
    );
  }

  factory WinterPayment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WinterPayment(
      syncStatus: $WinterPaymentsTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
      lastModifiedLocal: serializer.fromJson<DateTime>(
        json['lastModifiedLocal'],
      ),
      id: serializer.fromJson<String>(json['id']),
      contractId: serializer.fromJson<String>(json['contractId']),
      amountEgp: serializer.fromJson<double>(json['amountEgp']),
      paymentDate: serializer.fromJson<DateTime>(json['paymentDate']),
      receiptUrl: serializer.fromJson<String?>(json['receiptUrl']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncStatus': serializer.toJson<int>(
        $WinterPaymentsTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'lastModifiedLocal': serializer.toJson<DateTime>(lastModifiedLocal),
      'id': serializer.toJson<String>(id),
      'contractId': serializer.toJson<String>(contractId),
      'amountEgp': serializer.toJson<double>(amountEgp),
      'paymentDate': serializer.toJson<DateTime>(paymentDate),
      'receiptUrl': serializer.toJson<String?>(receiptUrl),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  WinterPayment copyWith({
    SyncStatus? syncStatus,
    DateTime? lastModifiedLocal,
    String? id,
    String? contractId,
    double? amountEgp,
    DateTime? paymentDate,
    Value<String?> receiptUrl = const Value.absent(),
    DateTime? createdAt,
  }) => WinterPayment(
    syncStatus: syncStatus ?? this.syncStatus,
    lastModifiedLocal: lastModifiedLocal ?? this.lastModifiedLocal,
    id: id ?? this.id,
    contractId: contractId ?? this.contractId,
    amountEgp: amountEgp ?? this.amountEgp,
    paymentDate: paymentDate ?? this.paymentDate,
    receiptUrl: receiptUrl.present ? receiptUrl.value : this.receiptUrl,
    createdAt: createdAt ?? this.createdAt,
  );
  WinterPayment copyWithCompanion(WinterPaymentsCompanion data) {
    return WinterPayment(
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastModifiedLocal: data.lastModifiedLocal.present
          ? data.lastModifiedLocal.value
          : this.lastModifiedLocal,
      id: data.id.present ? data.id.value : this.id,
      contractId: data.contractId.present
          ? data.contractId.value
          : this.contractId,
      amountEgp: data.amountEgp.present ? data.amountEgp.value : this.amountEgp,
      paymentDate: data.paymentDate.present
          ? data.paymentDate.value
          : this.paymentDate,
      receiptUrl: data.receiptUrl.present
          ? data.receiptUrl.value
          : this.receiptUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WinterPayment(')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedLocal: $lastModifiedLocal, ')
          ..write('id: $id, ')
          ..write('contractId: $contractId, ')
          ..write('amountEgp: $amountEgp, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('receiptUrl: $receiptUrl, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    syncStatus,
    lastModifiedLocal,
    id,
    contractId,
    amountEgp,
    paymentDate,
    receiptUrl,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WinterPayment &&
          other.syncStatus == this.syncStatus &&
          other.lastModifiedLocal == this.lastModifiedLocal &&
          other.id == this.id &&
          other.contractId == this.contractId &&
          other.amountEgp == this.amountEgp &&
          other.paymentDate == this.paymentDate &&
          other.receiptUrl == this.receiptUrl &&
          other.createdAt == this.createdAt);
}

class WinterPaymentsCompanion extends UpdateCompanion<WinterPayment> {
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> lastModifiedLocal;
  final Value<String> id;
  final Value<String> contractId;
  final Value<double> amountEgp;
  final Value<DateTime> paymentDate;
  final Value<String?> receiptUrl;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const WinterPaymentsCompanion({
    this.syncStatus = const Value.absent(),
    this.lastModifiedLocal = const Value.absent(),
    this.id = const Value.absent(),
    this.contractId = const Value.absent(),
    this.amountEgp = const Value.absent(),
    this.paymentDate = const Value.absent(),
    this.receiptUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WinterPaymentsCompanion.insert({
    this.syncStatus = const Value.absent(),
    this.lastModifiedLocal = const Value.absent(),
    required String id,
    required String contractId,
    required double amountEgp,
    required DateTime paymentDate,
    this.receiptUrl = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       contractId = Value(contractId),
       amountEgp = Value(amountEgp),
       paymentDate = Value(paymentDate),
       createdAt = Value(createdAt);
  static Insertable<WinterPayment> custom({
    Expression<int>? syncStatus,
    Expression<DateTime>? lastModifiedLocal,
    Expression<String>? id,
    Expression<String>? contractId,
    Expression<double>? amountEgp,
    Expression<DateTime>? paymentDate,
    Expression<String>? receiptUrl,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastModifiedLocal != null) 'last_modified_local': lastModifiedLocal,
      if (id != null) 'id': id,
      if (contractId != null) 'contract_id': contractId,
      if (amountEgp != null) 'amount_egp': amountEgp,
      if (paymentDate != null) 'payment_date': paymentDate,
      if (receiptUrl != null) 'receipt_url': receiptUrl,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WinterPaymentsCompanion copyWith({
    Value<SyncStatus>? syncStatus,
    Value<DateTime>? lastModifiedLocal,
    Value<String>? id,
    Value<String>? contractId,
    Value<double>? amountEgp,
    Value<DateTime>? paymentDate,
    Value<String?>? receiptUrl,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return WinterPaymentsCompanion(
      syncStatus: syncStatus ?? this.syncStatus,
      lastModifiedLocal: lastModifiedLocal ?? this.lastModifiedLocal,
      id: id ?? this.id,
      contractId: contractId ?? this.contractId,
      amountEgp: amountEgp ?? this.amountEgp,
      paymentDate: paymentDate ?? this.paymentDate,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $WinterPaymentsTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (lastModifiedLocal.present) {
      map['last_modified_local'] = Variable<DateTime>(lastModifiedLocal.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (contractId.present) {
      map['contract_id'] = Variable<String>(contractId.value);
    }
    if (amountEgp.present) {
      map['amount_egp'] = Variable<double>(amountEgp.value);
    }
    if (paymentDate.present) {
      map['payment_date'] = Variable<DateTime>(paymentDate.value);
    }
    if (receiptUrl.present) {
      map['receipt_url'] = Variable<String>(receiptUrl.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WinterPaymentsCompanion(')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedLocal: $lastModifiedLocal, ')
          ..write('id: $id, ')
          ..write('contractId: $contractId, ')
          ..write('amountEgp: $amountEgp, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('receiptUrl: $receiptUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MeterReadingsTable extends MeterReadings
    with TableInfo<$MeterReadingsTable, MeterReading> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeterReadingsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<SyncStatus>($MeterReadingsTable.$convertersyncStatus);
  static const VerificationMeta _lastModifiedLocalMeta = const VerificationMeta(
    'lastModifiedLocal',
  );
  @override
  late final GeneratedColumn<DateTime> lastModifiedLocal =
      GeneratedColumn<DateTime>(
        'last_modified_local',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _apartmentIdMeta = const VerificationMeta(
    'apartmentId',
  );
  @override
  late final GeneratedColumn<String> apartmentId = GeneratedColumn<String>(
    'apartment_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES apartments (id)',
    ),
  );
  static const VerificationMeta _buildingIdMeta = const VerificationMeta(
    'buildingId',
  );
  @override
  late final GeneratedColumn<String> buildingId = GeneratedColumn<String>(
    'building_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES buildings (id)',
    ),
  );
  static const VerificationMeta _readingDateMeta = const VerificationMeta(
    'readingDate',
  );
  @override
  late final GeneratedColumn<DateTime> readingDate = GeneratedColumn<DateTime>(
    'reading_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _previousReadingMeta = const VerificationMeta(
    'previousReading',
  );
  @override
  late final GeneratedColumn<double> previousReading = GeneratedColumn<double>(
    'previous_reading',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentReadingMeta = const VerificationMeta(
    'currentReading',
  );
  @override
  late final GeneratedColumn<double> currentReading = GeneratedColumn<double>(
    'current_reading',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountEgpMeta = const VerificationMeta(
    'amountEgp',
  );
  @override
  late final GeneratedColumn<double> amountEgp = GeneratedColumn<double>(
    'amount_egp',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSharedExpenseMeta = const VerificationMeta(
    'isSharedExpense',
  );
  @override
  late final GeneratedColumn<bool> isSharedExpense = GeneratedColumn<bool>(
    'is_shared_expense',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_shared_expense" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    syncStatus,
    lastModifiedLocal,
    id,
    apartmentId,
    buildingId,
    readingDate,
    previousReading,
    currentReading,
    amountEgp,
    isSharedExpense,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meter_readings';
  @override
  VerificationContext validateIntegrity(
    Insertable<MeterReading> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('last_modified_local')) {
      context.handle(
        _lastModifiedLocalMeta,
        lastModifiedLocal.isAcceptableOrUnknown(
          data['last_modified_local']!,
          _lastModifiedLocalMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('apartment_id')) {
      context.handle(
        _apartmentIdMeta,
        apartmentId.isAcceptableOrUnknown(
          data['apartment_id']!,
          _apartmentIdMeta,
        ),
      );
    }
    if (data.containsKey('building_id')) {
      context.handle(
        _buildingIdMeta,
        buildingId.isAcceptableOrUnknown(data['building_id']!, _buildingIdMeta),
      );
    }
    if (data.containsKey('reading_date')) {
      context.handle(
        _readingDateMeta,
        readingDate.isAcceptableOrUnknown(
          data['reading_date']!,
          _readingDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_readingDateMeta);
    }
    if (data.containsKey('previous_reading')) {
      context.handle(
        _previousReadingMeta,
        previousReading.isAcceptableOrUnknown(
          data['previous_reading']!,
          _previousReadingMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_previousReadingMeta);
    }
    if (data.containsKey('current_reading')) {
      context.handle(
        _currentReadingMeta,
        currentReading.isAcceptableOrUnknown(
          data['current_reading']!,
          _currentReadingMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentReadingMeta);
    }
    if (data.containsKey('amount_egp')) {
      context.handle(
        _amountEgpMeta,
        amountEgp.isAcceptableOrUnknown(data['amount_egp']!, _amountEgpMeta),
      );
    } else if (isInserting) {
      context.missing(_amountEgpMeta);
    }
    if (data.containsKey('is_shared_expense')) {
      context.handle(
        _isSharedExpenseMeta,
        isSharedExpense.isAcceptableOrUnknown(
          data['is_shared_expense']!,
          _isSharedExpenseMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MeterReading map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MeterReading(
      syncStatus: $MeterReadingsTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      lastModifiedLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified_local'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      apartmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}apartment_id'],
      ),
      buildingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}building_id'],
      ),
      readingDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reading_date'],
      )!,
      previousReading: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}previous_reading'],
      )!,
      currentReading: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_reading'],
      )!,
      amountEgp: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount_egp'],
      )!,
      isSharedExpense: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_shared_expense'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MeterReadingsTable createAlias(String alias) {
    return $MeterReadingsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class MeterReading extends DataClass implements Insertable<MeterReading> {
  final SyncStatus syncStatus;
  final DateTime lastModifiedLocal;
  final String id;
  final String? apartmentId;
  final String? buildingId;
  final DateTime readingDate;
  final double previousReading;
  final double currentReading;
  final double amountEgp;
  final bool isSharedExpense;
  final DateTime createdAt;
  const MeterReading({
    required this.syncStatus,
    required this.lastModifiedLocal,
    required this.id,
    this.apartmentId,
    this.buildingId,
    required this.readingDate,
    required this.previousReading,
    required this.currentReading,
    required this.amountEgp,
    required this.isSharedExpense,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['sync_status'] = Variable<int>(
        $MeterReadingsTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['last_modified_local'] = Variable<DateTime>(lastModifiedLocal);
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || apartmentId != null) {
      map['apartment_id'] = Variable<String>(apartmentId);
    }
    if (!nullToAbsent || buildingId != null) {
      map['building_id'] = Variable<String>(buildingId);
    }
    map['reading_date'] = Variable<DateTime>(readingDate);
    map['previous_reading'] = Variable<double>(previousReading);
    map['current_reading'] = Variable<double>(currentReading);
    map['amount_egp'] = Variable<double>(amountEgp);
    map['is_shared_expense'] = Variable<bool>(isSharedExpense);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MeterReadingsCompanion toCompanion(bool nullToAbsent) {
    return MeterReadingsCompanion(
      syncStatus: Value(syncStatus),
      lastModifiedLocal: Value(lastModifiedLocal),
      id: Value(id),
      apartmentId: apartmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(apartmentId),
      buildingId: buildingId == null && nullToAbsent
          ? const Value.absent()
          : Value(buildingId),
      readingDate: Value(readingDate),
      previousReading: Value(previousReading),
      currentReading: Value(currentReading),
      amountEgp: Value(amountEgp),
      isSharedExpense: Value(isSharedExpense),
      createdAt: Value(createdAt),
    );
  }

  factory MeterReading.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MeterReading(
      syncStatus: $MeterReadingsTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
      lastModifiedLocal: serializer.fromJson<DateTime>(
        json['lastModifiedLocal'],
      ),
      id: serializer.fromJson<String>(json['id']),
      apartmentId: serializer.fromJson<String?>(json['apartmentId']),
      buildingId: serializer.fromJson<String?>(json['buildingId']),
      readingDate: serializer.fromJson<DateTime>(json['readingDate']),
      previousReading: serializer.fromJson<double>(json['previousReading']),
      currentReading: serializer.fromJson<double>(json['currentReading']),
      amountEgp: serializer.fromJson<double>(json['amountEgp']),
      isSharedExpense: serializer.fromJson<bool>(json['isSharedExpense']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncStatus': serializer.toJson<int>(
        $MeterReadingsTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'lastModifiedLocal': serializer.toJson<DateTime>(lastModifiedLocal),
      'id': serializer.toJson<String>(id),
      'apartmentId': serializer.toJson<String?>(apartmentId),
      'buildingId': serializer.toJson<String?>(buildingId),
      'readingDate': serializer.toJson<DateTime>(readingDate),
      'previousReading': serializer.toJson<double>(previousReading),
      'currentReading': serializer.toJson<double>(currentReading),
      'amountEgp': serializer.toJson<double>(amountEgp),
      'isSharedExpense': serializer.toJson<bool>(isSharedExpense),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MeterReading copyWith({
    SyncStatus? syncStatus,
    DateTime? lastModifiedLocal,
    String? id,
    Value<String?> apartmentId = const Value.absent(),
    Value<String?> buildingId = const Value.absent(),
    DateTime? readingDate,
    double? previousReading,
    double? currentReading,
    double? amountEgp,
    bool? isSharedExpense,
    DateTime? createdAt,
  }) => MeterReading(
    syncStatus: syncStatus ?? this.syncStatus,
    lastModifiedLocal: lastModifiedLocal ?? this.lastModifiedLocal,
    id: id ?? this.id,
    apartmentId: apartmentId.present ? apartmentId.value : this.apartmentId,
    buildingId: buildingId.present ? buildingId.value : this.buildingId,
    readingDate: readingDate ?? this.readingDate,
    previousReading: previousReading ?? this.previousReading,
    currentReading: currentReading ?? this.currentReading,
    amountEgp: amountEgp ?? this.amountEgp,
    isSharedExpense: isSharedExpense ?? this.isSharedExpense,
    createdAt: createdAt ?? this.createdAt,
  );
  MeterReading copyWithCompanion(MeterReadingsCompanion data) {
    return MeterReading(
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastModifiedLocal: data.lastModifiedLocal.present
          ? data.lastModifiedLocal.value
          : this.lastModifiedLocal,
      id: data.id.present ? data.id.value : this.id,
      apartmentId: data.apartmentId.present
          ? data.apartmentId.value
          : this.apartmentId,
      buildingId: data.buildingId.present
          ? data.buildingId.value
          : this.buildingId,
      readingDate: data.readingDate.present
          ? data.readingDate.value
          : this.readingDate,
      previousReading: data.previousReading.present
          ? data.previousReading.value
          : this.previousReading,
      currentReading: data.currentReading.present
          ? data.currentReading.value
          : this.currentReading,
      amountEgp: data.amountEgp.present ? data.amountEgp.value : this.amountEgp,
      isSharedExpense: data.isSharedExpense.present
          ? data.isSharedExpense.value
          : this.isSharedExpense,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MeterReading(')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedLocal: $lastModifiedLocal, ')
          ..write('id: $id, ')
          ..write('apartmentId: $apartmentId, ')
          ..write('buildingId: $buildingId, ')
          ..write('readingDate: $readingDate, ')
          ..write('previousReading: $previousReading, ')
          ..write('currentReading: $currentReading, ')
          ..write('amountEgp: $amountEgp, ')
          ..write('isSharedExpense: $isSharedExpense, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    syncStatus,
    lastModifiedLocal,
    id,
    apartmentId,
    buildingId,
    readingDate,
    previousReading,
    currentReading,
    amountEgp,
    isSharedExpense,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeterReading &&
          other.syncStatus == this.syncStatus &&
          other.lastModifiedLocal == this.lastModifiedLocal &&
          other.id == this.id &&
          other.apartmentId == this.apartmentId &&
          other.buildingId == this.buildingId &&
          other.readingDate == this.readingDate &&
          other.previousReading == this.previousReading &&
          other.currentReading == this.currentReading &&
          other.amountEgp == this.amountEgp &&
          other.isSharedExpense == this.isSharedExpense &&
          other.createdAt == this.createdAt);
}

class MeterReadingsCompanion extends UpdateCompanion<MeterReading> {
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> lastModifiedLocal;
  final Value<String> id;
  final Value<String?> apartmentId;
  final Value<String?> buildingId;
  final Value<DateTime> readingDate;
  final Value<double> previousReading;
  final Value<double> currentReading;
  final Value<double> amountEgp;
  final Value<bool> isSharedExpense;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MeterReadingsCompanion({
    this.syncStatus = const Value.absent(),
    this.lastModifiedLocal = const Value.absent(),
    this.id = const Value.absent(),
    this.apartmentId = const Value.absent(),
    this.buildingId = const Value.absent(),
    this.readingDate = const Value.absent(),
    this.previousReading = const Value.absent(),
    this.currentReading = const Value.absent(),
    this.amountEgp = const Value.absent(),
    this.isSharedExpense = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MeterReadingsCompanion.insert({
    this.syncStatus = const Value.absent(),
    this.lastModifiedLocal = const Value.absent(),
    required String id,
    this.apartmentId = const Value.absent(),
    this.buildingId = const Value.absent(),
    required DateTime readingDate,
    required double previousReading,
    required double currentReading,
    required double amountEgp,
    this.isSharedExpense = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       readingDate = Value(readingDate),
       previousReading = Value(previousReading),
       currentReading = Value(currentReading),
       amountEgp = Value(amountEgp),
       createdAt = Value(createdAt);
  static Insertable<MeterReading> custom({
    Expression<int>? syncStatus,
    Expression<DateTime>? lastModifiedLocal,
    Expression<String>? id,
    Expression<String>? apartmentId,
    Expression<String>? buildingId,
    Expression<DateTime>? readingDate,
    Expression<double>? previousReading,
    Expression<double>? currentReading,
    Expression<double>? amountEgp,
    Expression<bool>? isSharedExpense,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastModifiedLocal != null) 'last_modified_local': lastModifiedLocal,
      if (id != null) 'id': id,
      if (apartmentId != null) 'apartment_id': apartmentId,
      if (buildingId != null) 'building_id': buildingId,
      if (readingDate != null) 'reading_date': readingDate,
      if (previousReading != null) 'previous_reading': previousReading,
      if (currentReading != null) 'current_reading': currentReading,
      if (amountEgp != null) 'amount_egp': amountEgp,
      if (isSharedExpense != null) 'is_shared_expense': isSharedExpense,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MeterReadingsCompanion copyWith({
    Value<SyncStatus>? syncStatus,
    Value<DateTime>? lastModifiedLocal,
    Value<String>? id,
    Value<String?>? apartmentId,
    Value<String?>? buildingId,
    Value<DateTime>? readingDate,
    Value<double>? previousReading,
    Value<double>? currentReading,
    Value<double>? amountEgp,
    Value<bool>? isSharedExpense,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return MeterReadingsCompanion(
      syncStatus: syncStatus ?? this.syncStatus,
      lastModifiedLocal: lastModifiedLocal ?? this.lastModifiedLocal,
      id: id ?? this.id,
      apartmentId: apartmentId ?? this.apartmentId,
      buildingId: buildingId ?? this.buildingId,
      readingDate: readingDate ?? this.readingDate,
      previousReading: previousReading ?? this.previousReading,
      currentReading: currentReading ?? this.currentReading,
      amountEgp: amountEgp ?? this.amountEgp,
      isSharedExpense: isSharedExpense ?? this.isSharedExpense,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $MeterReadingsTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (lastModifiedLocal.present) {
      map['last_modified_local'] = Variable<DateTime>(lastModifiedLocal.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (apartmentId.present) {
      map['apartment_id'] = Variable<String>(apartmentId.value);
    }
    if (buildingId.present) {
      map['building_id'] = Variable<String>(buildingId.value);
    }
    if (readingDate.present) {
      map['reading_date'] = Variable<DateTime>(readingDate.value);
    }
    if (previousReading.present) {
      map['previous_reading'] = Variable<double>(previousReading.value);
    }
    if (currentReading.present) {
      map['current_reading'] = Variable<double>(currentReading.value);
    }
    if (amountEgp.present) {
      map['amount_egp'] = Variable<double>(amountEgp.value);
    }
    if (isSharedExpense.present) {
      map['is_shared_expense'] = Variable<bool>(isSharedExpense.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeterReadingsCompanion(')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedLocal: $lastModifiedLocal, ')
          ..write('id: $id, ')
          ..write('apartmentId: $apartmentId, ')
          ..write('buildingId: $buildingId, ')
          ..write('readingDate: $readingDate, ')
          ..write('previousReading: $previousReading, ')
          ..write('currentReading: $currentReading, ')
          ..write('amountEgp: $amountEgp, ')
          ..write('isSharedExpense: $isSharedExpense, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTable extends Expenses with TableInfo<$ExpensesTable, Expense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<SyncStatus>($ExpensesTable.$convertersyncStatus);
  static const VerificationMeta _lastModifiedLocalMeta = const VerificationMeta(
    'lastModifiedLocal',
  );
  @override
  late final GeneratedColumn<DateTime> lastModifiedLocal =
      GeneratedColumn<DateTime>(
        'last_modified_local',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _buildingIdMeta = const VerificationMeta(
    'buildingId',
  );
  @override
  late final GeneratedColumn<String> buildingId = GeneratedColumn<String>(
    'building_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES buildings (id)',
    ),
  );
  static const VerificationMeta _apartmentIdMeta = const VerificationMeta(
    'apartmentId',
  );
  @override
  late final GeneratedColumn<String> apartmentId = GeneratedColumn<String>(
    'apartment_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES apartments (id)',
    ),
  );
  static const VerificationMeta _expenseTypeMeta = const VerificationMeta(
    'expenseType',
  );
  @override
  late final GeneratedColumn<String> expenseType = GeneratedColumn<String>(
    'expense_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountEgpMeta = const VerificationMeta(
    'amountEgp',
  );
  @override
  late final GeneratedColumn<double> amountEgp = GeneratedColumn<double>(
    'amount_egp',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expenseDateMeta = const VerificationMeta(
    'expenseDate',
  );
  @override
  late final GeneratedColumn<DateTime> expenseDate = GeneratedColumn<DateTime>(
    'expense_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _installmentNumberMeta = const VerificationMeta(
    'installmentNumber',
  );
  @override
  late final GeneratedColumn<int> installmentNumber = GeneratedColumn<int>(
    'installment_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receiptUrlMeta = const VerificationMeta(
    'receiptUrl',
  );
  @override
  late final GeneratedColumn<String> receiptUrl = GeneratedColumn<String>(
    'receipt_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    syncStatus,
    lastModifiedLocal,
    id,
    buildingId,
    apartmentId,
    expenseType,
    amountEgp,
    expenseDate,
    installmentNumber,
    description,
    receiptUrl,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Expense> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('last_modified_local')) {
      context.handle(
        _lastModifiedLocalMeta,
        lastModifiedLocal.isAcceptableOrUnknown(
          data['last_modified_local']!,
          _lastModifiedLocalMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('building_id')) {
      context.handle(
        _buildingIdMeta,
        buildingId.isAcceptableOrUnknown(data['building_id']!, _buildingIdMeta),
      );
    }
    if (data.containsKey('apartment_id')) {
      context.handle(
        _apartmentIdMeta,
        apartmentId.isAcceptableOrUnknown(
          data['apartment_id']!,
          _apartmentIdMeta,
        ),
      );
    }
    if (data.containsKey('expense_type')) {
      context.handle(
        _expenseTypeMeta,
        expenseType.isAcceptableOrUnknown(
          data['expense_type']!,
          _expenseTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expenseTypeMeta);
    }
    if (data.containsKey('amount_egp')) {
      context.handle(
        _amountEgpMeta,
        amountEgp.isAcceptableOrUnknown(data['amount_egp']!, _amountEgpMeta),
      );
    } else if (isInserting) {
      context.missing(_amountEgpMeta);
    }
    if (data.containsKey('expense_date')) {
      context.handle(
        _expenseDateMeta,
        expenseDate.isAcceptableOrUnknown(
          data['expense_date']!,
          _expenseDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expenseDateMeta);
    }
    if (data.containsKey('installment_number')) {
      context.handle(
        _installmentNumberMeta,
        installmentNumber.isAcceptableOrUnknown(
          data['installment_number']!,
          _installmentNumberMeta,
        ),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('receipt_url')) {
      context.handle(
        _receiptUrlMeta,
        receiptUrl.isAcceptableOrUnknown(data['receipt_url']!, _receiptUrlMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Expense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Expense(
      syncStatus: $ExpensesTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      lastModifiedLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified_local'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      buildingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}building_id'],
      ),
      apartmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}apartment_id'],
      ),
      expenseType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expense_type'],
      )!,
      amountEgp: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount_egp'],
      )!,
      expenseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expense_date'],
      )!,
      installmentNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}installment_number'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      receiptUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_url'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class Expense extends DataClass implements Insertable<Expense> {
  final SyncStatus syncStatus;
  final DateTime lastModifiedLocal;
  final String id;
  final String? buildingId;
  final String? apartmentId;
  final String expenseType;
  final double amountEgp;
  final DateTime expenseDate;
  final int? installmentNumber;
  final String? description;
  final String? receiptUrl;
  final DateTime createdAt;
  const Expense({
    required this.syncStatus,
    required this.lastModifiedLocal,
    required this.id,
    this.buildingId,
    this.apartmentId,
    required this.expenseType,
    required this.amountEgp,
    required this.expenseDate,
    this.installmentNumber,
    this.description,
    this.receiptUrl,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['sync_status'] = Variable<int>(
        $ExpensesTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['last_modified_local'] = Variable<DateTime>(lastModifiedLocal);
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || buildingId != null) {
      map['building_id'] = Variable<String>(buildingId);
    }
    if (!nullToAbsent || apartmentId != null) {
      map['apartment_id'] = Variable<String>(apartmentId);
    }
    map['expense_type'] = Variable<String>(expenseType);
    map['amount_egp'] = Variable<double>(amountEgp);
    map['expense_date'] = Variable<DateTime>(expenseDate);
    if (!nullToAbsent || installmentNumber != null) {
      map['installment_number'] = Variable<int>(installmentNumber);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || receiptUrl != null) {
      map['receipt_url'] = Variable<String>(receiptUrl);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      syncStatus: Value(syncStatus),
      lastModifiedLocal: Value(lastModifiedLocal),
      id: Value(id),
      buildingId: buildingId == null && nullToAbsent
          ? const Value.absent()
          : Value(buildingId),
      apartmentId: apartmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(apartmentId),
      expenseType: Value(expenseType),
      amountEgp: Value(amountEgp),
      expenseDate: Value(expenseDate),
      installmentNumber: installmentNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(installmentNumber),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      receiptUrl: receiptUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptUrl),
      createdAt: Value(createdAt),
    );
  }

  factory Expense.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Expense(
      syncStatus: $ExpensesTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
      lastModifiedLocal: serializer.fromJson<DateTime>(
        json['lastModifiedLocal'],
      ),
      id: serializer.fromJson<String>(json['id']),
      buildingId: serializer.fromJson<String?>(json['buildingId']),
      apartmentId: serializer.fromJson<String?>(json['apartmentId']),
      expenseType: serializer.fromJson<String>(json['expenseType']),
      amountEgp: serializer.fromJson<double>(json['amountEgp']),
      expenseDate: serializer.fromJson<DateTime>(json['expenseDate']),
      installmentNumber: serializer.fromJson<int?>(json['installmentNumber']),
      description: serializer.fromJson<String?>(json['description']),
      receiptUrl: serializer.fromJson<String?>(json['receiptUrl']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncStatus': serializer.toJson<int>(
        $ExpensesTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'lastModifiedLocal': serializer.toJson<DateTime>(lastModifiedLocal),
      'id': serializer.toJson<String>(id),
      'buildingId': serializer.toJson<String?>(buildingId),
      'apartmentId': serializer.toJson<String?>(apartmentId),
      'expenseType': serializer.toJson<String>(expenseType),
      'amountEgp': serializer.toJson<double>(amountEgp),
      'expenseDate': serializer.toJson<DateTime>(expenseDate),
      'installmentNumber': serializer.toJson<int?>(installmentNumber),
      'description': serializer.toJson<String?>(description),
      'receiptUrl': serializer.toJson<String?>(receiptUrl),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Expense copyWith({
    SyncStatus? syncStatus,
    DateTime? lastModifiedLocal,
    String? id,
    Value<String?> buildingId = const Value.absent(),
    Value<String?> apartmentId = const Value.absent(),
    String? expenseType,
    double? amountEgp,
    DateTime? expenseDate,
    Value<int?> installmentNumber = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<String?> receiptUrl = const Value.absent(),
    DateTime? createdAt,
  }) => Expense(
    syncStatus: syncStatus ?? this.syncStatus,
    lastModifiedLocal: lastModifiedLocal ?? this.lastModifiedLocal,
    id: id ?? this.id,
    buildingId: buildingId.present ? buildingId.value : this.buildingId,
    apartmentId: apartmentId.present ? apartmentId.value : this.apartmentId,
    expenseType: expenseType ?? this.expenseType,
    amountEgp: amountEgp ?? this.amountEgp,
    expenseDate: expenseDate ?? this.expenseDate,
    installmentNumber: installmentNumber.present
        ? installmentNumber.value
        : this.installmentNumber,
    description: description.present ? description.value : this.description,
    receiptUrl: receiptUrl.present ? receiptUrl.value : this.receiptUrl,
    createdAt: createdAt ?? this.createdAt,
  );
  Expense copyWithCompanion(ExpensesCompanion data) {
    return Expense(
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastModifiedLocal: data.lastModifiedLocal.present
          ? data.lastModifiedLocal.value
          : this.lastModifiedLocal,
      id: data.id.present ? data.id.value : this.id,
      buildingId: data.buildingId.present
          ? data.buildingId.value
          : this.buildingId,
      apartmentId: data.apartmentId.present
          ? data.apartmentId.value
          : this.apartmentId,
      expenseType: data.expenseType.present
          ? data.expenseType.value
          : this.expenseType,
      amountEgp: data.amountEgp.present ? data.amountEgp.value : this.amountEgp,
      expenseDate: data.expenseDate.present
          ? data.expenseDate.value
          : this.expenseDate,
      installmentNumber: data.installmentNumber.present
          ? data.installmentNumber.value
          : this.installmentNumber,
      description: data.description.present
          ? data.description.value
          : this.description,
      receiptUrl: data.receiptUrl.present
          ? data.receiptUrl.value
          : this.receiptUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Expense(')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedLocal: $lastModifiedLocal, ')
          ..write('id: $id, ')
          ..write('buildingId: $buildingId, ')
          ..write('apartmentId: $apartmentId, ')
          ..write('expenseType: $expenseType, ')
          ..write('amountEgp: $amountEgp, ')
          ..write('expenseDate: $expenseDate, ')
          ..write('installmentNumber: $installmentNumber, ')
          ..write('description: $description, ')
          ..write('receiptUrl: $receiptUrl, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    syncStatus,
    lastModifiedLocal,
    id,
    buildingId,
    apartmentId,
    expenseType,
    amountEgp,
    expenseDate,
    installmentNumber,
    description,
    receiptUrl,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Expense &&
          other.syncStatus == this.syncStatus &&
          other.lastModifiedLocal == this.lastModifiedLocal &&
          other.id == this.id &&
          other.buildingId == this.buildingId &&
          other.apartmentId == this.apartmentId &&
          other.expenseType == this.expenseType &&
          other.amountEgp == this.amountEgp &&
          other.expenseDate == this.expenseDate &&
          other.installmentNumber == this.installmentNumber &&
          other.description == this.description &&
          other.receiptUrl == this.receiptUrl &&
          other.createdAt == this.createdAt);
}

class ExpensesCompanion extends UpdateCompanion<Expense> {
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> lastModifiedLocal;
  final Value<String> id;
  final Value<String?> buildingId;
  final Value<String?> apartmentId;
  final Value<String> expenseType;
  final Value<double> amountEgp;
  final Value<DateTime> expenseDate;
  final Value<int?> installmentNumber;
  final Value<String?> description;
  final Value<String?> receiptUrl;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ExpensesCompanion({
    this.syncStatus = const Value.absent(),
    this.lastModifiedLocal = const Value.absent(),
    this.id = const Value.absent(),
    this.buildingId = const Value.absent(),
    this.apartmentId = const Value.absent(),
    this.expenseType = const Value.absent(),
    this.amountEgp = const Value.absent(),
    this.expenseDate = const Value.absent(),
    this.installmentNumber = const Value.absent(),
    this.description = const Value.absent(),
    this.receiptUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpensesCompanion.insert({
    this.syncStatus = const Value.absent(),
    this.lastModifiedLocal = const Value.absent(),
    required String id,
    this.buildingId = const Value.absent(),
    this.apartmentId = const Value.absent(),
    required String expenseType,
    required double amountEgp,
    required DateTime expenseDate,
    this.installmentNumber = const Value.absent(),
    this.description = const Value.absent(),
    this.receiptUrl = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       expenseType = Value(expenseType),
       amountEgp = Value(amountEgp),
       expenseDate = Value(expenseDate),
       createdAt = Value(createdAt);
  static Insertable<Expense> custom({
    Expression<int>? syncStatus,
    Expression<DateTime>? lastModifiedLocal,
    Expression<String>? id,
    Expression<String>? buildingId,
    Expression<String>? apartmentId,
    Expression<String>? expenseType,
    Expression<double>? amountEgp,
    Expression<DateTime>? expenseDate,
    Expression<int>? installmentNumber,
    Expression<String>? description,
    Expression<String>? receiptUrl,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastModifiedLocal != null) 'last_modified_local': lastModifiedLocal,
      if (id != null) 'id': id,
      if (buildingId != null) 'building_id': buildingId,
      if (apartmentId != null) 'apartment_id': apartmentId,
      if (expenseType != null) 'expense_type': expenseType,
      if (amountEgp != null) 'amount_egp': amountEgp,
      if (expenseDate != null) 'expense_date': expenseDate,
      if (installmentNumber != null) 'installment_number': installmentNumber,
      if (description != null) 'description': description,
      if (receiptUrl != null) 'receipt_url': receiptUrl,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpensesCompanion copyWith({
    Value<SyncStatus>? syncStatus,
    Value<DateTime>? lastModifiedLocal,
    Value<String>? id,
    Value<String?>? buildingId,
    Value<String?>? apartmentId,
    Value<String>? expenseType,
    Value<double>? amountEgp,
    Value<DateTime>? expenseDate,
    Value<int?>? installmentNumber,
    Value<String?>? description,
    Value<String?>? receiptUrl,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ExpensesCompanion(
      syncStatus: syncStatus ?? this.syncStatus,
      lastModifiedLocal: lastModifiedLocal ?? this.lastModifiedLocal,
      id: id ?? this.id,
      buildingId: buildingId ?? this.buildingId,
      apartmentId: apartmentId ?? this.apartmentId,
      expenseType: expenseType ?? this.expenseType,
      amountEgp: amountEgp ?? this.amountEgp,
      expenseDate: expenseDate ?? this.expenseDate,
      installmentNumber: installmentNumber ?? this.installmentNumber,
      description: description ?? this.description,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $ExpensesTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (lastModifiedLocal.present) {
      map['last_modified_local'] = Variable<DateTime>(lastModifiedLocal.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (buildingId.present) {
      map['building_id'] = Variable<String>(buildingId.value);
    }
    if (apartmentId.present) {
      map['apartment_id'] = Variable<String>(apartmentId.value);
    }
    if (expenseType.present) {
      map['expense_type'] = Variable<String>(expenseType.value);
    }
    if (amountEgp.present) {
      map['amount_egp'] = Variable<double>(amountEgp.value);
    }
    if (expenseDate.present) {
      map['expense_date'] = Variable<DateTime>(expenseDate.value);
    }
    if (installmentNumber.present) {
      map['installment_number'] = Variable<int>(installmentNumber.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (receiptUrl.present) {
      map['receipt_url'] = Variable<String>(receiptUrl.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedLocal: $lastModifiedLocal, ')
          ..write('id: $id, ')
          ..write('buildingId: $buildingId, ')
          ..write('apartmentId: $apartmentId, ')
          ..write('expenseType: $expenseType, ')
          ..write('amountEgp: $amountEgp, ')
          ..write('expenseDate: $expenseDate, ')
          ..write('installmentNumber: $installmentNumber, ')
          ..write('description: $description, ')
          ..write('receiptUrl: $receiptUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MaintenanceRequestsTable extends MaintenanceRequests
    with TableInfo<$MaintenanceRequestsTable, MaintenanceRequest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MaintenanceRequestsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<SyncStatus>(
        $MaintenanceRequestsTable.$convertersyncStatus,
      );
  static const VerificationMeta _lastModifiedLocalMeta = const VerificationMeta(
    'lastModifiedLocal',
  );
  @override
  late final GeneratedColumn<DateTime> lastModifiedLocal =
      GeneratedColumn<DateTime>(
        'last_modified_local',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _apartmentIdMeta = const VerificationMeta(
    'apartmentId',
  );
  @override
  late final GeneratedColumn<String> apartmentId = GeneratedColumn<String>(
    'apartment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES apartments (id)',
    ),
  );
  static const VerificationMeta _reportedByMeta = const VerificationMeta(
    'reportedBy',
  );
  @override
  late final GeneratedColumn<String> reportedBy = GeneratedColumn<String>(
    'reported_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _issueDescriptionMeta = const VerificationMeta(
    'issueDescription',
  );
  @override
  late final GeneratedColumn<String> issueDescription = GeneratedColumn<String>(
    'issue_description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('open'),
  );
  static const VerificationMeta _costEgpMeta = const VerificationMeta(
    'costEgp',
  );
  @override
  late final GeneratedColumn<double> costEgp = GeneratedColumn<double>(
    'cost_egp',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta(
    'resolvedAt',
  );
  @override
  late final GeneratedColumn<DateTime> resolvedAt = GeneratedColumn<DateTime>(
    'resolved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    syncStatus,
    lastModifiedLocal,
    id,
    apartmentId,
    reportedBy,
    issueDescription,
    status,
    costEgp,
    resolvedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'maintenance_requests';
  @override
  VerificationContext validateIntegrity(
    Insertable<MaintenanceRequest> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('last_modified_local')) {
      context.handle(
        _lastModifiedLocalMeta,
        lastModifiedLocal.isAcceptableOrUnknown(
          data['last_modified_local']!,
          _lastModifiedLocalMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('apartment_id')) {
      context.handle(
        _apartmentIdMeta,
        apartmentId.isAcceptableOrUnknown(
          data['apartment_id']!,
          _apartmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_apartmentIdMeta);
    }
    if (data.containsKey('reported_by')) {
      context.handle(
        _reportedByMeta,
        reportedBy.isAcceptableOrUnknown(data['reported_by']!, _reportedByMeta),
      );
    } else if (isInserting) {
      context.missing(_reportedByMeta);
    }
    if (data.containsKey('issue_description')) {
      context.handle(
        _issueDescriptionMeta,
        issueDescription.isAcceptableOrUnknown(
          data['issue_description']!,
          _issueDescriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_issueDescriptionMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('cost_egp')) {
      context.handle(
        _costEgpMeta,
        costEgp.isAcceptableOrUnknown(data['cost_egp']!, _costEgpMeta),
      );
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MaintenanceRequest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MaintenanceRequest(
      syncStatus: $MaintenanceRequestsTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      lastModifiedLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified_local'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      apartmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}apartment_id'],
      )!,
      reportedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reported_by'],
      )!,
      issueDescription: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}issue_description'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      costEgp: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost_egp'],
      )!,
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}resolved_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MaintenanceRequestsTable createAlias(String alias) {
    return $MaintenanceRequestsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class MaintenanceRequest extends DataClass
    implements Insertable<MaintenanceRequest> {
  final SyncStatus syncStatus;
  final DateTime lastModifiedLocal;
  final String id;
  final String apartmentId;
  final String reportedBy;
  final String issueDescription;
  final String status;
  final double costEgp;
  final DateTime? resolvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const MaintenanceRequest({
    required this.syncStatus,
    required this.lastModifiedLocal,
    required this.id,
    required this.apartmentId,
    required this.reportedBy,
    required this.issueDescription,
    required this.status,
    required this.costEgp,
    this.resolvedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['sync_status'] = Variable<int>(
        $MaintenanceRequestsTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['last_modified_local'] = Variable<DateTime>(lastModifiedLocal);
    map['id'] = Variable<String>(id);
    map['apartment_id'] = Variable<String>(apartmentId);
    map['reported_by'] = Variable<String>(reportedBy);
    map['issue_description'] = Variable<String>(issueDescription);
    map['status'] = Variable<String>(status);
    map['cost_egp'] = Variable<double>(costEgp);
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MaintenanceRequestsCompanion toCompanion(bool nullToAbsent) {
    return MaintenanceRequestsCompanion(
      syncStatus: Value(syncStatus),
      lastModifiedLocal: Value(lastModifiedLocal),
      id: Value(id),
      apartmentId: Value(apartmentId),
      reportedBy: Value(reportedBy),
      issueDescription: Value(issueDescription),
      status: Value(status),
      costEgp: Value(costEgp),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MaintenanceRequest.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MaintenanceRequest(
      syncStatus: $MaintenanceRequestsTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
      lastModifiedLocal: serializer.fromJson<DateTime>(
        json['lastModifiedLocal'],
      ),
      id: serializer.fromJson<String>(json['id']),
      apartmentId: serializer.fromJson<String>(json['apartmentId']),
      reportedBy: serializer.fromJson<String>(json['reportedBy']),
      issueDescription: serializer.fromJson<String>(json['issueDescription']),
      status: serializer.fromJson<String>(json['status']),
      costEgp: serializer.fromJson<double>(json['costEgp']),
      resolvedAt: serializer.fromJson<DateTime?>(json['resolvedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncStatus': serializer.toJson<int>(
        $MaintenanceRequestsTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'lastModifiedLocal': serializer.toJson<DateTime>(lastModifiedLocal),
      'id': serializer.toJson<String>(id),
      'apartmentId': serializer.toJson<String>(apartmentId),
      'reportedBy': serializer.toJson<String>(reportedBy),
      'issueDescription': serializer.toJson<String>(issueDescription),
      'status': serializer.toJson<String>(status),
      'costEgp': serializer.toJson<double>(costEgp),
      'resolvedAt': serializer.toJson<DateTime?>(resolvedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MaintenanceRequest copyWith({
    SyncStatus? syncStatus,
    DateTime? lastModifiedLocal,
    String? id,
    String? apartmentId,
    String? reportedBy,
    String? issueDescription,
    String? status,
    double? costEgp,
    Value<DateTime?> resolvedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => MaintenanceRequest(
    syncStatus: syncStatus ?? this.syncStatus,
    lastModifiedLocal: lastModifiedLocal ?? this.lastModifiedLocal,
    id: id ?? this.id,
    apartmentId: apartmentId ?? this.apartmentId,
    reportedBy: reportedBy ?? this.reportedBy,
    issueDescription: issueDescription ?? this.issueDescription,
    status: status ?? this.status,
    costEgp: costEgp ?? this.costEgp,
    resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MaintenanceRequest copyWithCompanion(MaintenanceRequestsCompanion data) {
    return MaintenanceRequest(
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastModifiedLocal: data.lastModifiedLocal.present
          ? data.lastModifiedLocal.value
          : this.lastModifiedLocal,
      id: data.id.present ? data.id.value : this.id,
      apartmentId: data.apartmentId.present
          ? data.apartmentId.value
          : this.apartmentId,
      reportedBy: data.reportedBy.present
          ? data.reportedBy.value
          : this.reportedBy,
      issueDescription: data.issueDescription.present
          ? data.issueDescription.value
          : this.issueDescription,
      status: data.status.present ? data.status.value : this.status,
      costEgp: data.costEgp.present ? data.costEgp.value : this.costEgp,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MaintenanceRequest(')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedLocal: $lastModifiedLocal, ')
          ..write('id: $id, ')
          ..write('apartmentId: $apartmentId, ')
          ..write('reportedBy: $reportedBy, ')
          ..write('issueDescription: $issueDescription, ')
          ..write('status: $status, ')
          ..write('costEgp: $costEgp, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    syncStatus,
    lastModifiedLocal,
    id,
    apartmentId,
    reportedBy,
    issueDescription,
    status,
    costEgp,
    resolvedAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MaintenanceRequest &&
          other.syncStatus == this.syncStatus &&
          other.lastModifiedLocal == this.lastModifiedLocal &&
          other.id == this.id &&
          other.apartmentId == this.apartmentId &&
          other.reportedBy == this.reportedBy &&
          other.issueDescription == this.issueDescription &&
          other.status == this.status &&
          other.costEgp == this.costEgp &&
          other.resolvedAt == this.resolvedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MaintenanceRequestsCompanion extends UpdateCompanion<MaintenanceRequest> {
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> lastModifiedLocal;
  final Value<String> id;
  final Value<String> apartmentId;
  final Value<String> reportedBy;
  final Value<String> issueDescription;
  final Value<String> status;
  final Value<double> costEgp;
  final Value<DateTime?> resolvedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MaintenanceRequestsCompanion({
    this.syncStatus = const Value.absent(),
    this.lastModifiedLocal = const Value.absent(),
    this.id = const Value.absent(),
    this.apartmentId = const Value.absent(),
    this.reportedBy = const Value.absent(),
    this.issueDescription = const Value.absent(),
    this.status = const Value.absent(),
    this.costEgp = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MaintenanceRequestsCompanion.insert({
    this.syncStatus = const Value.absent(),
    this.lastModifiedLocal = const Value.absent(),
    required String id,
    required String apartmentId,
    required String reportedBy,
    required String issueDescription,
    this.status = const Value.absent(),
    this.costEgp = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       apartmentId = Value(apartmentId),
       reportedBy = Value(reportedBy),
       issueDescription = Value(issueDescription),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<MaintenanceRequest> custom({
    Expression<int>? syncStatus,
    Expression<DateTime>? lastModifiedLocal,
    Expression<String>? id,
    Expression<String>? apartmentId,
    Expression<String>? reportedBy,
    Expression<String>? issueDescription,
    Expression<String>? status,
    Expression<double>? costEgp,
    Expression<DateTime>? resolvedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastModifiedLocal != null) 'last_modified_local': lastModifiedLocal,
      if (id != null) 'id': id,
      if (apartmentId != null) 'apartment_id': apartmentId,
      if (reportedBy != null) 'reported_by': reportedBy,
      if (issueDescription != null) 'issue_description': issueDescription,
      if (status != null) 'status': status,
      if (costEgp != null) 'cost_egp': costEgp,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MaintenanceRequestsCompanion copyWith({
    Value<SyncStatus>? syncStatus,
    Value<DateTime>? lastModifiedLocal,
    Value<String>? id,
    Value<String>? apartmentId,
    Value<String>? reportedBy,
    Value<String>? issueDescription,
    Value<String>? status,
    Value<double>? costEgp,
    Value<DateTime?>? resolvedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return MaintenanceRequestsCompanion(
      syncStatus: syncStatus ?? this.syncStatus,
      lastModifiedLocal: lastModifiedLocal ?? this.lastModifiedLocal,
      id: id ?? this.id,
      apartmentId: apartmentId ?? this.apartmentId,
      reportedBy: reportedBy ?? this.reportedBy,
      issueDescription: issueDescription ?? this.issueDescription,
      status: status ?? this.status,
      costEgp: costEgp ?? this.costEgp,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $MaintenanceRequestsTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (lastModifiedLocal.present) {
      map['last_modified_local'] = Variable<DateTime>(lastModifiedLocal.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (apartmentId.present) {
      map['apartment_id'] = Variable<String>(apartmentId.value);
    }
    if (reportedBy.present) {
      map['reported_by'] = Variable<String>(reportedBy.value);
    }
    if (issueDescription.present) {
      map['issue_description'] = Variable<String>(issueDescription.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (costEgp.present) {
      map['cost_egp'] = Variable<double>(costEgp.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MaintenanceRequestsCompanion(')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedLocal: $lastModifiedLocal, ')
          ..write('id: $id, ')
          ..write('apartmentId: $apartmentId, ')
          ..write('reportedBy: $reportedBy, ')
          ..write('issueDescription: $issueDescription, ')
          ..write('status: $status, ')
          ..write('costEgp: $costEgp, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BuildingsTable buildings = $BuildingsTable(this);
  late final $ApartmentsTable apartments = $ApartmentsTable(this);
  late final $SummerBookingsTable summerBookings = $SummerBookingsTable(this);
  late final $WinterContractsTable winterContracts = $WinterContractsTable(
    this,
  );
  late final $WinterPaymentsTable winterPayments = $WinterPaymentsTable(this);
  late final $MeterReadingsTable meterReadings = $MeterReadingsTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final $MaintenanceRequestsTable maintenanceRequests =
      $MaintenanceRequestsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    buildings,
    apartments,
    summerBookings,
    winterContracts,
    winterPayments,
    meterReadings,
    expenses,
    maintenanceRequests,
  ];
}

typedef $$BuildingsTableCreateCompanionBuilder =
    BuildingsCompanion Function({
      Value<SyncStatus> syncStatus,
      Value<DateTime> lastModifiedLocal,
      required String id,
      required String name,
      Value<String?> address,
      Value<int> totalApartments,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$BuildingsTableUpdateCompanionBuilder =
    BuildingsCompanion Function({
      Value<SyncStatus> syncStatus,
      Value<DateTime> lastModifiedLocal,
      Value<String> id,
      Value<String> name,
      Value<String?> address,
      Value<int> totalApartments,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$BuildingsTableReferences
    extends BaseReferences<_$AppDatabase, $BuildingsTable, Building> {
  $$BuildingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ApartmentsTable, List<Apartment>>
  _apartmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.apartments,
    aliasName: $_aliasNameGenerator(db.buildings.id, db.apartments.buildingId),
  );

  $$ApartmentsTableProcessedTableManager get apartmentsRefs {
    final manager = $$ApartmentsTableTableManager(
      $_db,
      $_db.apartments,
    ).filter((f) => f.buildingId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_apartmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MeterReadingsTable, List<MeterReading>>
  _meterReadingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.meterReadings,
    aliasName: $_aliasNameGenerator(
      db.buildings.id,
      db.meterReadings.buildingId,
    ),
  );

  $$MeterReadingsTableProcessedTableManager get meterReadingsRefs {
    final manager = $$MeterReadingsTableTableManager(
      $_db,
      $_db.meterReadings,
    ).filter((f) => f.buildingId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_meterReadingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExpensesTable, List<Expense>> _expensesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.expenses,
    aliasName: $_aliasNameGenerator(db.buildings.id, db.expenses.buildingId),
  );

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager(
      $_db,
      $_db.expenses,
    ).filter((f) => f.buildingId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BuildingsTableFilterComposer
    extends Composer<_$AppDatabase, $BuildingsTable> {
  $$BuildingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get lastModifiedLocal => $composableBuilder(
    column: $table.lastModifiedLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalApartments => $composableBuilder(
    column: $table.totalApartments,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> apartmentsRefs(
    Expression<bool> Function($$ApartmentsTableFilterComposer f) f,
  ) {
    final $$ApartmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.apartments,
      getReferencedColumn: (t) => t.buildingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApartmentsTableFilterComposer(
            $db: $db,
            $table: $db.apartments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> meterReadingsRefs(
    Expression<bool> Function($$MeterReadingsTableFilterComposer f) f,
  ) {
    final $$MeterReadingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.meterReadings,
      getReferencedColumn: (t) => t.buildingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeterReadingsTableFilterComposer(
            $db: $db,
            $table: $db.meterReadings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> expensesRefs(
    Expression<bool> Function($$ExpensesTableFilterComposer f) f,
  ) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.buildingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BuildingsTableOrderingComposer
    extends Composer<_$AppDatabase, $BuildingsTable> {
  $$BuildingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModifiedLocal => $composableBuilder(
    column: $table.lastModifiedLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalApartments => $composableBuilder(
    column: $table.totalApartments,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BuildingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BuildingsTable> {
  $$BuildingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get lastModifiedLocal => $composableBuilder(
    column: $table.lastModifiedLocal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<int> get totalApartments => $composableBuilder(
    column: $table.totalApartments,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> apartmentsRefs<T extends Object>(
    Expression<T> Function($$ApartmentsTableAnnotationComposer a) f,
  ) {
    final $$ApartmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.apartments,
      getReferencedColumn: (t) => t.buildingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApartmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.apartments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> meterReadingsRefs<T extends Object>(
    Expression<T> Function($$MeterReadingsTableAnnotationComposer a) f,
  ) {
    final $$MeterReadingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.meterReadings,
      getReferencedColumn: (t) => t.buildingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeterReadingsTableAnnotationComposer(
            $db: $db,
            $table: $db.meterReadings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> expensesRefs<T extends Object>(
    Expression<T> Function($$ExpensesTableAnnotationComposer a) f,
  ) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.buildingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BuildingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BuildingsTable,
          Building,
          $$BuildingsTableFilterComposer,
          $$BuildingsTableOrderingComposer,
          $$BuildingsTableAnnotationComposer,
          $$BuildingsTableCreateCompanionBuilder,
          $$BuildingsTableUpdateCompanionBuilder,
          (Building, $$BuildingsTableReferences),
          Building,
          PrefetchHooks Function({
            bool apartmentsRefs,
            bool meterReadingsRefs,
            bool expensesRefs,
          })
        > {
  $$BuildingsTableTableManager(_$AppDatabase db, $BuildingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BuildingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BuildingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BuildingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> lastModifiedLocal = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<int> totalApartments = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BuildingsCompanion(
                syncStatus: syncStatus,
                lastModifiedLocal: lastModifiedLocal,
                id: id,
                name: name,
                address: address,
                totalApartments: totalApartments,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> lastModifiedLocal = const Value.absent(),
                required String id,
                required String name,
                Value<String?> address = const Value.absent(),
                Value<int> totalApartments = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => BuildingsCompanion.insert(
                syncStatus: syncStatus,
                lastModifiedLocal: lastModifiedLocal,
                id: id,
                name: name,
                address: address,
                totalApartments: totalApartments,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BuildingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                apartmentsRefs = false,
                meterReadingsRefs = false,
                expensesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (apartmentsRefs) db.apartments,
                    if (meterReadingsRefs) db.meterReadings,
                    if (expensesRefs) db.expenses,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (apartmentsRefs)
                        await $_getPrefetchedData<
                          Building,
                          $BuildingsTable,
                          Apartment
                        >(
                          currentTable: table,
                          referencedTable: $$BuildingsTableReferences
                              ._apartmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BuildingsTableReferences(
                                db,
                                table,
                                p0,
                              ).apartmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.buildingId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (meterReadingsRefs)
                        await $_getPrefetchedData<
                          Building,
                          $BuildingsTable,
                          MeterReading
                        >(
                          currentTable: table,
                          referencedTable: $$BuildingsTableReferences
                              ._meterReadingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BuildingsTableReferences(
                                db,
                                table,
                                p0,
                              ).meterReadingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.buildingId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (expensesRefs)
                        await $_getPrefetchedData<
                          Building,
                          $BuildingsTable,
                          Expense
                        >(
                          currentTable: table,
                          referencedTable: $$BuildingsTableReferences
                              ._expensesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BuildingsTableReferences(
                                db,
                                table,
                                p0,
                              ).expensesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.buildingId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$BuildingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BuildingsTable,
      Building,
      $$BuildingsTableFilterComposer,
      $$BuildingsTableOrderingComposer,
      $$BuildingsTableAnnotationComposer,
      $$BuildingsTableCreateCompanionBuilder,
      $$BuildingsTableUpdateCompanionBuilder,
      (Building, $$BuildingsTableReferences),
      Building,
      PrefetchHooks Function({
        bool apartmentsRefs,
        bool meterReadingsRefs,
        bool expensesRefs,
      })
    >;
typedef $$ApartmentsTableCreateCompanionBuilder =
    ApartmentsCompanion Function({
      Value<SyncStatus> syncStatus,
      Value<DateTime> lastModifiedLocal,
      required String id,
      required String buildingId,
      required String apartmentNumber,
      Value<int?> floorNumber,
      Value<String> cleaningStatus,
      Value<bool> brokerVisibility,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ApartmentsTableUpdateCompanionBuilder =
    ApartmentsCompanion Function({
      Value<SyncStatus> syncStatus,
      Value<DateTime> lastModifiedLocal,
      Value<String> id,
      Value<String> buildingId,
      Value<String> apartmentNumber,
      Value<int?> floorNumber,
      Value<String> cleaningStatus,
      Value<bool> brokerVisibility,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ApartmentsTableReferences
    extends BaseReferences<_$AppDatabase, $ApartmentsTable, Apartment> {
  $$ApartmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BuildingsTable _buildingIdTable(_$AppDatabase db) =>
      db.buildings.createAlias(
        $_aliasNameGenerator(db.apartments.buildingId, db.buildings.id),
      );

  $$BuildingsTableProcessedTableManager get buildingId {
    final $_column = $_itemColumn<String>('building_id')!;

    final manager = $$BuildingsTableTableManager(
      $_db,
      $_db.buildings,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_buildingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SummerBookingsTable, List<SummerBooking>>
  _summerBookingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.summerBookings,
    aliasName: $_aliasNameGenerator(
      db.apartments.id,
      db.summerBookings.apartmentId,
    ),
  );

  $$SummerBookingsTableProcessedTableManager get summerBookingsRefs {
    final manager = $$SummerBookingsTableTableManager(
      $_db,
      $_db.summerBookings,
    ).filter((f) => f.apartmentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_summerBookingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WinterContractsTable, List<WinterContract>>
  _winterContractsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.winterContracts,
    aliasName: $_aliasNameGenerator(
      db.apartments.id,
      db.winterContracts.apartmentId,
    ),
  );

  $$WinterContractsTableProcessedTableManager get winterContractsRefs {
    final manager = $$WinterContractsTableTableManager(
      $_db,
      $_db.winterContracts,
    ).filter((f) => f.apartmentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _winterContractsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MeterReadingsTable, List<MeterReading>>
  _meterReadingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.meterReadings,
    aliasName: $_aliasNameGenerator(
      db.apartments.id,
      db.meterReadings.apartmentId,
    ),
  );

  $$MeterReadingsTableProcessedTableManager get meterReadingsRefs {
    final manager = $$MeterReadingsTableTableManager(
      $_db,
      $_db.meterReadings,
    ).filter((f) => f.apartmentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_meterReadingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExpensesTable, List<Expense>> _expensesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.expenses,
    aliasName: $_aliasNameGenerator(db.apartments.id, db.expenses.apartmentId),
  );

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager(
      $_db,
      $_db.expenses,
    ).filter((f) => f.apartmentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $MaintenanceRequestsTable,
    List<MaintenanceRequest>
  >
  _maintenanceRequestsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.maintenanceRequests,
        aliasName: $_aliasNameGenerator(
          db.apartments.id,
          db.maintenanceRequests.apartmentId,
        ),
      );

  $$MaintenanceRequestsTableProcessedTableManager get maintenanceRequestsRefs {
    final manager = $$MaintenanceRequestsTableTableManager(
      $_db,
      $_db.maintenanceRequests,
    ).filter((f) => f.apartmentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _maintenanceRequestsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ApartmentsTableFilterComposer
    extends Composer<_$AppDatabase, $ApartmentsTable> {
  $$ApartmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get lastModifiedLocal => $composableBuilder(
    column: $table.lastModifiedLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get apartmentNumber => $composableBuilder(
    column: $table.apartmentNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get floorNumber => $composableBuilder(
    column: $table.floorNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cleaningStatus => $composableBuilder(
    column: $table.cleaningStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get brokerVisibility => $composableBuilder(
    column: $table.brokerVisibility,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BuildingsTableFilterComposer get buildingId {
    final $$BuildingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.buildingId,
      referencedTable: $db.buildings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BuildingsTableFilterComposer(
            $db: $db,
            $table: $db.buildings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> summerBookingsRefs(
    Expression<bool> Function($$SummerBookingsTableFilterComposer f) f,
  ) {
    final $$SummerBookingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.summerBookings,
      getReferencedColumn: (t) => t.apartmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SummerBookingsTableFilterComposer(
            $db: $db,
            $table: $db.summerBookings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> winterContractsRefs(
    Expression<bool> Function($$WinterContractsTableFilterComposer f) f,
  ) {
    final $$WinterContractsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.winterContracts,
      getReferencedColumn: (t) => t.apartmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WinterContractsTableFilterComposer(
            $db: $db,
            $table: $db.winterContracts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> meterReadingsRefs(
    Expression<bool> Function($$MeterReadingsTableFilterComposer f) f,
  ) {
    final $$MeterReadingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.meterReadings,
      getReferencedColumn: (t) => t.apartmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeterReadingsTableFilterComposer(
            $db: $db,
            $table: $db.meterReadings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> expensesRefs(
    Expression<bool> Function($$ExpensesTableFilterComposer f) f,
  ) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.apartmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> maintenanceRequestsRefs(
    Expression<bool> Function($$MaintenanceRequestsTableFilterComposer f) f,
  ) {
    final $$MaintenanceRequestsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.maintenanceRequests,
      getReferencedColumn: (t) => t.apartmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaintenanceRequestsTableFilterComposer(
            $db: $db,
            $table: $db.maintenanceRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ApartmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $ApartmentsTable> {
  $$ApartmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModifiedLocal => $composableBuilder(
    column: $table.lastModifiedLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get apartmentNumber => $composableBuilder(
    column: $table.apartmentNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get floorNumber => $composableBuilder(
    column: $table.floorNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cleaningStatus => $composableBuilder(
    column: $table.cleaningStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get brokerVisibility => $composableBuilder(
    column: $table.brokerVisibility,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BuildingsTableOrderingComposer get buildingId {
    final $$BuildingsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.buildingId,
      referencedTable: $db.buildings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BuildingsTableOrderingComposer(
            $db: $db,
            $table: $db.buildings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ApartmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ApartmentsTable> {
  $$ApartmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get lastModifiedLocal => $composableBuilder(
    column: $table.lastModifiedLocal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get apartmentNumber => $composableBuilder(
    column: $table.apartmentNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get floorNumber => $composableBuilder(
    column: $table.floorNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cleaningStatus => $composableBuilder(
    column: $table.cleaningStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get brokerVisibility => $composableBuilder(
    column: $table.brokerVisibility,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$BuildingsTableAnnotationComposer get buildingId {
    final $$BuildingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.buildingId,
      referencedTable: $db.buildings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BuildingsTableAnnotationComposer(
            $db: $db,
            $table: $db.buildings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> summerBookingsRefs<T extends Object>(
    Expression<T> Function($$SummerBookingsTableAnnotationComposer a) f,
  ) {
    final $$SummerBookingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.summerBookings,
      getReferencedColumn: (t) => t.apartmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SummerBookingsTableAnnotationComposer(
            $db: $db,
            $table: $db.summerBookings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> winterContractsRefs<T extends Object>(
    Expression<T> Function($$WinterContractsTableAnnotationComposer a) f,
  ) {
    final $$WinterContractsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.winterContracts,
      getReferencedColumn: (t) => t.apartmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WinterContractsTableAnnotationComposer(
            $db: $db,
            $table: $db.winterContracts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> meterReadingsRefs<T extends Object>(
    Expression<T> Function($$MeterReadingsTableAnnotationComposer a) f,
  ) {
    final $$MeterReadingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.meterReadings,
      getReferencedColumn: (t) => t.apartmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeterReadingsTableAnnotationComposer(
            $db: $db,
            $table: $db.meterReadings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> expensesRefs<T extends Object>(
    Expression<T> Function($$ExpensesTableAnnotationComposer a) f,
  ) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.apartmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> maintenanceRequestsRefs<T extends Object>(
    Expression<T> Function($$MaintenanceRequestsTableAnnotationComposer a) f,
  ) {
    final $$MaintenanceRequestsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.maintenanceRequests,
          getReferencedColumn: (t) => t.apartmentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MaintenanceRequestsTableAnnotationComposer(
                $db: $db,
                $table: $db.maintenanceRequests,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ApartmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ApartmentsTable,
          Apartment,
          $$ApartmentsTableFilterComposer,
          $$ApartmentsTableOrderingComposer,
          $$ApartmentsTableAnnotationComposer,
          $$ApartmentsTableCreateCompanionBuilder,
          $$ApartmentsTableUpdateCompanionBuilder,
          (Apartment, $$ApartmentsTableReferences),
          Apartment,
          PrefetchHooks Function({
            bool buildingId,
            bool summerBookingsRefs,
            bool winterContractsRefs,
            bool meterReadingsRefs,
            bool expensesRefs,
            bool maintenanceRequestsRefs,
          })
        > {
  $$ApartmentsTableTableManager(_$AppDatabase db, $ApartmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ApartmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ApartmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ApartmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> lastModifiedLocal = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> buildingId = const Value.absent(),
                Value<String> apartmentNumber = const Value.absent(),
                Value<int?> floorNumber = const Value.absent(),
                Value<String> cleaningStatus = const Value.absent(),
                Value<bool> brokerVisibility = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ApartmentsCompanion(
                syncStatus: syncStatus,
                lastModifiedLocal: lastModifiedLocal,
                id: id,
                buildingId: buildingId,
                apartmentNumber: apartmentNumber,
                floorNumber: floorNumber,
                cleaningStatus: cleaningStatus,
                brokerVisibility: brokerVisibility,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> lastModifiedLocal = const Value.absent(),
                required String id,
                required String buildingId,
                required String apartmentNumber,
                Value<int?> floorNumber = const Value.absent(),
                Value<String> cleaningStatus = const Value.absent(),
                Value<bool> brokerVisibility = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ApartmentsCompanion.insert(
                syncStatus: syncStatus,
                lastModifiedLocal: lastModifiedLocal,
                id: id,
                buildingId: buildingId,
                apartmentNumber: apartmentNumber,
                floorNumber: floorNumber,
                cleaningStatus: cleaningStatus,
                brokerVisibility: brokerVisibility,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ApartmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                buildingId = false,
                summerBookingsRefs = false,
                winterContractsRefs = false,
                meterReadingsRefs = false,
                expensesRefs = false,
                maintenanceRequestsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (summerBookingsRefs) db.summerBookings,
                    if (winterContractsRefs) db.winterContracts,
                    if (meterReadingsRefs) db.meterReadings,
                    if (expensesRefs) db.expenses,
                    if (maintenanceRequestsRefs) db.maintenanceRequests,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (buildingId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.buildingId,
                                    referencedTable: $$ApartmentsTableReferences
                                        ._buildingIdTable(db),
                                    referencedColumn:
                                        $$ApartmentsTableReferences
                                            ._buildingIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (summerBookingsRefs)
                        await $_getPrefetchedData<
                          Apartment,
                          $ApartmentsTable,
                          SummerBooking
                        >(
                          currentTable: table,
                          referencedTable: $$ApartmentsTableReferences
                              ._summerBookingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ApartmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).summerBookingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.apartmentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (winterContractsRefs)
                        await $_getPrefetchedData<
                          Apartment,
                          $ApartmentsTable,
                          WinterContract
                        >(
                          currentTable: table,
                          referencedTable: $$ApartmentsTableReferences
                              ._winterContractsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ApartmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).winterContractsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.apartmentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (meterReadingsRefs)
                        await $_getPrefetchedData<
                          Apartment,
                          $ApartmentsTable,
                          MeterReading
                        >(
                          currentTable: table,
                          referencedTable: $$ApartmentsTableReferences
                              ._meterReadingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ApartmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).meterReadingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.apartmentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (expensesRefs)
                        await $_getPrefetchedData<
                          Apartment,
                          $ApartmentsTable,
                          Expense
                        >(
                          currentTable: table,
                          referencedTable: $$ApartmentsTableReferences
                              ._expensesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ApartmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).expensesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.apartmentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (maintenanceRequestsRefs)
                        await $_getPrefetchedData<
                          Apartment,
                          $ApartmentsTable,
                          MaintenanceRequest
                        >(
                          currentTable: table,
                          referencedTable: $$ApartmentsTableReferences
                              ._maintenanceRequestsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ApartmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).maintenanceRequestsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.apartmentId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ApartmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ApartmentsTable,
      Apartment,
      $$ApartmentsTableFilterComposer,
      $$ApartmentsTableOrderingComposer,
      $$ApartmentsTableAnnotationComposer,
      $$ApartmentsTableCreateCompanionBuilder,
      $$ApartmentsTableUpdateCompanionBuilder,
      (Apartment, $$ApartmentsTableReferences),
      Apartment,
      PrefetchHooks Function({
        bool buildingId,
        bool summerBookingsRefs,
        bool winterContractsRefs,
        bool meterReadingsRefs,
        bool expensesRefs,
        bool maintenanceRequestsRefs,
      })
    >;
typedef $$SummerBookingsTableCreateCompanionBuilder =
    SummerBookingsCompanion Function({
      Value<SyncStatus> syncStatus,
      Value<DateTime> lastModifiedLocal,
      required String id,
      required String apartmentId,
      required String guestName,
      Value<String?> guestPhone,
      required DateTime checkInDate,
      required DateTime checkOutDate,
      Value<String> status,
      required double totalPriceEgp,
      Value<double> amountPaidEgp,
      Value<String?> brokerId,
      Value<double> brokerCommissionPercentage,
      Value<double?> brokerCommissionAmountEgp,
      Value<DateTime?> earlyCheckoutDate,
      Value<int> overstayDays,
      Value<double> overstayFeeEgp,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SummerBookingsTableUpdateCompanionBuilder =
    SummerBookingsCompanion Function({
      Value<SyncStatus> syncStatus,
      Value<DateTime> lastModifiedLocal,
      Value<String> id,
      Value<String> apartmentId,
      Value<String> guestName,
      Value<String?> guestPhone,
      Value<DateTime> checkInDate,
      Value<DateTime> checkOutDate,
      Value<String> status,
      Value<double> totalPriceEgp,
      Value<double> amountPaidEgp,
      Value<String?> brokerId,
      Value<double> brokerCommissionPercentage,
      Value<double?> brokerCommissionAmountEgp,
      Value<DateTime?> earlyCheckoutDate,
      Value<int> overstayDays,
      Value<double> overstayFeeEgp,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$SummerBookingsTableReferences
    extends BaseReferences<_$AppDatabase, $SummerBookingsTable, SummerBooking> {
  $$SummerBookingsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ApartmentsTable _apartmentIdTable(_$AppDatabase db) =>
      db.apartments.createAlias(
        $_aliasNameGenerator(db.summerBookings.apartmentId, db.apartments.id),
      );

  $$ApartmentsTableProcessedTableManager get apartmentId {
    final $_column = $_itemColumn<String>('apartment_id')!;

    final manager = $$ApartmentsTableTableManager(
      $_db,
      $_db.apartments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_apartmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SummerBookingsTableFilterComposer
    extends Composer<_$AppDatabase, $SummerBookingsTable> {
  $$SummerBookingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get lastModifiedLocal => $composableBuilder(
    column: $table.lastModifiedLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get guestName => $composableBuilder(
    column: $table.guestName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get guestPhone => $composableBuilder(
    column: $table.guestPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get checkInDate => $composableBuilder(
    column: $table.checkInDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get checkOutDate => $composableBuilder(
    column: $table.checkOutDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalPriceEgp => $composableBuilder(
    column: $table.totalPriceEgp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amountPaidEgp => $composableBuilder(
    column: $table.amountPaidEgp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brokerId => $composableBuilder(
    column: $table.brokerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get brokerCommissionPercentage => $composableBuilder(
    column: $table.brokerCommissionPercentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get brokerCommissionAmountEgp => $composableBuilder(
    column: $table.brokerCommissionAmountEgp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get earlyCheckoutDate => $composableBuilder(
    column: $table.earlyCheckoutDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get overstayDays => $composableBuilder(
    column: $table.overstayDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get overstayFeeEgp => $composableBuilder(
    column: $table.overstayFeeEgp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ApartmentsTableFilterComposer get apartmentId {
    final $$ApartmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.apartmentId,
      referencedTable: $db.apartments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApartmentsTableFilterComposer(
            $db: $db,
            $table: $db.apartments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SummerBookingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SummerBookingsTable> {
  $$SummerBookingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModifiedLocal => $composableBuilder(
    column: $table.lastModifiedLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get guestName => $composableBuilder(
    column: $table.guestName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get guestPhone => $composableBuilder(
    column: $table.guestPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get checkInDate => $composableBuilder(
    column: $table.checkInDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get checkOutDate => $composableBuilder(
    column: $table.checkOutDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalPriceEgp => $composableBuilder(
    column: $table.totalPriceEgp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amountPaidEgp => $composableBuilder(
    column: $table.amountPaidEgp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brokerId => $composableBuilder(
    column: $table.brokerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get brokerCommissionPercentage => $composableBuilder(
    column: $table.brokerCommissionPercentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get brokerCommissionAmountEgp => $composableBuilder(
    column: $table.brokerCommissionAmountEgp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get earlyCheckoutDate => $composableBuilder(
    column: $table.earlyCheckoutDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get overstayDays => $composableBuilder(
    column: $table.overstayDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get overstayFeeEgp => $composableBuilder(
    column: $table.overstayFeeEgp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ApartmentsTableOrderingComposer get apartmentId {
    final $$ApartmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.apartmentId,
      referencedTable: $db.apartments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApartmentsTableOrderingComposer(
            $db: $db,
            $table: $db.apartments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SummerBookingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SummerBookingsTable> {
  $$SummerBookingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get lastModifiedLocal => $composableBuilder(
    column: $table.lastModifiedLocal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get guestName =>
      $composableBuilder(column: $table.guestName, builder: (column) => column);

  GeneratedColumn<String> get guestPhone => $composableBuilder(
    column: $table.guestPhone,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get checkInDate => $composableBuilder(
    column: $table.checkInDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get checkOutDate => $composableBuilder(
    column: $table.checkOutDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get totalPriceEgp => $composableBuilder(
    column: $table.totalPriceEgp,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amountPaidEgp => $composableBuilder(
    column: $table.amountPaidEgp,
    builder: (column) => column,
  );

  GeneratedColumn<String> get brokerId =>
      $composableBuilder(column: $table.brokerId, builder: (column) => column);

  GeneratedColumn<double> get brokerCommissionPercentage => $composableBuilder(
    column: $table.brokerCommissionPercentage,
    builder: (column) => column,
  );

  GeneratedColumn<double> get brokerCommissionAmountEgp => $composableBuilder(
    column: $table.brokerCommissionAmountEgp,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get earlyCheckoutDate => $composableBuilder(
    column: $table.earlyCheckoutDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get overstayDays => $composableBuilder(
    column: $table.overstayDays,
    builder: (column) => column,
  );

  GeneratedColumn<double> get overstayFeeEgp => $composableBuilder(
    column: $table.overstayFeeEgp,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ApartmentsTableAnnotationComposer get apartmentId {
    final $$ApartmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.apartmentId,
      referencedTable: $db.apartments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApartmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.apartments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SummerBookingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SummerBookingsTable,
          SummerBooking,
          $$SummerBookingsTableFilterComposer,
          $$SummerBookingsTableOrderingComposer,
          $$SummerBookingsTableAnnotationComposer,
          $$SummerBookingsTableCreateCompanionBuilder,
          $$SummerBookingsTableUpdateCompanionBuilder,
          (SummerBooking, $$SummerBookingsTableReferences),
          SummerBooking,
          PrefetchHooks Function({bool apartmentId})
        > {
  $$SummerBookingsTableTableManager(
    _$AppDatabase db,
    $SummerBookingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SummerBookingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SummerBookingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SummerBookingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> lastModifiedLocal = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> apartmentId = const Value.absent(),
                Value<String> guestName = const Value.absent(),
                Value<String?> guestPhone = const Value.absent(),
                Value<DateTime> checkInDate = const Value.absent(),
                Value<DateTime> checkOutDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> totalPriceEgp = const Value.absent(),
                Value<double> amountPaidEgp = const Value.absent(),
                Value<String?> brokerId = const Value.absent(),
                Value<double> brokerCommissionPercentage = const Value.absent(),
                Value<double?> brokerCommissionAmountEgp = const Value.absent(),
                Value<DateTime?> earlyCheckoutDate = const Value.absent(),
                Value<int> overstayDays = const Value.absent(),
                Value<double> overstayFeeEgp = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SummerBookingsCompanion(
                syncStatus: syncStatus,
                lastModifiedLocal: lastModifiedLocal,
                id: id,
                apartmentId: apartmentId,
                guestName: guestName,
                guestPhone: guestPhone,
                checkInDate: checkInDate,
                checkOutDate: checkOutDate,
                status: status,
                totalPriceEgp: totalPriceEgp,
                amountPaidEgp: amountPaidEgp,
                brokerId: brokerId,
                brokerCommissionPercentage: brokerCommissionPercentage,
                brokerCommissionAmountEgp: brokerCommissionAmountEgp,
                earlyCheckoutDate: earlyCheckoutDate,
                overstayDays: overstayDays,
                overstayFeeEgp: overstayFeeEgp,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> lastModifiedLocal = const Value.absent(),
                required String id,
                required String apartmentId,
                required String guestName,
                Value<String?> guestPhone = const Value.absent(),
                required DateTime checkInDate,
                required DateTime checkOutDate,
                Value<String> status = const Value.absent(),
                required double totalPriceEgp,
                Value<double> amountPaidEgp = const Value.absent(),
                Value<String?> brokerId = const Value.absent(),
                Value<double> brokerCommissionPercentage = const Value.absent(),
                Value<double?> brokerCommissionAmountEgp = const Value.absent(),
                Value<DateTime?> earlyCheckoutDate = const Value.absent(),
                Value<int> overstayDays = const Value.absent(),
                Value<double> overstayFeeEgp = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SummerBookingsCompanion.insert(
                syncStatus: syncStatus,
                lastModifiedLocal: lastModifiedLocal,
                id: id,
                apartmentId: apartmentId,
                guestName: guestName,
                guestPhone: guestPhone,
                checkInDate: checkInDate,
                checkOutDate: checkOutDate,
                status: status,
                totalPriceEgp: totalPriceEgp,
                amountPaidEgp: amountPaidEgp,
                brokerId: brokerId,
                brokerCommissionPercentage: brokerCommissionPercentage,
                brokerCommissionAmountEgp: brokerCommissionAmountEgp,
                earlyCheckoutDate: earlyCheckoutDate,
                overstayDays: overstayDays,
                overstayFeeEgp: overstayFeeEgp,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SummerBookingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({apartmentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (apartmentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.apartmentId,
                                referencedTable: $$SummerBookingsTableReferences
                                    ._apartmentIdTable(db),
                                referencedColumn:
                                    $$SummerBookingsTableReferences
                                        ._apartmentIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SummerBookingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SummerBookingsTable,
      SummerBooking,
      $$SummerBookingsTableFilterComposer,
      $$SummerBookingsTableOrderingComposer,
      $$SummerBookingsTableAnnotationComposer,
      $$SummerBookingsTableCreateCompanionBuilder,
      $$SummerBookingsTableUpdateCompanionBuilder,
      (SummerBooking, $$SummerBookingsTableReferences),
      SummerBooking,
      PrefetchHooks Function({bool apartmentId})
    >;
typedef $$WinterContractsTableCreateCompanionBuilder =
    WinterContractsCompanion Function({
      Value<SyncStatus> syncStatus,
      Value<DateTime> lastModifiedLocal,
      required String id,
      required String apartmentId,
      required String studentName,
      Value<String?> university,
      Value<String?> parentName,
      Value<String?> parentPhone,
      Value<String?> viewerUserId,
      required DateTime startDate,
      required DateTime endDate,
      required double monthlyRentEgp,
      Value<double> depositEgp,
      Value<bool> isActive,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$WinterContractsTableUpdateCompanionBuilder =
    WinterContractsCompanion Function({
      Value<SyncStatus> syncStatus,
      Value<DateTime> lastModifiedLocal,
      Value<String> id,
      Value<String> apartmentId,
      Value<String> studentName,
      Value<String?> university,
      Value<String?> parentName,
      Value<String?> parentPhone,
      Value<String?> viewerUserId,
      Value<DateTime> startDate,
      Value<DateTime> endDate,
      Value<double> monthlyRentEgp,
      Value<double> depositEgp,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$WinterContractsTableReferences
    extends
        BaseReferences<_$AppDatabase, $WinterContractsTable, WinterContract> {
  $$WinterContractsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ApartmentsTable _apartmentIdTable(_$AppDatabase db) =>
      db.apartments.createAlias(
        $_aliasNameGenerator(db.winterContracts.apartmentId, db.apartments.id),
      );

  $$ApartmentsTableProcessedTableManager get apartmentId {
    final $_column = $_itemColumn<String>('apartment_id')!;

    final manager = $$ApartmentsTableTableManager(
      $_db,
      $_db.apartments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_apartmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$WinterPaymentsTable, List<WinterPayment>>
  _winterPaymentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.winterPayments,
    aliasName: $_aliasNameGenerator(
      db.winterContracts.id,
      db.winterPayments.contractId,
    ),
  );

  $$WinterPaymentsTableProcessedTableManager get winterPaymentsRefs {
    final manager = $$WinterPaymentsTableTableManager(
      $_db,
      $_db.winterPayments,
    ).filter((f) => f.contractId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_winterPaymentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WinterContractsTableFilterComposer
    extends Composer<_$AppDatabase, $WinterContractsTable> {
  $$WinterContractsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get lastModifiedLocal => $composableBuilder(
    column: $table.lastModifiedLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentName => $composableBuilder(
    column: $table.studentName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get university => $composableBuilder(
    column: $table.university,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentName => $composableBuilder(
    column: $table.parentName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentPhone => $composableBuilder(
    column: $table.parentPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get viewerUserId => $composableBuilder(
    column: $table.viewerUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get monthlyRentEgp => $composableBuilder(
    column: $table.monthlyRentEgp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get depositEgp => $composableBuilder(
    column: $table.depositEgp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ApartmentsTableFilterComposer get apartmentId {
    final $$ApartmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.apartmentId,
      referencedTable: $db.apartments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApartmentsTableFilterComposer(
            $db: $db,
            $table: $db.apartments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> winterPaymentsRefs(
    Expression<bool> Function($$WinterPaymentsTableFilterComposer f) f,
  ) {
    final $$WinterPaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.winterPayments,
      getReferencedColumn: (t) => t.contractId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WinterPaymentsTableFilterComposer(
            $db: $db,
            $table: $db.winterPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WinterContractsTableOrderingComposer
    extends Composer<_$AppDatabase, $WinterContractsTable> {
  $$WinterContractsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModifiedLocal => $composableBuilder(
    column: $table.lastModifiedLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentName => $composableBuilder(
    column: $table.studentName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get university => $composableBuilder(
    column: $table.university,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentName => $composableBuilder(
    column: $table.parentName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentPhone => $composableBuilder(
    column: $table.parentPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get viewerUserId => $composableBuilder(
    column: $table.viewerUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get monthlyRentEgp => $composableBuilder(
    column: $table.monthlyRentEgp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get depositEgp => $composableBuilder(
    column: $table.depositEgp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ApartmentsTableOrderingComposer get apartmentId {
    final $$ApartmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.apartmentId,
      referencedTable: $db.apartments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApartmentsTableOrderingComposer(
            $db: $db,
            $table: $db.apartments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WinterContractsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WinterContractsTable> {
  $$WinterContractsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get lastModifiedLocal => $composableBuilder(
    column: $table.lastModifiedLocal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get studentName => $composableBuilder(
    column: $table.studentName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get university => $composableBuilder(
    column: $table.university,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parentName => $composableBuilder(
    column: $table.parentName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parentPhone => $composableBuilder(
    column: $table.parentPhone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get viewerUserId => $composableBuilder(
    column: $table.viewerUserId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<double> get monthlyRentEgp => $composableBuilder(
    column: $table.monthlyRentEgp,
    builder: (column) => column,
  );

  GeneratedColumn<double> get depositEgp => $composableBuilder(
    column: $table.depositEgp,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ApartmentsTableAnnotationComposer get apartmentId {
    final $$ApartmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.apartmentId,
      referencedTable: $db.apartments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApartmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.apartments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> winterPaymentsRefs<T extends Object>(
    Expression<T> Function($$WinterPaymentsTableAnnotationComposer a) f,
  ) {
    final $$WinterPaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.winterPayments,
      getReferencedColumn: (t) => t.contractId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WinterPaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.winterPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WinterContractsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WinterContractsTable,
          WinterContract,
          $$WinterContractsTableFilterComposer,
          $$WinterContractsTableOrderingComposer,
          $$WinterContractsTableAnnotationComposer,
          $$WinterContractsTableCreateCompanionBuilder,
          $$WinterContractsTableUpdateCompanionBuilder,
          (WinterContract, $$WinterContractsTableReferences),
          WinterContract,
          PrefetchHooks Function({bool apartmentId, bool winterPaymentsRefs})
        > {
  $$WinterContractsTableTableManager(
    _$AppDatabase db,
    $WinterContractsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WinterContractsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WinterContractsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WinterContractsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> lastModifiedLocal = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> apartmentId = const Value.absent(),
                Value<String> studentName = const Value.absent(),
                Value<String?> university = const Value.absent(),
                Value<String?> parentName = const Value.absent(),
                Value<String?> parentPhone = const Value.absent(),
                Value<String?> viewerUserId = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime> endDate = const Value.absent(),
                Value<double> monthlyRentEgp = const Value.absent(),
                Value<double> depositEgp = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WinterContractsCompanion(
                syncStatus: syncStatus,
                lastModifiedLocal: lastModifiedLocal,
                id: id,
                apartmentId: apartmentId,
                studentName: studentName,
                university: university,
                parentName: parentName,
                parentPhone: parentPhone,
                viewerUserId: viewerUserId,
                startDate: startDate,
                endDate: endDate,
                monthlyRentEgp: monthlyRentEgp,
                depositEgp: depositEgp,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> lastModifiedLocal = const Value.absent(),
                required String id,
                required String apartmentId,
                required String studentName,
                Value<String?> university = const Value.absent(),
                Value<String?> parentName = const Value.absent(),
                Value<String?> parentPhone = const Value.absent(),
                Value<String?> viewerUserId = const Value.absent(),
                required DateTime startDate,
                required DateTime endDate,
                required double monthlyRentEgp,
                Value<double> depositEgp = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => WinterContractsCompanion.insert(
                syncStatus: syncStatus,
                lastModifiedLocal: lastModifiedLocal,
                id: id,
                apartmentId: apartmentId,
                studentName: studentName,
                university: university,
                parentName: parentName,
                parentPhone: parentPhone,
                viewerUserId: viewerUserId,
                startDate: startDate,
                endDate: endDate,
                monthlyRentEgp: monthlyRentEgp,
                depositEgp: depositEgp,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WinterContractsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({apartmentId = false, winterPaymentsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (winterPaymentsRefs) db.winterPayments,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (apartmentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.apartmentId,
                                    referencedTable:
                                        $$WinterContractsTableReferences
                                            ._apartmentIdTable(db),
                                    referencedColumn:
                                        $$WinterContractsTableReferences
                                            ._apartmentIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (winterPaymentsRefs)
                        await $_getPrefetchedData<
                          WinterContract,
                          $WinterContractsTable,
                          WinterPayment
                        >(
                          currentTable: table,
                          referencedTable: $$WinterContractsTableReferences
                              ._winterPaymentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WinterContractsTableReferences(
                                db,
                                table,
                                p0,
                              ).winterPaymentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.contractId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$WinterContractsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WinterContractsTable,
      WinterContract,
      $$WinterContractsTableFilterComposer,
      $$WinterContractsTableOrderingComposer,
      $$WinterContractsTableAnnotationComposer,
      $$WinterContractsTableCreateCompanionBuilder,
      $$WinterContractsTableUpdateCompanionBuilder,
      (WinterContract, $$WinterContractsTableReferences),
      WinterContract,
      PrefetchHooks Function({bool apartmentId, bool winterPaymentsRefs})
    >;
typedef $$WinterPaymentsTableCreateCompanionBuilder =
    WinterPaymentsCompanion Function({
      Value<SyncStatus> syncStatus,
      Value<DateTime> lastModifiedLocal,
      required String id,
      required String contractId,
      required double amountEgp,
      required DateTime paymentDate,
      Value<String?> receiptUrl,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$WinterPaymentsTableUpdateCompanionBuilder =
    WinterPaymentsCompanion Function({
      Value<SyncStatus> syncStatus,
      Value<DateTime> lastModifiedLocal,
      Value<String> id,
      Value<String> contractId,
      Value<double> amountEgp,
      Value<DateTime> paymentDate,
      Value<String?> receiptUrl,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$WinterPaymentsTableReferences
    extends BaseReferences<_$AppDatabase, $WinterPaymentsTable, WinterPayment> {
  $$WinterPaymentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WinterContractsTable _contractIdTable(_$AppDatabase db) =>
      db.winterContracts.createAlias(
        $_aliasNameGenerator(
          db.winterPayments.contractId,
          db.winterContracts.id,
        ),
      );

  $$WinterContractsTableProcessedTableManager get contractId {
    final $_column = $_itemColumn<String>('contract_id')!;

    final manager = $$WinterContractsTableTableManager(
      $_db,
      $_db.winterContracts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contractIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WinterPaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $WinterPaymentsTable> {
  $$WinterPaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get lastModifiedLocal => $composableBuilder(
    column: $table.lastModifiedLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amountEgp => $composableBuilder(
    column: $table.amountEgp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptUrl => $composableBuilder(
    column: $table.receiptUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WinterContractsTableFilterComposer get contractId {
    final $$WinterContractsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contractId,
      referencedTable: $db.winterContracts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WinterContractsTableFilterComposer(
            $db: $db,
            $table: $db.winterContracts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WinterPaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $WinterPaymentsTable> {
  $$WinterPaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModifiedLocal => $composableBuilder(
    column: $table.lastModifiedLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amountEgp => $composableBuilder(
    column: $table.amountEgp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptUrl => $composableBuilder(
    column: $table.receiptUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WinterContractsTableOrderingComposer get contractId {
    final $$WinterContractsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contractId,
      referencedTable: $db.winterContracts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WinterContractsTableOrderingComposer(
            $db: $db,
            $table: $db.winterContracts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WinterPaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WinterPaymentsTable> {
  $$WinterPaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get lastModifiedLocal => $composableBuilder(
    column: $table.lastModifiedLocal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amountEgp =>
      $composableBuilder(column: $table.amountEgp, builder: (column) => column);

  GeneratedColumn<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get receiptUrl => $composableBuilder(
    column: $table.receiptUrl,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$WinterContractsTableAnnotationComposer get contractId {
    final $$WinterContractsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contractId,
      referencedTable: $db.winterContracts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WinterContractsTableAnnotationComposer(
            $db: $db,
            $table: $db.winterContracts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WinterPaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WinterPaymentsTable,
          WinterPayment,
          $$WinterPaymentsTableFilterComposer,
          $$WinterPaymentsTableOrderingComposer,
          $$WinterPaymentsTableAnnotationComposer,
          $$WinterPaymentsTableCreateCompanionBuilder,
          $$WinterPaymentsTableUpdateCompanionBuilder,
          (WinterPayment, $$WinterPaymentsTableReferences),
          WinterPayment,
          PrefetchHooks Function({bool contractId})
        > {
  $$WinterPaymentsTableTableManager(
    _$AppDatabase db,
    $WinterPaymentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WinterPaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WinterPaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WinterPaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> lastModifiedLocal = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> contractId = const Value.absent(),
                Value<double> amountEgp = const Value.absent(),
                Value<DateTime> paymentDate = const Value.absent(),
                Value<String?> receiptUrl = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WinterPaymentsCompanion(
                syncStatus: syncStatus,
                lastModifiedLocal: lastModifiedLocal,
                id: id,
                contractId: contractId,
                amountEgp: amountEgp,
                paymentDate: paymentDate,
                receiptUrl: receiptUrl,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> lastModifiedLocal = const Value.absent(),
                required String id,
                required String contractId,
                required double amountEgp,
                required DateTime paymentDate,
                Value<String?> receiptUrl = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => WinterPaymentsCompanion.insert(
                syncStatus: syncStatus,
                lastModifiedLocal: lastModifiedLocal,
                id: id,
                contractId: contractId,
                amountEgp: amountEgp,
                paymentDate: paymentDate,
                receiptUrl: receiptUrl,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WinterPaymentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({contractId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (contractId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.contractId,
                                referencedTable: $$WinterPaymentsTableReferences
                                    ._contractIdTable(db),
                                referencedColumn:
                                    $$WinterPaymentsTableReferences
                                        ._contractIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WinterPaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WinterPaymentsTable,
      WinterPayment,
      $$WinterPaymentsTableFilterComposer,
      $$WinterPaymentsTableOrderingComposer,
      $$WinterPaymentsTableAnnotationComposer,
      $$WinterPaymentsTableCreateCompanionBuilder,
      $$WinterPaymentsTableUpdateCompanionBuilder,
      (WinterPayment, $$WinterPaymentsTableReferences),
      WinterPayment,
      PrefetchHooks Function({bool contractId})
    >;
typedef $$MeterReadingsTableCreateCompanionBuilder =
    MeterReadingsCompanion Function({
      Value<SyncStatus> syncStatus,
      Value<DateTime> lastModifiedLocal,
      required String id,
      Value<String?> apartmentId,
      Value<String?> buildingId,
      required DateTime readingDate,
      required double previousReading,
      required double currentReading,
      required double amountEgp,
      Value<bool> isSharedExpense,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$MeterReadingsTableUpdateCompanionBuilder =
    MeterReadingsCompanion Function({
      Value<SyncStatus> syncStatus,
      Value<DateTime> lastModifiedLocal,
      Value<String> id,
      Value<String?> apartmentId,
      Value<String?> buildingId,
      Value<DateTime> readingDate,
      Value<double> previousReading,
      Value<double> currentReading,
      Value<double> amountEgp,
      Value<bool> isSharedExpense,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$MeterReadingsTableReferences
    extends BaseReferences<_$AppDatabase, $MeterReadingsTable, MeterReading> {
  $$MeterReadingsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ApartmentsTable _apartmentIdTable(_$AppDatabase db) =>
      db.apartments.createAlias(
        $_aliasNameGenerator(db.meterReadings.apartmentId, db.apartments.id),
      );

  $$ApartmentsTableProcessedTableManager? get apartmentId {
    final $_column = $_itemColumn<String>('apartment_id');
    if ($_column == null) return null;
    final manager = $$ApartmentsTableTableManager(
      $_db,
      $_db.apartments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_apartmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $BuildingsTable _buildingIdTable(_$AppDatabase db) =>
      db.buildings.createAlias(
        $_aliasNameGenerator(db.meterReadings.buildingId, db.buildings.id),
      );

  $$BuildingsTableProcessedTableManager? get buildingId {
    final $_column = $_itemColumn<String>('building_id');
    if ($_column == null) return null;
    final manager = $$BuildingsTableTableManager(
      $_db,
      $_db.buildings,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_buildingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MeterReadingsTableFilterComposer
    extends Composer<_$AppDatabase, $MeterReadingsTable> {
  $$MeterReadingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get lastModifiedLocal => $composableBuilder(
    column: $table.lastModifiedLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get readingDate => $composableBuilder(
    column: $table.readingDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get previousReading => $composableBuilder(
    column: $table.previousReading,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentReading => $composableBuilder(
    column: $table.currentReading,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amountEgp => $composableBuilder(
    column: $table.amountEgp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSharedExpense => $composableBuilder(
    column: $table.isSharedExpense,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ApartmentsTableFilterComposer get apartmentId {
    final $$ApartmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.apartmentId,
      referencedTable: $db.apartments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApartmentsTableFilterComposer(
            $db: $db,
            $table: $db.apartments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BuildingsTableFilterComposer get buildingId {
    final $$BuildingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.buildingId,
      referencedTable: $db.buildings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BuildingsTableFilterComposer(
            $db: $db,
            $table: $db.buildings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MeterReadingsTableOrderingComposer
    extends Composer<_$AppDatabase, $MeterReadingsTable> {
  $$MeterReadingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModifiedLocal => $composableBuilder(
    column: $table.lastModifiedLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get readingDate => $composableBuilder(
    column: $table.readingDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get previousReading => $composableBuilder(
    column: $table.previousReading,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentReading => $composableBuilder(
    column: $table.currentReading,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amountEgp => $composableBuilder(
    column: $table.amountEgp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSharedExpense => $composableBuilder(
    column: $table.isSharedExpense,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ApartmentsTableOrderingComposer get apartmentId {
    final $$ApartmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.apartmentId,
      referencedTable: $db.apartments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApartmentsTableOrderingComposer(
            $db: $db,
            $table: $db.apartments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BuildingsTableOrderingComposer get buildingId {
    final $$BuildingsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.buildingId,
      referencedTable: $db.buildings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BuildingsTableOrderingComposer(
            $db: $db,
            $table: $db.buildings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MeterReadingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MeterReadingsTable> {
  $$MeterReadingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get lastModifiedLocal => $composableBuilder(
    column: $table.lastModifiedLocal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get readingDate => $composableBuilder(
    column: $table.readingDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get previousReading => $composableBuilder(
    column: $table.previousReading,
    builder: (column) => column,
  );

  GeneratedColumn<double> get currentReading => $composableBuilder(
    column: $table.currentReading,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amountEgp =>
      $composableBuilder(column: $table.amountEgp, builder: (column) => column);

  GeneratedColumn<bool> get isSharedExpense => $composableBuilder(
    column: $table.isSharedExpense,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ApartmentsTableAnnotationComposer get apartmentId {
    final $$ApartmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.apartmentId,
      referencedTable: $db.apartments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApartmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.apartments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BuildingsTableAnnotationComposer get buildingId {
    final $$BuildingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.buildingId,
      referencedTable: $db.buildings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BuildingsTableAnnotationComposer(
            $db: $db,
            $table: $db.buildings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MeterReadingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MeterReadingsTable,
          MeterReading,
          $$MeterReadingsTableFilterComposer,
          $$MeterReadingsTableOrderingComposer,
          $$MeterReadingsTableAnnotationComposer,
          $$MeterReadingsTableCreateCompanionBuilder,
          $$MeterReadingsTableUpdateCompanionBuilder,
          (MeterReading, $$MeterReadingsTableReferences),
          MeterReading,
          PrefetchHooks Function({bool apartmentId, bool buildingId})
        > {
  $$MeterReadingsTableTableManager(_$AppDatabase db, $MeterReadingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MeterReadingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MeterReadingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MeterReadingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> lastModifiedLocal = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String?> apartmentId = const Value.absent(),
                Value<String?> buildingId = const Value.absent(),
                Value<DateTime> readingDate = const Value.absent(),
                Value<double> previousReading = const Value.absent(),
                Value<double> currentReading = const Value.absent(),
                Value<double> amountEgp = const Value.absent(),
                Value<bool> isSharedExpense = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MeterReadingsCompanion(
                syncStatus: syncStatus,
                lastModifiedLocal: lastModifiedLocal,
                id: id,
                apartmentId: apartmentId,
                buildingId: buildingId,
                readingDate: readingDate,
                previousReading: previousReading,
                currentReading: currentReading,
                amountEgp: amountEgp,
                isSharedExpense: isSharedExpense,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> lastModifiedLocal = const Value.absent(),
                required String id,
                Value<String?> apartmentId = const Value.absent(),
                Value<String?> buildingId = const Value.absent(),
                required DateTime readingDate,
                required double previousReading,
                required double currentReading,
                required double amountEgp,
                Value<bool> isSharedExpense = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => MeterReadingsCompanion.insert(
                syncStatus: syncStatus,
                lastModifiedLocal: lastModifiedLocal,
                id: id,
                apartmentId: apartmentId,
                buildingId: buildingId,
                readingDate: readingDate,
                previousReading: previousReading,
                currentReading: currentReading,
                amountEgp: amountEgp,
                isSharedExpense: isSharedExpense,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MeterReadingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({apartmentId = false, buildingId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (apartmentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.apartmentId,
                                referencedTable: $$MeterReadingsTableReferences
                                    ._apartmentIdTable(db),
                                referencedColumn: $$MeterReadingsTableReferences
                                    ._apartmentIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (buildingId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.buildingId,
                                referencedTable: $$MeterReadingsTableReferences
                                    ._buildingIdTable(db),
                                referencedColumn: $$MeterReadingsTableReferences
                                    ._buildingIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MeterReadingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MeterReadingsTable,
      MeterReading,
      $$MeterReadingsTableFilterComposer,
      $$MeterReadingsTableOrderingComposer,
      $$MeterReadingsTableAnnotationComposer,
      $$MeterReadingsTableCreateCompanionBuilder,
      $$MeterReadingsTableUpdateCompanionBuilder,
      (MeterReading, $$MeterReadingsTableReferences),
      MeterReading,
      PrefetchHooks Function({bool apartmentId, bool buildingId})
    >;
typedef $$ExpensesTableCreateCompanionBuilder =
    ExpensesCompanion Function({
      Value<SyncStatus> syncStatus,
      Value<DateTime> lastModifiedLocal,
      required String id,
      Value<String?> buildingId,
      Value<String?> apartmentId,
      required String expenseType,
      required double amountEgp,
      required DateTime expenseDate,
      Value<int?> installmentNumber,
      Value<String?> description,
      Value<String?> receiptUrl,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ExpensesTableUpdateCompanionBuilder =
    ExpensesCompanion Function({
      Value<SyncStatus> syncStatus,
      Value<DateTime> lastModifiedLocal,
      Value<String> id,
      Value<String?> buildingId,
      Value<String?> apartmentId,
      Value<String> expenseType,
      Value<double> amountEgp,
      Value<DateTime> expenseDate,
      Value<int?> installmentNumber,
      Value<String?> description,
      Value<String?> receiptUrl,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$ExpensesTableReferences
    extends BaseReferences<_$AppDatabase, $ExpensesTable, Expense> {
  $$ExpensesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BuildingsTable _buildingIdTable(_$AppDatabase db) =>
      db.buildings.createAlias(
        $_aliasNameGenerator(db.expenses.buildingId, db.buildings.id),
      );

  $$BuildingsTableProcessedTableManager? get buildingId {
    final $_column = $_itemColumn<String>('building_id');
    if ($_column == null) return null;
    final manager = $$BuildingsTableTableManager(
      $_db,
      $_db.buildings,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_buildingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ApartmentsTable _apartmentIdTable(_$AppDatabase db) =>
      db.apartments.createAlias(
        $_aliasNameGenerator(db.expenses.apartmentId, db.apartments.id),
      );

  $$ApartmentsTableProcessedTableManager? get apartmentId {
    final $_column = $_itemColumn<String>('apartment_id');
    if ($_column == null) return null;
    final manager = $$ApartmentsTableTableManager(
      $_db,
      $_db.apartments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_apartmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get lastModifiedLocal => $composableBuilder(
    column: $table.lastModifiedLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get expenseType => $composableBuilder(
    column: $table.expenseType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amountEgp => $composableBuilder(
    column: $table.amountEgp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expenseDate => $composableBuilder(
    column: $table.expenseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get installmentNumber => $composableBuilder(
    column: $table.installmentNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptUrl => $composableBuilder(
    column: $table.receiptUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BuildingsTableFilterComposer get buildingId {
    final $$BuildingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.buildingId,
      referencedTable: $db.buildings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BuildingsTableFilterComposer(
            $db: $db,
            $table: $db.buildings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ApartmentsTableFilterComposer get apartmentId {
    final $$ApartmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.apartmentId,
      referencedTable: $db.apartments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApartmentsTableFilterComposer(
            $db: $db,
            $table: $db.apartments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModifiedLocal => $composableBuilder(
    column: $table.lastModifiedLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expenseType => $composableBuilder(
    column: $table.expenseType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amountEgp => $composableBuilder(
    column: $table.amountEgp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expenseDate => $composableBuilder(
    column: $table.expenseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get installmentNumber => $composableBuilder(
    column: $table.installmentNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptUrl => $composableBuilder(
    column: $table.receiptUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BuildingsTableOrderingComposer get buildingId {
    final $$BuildingsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.buildingId,
      referencedTable: $db.buildings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BuildingsTableOrderingComposer(
            $db: $db,
            $table: $db.buildings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ApartmentsTableOrderingComposer get apartmentId {
    final $$ApartmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.apartmentId,
      referencedTable: $db.apartments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApartmentsTableOrderingComposer(
            $db: $db,
            $table: $db.apartments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get lastModifiedLocal => $composableBuilder(
    column: $table.lastModifiedLocal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get expenseType => $composableBuilder(
    column: $table.expenseType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amountEgp =>
      $composableBuilder(column: $table.amountEgp, builder: (column) => column);

  GeneratedColumn<DateTime> get expenseDate => $composableBuilder(
    column: $table.expenseDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get installmentNumber => $composableBuilder(
    column: $table.installmentNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get receiptUrl => $composableBuilder(
    column: $table.receiptUrl,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$BuildingsTableAnnotationComposer get buildingId {
    final $$BuildingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.buildingId,
      referencedTable: $db.buildings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BuildingsTableAnnotationComposer(
            $db: $db,
            $table: $db.buildings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ApartmentsTableAnnotationComposer get apartmentId {
    final $$ApartmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.apartmentId,
      referencedTable: $db.apartments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApartmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.apartments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpensesTable,
          Expense,
          $$ExpensesTableFilterComposer,
          $$ExpensesTableOrderingComposer,
          $$ExpensesTableAnnotationComposer,
          $$ExpensesTableCreateCompanionBuilder,
          $$ExpensesTableUpdateCompanionBuilder,
          (Expense, $$ExpensesTableReferences),
          Expense,
          PrefetchHooks Function({bool buildingId, bool apartmentId})
        > {
  $$ExpensesTableTableManager(_$AppDatabase db, $ExpensesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> lastModifiedLocal = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String?> buildingId = const Value.absent(),
                Value<String?> apartmentId = const Value.absent(),
                Value<String> expenseType = const Value.absent(),
                Value<double> amountEgp = const Value.absent(),
                Value<DateTime> expenseDate = const Value.absent(),
                Value<int?> installmentNumber = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> receiptUrl = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion(
                syncStatus: syncStatus,
                lastModifiedLocal: lastModifiedLocal,
                id: id,
                buildingId: buildingId,
                apartmentId: apartmentId,
                expenseType: expenseType,
                amountEgp: amountEgp,
                expenseDate: expenseDate,
                installmentNumber: installmentNumber,
                description: description,
                receiptUrl: receiptUrl,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> lastModifiedLocal = const Value.absent(),
                required String id,
                Value<String?> buildingId = const Value.absent(),
                Value<String?> apartmentId = const Value.absent(),
                required String expenseType,
                required double amountEgp,
                required DateTime expenseDate,
                Value<int?> installmentNumber = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> receiptUrl = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion.insert(
                syncStatus: syncStatus,
                lastModifiedLocal: lastModifiedLocal,
                id: id,
                buildingId: buildingId,
                apartmentId: apartmentId,
                expenseType: expenseType,
                amountEgp: amountEgp,
                expenseDate: expenseDate,
                installmentNumber: installmentNumber,
                description: description,
                receiptUrl: receiptUrl,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExpensesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({buildingId = false, apartmentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (buildingId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.buildingId,
                                referencedTable: $$ExpensesTableReferences
                                    ._buildingIdTable(db),
                                referencedColumn: $$ExpensesTableReferences
                                    ._buildingIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (apartmentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.apartmentId,
                                referencedTable: $$ExpensesTableReferences
                                    ._apartmentIdTable(db),
                                referencedColumn: $$ExpensesTableReferences
                                    ._apartmentIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpensesTable,
      Expense,
      $$ExpensesTableFilterComposer,
      $$ExpensesTableOrderingComposer,
      $$ExpensesTableAnnotationComposer,
      $$ExpensesTableCreateCompanionBuilder,
      $$ExpensesTableUpdateCompanionBuilder,
      (Expense, $$ExpensesTableReferences),
      Expense,
      PrefetchHooks Function({bool buildingId, bool apartmentId})
    >;
typedef $$MaintenanceRequestsTableCreateCompanionBuilder =
    MaintenanceRequestsCompanion Function({
      Value<SyncStatus> syncStatus,
      Value<DateTime> lastModifiedLocal,
      required String id,
      required String apartmentId,
      required String reportedBy,
      required String issueDescription,
      Value<String> status,
      Value<double> costEgp,
      Value<DateTime?> resolvedAt,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$MaintenanceRequestsTableUpdateCompanionBuilder =
    MaintenanceRequestsCompanion Function({
      Value<SyncStatus> syncStatus,
      Value<DateTime> lastModifiedLocal,
      Value<String> id,
      Value<String> apartmentId,
      Value<String> reportedBy,
      Value<String> issueDescription,
      Value<String> status,
      Value<double> costEgp,
      Value<DateTime?> resolvedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$MaintenanceRequestsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MaintenanceRequestsTable,
          MaintenanceRequest
        > {
  $$MaintenanceRequestsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ApartmentsTable _apartmentIdTable(_$AppDatabase db) =>
      db.apartments.createAlias(
        $_aliasNameGenerator(
          db.maintenanceRequests.apartmentId,
          db.apartments.id,
        ),
      );

  $$ApartmentsTableProcessedTableManager get apartmentId {
    final $_column = $_itemColumn<String>('apartment_id')!;

    final manager = $$ApartmentsTableTableManager(
      $_db,
      $_db.apartments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_apartmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MaintenanceRequestsTableFilterComposer
    extends Composer<_$AppDatabase, $MaintenanceRequestsTable> {
  $$MaintenanceRequestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get lastModifiedLocal => $composableBuilder(
    column: $table.lastModifiedLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reportedBy => $composableBuilder(
    column: $table.reportedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get issueDescription => $composableBuilder(
    column: $table.issueDescription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costEgp => $composableBuilder(
    column: $table.costEgp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ApartmentsTableFilterComposer get apartmentId {
    final $$ApartmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.apartmentId,
      referencedTable: $db.apartments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApartmentsTableFilterComposer(
            $db: $db,
            $table: $db.apartments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MaintenanceRequestsTableOrderingComposer
    extends Composer<_$AppDatabase, $MaintenanceRequestsTable> {
  $$MaintenanceRequestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModifiedLocal => $composableBuilder(
    column: $table.lastModifiedLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reportedBy => $composableBuilder(
    column: $table.reportedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get issueDescription => $composableBuilder(
    column: $table.issueDescription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costEgp => $composableBuilder(
    column: $table.costEgp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ApartmentsTableOrderingComposer get apartmentId {
    final $$ApartmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.apartmentId,
      referencedTable: $db.apartments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApartmentsTableOrderingComposer(
            $db: $db,
            $table: $db.apartments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MaintenanceRequestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MaintenanceRequestsTable> {
  $$MaintenanceRequestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get lastModifiedLocal => $composableBuilder(
    column: $table.lastModifiedLocal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get reportedBy => $composableBuilder(
    column: $table.reportedBy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get issueDescription => $composableBuilder(
    column: $table.issueDescription,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get costEgp =>
      $composableBuilder(column: $table.costEgp, builder: (column) => column);

  GeneratedColumn<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ApartmentsTableAnnotationComposer get apartmentId {
    final $$ApartmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.apartmentId,
      referencedTable: $db.apartments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApartmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.apartments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MaintenanceRequestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MaintenanceRequestsTable,
          MaintenanceRequest,
          $$MaintenanceRequestsTableFilterComposer,
          $$MaintenanceRequestsTableOrderingComposer,
          $$MaintenanceRequestsTableAnnotationComposer,
          $$MaintenanceRequestsTableCreateCompanionBuilder,
          $$MaintenanceRequestsTableUpdateCompanionBuilder,
          (MaintenanceRequest, $$MaintenanceRequestsTableReferences),
          MaintenanceRequest,
          PrefetchHooks Function({bool apartmentId})
        > {
  $$MaintenanceRequestsTableTableManager(
    _$AppDatabase db,
    $MaintenanceRequestsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MaintenanceRequestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MaintenanceRequestsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MaintenanceRequestsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> lastModifiedLocal = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> apartmentId = const Value.absent(),
                Value<String> reportedBy = const Value.absent(),
                Value<String> issueDescription = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> costEgp = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MaintenanceRequestsCompanion(
                syncStatus: syncStatus,
                lastModifiedLocal: lastModifiedLocal,
                id: id,
                apartmentId: apartmentId,
                reportedBy: reportedBy,
                issueDescription: issueDescription,
                status: status,
                costEgp: costEgp,
                resolvedAt: resolvedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> lastModifiedLocal = const Value.absent(),
                required String id,
                required String apartmentId,
                required String reportedBy,
                required String issueDescription,
                Value<String> status = const Value.absent(),
                Value<double> costEgp = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MaintenanceRequestsCompanion.insert(
                syncStatus: syncStatus,
                lastModifiedLocal: lastModifiedLocal,
                id: id,
                apartmentId: apartmentId,
                reportedBy: reportedBy,
                issueDescription: issueDescription,
                status: status,
                costEgp: costEgp,
                resolvedAt: resolvedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MaintenanceRequestsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({apartmentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (apartmentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.apartmentId,
                                referencedTable:
                                    $$MaintenanceRequestsTableReferences
                                        ._apartmentIdTable(db),
                                referencedColumn:
                                    $$MaintenanceRequestsTableReferences
                                        ._apartmentIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MaintenanceRequestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MaintenanceRequestsTable,
      MaintenanceRequest,
      $$MaintenanceRequestsTableFilterComposer,
      $$MaintenanceRequestsTableOrderingComposer,
      $$MaintenanceRequestsTableAnnotationComposer,
      $$MaintenanceRequestsTableCreateCompanionBuilder,
      $$MaintenanceRequestsTableUpdateCompanionBuilder,
      (MaintenanceRequest, $$MaintenanceRequestsTableReferences),
      MaintenanceRequest,
      PrefetchHooks Function({bool apartmentId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BuildingsTableTableManager get buildings =>
      $$BuildingsTableTableManager(_db, _db.buildings);
  $$ApartmentsTableTableManager get apartments =>
      $$ApartmentsTableTableManager(_db, _db.apartments);
  $$SummerBookingsTableTableManager get summerBookings =>
      $$SummerBookingsTableTableManager(_db, _db.summerBookings);
  $$WinterContractsTableTableManager get winterContracts =>
      $$WinterContractsTableTableManager(_db, _db.winterContracts);
  $$WinterPaymentsTableTableManager get winterPayments =>
      $$WinterPaymentsTableTableManager(_db, _db.winterPayments);
  $$MeterReadingsTableTableManager get meterReadings =>
      $$MeterReadingsTableTableManager(_db, _db.meterReadings);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
  $$MaintenanceRequestsTableTableManager get maintenanceRequests =>
      $$MaintenanceRequestsTableTableManager(_db, _db.maintenanceRequests);
}
