// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<SyncStatus>($UserProfilesTable.$convertersyncStatus);
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
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneNumberMeta = const VerificationMeta(
    'phoneNumber',
  );
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
    'phone_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _secondaryPhoneMeta = const VerificationMeta(
    'secondaryPhone',
  );
  @override
  late final GeneratedColumn<String> secondaryPhone = GeneratedColumn<String>(
    'secondary_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('viewer'),
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
    email,
    fullName,
    phoneNumber,
    secondaryPhone,
    role,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfile> instance, {
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
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    }
    if (data.containsKey('phone_number')) {
      context.handle(
        _phoneNumberMeta,
        phoneNumber.isAcceptableOrUnknown(
          data['phone_number']!,
          _phoneNumberMeta,
        ),
      );
    }
    if (data.containsKey('secondary_phone')) {
      context.handle(
        _secondaryPhoneMeta,
        secondaryPhone.isAcceptableOrUnknown(
          data['secondary_phone']!,
          _secondaryPhoneMeta,
        ),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
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
  UserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfile(
      syncStatus: $UserProfilesTable.$convertersyncStatus.fromSql(
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
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      ),
      phoneNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_number'],
      ),
      secondaryPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}secondary_phone'],
      ),
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
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
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class UserProfile extends DataClass implements Insertable<UserProfile> {
  final SyncStatus syncStatus;
  final DateTime lastModifiedLocal;
  final String id;
  final String email;
  final String? fullName;
  final String? phoneNumber;
  final String? secondaryPhone;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;
  const UserProfile({
    required this.syncStatus,
    required this.lastModifiedLocal,
    required this.id,
    required this.email,
    this.fullName,
    this.phoneNumber,
    this.secondaryPhone,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['sync_status'] = Variable<int>(
        $UserProfilesTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['last_modified_local'] = Variable<DateTime>(lastModifiedLocal);
    map['id'] = Variable<String>(id);
    map['email'] = Variable<String>(email);
    if (!nullToAbsent || fullName != null) {
      map['full_name'] = Variable<String>(fullName);
    }
    if (!nullToAbsent || phoneNumber != null) {
      map['phone_number'] = Variable<String>(phoneNumber);
    }
    if (!nullToAbsent || secondaryPhone != null) {
      map['secondary_phone'] = Variable<String>(secondaryPhone);
    }
    map['role'] = Variable<String>(role);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      syncStatus: Value(syncStatus),
      lastModifiedLocal: Value(lastModifiedLocal),
      id: Value(id),
      email: Value(email),
      fullName: fullName == null && nullToAbsent
          ? const Value.absent()
          : Value(fullName),
      phoneNumber: phoneNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(phoneNumber),
      secondaryPhone: secondaryPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(secondaryPhone),
      role: Value(role),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfile(
      syncStatus: $UserProfilesTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
      lastModifiedLocal: serializer.fromJson<DateTime>(
        json['lastModifiedLocal'],
      ),
      id: serializer.fromJson<String>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      fullName: serializer.fromJson<String?>(json['fullName']),
      phoneNumber: serializer.fromJson<String?>(json['phoneNumber']),
      secondaryPhone: serializer.fromJson<String?>(json['secondaryPhone']),
      role: serializer.fromJson<String>(json['role']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncStatus': serializer.toJson<int>(
        $UserProfilesTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'lastModifiedLocal': serializer.toJson<DateTime>(lastModifiedLocal),
      'id': serializer.toJson<String>(id),
      'email': serializer.toJson<String>(email),
      'fullName': serializer.toJson<String?>(fullName),
      'phoneNumber': serializer.toJson<String?>(phoneNumber),
      'secondaryPhone': serializer.toJson<String?>(secondaryPhone),
      'role': serializer.toJson<String>(role),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserProfile copyWith({
    SyncStatus? syncStatus,
    DateTime? lastModifiedLocal,
    String? id,
    String? email,
    Value<String?> fullName = const Value.absent(),
    Value<String?> phoneNumber = const Value.absent(),
    Value<String?> secondaryPhone = const Value.absent(),
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => UserProfile(
    syncStatus: syncStatus ?? this.syncStatus,
    lastModifiedLocal: lastModifiedLocal ?? this.lastModifiedLocal,
    id: id ?? this.id,
    email: email ?? this.email,
    fullName: fullName.present ? fullName.value : this.fullName,
    phoneNumber: phoneNumber.present ? phoneNumber.value : this.phoneNumber,
    secondaryPhone: secondaryPhone.present
        ? secondaryPhone.value
        : this.secondaryPhone,
    role: role ?? this.role,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserProfile copyWithCompanion(UserProfilesCompanion data) {
    return UserProfile(
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastModifiedLocal: data.lastModifiedLocal.present
          ? data.lastModifiedLocal.value
          : this.lastModifiedLocal,
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      phoneNumber: data.phoneNumber.present
          ? data.phoneNumber.value
          : this.phoneNumber,
      secondaryPhone: data.secondaryPhone.present
          ? data.secondaryPhone.value
          : this.secondaryPhone,
      role: data.role.present ? data.role.value : this.role,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfile(')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedLocal: $lastModifiedLocal, ')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('fullName: $fullName, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('secondaryPhone: $secondaryPhone, ')
          ..write('role: $role, ')
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
    email,
    fullName,
    phoneNumber,
    secondaryPhone,
    role,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.syncStatus == this.syncStatus &&
          other.lastModifiedLocal == this.lastModifiedLocal &&
          other.id == this.id &&
          other.email == this.email &&
          other.fullName == this.fullName &&
          other.phoneNumber == this.phoneNumber &&
          other.secondaryPhone == this.secondaryPhone &&
          other.role == this.role &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfile> {
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> lastModifiedLocal;
  final Value<String> id;
  final Value<String> email;
  final Value<String?> fullName;
  final Value<String?> phoneNumber;
  final Value<String?> secondaryPhone;
  final Value<String> role;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UserProfilesCompanion({
    this.syncStatus = const Value.absent(),
    this.lastModifiedLocal = const Value.absent(),
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.fullName = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.secondaryPhone = const Value.absent(),
    this.role = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    this.syncStatus = const Value.absent(),
    this.lastModifiedLocal = const Value.absent(),
    required String id,
    required String email,
    this.fullName = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.secondaryPhone = const Value.absent(),
    this.role = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       email = Value(email),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<UserProfile> custom({
    Expression<int>? syncStatus,
    Expression<DateTime>? lastModifiedLocal,
    Expression<String>? id,
    Expression<String>? email,
    Expression<String>? fullName,
    Expression<String>? phoneNumber,
    Expression<String>? secondaryPhone,
    Expression<String>? role,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastModifiedLocal != null) 'last_modified_local': lastModifiedLocal,
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (fullName != null) 'full_name': fullName,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (secondaryPhone != null) 'secondary_phone': secondaryPhone,
      if (role != null) 'role': role,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserProfilesCompanion copyWith({
    Value<SyncStatus>? syncStatus,
    Value<DateTime>? lastModifiedLocal,
    Value<String>? id,
    Value<String>? email,
    Value<String?>? fullName,
    Value<String?>? phoneNumber,
    Value<String?>? secondaryPhone,
    Value<String>? role,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return UserProfilesCompanion(
      syncStatus: syncStatus ?? this.syncStatus,
      lastModifiedLocal: lastModifiedLocal ?? this.lastModifiedLocal,
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      secondaryPhone: secondaryPhone ?? this.secondaryPhone,
      role: role ?? this.role,
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
        $UserProfilesTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (lastModifiedLocal.present) {
      map['last_modified_local'] = Variable<DateTime>(lastModifiedLocal.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (secondaryPhone.present) {
      map['secondary_phone'] = Variable<String>(secondaryPhone.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
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
    return (StringBuffer('UserProfilesCompanion(')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedLocal: $lastModifiedLocal, ')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('fullName: $fullName, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('secondaryPhone: $secondaryPhone, ')
          ..write('role: $role, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

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
  static const VerificationMeta _annualRentEgpMeta = const VerificationMeta(
    'annualRentEgp',
  );
  @override
  late final GeneratedColumn<double> annualRentEgp = GeneratedColumn<double>(
    'annual_rent_egp',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _rentInstallmentsDatesMeta =
      const VerificationMeta('rentInstallmentsDates');
  @override
  late final GeneratedColumn<String> rentInstallmentsDates =
      GeneratedColumn<String>(
        'rent_installments_dates',
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
    annualRentEgp,
    rentInstallmentsDates,
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
    if (data.containsKey('annual_rent_egp')) {
      context.handle(
        _annualRentEgpMeta,
        annualRentEgp.isAcceptableOrUnknown(
          data['annual_rent_egp']!,
          _annualRentEgpMeta,
        ),
      );
    }
    if (data.containsKey('rent_installments_dates')) {
      context.handle(
        _rentInstallmentsDatesMeta,
        rentInstallmentsDates.isAcceptableOrUnknown(
          data['rent_installments_dates']!,
          _rentInstallmentsDatesMeta,
        ),
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
      annualRentEgp: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}annual_rent_egp'],
      )!,
      rentInstallmentsDates: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rent_installments_dates'],
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
  final double annualRentEgp;
  final String? rentInstallmentsDates;
  final int totalApartments;
  final DateTime createdAt;
  const Building({
    required this.syncStatus,
    required this.lastModifiedLocal,
    required this.id,
    required this.name,
    this.address,
    required this.annualRentEgp,
    this.rentInstallmentsDates,
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
    map['annual_rent_egp'] = Variable<double>(annualRentEgp);
    if (!nullToAbsent || rentInstallmentsDates != null) {
      map['rent_installments_dates'] = Variable<String>(rentInstallmentsDates);
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
      annualRentEgp: Value(annualRentEgp),
      rentInstallmentsDates: rentInstallmentsDates == null && nullToAbsent
          ? const Value.absent()
          : Value(rentInstallmentsDates),
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
      annualRentEgp: serializer.fromJson<double>(json['annualRentEgp']),
      rentInstallmentsDates: serializer.fromJson<String?>(
        json['rentInstallmentsDates'],
      ),
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
      'annualRentEgp': serializer.toJson<double>(annualRentEgp),
      'rentInstallmentsDates': serializer.toJson<String?>(
        rentInstallmentsDates,
      ),
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
    double? annualRentEgp,
    Value<String?> rentInstallmentsDates = const Value.absent(),
    int? totalApartments,
    DateTime? createdAt,
  }) => Building(
    syncStatus: syncStatus ?? this.syncStatus,
    lastModifiedLocal: lastModifiedLocal ?? this.lastModifiedLocal,
    id: id ?? this.id,
    name: name ?? this.name,
    address: address.present ? address.value : this.address,
    annualRentEgp: annualRentEgp ?? this.annualRentEgp,
    rentInstallmentsDates: rentInstallmentsDates.present
        ? rentInstallmentsDates.value
        : this.rentInstallmentsDates,
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
      annualRentEgp: data.annualRentEgp.present
          ? data.annualRentEgp.value
          : this.annualRentEgp,
      rentInstallmentsDates: data.rentInstallmentsDates.present
          ? data.rentInstallmentsDates.value
          : this.rentInstallmentsDates,
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
          ..write('annualRentEgp: $annualRentEgp, ')
          ..write('rentInstallmentsDates: $rentInstallmentsDates, ')
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
    annualRentEgp,
    rentInstallmentsDates,
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
          other.annualRentEgp == this.annualRentEgp &&
          other.rentInstallmentsDates == this.rentInstallmentsDates &&
          other.totalApartments == this.totalApartments &&
          other.createdAt == this.createdAt);
}

class BuildingsCompanion extends UpdateCompanion<Building> {
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> lastModifiedLocal;
  final Value<String> id;
  final Value<String> name;
  final Value<String?> address;
  final Value<double> annualRentEgp;
  final Value<String?> rentInstallmentsDates;
  final Value<int> totalApartments;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BuildingsCompanion({
    this.syncStatus = const Value.absent(),
    this.lastModifiedLocal = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.address = const Value.absent(),
    this.annualRentEgp = const Value.absent(),
    this.rentInstallmentsDates = const Value.absent(),
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
    this.annualRentEgp = const Value.absent(),
    this.rentInstallmentsDates = const Value.absent(),
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
    Expression<double>? annualRentEgp,
    Expression<String>? rentInstallmentsDates,
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
      if (annualRentEgp != null) 'annual_rent_egp': annualRentEgp,
      if (rentInstallmentsDates != null)
        'rent_installments_dates': rentInstallmentsDates,
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
    Value<double>? annualRentEgp,
    Value<String?>? rentInstallmentsDates,
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
      annualRentEgp: annualRentEgp ?? this.annualRentEgp,
      rentInstallmentsDates:
          rentInstallmentsDates ?? this.rentInstallmentsDates,
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
    if (annualRentEgp.present) {
      map['annual_rent_egp'] = Variable<double>(annualRentEgp.value);
    }
    if (rentInstallmentsDates.present) {
      map['rent_installments_dates'] = Variable<String>(
        rentInstallmentsDates.value,
      );
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
          ..write('annualRentEgp: $annualRentEgp, ')
          ..write('rentInstallmentsDates: $rentInstallmentsDates, ')
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
  static const VerificationMeta _inventoryMeta = const VerificationMeta(
    'inventory',
  );
  @override
  late final GeneratedColumn<String> inventory = GeneratedColumn<String>(
    'inventory',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _landlineNumberMeta = const VerificationMeta(
    'landlineNumber',
  );
  @override
  late final GeneratedColumn<String> landlineNumber = GeneratedColumn<String>(
    'landline_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _landlineOwnerNameMeta = const VerificationMeta(
    'landlineOwnerName',
  );
  @override
  late final GeneratedColumn<String> landlineOwnerName =
      GeneratedColumn<String>(
        'landline_owner_name',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _landlineNotesMeta = const VerificationMeta(
    'landlineNotes',
  );
  @override
  late final GeneratedColumn<String> landlineNotes = GeneratedColumn<String>(
    'landline_notes',
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
    inventory,
    landlineNumber,
    landlineOwnerName,
    landlineNotes,
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
    if (data.containsKey('inventory')) {
      context.handle(
        _inventoryMeta,
        inventory.isAcceptableOrUnknown(data['inventory']!, _inventoryMeta),
      );
    }
    if (data.containsKey('landline_number')) {
      context.handle(
        _landlineNumberMeta,
        landlineNumber.isAcceptableOrUnknown(
          data['landline_number']!,
          _landlineNumberMeta,
        ),
      );
    }
    if (data.containsKey('landline_owner_name')) {
      context.handle(
        _landlineOwnerNameMeta,
        landlineOwnerName.isAcceptableOrUnknown(
          data['landline_owner_name']!,
          _landlineOwnerNameMeta,
        ),
      );
    }
    if (data.containsKey('landline_notes')) {
      context.handle(
        _landlineNotesMeta,
        landlineNotes.isAcceptableOrUnknown(
          data['landline_notes']!,
          _landlineNotesMeta,
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
      inventory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}inventory'],
      ),
      landlineNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}landline_number'],
      ),
      landlineOwnerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}landline_owner_name'],
      ),
      landlineNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}landline_notes'],
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
  final String? inventory;
  final String? landlineNumber;
  final String? landlineOwnerName;
  final String? landlineNotes;
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
    this.inventory,
    this.landlineNumber,
    this.landlineOwnerName,
    this.landlineNotes,
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
    if (!nullToAbsent || inventory != null) {
      map['inventory'] = Variable<String>(inventory);
    }
    if (!nullToAbsent || landlineNumber != null) {
      map['landline_number'] = Variable<String>(landlineNumber);
    }
    if (!nullToAbsent || landlineOwnerName != null) {
      map['landline_owner_name'] = Variable<String>(landlineOwnerName);
    }
    if (!nullToAbsent || landlineNotes != null) {
      map['landline_notes'] = Variable<String>(landlineNotes);
    }
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
      inventory: inventory == null && nullToAbsent
          ? const Value.absent()
          : Value(inventory),
      landlineNumber: landlineNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(landlineNumber),
      landlineOwnerName: landlineOwnerName == null && nullToAbsent
          ? const Value.absent()
          : Value(landlineOwnerName),
      landlineNotes: landlineNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(landlineNotes),
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
      inventory: serializer.fromJson<String?>(json['inventory']),
      landlineNumber: serializer.fromJson<String?>(json['landlineNumber']),
      landlineOwnerName: serializer.fromJson<String?>(
        json['landlineOwnerName'],
      ),
      landlineNotes: serializer.fromJson<String?>(json['landlineNotes']),
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
      'inventory': serializer.toJson<String?>(inventory),
      'landlineNumber': serializer.toJson<String?>(landlineNumber),
      'landlineOwnerName': serializer.toJson<String?>(landlineOwnerName),
      'landlineNotes': serializer.toJson<String?>(landlineNotes),
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
    Value<String?> inventory = const Value.absent(),
    Value<String?> landlineNumber = const Value.absent(),
    Value<String?> landlineOwnerName = const Value.absent(),
    Value<String?> landlineNotes = const Value.absent(),
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
    inventory: inventory.present ? inventory.value : this.inventory,
    landlineNumber: landlineNumber.present
        ? landlineNumber.value
        : this.landlineNumber,
    landlineOwnerName: landlineOwnerName.present
        ? landlineOwnerName.value
        : this.landlineOwnerName,
    landlineNotes: landlineNotes.present
        ? landlineNotes.value
        : this.landlineNotes,
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
      inventory: data.inventory.present ? data.inventory.value : this.inventory,
      landlineNumber: data.landlineNumber.present
          ? data.landlineNumber.value
          : this.landlineNumber,
      landlineOwnerName: data.landlineOwnerName.present
          ? data.landlineOwnerName.value
          : this.landlineOwnerName,
      landlineNotes: data.landlineNotes.present
          ? data.landlineNotes.value
          : this.landlineNotes,
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
          ..write('inventory: $inventory, ')
          ..write('landlineNumber: $landlineNumber, ')
          ..write('landlineOwnerName: $landlineOwnerName, ')
          ..write('landlineNotes: $landlineNotes, ')
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
    inventory,
    landlineNumber,
    landlineOwnerName,
    landlineNotes,
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
          other.inventory == this.inventory &&
          other.landlineNumber == this.landlineNumber &&
          other.landlineOwnerName == this.landlineOwnerName &&
          other.landlineNotes == this.landlineNotes &&
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
  final Value<String?> inventory;
  final Value<String?> landlineNumber;
  final Value<String?> landlineOwnerName;
  final Value<String?> landlineNotes;
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
    this.inventory = const Value.absent(),
    this.landlineNumber = const Value.absent(),
    this.landlineOwnerName = const Value.absent(),
    this.landlineNotes = const Value.absent(),
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
    this.inventory = const Value.absent(),
    this.landlineNumber = const Value.absent(),
    this.landlineOwnerName = const Value.absent(),
    this.landlineNotes = const Value.absent(),
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
    Expression<String>? inventory,
    Expression<String>? landlineNumber,
    Expression<String>? landlineOwnerName,
    Expression<String>? landlineNotes,
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
      if (inventory != null) 'inventory': inventory,
      if (landlineNumber != null) 'landline_number': landlineNumber,
      if (landlineOwnerName != null) 'landline_owner_name': landlineOwnerName,
      if (landlineNotes != null) 'landline_notes': landlineNotes,
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
    Value<String?>? inventory,
    Value<String?>? landlineNumber,
    Value<String?>? landlineOwnerName,
    Value<String?>? landlineNotes,
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
      inventory: inventory ?? this.inventory,
      landlineNumber: landlineNumber ?? this.landlineNumber,
      landlineOwnerName: landlineOwnerName ?? this.landlineOwnerName,
      landlineNotes: landlineNotes ?? this.landlineNotes,
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
    if (inventory.present) {
      map['inventory'] = Variable<String>(inventory.value);
    }
    if (landlineNumber.present) {
      map['landline_number'] = Variable<String>(landlineNumber.value);
    }
    if (landlineOwnerName.present) {
      map['landline_owner_name'] = Variable<String>(landlineOwnerName.value);
    }
    if (landlineNotes.present) {
      map['landline_notes'] = Variable<String>(landlineNotes.value);
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
          ..write('inventory: $inventory, ')
          ..write('landlineNumber: $landlineNumber, ')
          ..write('landlineOwnerName: $landlineOwnerName, ')
          ..write('landlineNotes: $landlineNotes, ')
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
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('cash'),
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
  static const VerificationMeta _brokerNameMeta = const VerificationMeta(
    'brokerName',
  );
  @override
  late final GeneratedColumn<String> brokerName = GeneratedColumn<String>(
    'broker_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _brokerCommissionTypeMeta =
      const VerificationMeta('brokerCommissionType');
  @override
  late final GeneratedColumn<String> brokerCommissionType =
      GeneratedColumn<String>(
        'broker_commission_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('none'),
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
  static const VerificationMeta _brokerCommissionFixedEgpMeta =
      const VerificationMeta('brokerCommissionFixedEgp');
  @override
  late final GeneratedColumn<double> brokerCommissionFixedEgp =
      GeneratedColumn<double>(
        'broker_commission_fixed_egp',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
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
  static const VerificationMeta _nationalIdMeta = const VerificationMeta(
    'nationalId',
  );
  @override
  late final GeneratedColumn<String> nationalId = GeneratedColumn<String>(
    'national_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idFrontImageMeta = const VerificationMeta(
    'idFrontImage',
  );
  @override
  late final GeneratedColumn<String> idFrontImage = GeneratedColumn<String>(
    'id_front_image',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idBackImageMeta = const VerificationMeta(
    'idBackImage',
  );
  @override
  late final GeneratedColumn<String> idBackImage = GeneratedColumn<String>(
    'id_back_image',
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
    paymentMethod,
    brokerId,
    brokerName,
    brokerCommissionType,
    brokerCommissionPercentage,
    brokerCommissionFixedEgp,
    brokerCommissionAmountEgp,
    earlyCheckoutDate,
    overstayDays,
    overstayFeeEgp,
    nationalId,
    idFrontImage,
    idBackImage,
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
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    }
    if (data.containsKey('broker_id')) {
      context.handle(
        _brokerIdMeta,
        brokerId.isAcceptableOrUnknown(data['broker_id']!, _brokerIdMeta),
      );
    }
    if (data.containsKey('broker_name')) {
      context.handle(
        _brokerNameMeta,
        brokerName.isAcceptableOrUnknown(data['broker_name']!, _brokerNameMeta),
      );
    }
    if (data.containsKey('broker_commission_type')) {
      context.handle(
        _brokerCommissionTypeMeta,
        brokerCommissionType.isAcceptableOrUnknown(
          data['broker_commission_type']!,
          _brokerCommissionTypeMeta,
        ),
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
    if (data.containsKey('broker_commission_fixed_egp')) {
      context.handle(
        _brokerCommissionFixedEgpMeta,
        brokerCommissionFixedEgp.isAcceptableOrUnknown(
          data['broker_commission_fixed_egp']!,
          _brokerCommissionFixedEgpMeta,
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
    if (data.containsKey('national_id')) {
      context.handle(
        _nationalIdMeta,
        nationalId.isAcceptableOrUnknown(data['national_id']!, _nationalIdMeta),
      );
    }
    if (data.containsKey('id_front_image')) {
      context.handle(
        _idFrontImageMeta,
        idFrontImage.isAcceptableOrUnknown(
          data['id_front_image']!,
          _idFrontImageMeta,
        ),
      );
    }
    if (data.containsKey('id_back_image')) {
      context.handle(
        _idBackImageMeta,
        idBackImage.isAcceptableOrUnknown(
          data['id_back_image']!,
          _idBackImageMeta,
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
      paymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method'],
      )!,
      brokerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}broker_id'],
      ),
      brokerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}broker_name'],
      ),
      brokerCommissionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}broker_commission_type'],
      )!,
      brokerCommissionPercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}broker_commission_percentage'],
      )!,
      brokerCommissionFixedEgp: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}broker_commission_fixed_egp'],
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
      nationalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}national_id'],
      ),
      idFrontImage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id_front_image'],
      ),
      idBackImage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id_back_image'],
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
  final String paymentMethod;
  final String? brokerId;
  final String? brokerName;
  final String brokerCommissionType;
  final double brokerCommissionPercentage;
  final double brokerCommissionFixedEgp;
  final double? brokerCommissionAmountEgp;
  final DateTime? earlyCheckoutDate;
  final int overstayDays;
  final double overstayFeeEgp;
  final String? nationalId;
  final String? idFrontImage;
  final String? idBackImage;
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
    required this.paymentMethod,
    this.brokerId,
    this.brokerName,
    required this.brokerCommissionType,
    required this.brokerCommissionPercentage,
    required this.brokerCommissionFixedEgp,
    this.brokerCommissionAmountEgp,
    this.earlyCheckoutDate,
    required this.overstayDays,
    required this.overstayFeeEgp,
    this.nationalId,
    this.idFrontImage,
    this.idBackImage,
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
    map['payment_method'] = Variable<String>(paymentMethod);
    if (!nullToAbsent || brokerId != null) {
      map['broker_id'] = Variable<String>(brokerId);
    }
    if (!nullToAbsent || brokerName != null) {
      map['broker_name'] = Variable<String>(brokerName);
    }
    map['broker_commission_type'] = Variable<String>(brokerCommissionType);
    map['broker_commission_percentage'] = Variable<double>(
      brokerCommissionPercentage,
    );
    map['broker_commission_fixed_egp'] = Variable<double>(
      brokerCommissionFixedEgp,
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
    if (!nullToAbsent || nationalId != null) {
      map['national_id'] = Variable<String>(nationalId);
    }
    if (!nullToAbsent || idFrontImage != null) {
      map['id_front_image'] = Variable<String>(idFrontImage);
    }
    if (!nullToAbsent || idBackImage != null) {
      map['id_back_image'] = Variable<String>(idBackImage);
    }
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
      paymentMethod: Value(paymentMethod),
      brokerId: brokerId == null && nullToAbsent
          ? const Value.absent()
          : Value(brokerId),
      brokerName: brokerName == null && nullToAbsent
          ? const Value.absent()
          : Value(brokerName),
      brokerCommissionType: Value(brokerCommissionType),
      brokerCommissionPercentage: Value(brokerCommissionPercentage),
      brokerCommissionFixedEgp: Value(brokerCommissionFixedEgp),
      brokerCommissionAmountEgp:
          brokerCommissionAmountEgp == null && nullToAbsent
          ? const Value.absent()
          : Value(brokerCommissionAmountEgp),
      earlyCheckoutDate: earlyCheckoutDate == null && nullToAbsent
          ? const Value.absent()
          : Value(earlyCheckoutDate),
      overstayDays: Value(overstayDays),
      overstayFeeEgp: Value(overstayFeeEgp),
      nationalId: nationalId == null && nullToAbsent
          ? const Value.absent()
          : Value(nationalId),
      idFrontImage: idFrontImage == null && nullToAbsent
          ? const Value.absent()
          : Value(idFrontImage),
      idBackImage: idBackImage == null && nullToAbsent
          ? const Value.absent()
          : Value(idBackImage),
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
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      brokerId: serializer.fromJson<String?>(json['brokerId']),
      brokerName: serializer.fromJson<String?>(json['brokerName']),
      brokerCommissionType: serializer.fromJson<String>(
        json['brokerCommissionType'],
      ),
      brokerCommissionPercentage: serializer.fromJson<double>(
        json['brokerCommissionPercentage'],
      ),
      brokerCommissionFixedEgp: serializer.fromJson<double>(
        json['brokerCommissionFixedEgp'],
      ),
      brokerCommissionAmountEgp: serializer.fromJson<double?>(
        json['brokerCommissionAmountEgp'],
      ),
      earlyCheckoutDate: serializer.fromJson<DateTime?>(
        json['earlyCheckoutDate'],
      ),
      overstayDays: serializer.fromJson<int>(json['overstayDays']),
      overstayFeeEgp: serializer.fromJson<double>(json['overstayFeeEgp']),
      nationalId: serializer.fromJson<String?>(json['nationalId']),
      idFrontImage: serializer.fromJson<String?>(json['idFrontImage']),
      idBackImage: serializer.fromJson<String?>(json['idBackImage']),
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
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'brokerId': serializer.toJson<String?>(brokerId),
      'brokerName': serializer.toJson<String?>(brokerName),
      'brokerCommissionType': serializer.toJson<String>(brokerCommissionType),
      'brokerCommissionPercentage': serializer.toJson<double>(
        brokerCommissionPercentage,
      ),
      'brokerCommissionFixedEgp': serializer.toJson<double>(
        brokerCommissionFixedEgp,
      ),
      'brokerCommissionAmountEgp': serializer.toJson<double?>(
        brokerCommissionAmountEgp,
      ),
      'earlyCheckoutDate': serializer.toJson<DateTime?>(earlyCheckoutDate),
      'overstayDays': serializer.toJson<int>(overstayDays),
      'overstayFeeEgp': serializer.toJson<double>(overstayFeeEgp),
      'nationalId': serializer.toJson<String?>(nationalId),
      'idFrontImage': serializer.toJson<String?>(idFrontImage),
      'idBackImage': serializer.toJson<String?>(idBackImage),
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
    String? paymentMethod,
    Value<String?> brokerId = const Value.absent(),
    Value<String?> brokerName = const Value.absent(),
    String? brokerCommissionType,
    double? brokerCommissionPercentage,
    double? brokerCommissionFixedEgp,
    Value<double?> brokerCommissionAmountEgp = const Value.absent(),
    Value<DateTime?> earlyCheckoutDate = const Value.absent(),
    int? overstayDays,
    double? overstayFeeEgp,
    Value<String?> nationalId = const Value.absent(),
    Value<String?> idFrontImage = const Value.absent(),
    Value<String?> idBackImage = const Value.absent(),
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
    paymentMethod: paymentMethod ?? this.paymentMethod,
    brokerId: brokerId.present ? brokerId.value : this.brokerId,
    brokerName: brokerName.present ? brokerName.value : this.brokerName,
    brokerCommissionType: brokerCommissionType ?? this.brokerCommissionType,
    brokerCommissionPercentage:
        brokerCommissionPercentage ?? this.brokerCommissionPercentage,
    brokerCommissionFixedEgp:
        brokerCommissionFixedEgp ?? this.brokerCommissionFixedEgp,
    brokerCommissionAmountEgp: brokerCommissionAmountEgp.present
        ? brokerCommissionAmountEgp.value
        : this.brokerCommissionAmountEgp,
    earlyCheckoutDate: earlyCheckoutDate.present
        ? earlyCheckoutDate.value
        : this.earlyCheckoutDate,
    overstayDays: overstayDays ?? this.overstayDays,
    overstayFeeEgp: overstayFeeEgp ?? this.overstayFeeEgp,
    nationalId: nationalId.present ? nationalId.value : this.nationalId,
    idFrontImage: idFrontImage.present ? idFrontImage.value : this.idFrontImage,
    idBackImage: idBackImage.present ? idBackImage.value : this.idBackImage,
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
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      brokerId: data.brokerId.present ? data.brokerId.value : this.brokerId,
      brokerName: data.brokerName.present
          ? data.brokerName.value
          : this.brokerName,
      brokerCommissionType: data.brokerCommissionType.present
          ? data.brokerCommissionType.value
          : this.brokerCommissionType,
      brokerCommissionPercentage: data.brokerCommissionPercentage.present
          ? data.brokerCommissionPercentage.value
          : this.brokerCommissionPercentage,
      brokerCommissionFixedEgp: data.brokerCommissionFixedEgp.present
          ? data.brokerCommissionFixedEgp.value
          : this.brokerCommissionFixedEgp,
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
      nationalId: data.nationalId.present
          ? data.nationalId.value
          : this.nationalId,
      idFrontImage: data.idFrontImage.present
          ? data.idFrontImage.value
          : this.idFrontImage,
      idBackImage: data.idBackImage.present
          ? data.idBackImage.value
          : this.idBackImage,
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
          ..write('paymentMethod: $paymentMethod, ')
          ..write('brokerId: $brokerId, ')
          ..write('brokerName: $brokerName, ')
          ..write('brokerCommissionType: $brokerCommissionType, ')
          ..write('brokerCommissionPercentage: $brokerCommissionPercentage, ')
          ..write('brokerCommissionFixedEgp: $brokerCommissionFixedEgp, ')
          ..write('brokerCommissionAmountEgp: $brokerCommissionAmountEgp, ')
          ..write('earlyCheckoutDate: $earlyCheckoutDate, ')
          ..write('overstayDays: $overstayDays, ')
          ..write('overstayFeeEgp: $overstayFeeEgp, ')
          ..write('nationalId: $nationalId, ')
          ..write('idFrontImage: $idFrontImage, ')
          ..write('idBackImage: $idBackImage, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
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
    paymentMethod,
    brokerId,
    brokerName,
    brokerCommissionType,
    brokerCommissionPercentage,
    brokerCommissionFixedEgp,
    brokerCommissionAmountEgp,
    earlyCheckoutDate,
    overstayDays,
    overstayFeeEgp,
    nationalId,
    idFrontImage,
    idBackImage,
    createdAt,
    updatedAt,
  ]);
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
          other.paymentMethod == this.paymentMethod &&
          other.brokerId == this.brokerId &&
          other.brokerName == this.brokerName &&
          other.brokerCommissionType == this.brokerCommissionType &&
          other.brokerCommissionPercentage == this.brokerCommissionPercentage &&
          other.brokerCommissionFixedEgp == this.brokerCommissionFixedEgp &&
          other.brokerCommissionAmountEgp == this.brokerCommissionAmountEgp &&
          other.earlyCheckoutDate == this.earlyCheckoutDate &&
          other.overstayDays == this.overstayDays &&
          other.overstayFeeEgp == this.overstayFeeEgp &&
          other.nationalId == this.nationalId &&
          other.idFrontImage == this.idFrontImage &&
          other.idBackImage == this.idBackImage &&
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
  final Value<String> paymentMethod;
  final Value<String?> brokerId;
  final Value<String?> brokerName;
  final Value<String> brokerCommissionType;
  final Value<double> brokerCommissionPercentage;
  final Value<double> brokerCommissionFixedEgp;
  final Value<double?> brokerCommissionAmountEgp;
  final Value<DateTime?> earlyCheckoutDate;
  final Value<int> overstayDays;
  final Value<double> overstayFeeEgp;
  final Value<String?> nationalId;
  final Value<String?> idFrontImage;
  final Value<String?> idBackImage;
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
    this.paymentMethod = const Value.absent(),
    this.brokerId = const Value.absent(),
    this.brokerName = const Value.absent(),
    this.brokerCommissionType = const Value.absent(),
    this.brokerCommissionPercentage = const Value.absent(),
    this.brokerCommissionFixedEgp = const Value.absent(),
    this.brokerCommissionAmountEgp = const Value.absent(),
    this.earlyCheckoutDate = const Value.absent(),
    this.overstayDays = const Value.absent(),
    this.overstayFeeEgp = const Value.absent(),
    this.nationalId = const Value.absent(),
    this.idFrontImage = const Value.absent(),
    this.idBackImage = const Value.absent(),
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
    this.paymentMethod = const Value.absent(),
    this.brokerId = const Value.absent(),
    this.brokerName = const Value.absent(),
    this.brokerCommissionType = const Value.absent(),
    this.brokerCommissionPercentage = const Value.absent(),
    this.brokerCommissionFixedEgp = const Value.absent(),
    this.brokerCommissionAmountEgp = const Value.absent(),
    this.earlyCheckoutDate = const Value.absent(),
    this.overstayDays = const Value.absent(),
    this.overstayFeeEgp = const Value.absent(),
    this.nationalId = const Value.absent(),
    this.idFrontImage = const Value.absent(),
    this.idBackImage = const Value.absent(),
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
    Expression<String>? paymentMethod,
    Expression<String>? brokerId,
    Expression<String>? brokerName,
    Expression<String>? brokerCommissionType,
    Expression<double>? brokerCommissionPercentage,
    Expression<double>? brokerCommissionFixedEgp,
    Expression<double>? brokerCommissionAmountEgp,
    Expression<DateTime>? earlyCheckoutDate,
    Expression<int>? overstayDays,
    Expression<double>? overstayFeeEgp,
    Expression<String>? nationalId,
    Expression<String>? idFrontImage,
    Expression<String>? idBackImage,
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
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (brokerId != null) 'broker_id': brokerId,
      if (brokerName != null) 'broker_name': brokerName,
      if (brokerCommissionType != null)
        'broker_commission_type': brokerCommissionType,
      if (brokerCommissionPercentage != null)
        'broker_commission_percentage': brokerCommissionPercentage,
      if (brokerCommissionFixedEgp != null)
        'broker_commission_fixed_egp': brokerCommissionFixedEgp,
      if (brokerCommissionAmountEgp != null)
        'broker_commission_amount_egp': brokerCommissionAmountEgp,
      if (earlyCheckoutDate != null) 'early_checkout_date': earlyCheckoutDate,
      if (overstayDays != null) 'overstay_days': overstayDays,
      if (overstayFeeEgp != null) 'overstay_fee_egp': overstayFeeEgp,
      if (nationalId != null) 'national_id': nationalId,
      if (idFrontImage != null) 'id_front_image': idFrontImage,
      if (idBackImage != null) 'id_back_image': idBackImage,
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
    Value<String>? paymentMethod,
    Value<String?>? brokerId,
    Value<String?>? brokerName,
    Value<String>? brokerCommissionType,
    Value<double>? brokerCommissionPercentage,
    Value<double>? brokerCommissionFixedEgp,
    Value<double?>? brokerCommissionAmountEgp,
    Value<DateTime?>? earlyCheckoutDate,
    Value<int>? overstayDays,
    Value<double>? overstayFeeEgp,
    Value<String?>? nationalId,
    Value<String?>? idFrontImage,
    Value<String?>? idBackImage,
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
      paymentMethod: paymentMethod ?? this.paymentMethod,
      brokerId: brokerId ?? this.brokerId,
      brokerName: brokerName ?? this.brokerName,
      brokerCommissionType: brokerCommissionType ?? this.brokerCommissionType,
      brokerCommissionPercentage:
          brokerCommissionPercentage ?? this.brokerCommissionPercentage,
      brokerCommissionFixedEgp:
          brokerCommissionFixedEgp ?? this.brokerCommissionFixedEgp,
      brokerCommissionAmountEgp:
          brokerCommissionAmountEgp ?? this.brokerCommissionAmountEgp,
      earlyCheckoutDate: earlyCheckoutDate ?? this.earlyCheckoutDate,
      overstayDays: overstayDays ?? this.overstayDays,
      overstayFeeEgp: overstayFeeEgp ?? this.overstayFeeEgp,
      nationalId: nationalId ?? this.nationalId,
      idFrontImage: idFrontImage ?? this.idFrontImage,
      idBackImage: idBackImage ?? this.idBackImage,
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
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (brokerId.present) {
      map['broker_id'] = Variable<String>(brokerId.value);
    }
    if (brokerName.present) {
      map['broker_name'] = Variable<String>(brokerName.value);
    }
    if (brokerCommissionType.present) {
      map['broker_commission_type'] = Variable<String>(
        brokerCommissionType.value,
      );
    }
    if (brokerCommissionPercentage.present) {
      map['broker_commission_percentage'] = Variable<double>(
        brokerCommissionPercentage.value,
      );
    }
    if (brokerCommissionFixedEgp.present) {
      map['broker_commission_fixed_egp'] = Variable<double>(
        brokerCommissionFixedEgp.value,
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
    if (nationalId.present) {
      map['national_id'] = Variable<String>(nationalId.value);
    }
    if (idFrontImage.present) {
      map['id_front_image'] = Variable<String>(idFrontImage.value);
    }
    if (idBackImage.present) {
      map['id_back_image'] = Variable<String>(idBackImage.value);
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
          ..write('paymentMethod: $paymentMethod, ')
          ..write('brokerId: $brokerId, ')
          ..write('brokerName: $brokerName, ')
          ..write('brokerCommissionType: $brokerCommissionType, ')
          ..write('brokerCommissionPercentage: $brokerCommissionPercentage, ')
          ..write('brokerCommissionFixedEgp: $brokerCommissionFixedEgp, ')
          ..write('brokerCommissionAmountEgp: $brokerCommissionAmountEgp, ')
          ..write('earlyCheckoutDate: $earlyCheckoutDate, ')
          ..write('overstayDays: $overstayDays, ')
          ..write('overstayFeeEgp: $overstayFeeEgp, ')
          ..write('nationalId: $nationalId, ')
          ..write('idFrontImage: $idFrontImage, ')
          ..write('idBackImage: $idBackImage, ')
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
  static const VerificationMeta _contractTypeMeta = const VerificationMeta(
    'contractType',
  );
  @override
  late final GeneratedColumn<String> contractType = GeneratedColumn<String>(
    'contract_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('student'),
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
  static const VerificationMeta _isElectricityOnStudentMeta =
      const VerificationMeta('isElectricityOnStudent');
  @override
  late final GeneratedColumn<bool> isElectricityOnStudent =
      GeneratedColumn<bool>(
        'is_electricity_on_student',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_electricity_on_student" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _isGasOnStudentMeta = const VerificationMeta(
    'isGasOnStudent',
  );
  @override
  late final GeneratedColumn<bool> isGasOnStudent = GeneratedColumn<bool>(
    'is_gas_on_student',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_gas_on_student" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isWaterOnStudentMeta = const VerificationMeta(
    'isWaterOnStudent',
  );
  @override
  late final GeneratedColumn<bool> isWaterOnStudent = GeneratedColumn<bool>(
    'is_water_on_student',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_water_on_student" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _roommatesMeta = const VerificationMeta(
    'roommates',
  );
  @override
  late final GeneratedColumn<String> roommates = GeneratedColumn<String>(
    'roommates',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nationalIdMeta = const VerificationMeta(
    'nationalId',
  );
  @override
  late final GeneratedColumn<String> nationalId = GeneratedColumn<String>(
    'national_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idFrontImageMeta = const VerificationMeta(
    'idFrontImage',
  );
  @override
  late final GeneratedColumn<String> idFrontImage = GeneratedColumn<String>(
    'id_front_image',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idBackImageMeta = const VerificationMeta(
    'idBackImage',
  );
  @override
  late final GeneratedColumn<String> idBackImage = GeneratedColumn<String>(
    'id_back_image',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contractFrontImageMeta =
      const VerificationMeta('contractFrontImage');
  @override
  late final GeneratedColumn<String> contractFrontImage =
      GeneratedColumn<String>(
        'contract_front_image',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _contractBackImageMeta = const VerificationMeta(
    'contractBackImage',
  );
  @override
  late final GeneratedColumn<String> contractBackImage =
      GeneratedColumn<String>(
        'contract_back_image',
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
    contractType,
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
    isElectricityOnStudent,
    isGasOnStudent,
    isWaterOnStudent,
    roommates,
    nationalId,
    idFrontImage,
    idBackImage,
    contractFrontImage,
    contractBackImage,
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
    if (data.containsKey('contract_type')) {
      context.handle(
        _contractTypeMeta,
        contractType.isAcceptableOrUnknown(
          data['contract_type']!,
          _contractTypeMeta,
        ),
      );
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
    if (data.containsKey('is_electricity_on_student')) {
      context.handle(
        _isElectricityOnStudentMeta,
        isElectricityOnStudent.isAcceptableOrUnknown(
          data['is_electricity_on_student']!,
          _isElectricityOnStudentMeta,
        ),
      );
    }
    if (data.containsKey('is_gas_on_student')) {
      context.handle(
        _isGasOnStudentMeta,
        isGasOnStudent.isAcceptableOrUnknown(
          data['is_gas_on_student']!,
          _isGasOnStudentMeta,
        ),
      );
    }
    if (data.containsKey('is_water_on_student')) {
      context.handle(
        _isWaterOnStudentMeta,
        isWaterOnStudent.isAcceptableOrUnknown(
          data['is_water_on_student']!,
          _isWaterOnStudentMeta,
        ),
      );
    }
    if (data.containsKey('roommates')) {
      context.handle(
        _roommatesMeta,
        roommates.isAcceptableOrUnknown(data['roommates']!, _roommatesMeta),
      );
    }
    if (data.containsKey('national_id')) {
      context.handle(
        _nationalIdMeta,
        nationalId.isAcceptableOrUnknown(data['national_id']!, _nationalIdMeta),
      );
    }
    if (data.containsKey('id_front_image')) {
      context.handle(
        _idFrontImageMeta,
        idFrontImage.isAcceptableOrUnknown(
          data['id_front_image']!,
          _idFrontImageMeta,
        ),
      );
    }
    if (data.containsKey('id_back_image')) {
      context.handle(
        _idBackImageMeta,
        idBackImage.isAcceptableOrUnknown(
          data['id_back_image']!,
          _idBackImageMeta,
        ),
      );
    }
    if (data.containsKey('contract_front_image')) {
      context.handle(
        _contractFrontImageMeta,
        contractFrontImage.isAcceptableOrUnknown(
          data['contract_front_image']!,
          _contractFrontImageMeta,
        ),
      );
    }
    if (data.containsKey('contract_back_image')) {
      context.handle(
        _contractBackImageMeta,
        contractBackImage.isAcceptableOrUnknown(
          data['contract_back_image']!,
          _contractBackImageMeta,
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
      contractType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contract_type'],
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
      isElectricityOnStudent: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_electricity_on_student'],
      )!,
      isGasOnStudent: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_gas_on_student'],
      )!,
      isWaterOnStudent: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_water_on_student'],
      )!,
      roommates: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}roommates'],
      ),
      nationalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}national_id'],
      ),
      idFrontImage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id_front_image'],
      ),
      idBackImage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id_back_image'],
      ),
      contractFrontImage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contract_front_image'],
      ),
      contractBackImage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contract_back_image'],
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
  final String contractType;
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
  final bool isElectricityOnStudent;
  final bool isGasOnStudent;
  final bool isWaterOnStudent;
  final String? roommates;
  final String? nationalId;
  final String? idFrontImage;
  final String? idBackImage;
  final String? contractFrontImage;
  final String? contractBackImage;
  final DateTime createdAt;
  final DateTime updatedAt;
  const WinterContract({
    required this.syncStatus,
    required this.lastModifiedLocal,
    required this.id,
    required this.apartmentId,
    required this.contractType,
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
    required this.isElectricityOnStudent,
    required this.isGasOnStudent,
    required this.isWaterOnStudent,
    this.roommates,
    this.nationalId,
    this.idFrontImage,
    this.idBackImage,
    this.contractFrontImage,
    this.contractBackImage,
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
    map['contract_type'] = Variable<String>(contractType);
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
    map['is_electricity_on_student'] = Variable<bool>(isElectricityOnStudent);
    map['is_gas_on_student'] = Variable<bool>(isGasOnStudent);
    map['is_water_on_student'] = Variable<bool>(isWaterOnStudent);
    if (!nullToAbsent || roommates != null) {
      map['roommates'] = Variable<String>(roommates);
    }
    if (!nullToAbsent || nationalId != null) {
      map['national_id'] = Variable<String>(nationalId);
    }
    if (!nullToAbsent || idFrontImage != null) {
      map['id_front_image'] = Variable<String>(idFrontImage);
    }
    if (!nullToAbsent || idBackImage != null) {
      map['id_back_image'] = Variable<String>(idBackImage);
    }
    if (!nullToAbsent || contractFrontImage != null) {
      map['contract_front_image'] = Variable<String>(contractFrontImage);
    }
    if (!nullToAbsent || contractBackImage != null) {
      map['contract_back_image'] = Variable<String>(contractBackImage);
    }
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
      contractType: Value(contractType),
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
      isElectricityOnStudent: Value(isElectricityOnStudent),
      isGasOnStudent: Value(isGasOnStudent),
      isWaterOnStudent: Value(isWaterOnStudent),
      roommates: roommates == null && nullToAbsent
          ? const Value.absent()
          : Value(roommates),
      nationalId: nationalId == null && nullToAbsent
          ? const Value.absent()
          : Value(nationalId),
      idFrontImage: idFrontImage == null && nullToAbsent
          ? const Value.absent()
          : Value(idFrontImage),
      idBackImage: idBackImage == null && nullToAbsent
          ? const Value.absent()
          : Value(idBackImage),
      contractFrontImage: contractFrontImage == null && nullToAbsent
          ? const Value.absent()
          : Value(contractFrontImage),
      contractBackImage: contractBackImage == null && nullToAbsent
          ? const Value.absent()
          : Value(contractBackImage),
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
      contractType: serializer.fromJson<String>(json['contractType']),
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
      isElectricityOnStudent: serializer.fromJson<bool>(
        json['isElectricityOnStudent'],
      ),
      isGasOnStudent: serializer.fromJson<bool>(json['isGasOnStudent']),
      isWaterOnStudent: serializer.fromJson<bool>(json['isWaterOnStudent']),
      roommates: serializer.fromJson<String?>(json['roommates']),
      nationalId: serializer.fromJson<String?>(json['nationalId']),
      idFrontImage: serializer.fromJson<String?>(json['idFrontImage']),
      idBackImage: serializer.fromJson<String?>(json['idBackImage']),
      contractFrontImage: serializer.fromJson<String?>(
        json['contractFrontImage'],
      ),
      contractBackImage: serializer.fromJson<String?>(
        json['contractBackImage'],
      ),
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
      'contractType': serializer.toJson<String>(contractType),
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
      'isElectricityOnStudent': serializer.toJson<bool>(isElectricityOnStudent),
      'isGasOnStudent': serializer.toJson<bool>(isGasOnStudent),
      'isWaterOnStudent': serializer.toJson<bool>(isWaterOnStudent),
      'roommates': serializer.toJson<String?>(roommates),
      'nationalId': serializer.toJson<String?>(nationalId),
      'idFrontImage': serializer.toJson<String?>(idFrontImage),
      'idBackImage': serializer.toJson<String?>(idBackImage),
      'contractFrontImage': serializer.toJson<String?>(contractFrontImage),
      'contractBackImage': serializer.toJson<String?>(contractBackImage),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WinterContract copyWith({
    SyncStatus? syncStatus,
    DateTime? lastModifiedLocal,
    String? id,
    String? apartmentId,
    String? contractType,
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
    bool? isElectricityOnStudent,
    bool? isGasOnStudent,
    bool? isWaterOnStudent,
    Value<String?> roommates = const Value.absent(),
    Value<String?> nationalId = const Value.absent(),
    Value<String?> idFrontImage = const Value.absent(),
    Value<String?> idBackImage = const Value.absent(),
    Value<String?> contractFrontImage = const Value.absent(),
    Value<String?> contractBackImage = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => WinterContract(
    syncStatus: syncStatus ?? this.syncStatus,
    lastModifiedLocal: lastModifiedLocal ?? this.lastModifiedLocal,
    id: id ?? this.id,
    apartmentId: apartmentId ?? this.apartmentId,
    contractType: contractType ?? this.contractType,
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
    isElectricityOnStudent:
        isElectricityOnStudent ?? this.isElectricityOnStudent,
    isGasOnStudent: isGasOnStudent ?? this.isGasOnStudent,
    isWaterOnStudent: isWaterOnStudent ?? this.isWaterOnStudent,
    roommates: roommates.present ? roommates.value : this.roommates,
    nationalId: nationalId.present ? nationalId.value : this.nationalId,
    idFrontImage: idFrontImage.present ? idFrontImage.value : this.idFrontImage,
    idBackImage: idBackImage.present ? idBackImage.value : this.idBackImage,
    contractFrontImage: contractFrontImage.present
        ? contractFrontImage.value
        : this.contractFrontImage,
    contractBackImage: contractBackImage.present
        ? contractBackImage.value
        : this.contractBackImage,
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
      contractType: data.contractType.present
          ? data.contractType.value
          : this.contractType,
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
      isElectricityOnStudent: data.isElectricityOnStudent.present
          ? data.isElectricityOnStudent.value
          : this.isElectricityOnStudent,
      isGasOnStudent: data.isGasOnStudent.present
          ? data.isGasOnStudent.value
          : this.isGasOnStudent,
      isWaterOnStudent: data.isWaterOnStudent.present
          ? data.isWaterOnStudent.value
          : this.isWaterOnStudent,
      roommates: data.roommates.present ? data.roommates.value : this.roommates,
      nationalId: data.nationalId.present
          ? data.nationalId.value
          : this.nationalId,
      idFrontImage: data.idFrontImage.present
          ? data.idFrontImage.value
          : this.idFrontImage,
      idBackImage: data.idBackImage.present
          ? data.idBackImage.value
          : this.idBackImage,
      contractFrontImage: data.contractFrontImage.present
          ? data.contractFrontImage.value
          : this.contractFrontImage,
      contractBackImage: data.contractBackImage.present
          ? data.contractBackImage.value
          : this.contractBackImage,
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
          ..write('contractType: $contractType, ')
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
          ..write('isElectricityOnStudent: $isElectricityOnStudent, ')
          ..write('isGasOnStudent: $isGasOnStudent, ')
          ..write('isWaterOnStudent: $isWaterOnStudent, ')
          ..write('roommates: $roommates, ')
          ..write('nationalId: $nationalId, ')
          ..write('idFrontImage: $idFrontImage, ')
          ..write('idBackImage: $idBackImage, ')
          ..write('contractFrontImage: $contractFrontImage, ')
          ..write('contractBackImage: $contractBackImage, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    syncStatus,
    lastModifiedLocal,
    id,
    apartmentId,
    contractType,
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
    isElectricityOnStudent,
    isGasOnStudent,
    isWaterOnStudent,
    roommates,
    nationalId,
    idFrontImage,
    idBackImage,
    contractFrontImage,
    contractBackImage,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WinterContract &&
          other.syncStatus == this.syncStatus &&
          other.lastModifiedLocal == this.lastModifiedLocal &&
          other.id == this.id &&
          other.apartmentId == this.apartmentId &&
          other.contractType == this.contractType &&
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
          other.isElectricityOnStudent == this.isElectricityOnStudent &&
          other.isGasOnStudent == this.isGasOnStudent &&
          other.isWaterOnStudent == this.isWaterOnStudent &&
          other.roommates == this.roommates &&
          other.nationalId == this.nationalId &&
          other.idFrontImage == this.idFrontImage &&
          other.idBackImage == this.idBackImage &&
          other.contractFrontImage == this.contractFrontImage &&
          other.contractBackImage == this.contractBackImage &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WinterContractsCompanion extends UpdateCompanion<WinterContract> {
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> lastModifiedLocal;
  final Value<String> id;
  final Value<String> apartmentId;
  final Value<String> contractType;
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
  final Value<bool> isElectricityOnStudent;
  final Value<bool> isGasOnStudent;
  final Value<bool> isWaterOnStudent;
  final Value<String?> roommates;
  final Value<String?> nationalId;
  final Value<String?> idFrontImage;
  final Value<String?> idBackImage;
  final Value<String?> contractFrontImage;
  final Value<String?> contractBackImage;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const WinterContractsCompanion({
    this.syncStatus = const Value.absent(),
    this.lastModifiedLocal = const Value.absent(),
    this.id = const Value.absent(),
    this.apartmentId = const Value.absent(),
    this.contractType = const Value.absent(),
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
    this.isElectricityOnStudent = const Value.absent(),
    this.isGasOnStudent = const Value.absent(),
    this.isWaterOnStudent = const Value.absent(),
    this.roommates = const Value.absent(),
    this.nationalId = const Value.absent(),
    this.idFrontImage = const Value.absent(),
    this.idBackImage = const Value.absent(),
    this.contractFrontImage = const Value.absent(),
    this.contractBackImage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WinterContractsCompanion.insert({
    this.syncStatus = const Value.absent(),
    this.lastModifiedLocal = const Value.absent(),
    required String id,
    required String apartmentId,
    this.contractType = const Value.absent(),
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
    this.isElectricityOnStudent = const Value.absent(),
    this.isGasOnStudent = const Value.absent(),
    this.isWaterOnStudent = const Value.absent(),
    this.roommates = const Value.absent(),
    this.nationalId = const Value.absent(),
    this.idFrontImage = const Value.absent(),
    this.idBackImage = const Value.absent(),
    this.contractFrontImage = const Value.absent(),
    this.contractBackImage = const Value.absent(),
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
    Expression<String>? contractType,
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
    Expression<bool>? isElectricityOnStudent,
    Expression<bool>? isGasOnStudent,
    Expression<bool>? isWaterOnStudent,
    Expression<String>? roommates,
    Expression<String>? nationalId,
    Expression<String>? idFrontImage,
    Expression<String>? idBackImage,
    Expression<String>? contractFrontImage,
    Expression<String>? contractBackImage,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastModifiedLocal != null) 'last_modified_local': lastModifiedLocal,
      if (id != null) 'id': id,
      if (apartmentId != null) 'apartment_id': apartmentId,
      if (contractType != null) 'contract_type': contractType,
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
      if (isElectricityOnStudent != null)
        'is_electricity_on_student': isElectricityOnStudent,
      if (isGasOnStudent != null) 'is_gas_on_student': isGasOnStudent,
      if (isWaterOnStudent != null) 'is_water_on_student': isWaterOnStudent,
      if (roommates != null) 'roommates': roommates,
      if (nationalId != null) 'national_id': nationalId,
      if (idFrontImage != null) 'id_front_image': idFrontImage,
      if (idBackImage != null) 'id_back_image': idBackImage,
      if (contractFrontImage != null)
        'contract_front_image': contractFrontImage,
      if (contractBackImage != null) 'contract_back_image': contractBackImage,
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
    Value<String>? contractType,
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
    Value<bool>? isElectricityOnStudent,
    Value<bool>? isGasOnStudent,
    Value<bool>? isWaterOnStudent,
    Value<String?>? roommates,
    Value<String?>? nationalId,
    Value<String?>? idFrontImage,
    Value<String?>? idBackImage,
    Value<String?>? contractFrontImage,
    Value<String?>? contractBackImage,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return WinterContractsCompanion(
      syncStatus: syncStatus ?? this.syncStatus,
      lastModifiedLocal: lastModifiedLocal ?? this.lastModifiedLocal,
      id: id ?? this.id,
      apartmentId: apartmentId ?? this.apartmentId,
      contractType: contractType ?? this.contractType,
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
      isElectricityOnStudent:
          isElectricityOnStudent ?? this.isElectricityOnStudent,
      isGasOnStudent: isGasOnStudent ?? this.isGasOnStudent,
      isWaterOnStudent: isWaterOnStudent ?? this.isWaterOnStudent,
      roommates: roommates ?? this.roommates,
      nationalId: nationalId ?? this.nationalId,
      idFrontImage: idFrontImage ?? this.idFrontImage,
      idBackImage: idBackImage ?? this.idBackImage,
      contractFrontImage: contractFrontImage ?? this.contractFrontImage,
      contractBackImage: contractBackImage ?? this.contractBackImage,
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
    if (contractType.present) {
      map['contract_type'] = Variable<String>(contractType.value);
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
    if (isElectricityOnStudent.present) {
      map['is_electricity_on_student'] = Variable<bool>(
        isElectricityOnStudent.value,
      );
    }
    if (isGasOnStudent.present) {
      map['is_gas_on_student'] = Variable<bool>(isGasOnStudent.value);
    }
    if (isWaterOnStudent.present) {
      map['is_water_on_student'] = Variable<bool>(isWaterOnStudent.value);
    }
    if (roommates.present) {
      map['roommates'] = Variable<String>(roommates.value);
    }
    if (nationalId.present) {
      map['national_id'] = Variable<String>(nationalId.value);
    }
    if (idFrontImage.present) {
      map['id_front_image'] = Variable<String>(idFrontImage.value);
    }
    if (idBackImage.present) {
      map['id_back_image'] = Variable<String>(idBackImage.value);
    }
    if (contractFrontImage.present) {
      map['contract_front_image'] = Variable<String>(contractFrontImage.value);
    }
    if (contractBackImage.present) {
      map['contract_back_image'] = Variable<String>(contractBackImage.value);
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
          ..write('contractType: $contractType, ')
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
          ..write('isElectricityOnStudent: $isElectricityOnStudent, ')
          ..write('isGasOnStudent: $isGasOnStudent, ')
          ..write('isWaterOnStudent: $isWaterOnStudent, ')
          ..write('roommates: $roommates, ')
          ..write('nationalId: $nationalId, ')
          ..write('idFrontImage: $idFrontImage, ')
          ..write('idBackImage: $idBackImage, ')
          ..write('contractFrontImage: $contractFrontImage, ')
          ..write('contractBackImage: $contractBackImage, ')
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
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('cash'),
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
    paymentMethod,
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
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
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
      paymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method'],
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
  final String paymentMethod;
  final String? receiptUrl;
  final DateTime createdAt;
  const WinterPayment({
    required this.syncStatus,
    required this.lastModifiedLocal,
    required this.id,
    required this.contractId,
    required this.amountEgp,
    required this.paymentDate,
    required this.paymentMethod,
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
    map['payment_method'] = Variable<String>(paymentMethod);
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
      paymentMethod: Value(paymentMethod),
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
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
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
      'paymentMethod': serializer.toJson<String>(paymentMethod),
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
    String? paymentMethod,
    Value<String?> receiptUrl = const Value.absent(),
    DateTime? createdAt,
  }) => WinterPayment(
    syncStatus: syncStatus ?? this.syncStatus,
    lastModifiedLocal: lastModifiedLocal ?? this.lastModifiedLocal,
    id: id ?? this.id,
    contractId: contractId ?? this.contractId,
    amountEgp: amountEgp ?? this.amountEgp,
    paymentDate: paymentDate ?? this.paymentDate,
    paymentMethod: paymentMethod ?? this.paymentMethod,
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
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
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
          ..write('paymentMethod: $paymentMethod, ')
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
    paymentMethod,
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
          other.paymentMethod == this.paymentMethod &&
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
  final Value<String> paymentMethod;
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
    this.paymentMethod = const Value.absent(),
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
    this.paymentMethod = const Value.absent(),
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
    Expression<String>? paymentMethod,
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
      if (paymentMethod != null) 'payment_method': paymentMethod,
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
    Value<String>? paymentMethod,
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
      paymentMethod: paymentMethod ?? this.paymentMethod,
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
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
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
          ..write('paymentMethod: $paymentMethod, ')
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
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('cash'),
  );
  static const VerificationMeta _seasonMeta = const VerificationMeta('season');
  @override
  late final GeneratedColumn<String> season = GeneratedColumn<String>(
    'season',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('all'),
  );
  static const VerificationMeta _discountEgpMeta = const VerificationMeta(
    'discountEgp',
  );
  @override
  late final GeneratedColumn<double> discountEgp = GeneratedColumn<double>(
    'discount_egp',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _discountReasonMeta = const VerificationMeta(
    'discountReason',
  );
  @override
  late final GeneratedColumn<String> discountReason = GeneratedColumn<String>(
    'discount_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    paymentMethod,
    season,
    discountEgp,
    discountReason,
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
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    }
    if (data.containsKey('season')) {
      context.handle(
        _seasonMeta,
        season.isAcceptableOrUnknown(data['season']!, _seasonMeta),
      );
    }
    if (data.containsKey('discount_egp')) {
      context.handle(
        _discountEgpMeta,
        discountEgp.isAcceptableOrUnknown(
          data['discount_egp']!,
          _discountEgpMeta,
        ),
      );
    }
    if (data.containsKey('discount_reason')) {
      context.handle(
        _discountReasonMeta,
        discountReason.isAcceptableOrUnknown(
          data['discount_reason']!,
          _discountReasonMeta,
        ),
      );
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
      paymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method'],
      )!,
      season: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}season'],
      )!,
      discountEgp: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discount_egp'],
      )!,
      discountReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}discount_reason'],
      ),
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
  final String paymentMethod;
  final String season;
  final double discountEgp;
  final String? discountReason;
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
    required this.paymentMethod,
    required this.season,
    required this.discountEgp,
    this.discountReason,
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
    map['payment_method'] = Variable<String>(paymentMethod);
    map['season'] = Variable<String>(season);
    map['discount_egp'] = Variable<double>(discountEgp);
    if (!nullToAbsent || discountReason != null) {
      map['discount_reason'] = Variable<String>(discountReason);
    }
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
      paymentMethod: Value(paymentMethod),
      season: Value(season),
      discountEgp: Value(discountEgp),
      discountReason: discountReason == null && nullToAbsent
          ? const Value.absent()
          : Value(discountReason),
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
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      season: serializer.fromJson<String>(json['season']),
      discountEgp: serializer.fromJson<double>(json['discountEgp']),
      discountReason: serializer.fromJson<String?>(json['discountReason']),
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
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'season': serializer.toJson<String>(season),
      'discountEgp': serializer.toJson<double>(discountEgp),
      'discountReason': serializer.toJson<String?>(discountReason),
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
    String? paymentMethod,
    String? season,
    double? discountEgp,
    Value<String?> discountReason = const Value.absent(),
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
    paymentMethod: paymentMethod ?? this.paymentMethod,
    season: season ?? this.season,
    discountEgp: discountEgp ?? this.discountEgp,
    discountReason: discountReason.present
        ? discountReason.value
        : this.discountReason,
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
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      season: data.season.present ? data.season.value : this.season,
      discountEgp: data.discountEgp.present
          ? data.discountEgp.value
          : this.discountEgp,
      discountReason: data.discountReason.present
          ? data.discountReason.value
          : this.discountReason,
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
          ..write('paymentMethod: $paymentMethod, ')
          ..write('season: $season, ')
          ..write('discountEgp: $discountEgp, ')
          ..write('discountReason: $discountReason, ')
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
    paymentMethod,
    season,
    discountEgp,
    discountReason,
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
          other.paymentMethod == this.paymentMethod &&
          other.season == this.season &&
          other.discountEgp == this.discountEgp &&
          other.discountReason == this.discountReason &&
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
  final Value<String> paymentMethod;
  final Value<String> season;
  final Value<double> discountEgp;
  final Value<String?> discountReason;
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
    this.paymentMethod = const Value.absent(),
    this.season = const Value.absent(),
    this.discountEgp = const Value.absent(),
    this.discountReason = const Value.absent(),
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
    this.paymentMethod = const Value.absent(),
    this.season = const Value.absent(),
    this.discountEgp = const Value.absent(),
    this.discountReason = const Value.absent(),
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
    Expression<String>? paymentMethod,
    Expression<String>? season,
    Expression<double>? discountEgp,
    Expression<String>? discountReason,
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
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (season != null) 'season': season,
      if (discountEgp != null) 'discount_egp': discountEgp,
      if (discountReason != null) 'discount_reason': discountReason,
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
    Value<String>? paymentMethod,
    Value<String>? season,
    Value<double>? discountEgp,
    Value<String?>? discountReason,
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
      paymentMethod: paymentMethod ?? this.paymentMethod,
      season: season ?? this.season,
      discountEgp: discountEgp ?? this.discountEgp,
      discountReason: discountReason ?? this.discountReason,
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
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (season.present) {
      map['season'] = Variable<String>(season.value);
    }
    if (discountEgp.present) {
      map['discount_egp'] = Variable<double>(discountEgp.value);
    }
    if (discountReason.present) {
      map['discount_reason'] = Variable<String>(discountReason.value);
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
          ..write('paymentMethod: $paymentMethod, ')
          ..write('season: $season, ')
          ..write('discountEgp: $discountEgp, ')
          ..write('discountReason: $discountReason, ')
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

class $FinancialTransfersTable extends FinancialTransfers
    with TableInfo<$FinancialTransfersTable, FinancialTransfer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FinancialTransfersTable(this.attachedDatabase, [this._alias]);
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
        $FinancialTransfersTable.$convertersyncStatus,
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
  static const VerificationMeta _fromAccountMeta = const VerificationMeta(
    'fromAccount',
  );
  @override
  late final GeneratedColumn<String> fromAccount = GeneratedColumn<String>(
    'from_account',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toAccountMeta = const VerificationMeta(
    'toAccount',
  );
  @override
  late final GeneratedColumn<String> toAccount = GeneratedColumn<String>(
    'to_account',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transferTypeMeta = const VerificationMeta(
    'transferType',
  );
  @override
  late final GeneratedColumn<String> transferType = GeneratedColumn<String>(
    'transfer_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('internal'),
  );
  static const VerificationMeta _seasonMeta = const VerificationMeta('season');
  @override
  late final GeneratedColumn<String> season = GeneratedColumn<String>(
    'season',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('all'),
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
  static const VerificationMeta _transferDateMeta = const VerificationMeta(
    'transferDate',
  );
  @override
  late final GeneratedColumn<DateTime> transferDate = GeneratedColumn<DateTime>(
    'transfer_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
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
    fromAccount,
    toAccount,
    transferType,
    season,
    amountEgp,
    transferDate,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'financial_transfers';
  @override
  VerificationContext validateIntegrity(
    Insertable<FinancialTransfer> instance, {
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
    if (data.containsKey('from_account')) {
      context.handle(
        _fromAccountMeta,
        fromAccount.isAcceptableOrUnknown(
          data['from_account']!,
          _fromAccountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fromAccountMeta);
    }
    if (data.containsKey('to_account')) {
      context.handle(
        _toAccountMeta,
        toAccount.isAcceptableOrUnknown(data['to_account']!, _toAccountMeta),
      );
    } else if (isInserting) {
      context.missing(_toAccountMeta);
    }
    if (data.containsKey('transfer_type')) {
      context.handle(
        _transferTypeMeta,
        transferType.isAcceptableOrUnknown(
          data['transfer_type']!,
          _transferTypeMeta,
        ),
      );
    }
    if (data.containsKey('season')) {
      context.handle(
        _seasonMeta,
        season.isAcceptableOrUnknown(data['season']!, _seasonMeta),
      );
    }
    if (data.containsKey('amount_egp')) {
      context.handle(
        _amountEgpMeta,
        amountEgp.isAcceptableOrUnknown(data['amount_egp']!, _amountEgpMeta),
      );
    } else if (isInserting) {
      context.missing(_amountEgpMeta);
    }
    if (data.containsKey('transfer_date')) {
      context.handle(
        _transferDateMeta,
        transferDate.isAcceptableOrUnknown(
          data['transfer_date']!,
          _transferDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transferDateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
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
  FinancialTransfer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FinancialTransfer(
      syncStatus: $FinancialTransfersTable.$convertersyncStatus.fromSql(
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
      fromAccount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_account'],
      )!,
      toAccount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_account'],
      )!,
      transferType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transfer_type'],
      )!,
      season: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}season'],
      )!,
      amountEgp: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount_egp'],
      )!,
      transferDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}transfer_date'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FinancialTransfersTable createAlias(String alias) {
    return $FinancialTransfersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class FinancialTransfer extends DataClass
    implements Insertable<FinancialTransfer> {
  final SyncStatus syncStatus;
  final DateTime lastModifiedLocal;
  final String id;
  final String fromAccount;
  final String toAccount;
  final String transferType;
  final String season;
  final double amountEgp;
  final DateTime transferDate;
  final String? notes;
  final DateTime createdAt;
  const FinancialTransfer({
    required this.syncStatus,
    required this.lastModifiedLocal,
    required this.id,
    required this.fromAccount,
    required this.toAccount,
    required this.transferType,
    required this.season,
    required this.amountEgp,
    required this.transferDate,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['sync_status'] = Variable<int>(
        $FinancialTransfersTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['last_modified_local'] = Variable<DateTime>(lastModifiedLocal);
    map['id'] = Variable<String>(id);
    map['from_account'] = Variable<String>(fromAccount);
    map['to_account'] = Variable<String>(toAccount);
    map['transfer_type'] = Variable<String>(transferType);
    map['season'] = Variable<String>(season);
    map['amount_egp'] = Variable<double>(amountEgp);
    map['transfer_date'] = Variable<DateTime>(transferDate);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FinancialTransfersCompanion toCompanion(bool nullToAbsent) {
    return FinancialTransfersCompanion(
      syncStatus: Value(syncStatus),
      lastModifiedLocal: Value(lastModifiedLocal),
      id: Value(id),
      fromAccount: Value(fromAccount),
      toAccount: Value(toAccount),
      transferType: Value(transferType),
      season: Value(season),
      amountEgp: Value(amountEgp),
      transferDate: Value(transferDate),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory FinancialTransfer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FinancialTransfer(
      syncStatus: $FinancialTransfersTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
      lastModifiedLocal: serializer.fromJson<DateTime>(
        json['lastModifiedLocal'],
      ),
      id: serializer.fromJson<String>(json['id']),
      fromAccount: serializer.fromJson<String>(json['fromAccount']),
      toAccount: serializer.fromJson<String>(json['toAccount']),
      transferType: serializer.fromJson<String>(json['transferType']),
      season: serializer.fromJson<String>(json['season']),
      amountEgp: serializer.fromJson<double>(json['amountEgp']),
      transferDate: serializer.fromJson<DateTime>(json['transferDate']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncStatus': serializer.toJson<int>(
        $FinancialTransfersTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'lastModifiedLocal': serializer.toJson<DateTime>(lastModifiedLocal),
      'id': serializer.toJson<String>(id),
      'fromAccount': serializer.toJson<String>(fromAccount),
      'toAccount': serializer.toJson<String>(toAccount),
      'transferType': serializer.toJson<String>(transferType),
      'season': serializer.toJson<String>(season),
      'amountEgp': serializer.toJson<double>(amountEgp),
      'transferDate': serializer.toJson<DateTime>(transferDate),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FinancialTransfer copyWith({
    SyncStatus? syncStatus,
    DateTime? lastModifiedLocal,
    String? id,
    String? fromAccount,
    String? toAccount,
    String? transferType,
    String? season,
    double? amountEgp,
    DateTime? transferDate,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => FinancialTransfer(
    syncStatus: syncStatus ?? this.syncStatus,
    lastModifiedLocal: lastModifiedLocal ?? this.lastModifiedLocal,
    id: id ?? this.id,
    fromAccount: fromAccount ?? this.fromAccount,
    toAccount: toAccount ?? this.toAccount,
    transferType: transferType ?? this.transferType,
    season: season ?? this.season,
    amountEgp: amountEgp ?? this.amountEgp,
    transferDate: transferDate ?? this.transferDate,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  FinancialTransfer copyWithCompanion(FinancialTransfersCompanion data) {
    return FinancialTransfer(
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastModifiedLocal: data.lastModifiedLocal.present
          ? data.lastModifiedLocal.value
          : this.lastModifiedLocal,
      id: data.id.present ? data.id.value : this.id,
      fromAccount: data.fromAccount.present
          ? data.fromAccount.value
          : this.fromAccount,
      toAccount: data.toAccount.present ? data.toAccount.value : this.toAccount,
      transferType: data.transferType.present
          ? data.transferType.value
          : this.transferType,
      season: data.season.present ? data.season.value : this.season,
      amountEgp: data.amountEgp.present ? data.amountEgp.value : this.amountEgp,
      transferDate: data.transferDate.present
          ? data.transferDate.value
          : this.transferDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FinancialTransfer(')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedLocal: $lastModifiedLocal, ')
          ..write('id: $id, ')
          ..write('fromAccount: $fromAccount, ')
          ..write('toAccount: $toAccount, ')
          ..write('transferType: $transferType, ')
          ..write('season: $season, ')
          ..write('amountEgp: $amountEgp, ')
          ..write('transferDate: $transferDate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    syncStatus,
    lastModifiedLocal,
    id,
    fromAccount,
    toAccount,
    transferType,
    season,
    amountEgp,
    transferDate,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FinancialTransfer &&
          other.syncStatus == this.syncStatus &&
          other.lastModifiedLocal == this.lastModifiedLocal &&
          other.id == this.id &&
          other.fromAccount == this.fromAccount &&
          other.toAccount == this.toAccount &&
          other.transferType == this.transferType &&
          other.season == this.season &&
          other.amountEgp == this.amountEgp &&
          other.transferDate == this.transferDate &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class FinancialTransfersCompanion extends UpdateCompanion<FinancialTransfer> {
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> lastModifiedLocal;
  final Value<String> id;
  final Value<String> fromAccount;
  final Value<String> toAccount;
  final Value<String> transferType;
  final Value<String> season;
  final Value<double> amountEgp;
  final Value<DateTime> transferDate;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const FinancialTransfersCompanion({
    this.syncStatus = const Value.absent(),
    this.lastModifiedLocal = const Value.absent(),
    this.id = const Value.absent(),
    this.fromAccount = const Value.absent(),
    this.toAccount = const Value.absent(),
    this.transferType = const Value.absent(),
    this.season = const Value.absent(),
    this.amountEgp = const Value.absent(),
    this.transferDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FinancialTransfersCompanion.insert({
    this.syncStatus = const Value.absent(),
    this.lastModifiedLocal = const Value.absent(),
    required String id,
    required String fromAccount,
    required String toAccount,
    this.transferType = const Value.absent(),
    this.season = const Value.absent(),
    required double amountEgp,
    required DateTime transferDate,
    this.notes = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fromAccount = Value(fromAccount),
       toAccount = Value(toAccount),
       amountEgp = Value(amountEgp),
       transferDate = Value(transferDate),
       createdAt = Value(createdAt);
  static Insertable<FinancialTransfer> custom({
    Expression<int>? syncStatus,
    Expression<DateTime>? lastModifiedLocal,
    Expression<String>? id,
    Expression<String>? fromAccount,
    Expression<String>? toAccount,
    Expression<String>? transferType,
    Expression<String>? season,
    Expression<double>? amountEgp,
    Expression<DateTime>? transferDate,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastModifiedLocal != null) 'last_modified_local': lastModifiedLocal,
      if (id != null) 'id': id,
      if (fromAccount != null) 'from_account': fromAccount,
      if (toAccount != null) 'to_account': toAccount,
      if (transferType != null) 'transfer_type': transferType,
      if (season != null) 'season': season,
      if (amountEgp != null) 'amount_egp': amountEgp,
      if (transferDate != null) 'transfer_date': transferDate,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FinancialTransfersCompanion copyWith({
    Value<SyncStatus>? syncStatus,
    Value<DateTime>? lastModifiedLocal,
    Value<String>? id,
    Value<String>? fromAccount,
    Value<String>? toAccount,
    Value<String>? transferType,
    Value<String>? season,
    Value<double>? amountEgp,
    Value<DateTime>? transferDate,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return FinancialTransfersCompanion(
      syncStatus: syncStatus ?? this.syncStatus,
      lastModifiedLocal: lastModifiedLocal ?? this.lastModifiedLocal,
      id: id ?? this.id,
      fromAccount: fromAccount ?? this.fromAccount,
      toAccount: toAccount ?? this.toAccount,
      transferType: transferType ?? this.transferType,
      season: season ?? this.season,
      amountEgp: amountEgp ?? this.amountEgp,
      transferDate: transferDate ?? this.transferDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $FinancialTransfersTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (lastModifiedLocal.present) {
      map['last_modified_local'] = Variable<DateTime>(lastModifiedLocal.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fromAccount.present) {
      map['from_account'] = Variable<String>(fromAccount.value);
    }
    if (toAccount.present) {
      map['to_account'] = Variable<String>(toAccount.value);
    }
    if (transferType.present) {
      map['transfer_type'] = Variable<String>(transferType.value);
    }
    if (season.present) {
      map['season'] = Variable<String>(season.value);
    }
    if (amountEgp.present) {
      map['amount_egp'] = Variable<double>(amountEgp.value);
    }
    if (transferDate.present) {
      map['transfer_date'] = Variable<DateTime>(transferDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
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
    return (StringBuffer('FinancialTransfersCompanion(')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedLocal: $lastModifiedLocal, ')
          ..write('id: $id, ')
          ..write('fromAccount: $fromAccount, ')
          ..write('toAccount: $toAccount, ')
          ..write('transferType: $transferType, ')
          ..write('season: $season, ')
          ..write('amountEgp: $amountEgp, ')
          ..write('transferDate: $transferDate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TechniciansTable extends Technicians
    with TableInfo<$TechniciansTable, Technician> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TechniciansTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<SyncStatus>($TechniciansTable.$convertersyncStatus);
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
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _secondaryPhoneMeta = const VerificationMeta(
    'secondaryPhone',
  );
  @override
  late final GeneratedColumn<String> secondaryPhone = GeneratedColumn<String>(
    'secondary_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _specialtyMeta = const VerificationMeta(
    'specialty',
  );
  @override
  late final GeneratedColumn<String> specialty = GeneratedColumn<String>(
    'specialty',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
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
    name,
    phone,
    secondaryPhone,
    specialty,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'technicians';
  @override
  VerificationContext validateIntegrity(
    Insertable<Technician> instance, {
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
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('secondary_phone')) {
      context.handle(
        _secondaryPhoneMeta,
        secondaryPhone.isAcceptableOrUnknown(
          data['secondary_phone']!,
          _secondaryPhoneMeta,
        ),
      );
    }
    if (data.containsKey('specialty')) {
      context.handle(
        _specialtyMeta,
        specialty.isAcceptableOrUnknown(data['specialty']!, _specialtyMeta),
      );
    } else if (isInserting) {
      context.missing(_specialtyMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
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
  Technician map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Technician(
      syncStatus: $TechniciansTable.$convertersyncStatus.fromSql(
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
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      secondaryPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}secondary_phone'],
      ),
      specialty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}specialty'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TechniciansTable createAlias(String alias) {
    return $TechniciansTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class Technician extends DataClass implements Insertable<Technician> {
  final SyncStatus syncStatus;
  final DateTime lastModifiedLocal;
  final String id;
  final String name;
  final String? phone;
  final String? secondaryPhone;
  final String specialty;
  final String? notes;
  final DateTime createdAt;
  const Technician({
    required this.syncStatus,
    required this.lastModifiedLocal,
    required this.id,
    required this.name,
    this.phone,
    this.secondaryPhone,
    required this.specialty,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['sync_status'] = Variable<int>(
        $TechniciansTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['last_modified_local'] = Variable<DateTime>(lastModifiedLocal);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || secondaryPhone != null) {
      map['secondary_phone'] = Variable<String>(secondaryPhone);
    }
    map['specialty'] = Variable<String>(specialty);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TechniciansCompanion toCompanion(bool nullToAbsent) {
    return TechniciansCompanion(
      syncStatus: Value(syncStatus),
      lastModifiedLocal: Value(lastModifiedLocal),
      id: Value(id),
      name: Value(name),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      secondaryPhone: secondaryPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(secondaryPhone),
      specialty: Value(specialty),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory Technician.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Technician(
      syncStatus: $TechniciansTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
      lastModifiedLocal: serializer.fromJson<DateTime>(
        json['lastModifiedLocal'],
      ),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      secondaryPhone: serializer.fromJson<String?>(json['secondaryPhone']),
      specialty: serializer.fromJson<String>(json['specialty']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncStatus': serializer.toJson<int>(
        $TechniciansTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'lastModifiedLocal': serializer.toJson<DateTime>(lastModifiedLocal),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'secondaryPhone': serializer.toJson<String?>(secondaryPhone),
      'specialty': serializer.toJson<String>(specialty),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Technician copyWith({
    SyncStatus? syncStatus,
    DateTime? lastModifiedLocal,
    String? id,
    String? name,
    Value<String?> phone = const Value.absent(),
    Value<String?> secondaryPhone = const Value.absent(),
    String? specialty,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => Technician(
    syncStatus: syncStatus ?? this.syncStatus,
    lastModifiedLocal: lastModifiedLocal ?? this.lastModifiedLocal,
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone.present ? phone.value : this.phone,
    secondaryPhone: secondaryPhone.present
        ? secondaryPhone.value
        : this.secondaryPhone,
    specialty: specialty ?? this.specialty,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  Technician copyWithCompanion(TechniciansCompanion data) {
    return Technician(
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastModifiedLocal: data.lastModifiedLocal.present
          ? data.lastModifiedLocal.value
          : this.lastModifiedLocal,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      secondaryPhone: data.secondaryPhone.present
          ? data.secondaryPhone.value
          : this.secondaryPhone,
      specialty: data.specialty.present ? data.specialty.value : this.specialty,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Technician(')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedLocal: $lastModifiedLocal, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('secondaryPhone: $secondaryPhone, ')
          ..write('specialty: $specialty, ')
          ..write('notes: $notes, ')
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
    phone,
    secondaryPhone,
    specialty,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Technician &&
          other.syncStatus == this.syncStatus &&
          other.lastModifiedLocal == this.lastModifiedLocal &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.secondaryPhone == this.secondaryPhone &&
          other.specialty == this.specialty &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class TechniciansCompanion extends UpdateCompanion<Technician> {
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> lastModifiedLocal;
  final Value<String> id;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String?> secondaryPhone;
  final Value<String> specialty;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TechniciansCompanion({
    this.syncStatus = const Value.absent(),
    this.lastModifiedLocal = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.secondaryPhone = const Value.absent(),
    this.specialty = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TechniciansCompanion.insert({
    this.syncStatus = const Value.absent(),
    this.lastModifiedLocal = const Value.absent(),
    required String id,
    required String name,
    this.phone = const Value.absent(),
    this.secondaryPhone = const Value.absent(),
    required String specialty,
    this.notes = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       specialty = Value(specialty),
       createdAt = Value(createdAt);
  static Insertable<Technician> custom({
    Expression<int>? syncStatus,
    Expression<DateTime>? lastModifiedLocal,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? secondaryPhone,
    Expression<String>? specialty,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastModifiedLocal != null) 'last_modified_local': lastModifiedLocal,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (secondaryPhone != null) 'secondary_phone': secondaryPhone,
      if (specialty != null) 'specialty': specialty,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TechniciansCompanion copyWith({
    Value<SyncStatus>? syncStatus,
    Value<DateTime>? lastModifiedLocal,
    Value<String>? id,
    Value<String>? name,
    Value<String?>? phone,
    Value<String?>? secondaryPhone,
    Value<String>? specialty,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return TechniciansCompanion(
      syncStatus: syncStatus ?? this.syncStatus,
      lastModifiedLocal: lastModifiedLocal ?? this.lastModifiedLocal,
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      secondaryPhone: secondaryPhone ?? this.secondaryPhone,
      specialty: specialty ?? this.specialty,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $TechniciansTable.$convertersyncStatus.toSql(syncStatus.value),
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
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (secondaryPhone.present) {
      map['secondary_phone'] = Variable<String>(secondaryPhone.value);
    }
    if (specialty.present) {
      map['specialty'] = Variable<String>(specialty.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
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
    return (StringBuffer('TechniciansCompanion(')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedLocal: $lastModifiedLocal, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('secondaryPhone: $secondaryPhone, ')
          ..write('specialty: $specialty, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CleaningSuppliesTable extends CleaningSupplies
    with TableInfo<$CleaningSuppliesTable, CleaningSupply> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CleaningSuppliesTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<SyncStatus>($CleaningSuppliesTable.$convertersyncStatus);
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
  static const VerificationMeta _stockQuantityMeta = const VerificationMeta(
    'stockQuantity',
  );
  @override
  late final GeneratedColumn<double> stockQuantity = GeneratedColumn<double>(
    'stock_quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('عبوة'),
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
    name,
    stockQuantity,
    unit,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cleaning_supplies';
  @override
  VerificationContext validateIntegrity(
    Insertable<CleaningSupply> instance, {
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
    if (data.containsKey('stock_quantity')) {
      context.handle(
        _stockQuantityMeta,
        stockQuantity.isAcceptableOrUnknown(
          data['stock_quantity']!,
          _stockQuantityMeta,
        ),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
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
  CleaningSupply map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CleaningSupply(
      syncStatus: $CleaningSuppliesTable.$convertersyncStatus.fromSql(
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
      stockQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stock_quantity'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
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
  $CleaningSuppliesTable createAlias(String alias) {
    return $CleaningSuppliesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class CleaningSupply extends DataClass implements Insertable<CleaningSupply> {
  final SyncStatus syncStatus;
  final DateTime lastModifiedLocal;
  final String id;
  final String name;
  final double stockQuantity;
  final String unit;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CleaningSupply({
    required this.syncStatus,
    required this.lastModifiedLocal,
    required this.id,
    required this.name,
    required this.stockQuantity,
    required this.unit,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['sync_status'] = Variable<int>(
        $CleaningSuppliesTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['last_modified_local'] = Variable<DateTime>(lastModifiedLocal);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['stock_quantity'] = Variable<double>(stockQuantity);
    map['unit'] = Variable<String>(unit);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CleaningSuppliesCompanion toCompanion(bool nullToAbsent) {
    return CleaningSuppliesCompanion(
      syncStatus: Value(syncStatus),
      lastModifiedLocal: Value(lastModifiedLocal),
      id: Value(id),
      name: Value(name),
      stockQuantity: Value(stockQuantity),
      unit: Value(unit),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CleaningSupply.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CleaningSupply(
      syncStatus: $CleaningSuppliesTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
      lastModifiedLocal: serializer.fromJson<DateTime>(
        json['lastModifiedLocal'],
      ),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      stockQuantity: serializer.fromJson<double>(json['stockQuantity']),
      unit: serializer.fromJson<String>(json['unit']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncStatus': serializer.toJson<int>(
        $CleaningSuppliesTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'lastModifiedLocal': serializer.toJson<DateTime>(lastModifiedLocal),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'stockQuantity': serializer.toJson<double>(stockQuantity),
      'unit': serializer.toJson<String>(unit),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CleaningSupply copyWith({
    SyncStatus? syncStatus,
    DateTime? lastModifiedLocal,
    String? id,
    String? name,
    double? stockQuantity,
    String? unit,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CleaningSupply(
    syncStatus: syncStatus ?? this.syncStatus,
    lastModifiedLocal: lastModifiedLocal ?? this.lastModifiedLocal,
    id: id ?? this.id,
    name: name ?? this.name,
    stockQuantity: stockQuantity ?? this.stockQuantity,
    unit: unit ?? this.unit,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CleaningSupply copyWithCompanion(CleaningSuppliesCompanion data) {
    return CleaningSupply(
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastModifiedLocal: data.lastModifiedLocal.present
          ? data.lastModifiedLocal.value
          : this.lastModifiedLocal,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      stockQuantity: data.stockQuantity.present
          ? data.stockQuantity.value
          : this.stockQuantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CleaningSupply(')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedLocal: $lastModifiedLocal, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('stockQuantity: $stockQuantity, ')
          ..write('unit: $unit, ')
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
    name,
    stockQuantity,
    unit,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CleaningSupply &&
          other.syncStatus == this.syncStatus &&
          other.lastModifiedLocal == this.lastModifiedLocal &&
          other.id == this.id &&
          other.name == this.name &&
          other.stockQuantity == this.stockQuantity &&
          other.unit == this.unit &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CleaningSuppliesCompanion extends UpdateCompanion<CleaningSupply> {
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> lastModifiedLocal;
  final Value<String> id;
  final Value<String> name;
  final Value<double> stockQuantity;
  final Value<String> unit;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CleaningSuppliesCompanion({
    this.syncStatus = const Value.absent(),
    this.lastModifiedLocal = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.stockQuantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CleaningSuppliesCompanion.insert({
    this.syncStatus = const Value.absent(),
    this.lastModifiedLocal = const Value.absent(),
    required String id,
    required String name,
    this.stockQuantity = const Value.absent(),
    this.unit = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CleaningSupply> custom({
    Expression<int>? syncStatus,
    Expression<DateTime>? lastModifiedLocal,
    Expression<String>? id,
    Expression<String>? name,
    Expression<double>? stockQuantity,
    Expression<String>? unit,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastModifiedLocal != null) 'last_modified_local': lastModifiedLocal,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (stockQuantity != null) 'stock_quantity': stockQuantity,
      if (unit != null) 'unit': unit,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CleaningSuppliesCompanion copyWith({
    Value<SyncStatus>? syncStatus,
    Value<DateTime>? lastModifiedLocal,
    Value<String>? id,
    Value<String>? name,
    Value<double>? stockQuantity,
    Value<String>? unit,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CleaningSuppliesCompanion(
      syncStatus: syncStatus ?? this.syncStatus,
      lastModifiedLocal: lastModifiedLocal ?? this.lastModifiedLocal,
      id: id ?? this.id,
      name: name ?? this.name,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      unit: unit ?? this.unit,
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
        $CleaningSuppliesTable.$convertersyncStatus.toSql(syncStatus.value),
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
    if (stockQuantity.present) {
      map['stock_quantity'] = Variable<double>(stockQuantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
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
    return (StringBuffer('CleaningSuppliesCompanion(')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedLocal: $lastModifiedLocal, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('stockQuantity: $stockQuantity, ')
          ..write('unit: $unit, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CleaningTransactionsTable extends CleaningTransactions
    with TableInfo<$CleaningTransactionsTable, CleaningTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CleaningTransactionsTable(this.attachedDatabase, [this._alias]);
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
        $CleaningTransactionsTable.$convertersyncStatus,
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
  static const VerificationMeta _supplyIdMeta = const VerificationMeta(
    'supplyId',
  );
  @override
  late final GeneratedColumn<String> supplyId = GeneratedColumn<String>(
    'supply_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cleaning_supplies (id)',
    ),
  );
  static const VerificationMeta _transactionTypeMeta = const VerificationMeta(
    'transactionType',
  );
  @override
  late final GeneratedColumn<String> transactionType = GeneratedColumn<String>(
    'transaction_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
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
  static const VerificationMeta _transactionDateMeta = const VerificationMeta(
    'transactionDate',
  );
  @override
  late final GeneratedColumn<DateTime> transactionDate =
      GeneratedColumn<DateTime>(
        'transaction_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
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
    supplyId,
    transactionType,
    quantity,
    costEgp,
    transactionDate,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cleaning_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<CleaningTransaction> instance, {
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
    if (data.containsKey('supply_id')) {
      context.handle(
        _supplyIdMeta,
        supplyId.isAcceptableOrUnknown(data['supply_id']!, _supplyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_supplyIdMeta);
    }
    if (data.containsKey('transaction_type')) {
      context.handle(
        _transactionTypeMeta,
        transactionType.isAcceptableOrUnknown(
          data['transaction_type']!,
          _transactionTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionTypeMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('cost_egp')) {
      context.handle(
        _costEgpMeta,
        costEgp.isAcceptableOrUnknown(data['cost_egp']!, _costEgpMeta),
      );
    }
    if (data.containsKey('transaction_date')) {
      context.handle(
        _transactionDateMeta,
        transactionDate.isAcceptableOrUnknown(
          data['transaction_date']!,
          _transactionDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionDateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
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
  CleaningTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CleaningTransaction(
      syncStatus: $CleaningTransactionsTable.$convertersyncStatus.fromSql(
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
      supplyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supply_id'],
      )!,
      transactionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_type'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      costEgp: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost_egp'],
      )!,
      transactionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}transaction_date'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CleaningTransactionsTable createAlias(String alias) {
    return $CleaningTransactionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class CleaningTransaction extends DataClass
    implements Insertable<CleaningTransaction> {
  final SyncStatus syncStatus;
  final DateTime lastModifiedLocal;
  final String id;
  final String supplyId;
  final String transactionType;
  final double quantity;
  final double costEgp;
  final DateTime transactionDate;
  final String? notes;
  final DateTime createdAt;
  const CleaningTransaction({
    required this.syncStatus,
    required this.lastModifiedLocal,
    required this.id,
    required this.supplyId,
    required this.transactionType,
    required this.quantity,
    required this.costEgp,
    required this.transactionDate,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['sync_status'] = Variable<int>(
        $CleaningTransactionsTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['last_modified_local'] = Variable<DateTime>(lastModifiedLocal);
    map['id'] = Variable<String>(id);
    map['supply_id'] = Variable<String>(supplyId);
    map['transaction_type'] = Variable<String>(transactionType);
    map['quantity'] = Variable<double>(quantity);
    map['cost_egp'] = Variable<double>(costEgp);
    map['transaction_date'] = Variable<DateTime>(transactionDate);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CleaningTransactionsCompanion toCompanion(bool nullToAbsent) {
    return CleaningTransactionsCompanion(
      syncStatus: Value(syncStatus),
      lastModifiedLocal: Value(lastModifiedLocal),
      id: Value(id),
      supplyId: Value(supplyId),
      transactionType: Value(transactionType),
      quantity: Value(quantity),
      costEgp: Value(costEgp),
      transactionDate: Value(transactionDate),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory CleaningTransaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CleaningTransaction(
      syncStatus: $CleaningTransactionsTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
      lastModifiedLocal: serializer.fromJson<DateTime>(
        json['lastModifiedLocal'],
      ),
      id: serializer.fromJson<String>(json['id']),
      supplyId: serializer.fromJson<String>(json['supplyId']),
      transactionType: serializer.fromJson<String>(json['transactionType']),
      quantity: serializer.fromJson<double>(json['quantity']),
      costEgp: serializer.fromJson<double>(json['costEgp']),
      transactionDate: serializer.fromJson<DateTime>(json['transactionDate']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncStatus': serializer.toJson<int>(
        $CleaningTransactionsTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'lastModifiedLocal': serializer.toJson<DateTime>(lastModifiedLocal),
      'id': serializer.toJson<String>(id),
      'supplyId': serializer.toJson<String>(supplyId),
      'transactionType': serializer.toJson<String>(transactionType),
      'quantity': serializer.toJson<double>(quantity),
      'costEgp': serializer.toJson<double>(costEgp),
      'transactionDate': serializer.toJson<DateTime>(transactionDate),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CleaningTransaction copyWith({
    SyncStatus? syncStatus,
    DateTime? lastModifiedLocal,
    String? id,
    String? supplyId,
    String? transactionType,
    double? quantity,
    double? costEgp,
    DateTime? transactionDate,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => CleaningTransaction(
    syncStatus: syncStatus ?? this.syncStatus,
    lastModifiedLocal: lastModifiedLocal ?? this.lastModifiedLocal,
    id: id ?? this.id,
    supplyId: supplyId ?? this.supplyId,
    transactionType: transactionType ?? this.transactionType,
    quantity: quantity ?? this.quantity,
    costEgp: costEgp ?? this.costEgp,
    transactionDate: transactionDate ?? this.transactionDate,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  CleaningTransaction copyWithCompanion(CleaningTransactionsCompanion data) {
    return CleaningTransaction(
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastModifiedLocal: data.lastModifiedLocal.present
          ? data.lastModifiedLocal.value
          : this.lastModifiedLocal,
      id: data.id.present ? data.id.value : this.id,
      supplyId: data.supplyId.present ? data.supplyId.value : this.supplyId,
      transactionType: data.transactionType.present
          ? data.transactionType.value
          : this.transactionType,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      costEgp: data.costEgp.present ? data.costEgp.value : this.costEgp,
      transactionDate: data.transactionDate.present
          ? data.transactionDate.value
          : this.transactionDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CleaningTransaction(')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedLocal: $lastModifiedLocal, ')
          ..write('id: $id, ')
          ..write('supplyId: $supplyId, ')
          ..write('transactionType: $transactionType, ')
          ..write('quantity: $quantity, ')
          ..write('costEgp: $costEgp, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    syncStatus,
    lastModifiedLocal,
    id,
    supplyId,
    transactionType,
    quantity,
    costEgp,
    transactionDate,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CleaningTransaction &&
          other.syncStatus == this.syncStatus &&
          other.lastModifiedLocal == this.lastModifiedLocal &&
          other.id == this.id &&
          other.supplyId == this.supplyId &&
          other.transactionType == this.transactionType &&
          other.quantity == this.quantity &&
          other.costEgp == this.costEgp &&
          other.transactionDate == this.transactionDate &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class CleaningTransactionsCompanion
    extends UpdateCompanion<CleaningTransaction> {
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> lastModifiedLocal;
  final Value<String> id;
  final Value<String> supplyId;
  final Value<String> transactionType;
  final Value<double> quantity;
  final Value<double> costEgp;
  final Value<DateTime> transactionDate;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CleaningTransactionsCompanion({
    this.syncStatus = const Value.absent(),
    this.lastModifiedLocal = const Value.absent(),
    this.id = const Value.absent(),
    this.supplyId = const Value.absent(),
    this.transactionType = const Value.absent(),
    this.quantity = const Value.absent(),
    this.costEgp = const Value.absent(),
    this.transactionDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CleaningTransactionsCompanion.insert({
    this.syncStatus = const Value.absent(),
    this.lastModifiedLocal = const Value.absent(),
    required String id,
    required String supplyId,
    required String transactionType,
    required double quantity,
    this.costEgp = const Value.absent(),
    required DateTime transactionDate,
    this.notes = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       supplyId = Value(supplyId),
       transactionType = Value(transactionType),
       quantity = Value(quantity),
       transactionDate = Value(transactionDate),
       createdAt = Value(createdAt);
  static Insertable<CleaningTransaction> custom({
    Expression<int>? syncStatus,
    Expression<DateTime>? lastModifiedLocal,
    Expression<String>? id,
    Expression<String>? supplyId,
    Expression<String>? transactionType,
    Expression<double>? quantity,
    Expression<double>? costEgp,
    Expression<DateTime>? transactionDate,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastModifiedLocal != null) 'last_modified_local': lastModifiedLocal,
      if (id != null) 'id': id,
      if (supplyId != null) 'supply_id': supplyId,
      if (transactionType != null) 'transaction_type': transactionType,
      if (quantity != null) 'quantity': quantity,
      if (costEgp != null) 'cost_egp': costEgp,
      if (transactionDate != null) 'transaction_date': transactionDate,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CleaningTransactionsCompanion copyWith({
    Value<SyncStatus>? syncStatus,
    Value<DateTime>? lastModifiedLocal,
    Value<String>? id,
    Value<String>? supplyId,
    Value<String>? transactionType,
    Value<double>? quantity,
    Value<double>? costEgp,
    Value<DateTime>? transactionDate,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CleaningTransactionsCompanion(
      syncStatus: syncStatus ?? this.syncStatus,
      lastModifiedLocal: lastModifiedLocal ?? this.lastModifiedLocal,
      id: id ?? this.id,
      supplyId: supplyId ?? this.supplyId,
      transactionType: transactionType ?? this.transactionType,
      quantity: quantity ?? this.quantity,
      costEgp: costEgp ?? this.costEgp,
      transactionDate: transactionDate ?? this.transactionDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $CleaningTransactionsTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (lastModifiedLocal.present) {
      map['last_modified_local'] = Variable<DateTime>(lastModifiedLocal.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (supplyId.present) {
      map['supply_id'] = Variable<String>(supplyId.value);
    }
    if (transactionType.present) {
      map['transaction_type'] = Variable<String>(transactionType.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (costEgp.present) {
      map['cost_egp'] = Variable<double>(costEgp.value);
    }
    if (transactionDate.present) {
      map['transaction_date'] = Variable<DateTime>(transactionDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
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
    return (StringBuffer('CleaningTransactionsCompanion(')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedLocal: $lastModifiedLocal, ')
          ..write('id: $id, ')
          ..write('supplyId: $supplyId, ')
          ..write('transactionType: $transactionType, ')
          ..write('quantity: $quantity, ')
          ..write('costEgp: $costEgp, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ApartmentInspectionsTable extends ApartmentInspections
    with TableInfo<$ApartmentInspectionsTable, ApartmentInspection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ApartmentInspectionsTable(this.attachedDatabase, [this._alias]);
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
        $ApartmentInspectionsTable.$convertersyncStatus,
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
  static const VerificationMeta _inspectionDateMeta = const VerificationMeta(
    'inspectionDate',
  );
  @override
  late final GeneratedColumn<DateTime> inspectionDate =
      GeneratedColumn<DateTime>(
        'inspection_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _isCleanMeta = const VerificationMeta(
    'isClean',
  );
  @override
  late final GeneratedColumn<bool> isClean = GeneratedColumn<bool>(
    'is_clean',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_clean" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _hasDamagesMeta = const VerificationMeta(
    'hasDamages',
  );
  @override
  late final GeneratedColumn<bool> hasDamages = GeneratedColumn<bool>(
    'has_damages',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_damages" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _damagesDescriptionMeta =
      const VerificationMeta('damagesDescription');
  @override
  late final GeneratedColumn<String> damagesDescription =
      GeneratedColumn<String>(
        'damages_description',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _tenantFineEgpMeta = const VerificationMeta(
    'tenantFineEgp',
  );
  @override
  late final GeneratedColumn<double> tenantFineEgp = GeneratedColumn<double>(
    'tenant_fine_egp',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _ownerRepairCostEgpMeta =
      const VerificationMeta('ownerRepairCostEgp');
  @override
  late final GeneratedColumn<double> ownerRepairCostEgp =
      GeneratedColumn<double>(
        'owner_repair_cost_egp',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _inspectorNameMeta = const VerificationMeta(
    'inspectorName',
  );
  @override
  late final GeneratedColumn<String> inspectorName = GeneratedColumn<String>(
    'inspector_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
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
    inspectionDate,
    isClean,
    hasDamages,
    damagesDescription,
    tenantFineEgp,
    ownerRepairCostEgp,
    inspectorName,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'apartment_inspections';
  @override
  VerificationContext validateIntegrity(
    Insertable<ApartmentInspection> instance, {
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
    if (data.containsKey('inspection_date')) {
      context.handle(
        _inspectionDateMeta,
        inspectionDate.isAcceptableOrUnknown(
          data['inspection_date']!,
          _inspectionDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_inspectionDateMeta);
    }
    if (data.containsKey('is_clean')) {
      context.handle(
        _isCleanMeta,
        isClean.isAcceptableOrUnknown(data['is_clean']!, _isCleanMeta),
      );
    }
    if (data.containsKey('has_damages')) {
      context.handle(
        _hasDamagesMeta,
        hasDamages.isAcceptableOrUnknown(data['has_damages']!, _hasDamagesMeta),
      );
    }
    if (data.containsKey('damages_description')) {
      context.handle(
        _damagesDescriptionMeta,
        damagesDescription.isAcceptableOrUnknown(
          data['damages_description']!,
          _damagesDescriptionMeta,
        ),
      );
    }
    if (data.containsKey('tenant_fine_egp')) {
      context.handle(
        _tenantFineEgpMeta,
        tenantFineEgp.isAcceptableOrUnknown(
          data['tenant_fine_egp']!,
          _tenantFineEgpMeta,
        ),
      );
    }
    if (data.containsKey('owner_repair_cost_egp')) {
      context.handle(
        _ownerRepairCostEgpMeta,
        ownerRepairCostEgp.isAcceptableOrUnknown(
          data['owner_repair_cost_egp']!,
          _ownerRepairCostEgpMeta,
        ),
      );
    }
    if (data.containsKey('inspector_name')) {
      context.handle(
        _inspectorNameMeta,
        inspectorName.isAcceptableOrUnknown(
          data['inspector_name']!,
          _inspectorNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_inspectorNameMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
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
  ApartmentInspection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ApartmentInspection(
      syncStatus: $ApartmentInspectionsTable.$convertersyncStatus.fromSql(
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
      inspectionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}inspection_date'],
      )!,
      isClean: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_clean'],
      )!,
      hasDamages: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_damages'],
      )!,
      damagesDescription: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}damages_description'],
      ),
      tenantFineEgp: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tenant_fine_egp'],
      )!,
      ownerRepairCostEgp: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}owner_repair_cost_egp'],
      )!,
      inspectorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}inspector_name'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
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
  $ApartmentInspectionsTable createAlias(String alias) {
    return $ApartmentInspectionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class ApartmentInspection extends DataClass
    implements Insertable<ApartmentInspection> {
  final SyncStatus syncStatus;
  final DateTime lastModifiedLocal;
  final String id;
  final String apartmentId;
  final DateTime inspectionDate;
  final bool isClean;
  final bool hasDamages;
  final String? damagesDescription;
  final double tenantFineEgp;
  final double ownerRepairCostEgp;
  final String inspectorName;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ApartmentInspection({
    required this.syncStatus,
    required this.lastModifiedLocal,
    required this.id,
    required this.apartmentId,
    required this.inspectionDate,
    required this.isClean,
    required this.hasDamages,
    this.damagesDescription,
    required this.tenantFineEgp,
    required this.ownerRepairCostEgp,
    required this.inspectorName,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['sync_status'] = Variable<int>(
        $ApartmentInspectionsTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['last_modified_local'] = Variable<DateTime>(lastModifiedLocal);
    map['id'] = Variable<String>(id);
    map['apartment_id'] = Variable<String>(apartmentId);
    map['inspection_date'] = Variable<DateTime>(inspectionDate);
    map['is_clean'] = Variable<bool>(isClean);
    map['has_damages'] = Variable<bool>(hasDamages);
    if (!nullToAbsent || damagesDescription != null) {
      map['damages_description'] = Variable<String>(damagesDescription);
    }
    map['tenant_fine_egp'] = Variable<double>(tenantFineEgp);
    map['owner_repair_cost_egp'] = Variable<double>(ownerRepairCostEgp);
    map['inspector_name'] = Variable<String>(inspectorName);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ApartmentInspectionsCompanion toCompanion(bool nullToAbsent) {
    return ApartmentInspectionsCompanion(
      syncStatus: Value(syncStatus),
      lastModifiedLocal: Value(lastModifiedLocal),
      id: Value(id),
      apartmentId: Value(apartmentId),
      inspectionDate: Value(inspectionDate),
      isClean: Value(isClean),
      hasDamages: Value(hasDamages),
      damagesDescription: damagesDescription == null && nullToAbsent
          ? const Value.absent()
          : Value(damagesDescription),
      tenantFineEgp: Value(tenantFineEgp),
      ownerRepairCostEgp: Value(ownerRepairCostEgp),
      inspectorName: Value(inspectorName),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ApartmentInspection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ApartmentInspection(
      syncStatus: $ApartmentInspectionsTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
      lastModifiedLocal: serializer.fromJson<DateTime>(
        json['lastModifiedLocal'],
      ),
      id: serializer.fromJson<String>(json['id']),
      apartmentId: serializer.fromJson<String>(json['apartmentId']),
      inspectionDate: serializer.fromJson<DateTime>(json['inspectionDate']),
      isClean: serializer.fromJson<bool>(json['isClean']),
      hasDamages: serializer.fromJson<bool>(json['hasDamages']),
      damagesDescription: serializer.fromJson<String?>(
        json['damagesDescription'],
      ),
      tenantFineEgp: serializer.fromJson<double>(json['tenantFineEgp']),
      ownerRepairCostEgp: serializer.fromJson<double>(
        json['ownerRepairCostEgp'],
      ),
      inspectorName: serializer.fromJson<String>(json['inspectorName']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncStatus': serializer.toJson<int>(
        $ApartmentInspectionsTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'lastModifiedLocal': serializer.toJson<DateTime>(lastModifiedLocal),
      'id': serializer.toJson<String>(id),
      'apartmentId': serializer.toJson<String>(apartmentId),
      'inspectionDate': serializer.toJson<DateTime>(inspectionDate),
      'isClean': serializer.toJson<bool>(isClean),
      'hasDamages': serializer.toJson<bool>(hasDamages),
      'damagesDescription': serializer.toJson<String?>(damagesDescription),
      'tenantFineEgp': serializer.toJson<double>(tenantFineEgp),
      'ownerRepairCostEgp': serializer.toJson<double>(ownerRepairCostEgp),
      'inspectorName': serializer.toJson<String>(inspectorName),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ApartmentInspection copyWith({
    SyncStatus? syncStatus,
    DateTime? lastModifiedLocal,
    String? id,
    String? apartmentId,
    DateTime? inspectionDate,
    bool? isClean,
    bool? hasDamages,
    Value<String?> damagesDescription = const Value.absent(),
    double? tenantFineEgp,
    double? ownerRepairCostEgp,
    String? inspectorName,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ApartmentInspection(
    syncStatus: syncStatus ?? this.syncStatus,
    lastModifiedLocal: lastModifiedLocal ?? this.lastModifiedLocal,
    id: id ?? this.id,
    apartmentId: apartmentId ?? this.apartmentId,
    inspectionDate: inspectionDate ?? this.inspectionDate,
    isClean: isClean ?? this.isClean,
    hasDamages: hasDamages ?? this.hasDamages,
    damagesDescription: damagesDescription.present
        ? damagesDescription.value
        : this.damagesDescription,
    tenantFineEgp: tenantFineEgp ?? this.tenantFineEgp,
    ownerRepairCostEgp: ownerRepairCostEgp ?? this.ownerRepairCostEgp,
    inspectorName: inspectorName ?? this.inspectorName,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ApartmentInspection copyWithCompanion(ApartmentInspectionsCompanion data) {
    return ApartmentInspection(
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
      inspectionDate: data.inspectionDate.present
          ? data.inspectionDate.value
          : this.inspectionDate,
      isClean: data.isClean.present ? data.isClean.value : this.isClean,
      hasDamages: data.hasDamages.present
          ? data.hasDamages.value
          : this.hasDamages,
      damagesDescription: data.damagesDescription.present
          ? data.damagesDescription.value
          : this.damagesDescription,
      tenantFineEgp: data.tenantFineEgp.present
          ? data.tenantFineEgp.value
          : this.tenantFineEgp,
      ownerRepairCostEgp: data.ownerRepairCostEgp.present
          ? data.ownerRepairCostEgp.value
          : this.ownerRepairCostEgp,
      inspectorName: data.inspectorName.present
          ? data.inspectorName.value
          : this.inspectorName,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ApartmentInspection(')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedLocal: $lastModifiedLocal, ')
          ..write('id: $id, ')
          ..write('apartmentId: $apartmentId, ')
          ..write('inspectionDate: $inspectionDate, ')
          ..write('isClean: $isClean, ')
          ..write('hasDamages: $hasDamages, ')
          ..write('damagesDescription: $damagesDescription, ')
          ..write('tenantFineEgp: $tenantFineEgp, ')
          ..write('ownerRepairCostEgp: $ownerRepairCostEgp, ')
          ..write('inspectorName: $inspectorName, ')
          ..write('notes: $notes, ')
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
    inspectionDate,
    isClean,
    hasDamages,
    damagesDescription,
    tenantFineEgp,
    ownerRepairCostEgp,
    inspectorName,
    notes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ApartmentInspection &&
          other.syncStatus == this.syncStatus &&
          other.lastModifiedLocal == this.lastModifiedLocal &&
          other.id == this.id &&
          other.apartmentId == this.apartmentId &&
          other.inspectionDate == this.inspectionDate &&
          other.isClean == this.isClean &&
          other.hasDamages == this.hasDamages &&
          other.damagesDescription == this.damagesDescription &&
          other.tenantFineEgp == this.tenantFineEgp &&
          other.ownerRepairCostEgp == this.ownerRepairCostEgp &&
          other.inspectorName == this.inspectorName &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ApartmentInspectionsCompanion
    extends UpdateCompanion<ApartmentInspection> {
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> lastModifiedLocal;
  final Value<String> id;
  final Value<String> apartmentId;
  final Value<DateTime> inspectionDate;
  final Value<bool> isClean;
  final Value<bool> hasDamages;
  final Value<String?> damagesDescription;
  final Value<double> tenantFineEgp;
  final Value<double> ownerRepairCostEgp;
  final Value<String> inspectorName;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ApartmentInspectionsCompanion({
    this.syncStatus = const Value.absent(),
    this.lastModifiedLocal = const Value.absent(),
    this.id = const Value.absent(),
    this.apartmentId = const Value.absent(),
    this.inspectionDate = const Value.absent(),
    this.isClean = const Value.absent(),
    this.hasDamages = const Value.absent(),
    this.damagesDescription = const Value.absent(),
    this.tenantFineEgp = const Value.absent(),
    this.ownerRepairCostEgp = const Value.absent(),
    this.inspectorName = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ApartmentInspectionsCompanion.insert({
    this.syncStatus = const Value.absent(),
    this.lastModifiedLocal = const Value.absent(),
    required String id,
    required String apartmentId,
    required DateTime inspectionDate,
    this.isClean = const Value.absent(),
    this.hasDamages = const Value.absent(),
    this.damagesDescription = const Value.absent(),
    this.tenantFineEgp = const Value.absent(),
    this.ownerRepairCostEgp = const Value.absent(),
    required String inspectorName,
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       apartmentId = Value(apartmentId),
       inspectionDate = Value(inspectionDate),
       inspectorName = Value(inspectorName),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ApartmentInspection> custom({
    Expression<int>? syncStatus,
    Expression<DateTime>? lastModifiedLocal,
    Expression<String>? id,
    Expression<String>? apartmentId,
    Expression<DateTime>? inspectionDate,
    Expression<bool>? isClean,
    Expression<bool>? hasDamages,
    Expression<String>? damagesDescription,
    Expression<double>? tenantFineEgp,
    Expression<double>? ownerRepairCostEgp,
    Expression<String>? inspectorName,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastModifiedLocal != null) 'last_modified_local': lastModifiedLocal,
      if (id != null) 'id': id,
      if (apartmentId != null) 'apartment_id': apartmentId,
      if (inspectionDate != null) 'inspection_date': inspectionDate,
      if (isClean != null) 'is_clean': isClean,
      if (hasDamages != null) 'has_damages': hasDamages,
      if (damagesDescription != null) 'damages_description': damagesDescription,
      if (tenantFineEgp != null) 'tenant_fine_egp': tenantFineEgp,
      if (ownerRepairCostEgp != null)
        'owner_repair_cost_egp': ownerRepairCostEgp,
      if (inspectorName != null) 'inspector_name': inspectorName,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ApartmentInspectionsCompanion copyWith({
    Value<SyncStatus>? syncStatus,
    Value<DateTime>? lastModifiedLocal,
    Value<String>? id,
    Value<String>? apartmentId,
    Value<DateTime>? inspectionDate,
    Value<bool>? isClean,
    Value<bool>? hasDamages,
    Value<String?>? damagesDescription,
    Value<double>? tenantFineEgp,
    Value<double>? ownerRepairCostEgp,
    Value<String>? inspectorName,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ApartmentInspectionsCompanion(
      syncStatus: syncStatus ?? this.syncStatus,
      lastModifiedLocal: lastModifiedLocal ?? this.lastModifiedLocal,
      id: id ?? this.id,
      apartmentId: apartmentId ?? this.apartmentId,
      inspectionDate: inspectionDate ?? this.inspectionDate,
      isClean: isClean ?? this.isClean,
      hasDamages: hasDamages ?? this.hasDamages,
      damagesDescription: damagesDescription ?? this.damagesDescription,
      tenantFineEgp: tenantFineEgp ?? this.tenantFineEgp,
      ownerRepairCostEgp: ownerRepairCostEgp ?? this.ownerRepairCostEgp,
      inspectorName: inspectorName ?? this.inspectorName,
      notes: notes ?? this.notes,
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
        $ApartmentInspectionsTable.$convertersyncStatus.toSql(syncStatus.value),
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
    if (inspectionDate.present) {
      map['inspection_date'] = Variable<DateTime>(inspectionDate.value);
    }
    if (isClean.present) {
      map['is_clean'] = Variable<bool>(isClean.value);
    }
    if (hasDamages.present) {
      map['has_damages'] = Variable<bool>(hasDamages.value);
    }
    if (damagesDescription.present) {
      map['damages_description'] = Variable<String>(damagesDescription.value);
    }
    if (tenantFineEgp.present) {
      map['tenant_fine_egp'] = Variable<double>(tenantFineEgp.value);
    }
    if (ownerRepairCostEgp.present) {
      map['owner_repair_cost_egp'] = Variable<double>(ownerRepairCostEgp.value);
    }
    if (inspectorName.present) {
      map['inspector_name'] = Variable<String>(inspectorName.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
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
    return (StringBuffer('ApartmentInspectionsCompanion(')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedLocal: $lastModifiedLocal, ')
          ..write('id: $id, ')
          ..write('apartmentId: $apartmentId, ')
          ..write('inspectionDate: $inspectionDate, ')
          ..write('isClean: $isClean, ')
          ..write('hasDamages: $hasDamages, ')
          ..write('damagesDescription: $damagesDescription, ')
          ..write('tenantFineEgp: $tenantFineEgp, ')
          ..write('ownerRepairCostEgp: $ownerRepairCostEgp, ')
          ..write('inspectorName: $inspectorName, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
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
  static const VerificationMeta _technicianIdMeta = const VerificationMeta(
    'technicianId',
  );
  @override
  late final GeneratedColumn<String> technicianId = GeneratedColumn<String>(
    'technician_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES technicians (id)',
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
    technicianId,
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
    if (data.containsKey('technician_id')) {
      context.handle(
        _technicianIdMeta,
        technicianId.isAcceptableOrUnknown(
          data['technician_id']!,
          _technicianIdMeta,
        ),
      );
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
      technicianId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}technician_id'],
      ),
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
  final String? technicianId;
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
    this.technicianId,
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
    if (!nullToAbsent || technicianId != null) {
      map['technician_id'] = Variable<String>(technicianId);
    }
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
      technicianId: technicianId == null && nullToAbsent
          ? const Value.absent()
          : Value(technicianId),
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
      technicianId: serializer.fromJson<String?>(json['technicianId']),
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
      'technicianId': serializer.toJson<String?>(technicianId),
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
    Value<String?> technicianId = const Value.absent(),
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
    technicianId: technicianId.present ? technicianId.value : this.technicianId,
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
      technicianId: data.technicianId.present
          ? data.technicianId.value
          : this.technicianId,
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
          ..write('technicianId: $technicianId, ')
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
    technicianId,
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
          other.technicianId == this.technicianId &&
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
  final Value<String?> technicianId;
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
    this.technicianId = const Value.absent(),
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
    this.technicianId = const Value.absent(),
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
    Expression<String>? technicianId,
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
      if (technicianId != null) 'technician_id': technicianId,
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
    Value<String?>? technicianId,
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
      technicianId: technicianId ?? this.technicianId,
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
    if (technicianId.present) {
      map['technician_id'] = Variable<String>(technicianId.value);
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
          ..write('technicianId: $technicianId, ')
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

class $AuditLogsTable extends AuditLogs
    with TableInfo<$AuditLogsTable, AuditLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditLogsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<SyncStatus>($AuditLogsTable.$convertersyncStatus);
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
  static const VerificationMeta _actorUserIdMeta = const VerificationMeta(
    'actorUserId',
  );
  @override
  late final GeneratedColumn<String> actorUserId = GeneratedColumn<String>(
    'actor_user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actorNameMeta = const VerificationMeta(
    'actorName',
  );
  @override
  late final GeneratedColumn<String> actorName = GeneratedColumn<String>(
    'actor_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _routeMeta = const VerificationMeta('route');
  @override
  late final GeneratedColumn<String> route = GeneratedColumn<String>(
    'route',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _oldValuesJsonMeta = const VerificationMeta(
    'oldValuesJson',
  );
  @override
  late final GeneratedColumn<String> oldValuesJson = GeneratedColumn<String>(
    'old_values_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _newValuesJsonMeta = const VerificationMeta(
    'newValuesJson',
  );
  @override
  late final GeneratedColumn<String> newValuesJson = GeneratedColumn<String>(
    'new_values_json',
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
    actorUserId,
    actorName,
    action,
    entityType,
    entityId,
    title,
    description,
    route,
    oldValuesJson,
    newValuesJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuditLog> instance, {
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
    if (data.containsKey('actor_user_id')) {
      context.handle(
        _actorUserIdMeta,
        actorUserId.isAcceptableOrUnknown(
          data['actor_user_id']!,
          _actorUserIdMeta,
        ),
      );
    }
    if (data.containsKey('actor_name')) {
      context.handle(
        _actorNameMeta,
        actorName.isAcceptableOrUnknown(data['actor_name']!, _actorNameMeta),
      );
    } else if (isInserting) {
      context.missing(_actorNameMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('route')) {
      context.handle(
        _routeMeta,
        route.isAcceptableOrUnknown(data['route']!, _routeMeta),
      );
    }
    if (data.containsKey('old_values_json')) {
      context.handle(
        _oldValuesJsonMeta,
        oldValuesJson.isAcceptableOrUnknown(
          data['old_values_json']!,
          _oldValuesJsonMeta,
        ),
      );
    }
    if (data.containsKey('new_values_json')) {
      context.handle(
        _newValuesJsonMeta,
        newValuesJson.isAcceptableOrUnknown(
          data['new_values_json']!,
          _newValuesJsonMeta,
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
  AuditLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditLog(
      syncStatus: $AuditLogsTable.$convertersyncStatus.fromSql(
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
      actorUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_user_id'],
      ),
      actorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_name'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      route: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}route'],
      ),
      oldValuesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}old_values_json'],
      ),
      newValuesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}new_values_json'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AuditLogsTable createAlias(String alias) {
    return $AuditLogsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class AuditLog extends DataClass implements Insertable<AuditLog> {
  final SyncStatus syncStatus;
  final DateTime lastModifiedLocal;
  final String id;
  final String? actorUserId;
  final String actorName;
  final String action;
  final String entityType;
  final String? entityId;
  final String title;
  final String description;
  final String? route;
  final String? oldValuesJson;
  final String? newValuesJson;
  final DateTime createdAt;
  const AuditLog({
    required this.syncStatus,
    required this.lastModifiedLocal,
    required this.id,
    this.actorUserId,
    required this.actorName,
    required this.action,
    required this.entityType,
    this.entityId,
    required this.title,
    required this.description,
    this.route,
    this.oldValuesJson,
    this.newValuesJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['sync_status'] = Variable<int>(
        $AuditLogsTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['last_modified_local'] = Variable<DateTime>(lastModifiedLocal);
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || actorUserId != null) {
      map['actor_user_id'] = Variable<String>(actorUserId);
    }
    map['actor_name'] = Variable<String>(actorName);
    map['action'] = Variable<String>(action);
    map['entity_type'] = Variable<String>(entityType);
    if (!nullToAbsent || entityId != null) {
      map['entity_id'] = Variable<String>(entityId);
    }
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || route != null) {
      map['route'] = Variable<String>(route);
    }
    if (!nullToAbsent || oldValuesJson != null) {
      map['old_values_json'] = Variable<String>(oldValuesJson);
    }
    if (!nullToAbsent || newValuesJson != null) {
      map['new_values_json'] = Variable<String>(newValuesJson);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AuditLogsCompanion toCompanion(bool nullToAbsent) {
    return AuditLogsCompanion(
      syncStatus: Value(syncStatus),
      lastModifiedLocal: Value(lastModifiedLocal),
      id: Value(id),
      actorUserId: actorUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(actorUserId),
      actorName: Value(actorName),
      action: Value(action),
      entityType: Value(entityType),
      entityId: entityId == null && nullToAbsent
          ? const Value.absent()
          : Value(entityId),
      title: Value(title),
      description: Value(description),
      route: route == null && nullToAbsent
          ? const Value.absent()
          : Value(route),
      oldValuesJson: oldValuesJson == null && nullToAbsent
          ? const Value.absent()
          : Value(oldValuesJson),
      newValuesJson: newValuesJson == null && nullToAbsent
          ? const Value.absent()
          : Value(newValuesJson),
      createdAt: Value(createdAt),
    );
  }

  factory AuditLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditLog(
      syncStatus: $AuditLogsTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
      lastModifiedLocal: serializer.fromJson<DateTime>(
        json['lastModifiedLocal'],
      ),
      id: serializer.fromJson<String>(json['id']),
      actorUserId: serializer.fromJson<String?>(json['actorUserId']),
      actorName: serializer.fromJson<String>(json['actorName']),
      action: serializer.fromJson<String>(json['action']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String?>(json['entityId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      route: serializer.fromJson<String?>(json['route']),
      oldValuesJson: serializer.fromJson<String?>(json['oldValuesJson']),
      newValuesJson: serializer.fromJson<String?>(json['newValuesJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncStatus': serializer.toJson<int>(
        $AuditLogsTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'lastModifiedLocal': serializer.toJson<DateTime>(lastModifiedLocal),
      'id': serializer.toJson<String>(id),
      'actorUserId': serializer.toJson<String?>(actorUserId),
      'actorName': serializer.toJson<String>(actorName),
      'action': serializer.toJson<String>(action),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String?>(entityId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'route': serializer.toJson<String?>(route),
      'oldValuesJson': serializer.toJson<String?>(oldValuesJson),
      'newValuesJson': serializer.toJson<String?>(newValuesJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AuditLog copyWith({
    SyncStatus? syncStatus,
    DateTime? lastModifiedLocal,
    String? id,
    Value<String?> actorUserId = const Value.absent(),
    String? actorName,
    String? action,
    String? entityType,
    Value<String?> entityId = const Value.absent(),
    String? title,
    String? description,
    Value<String?> route = const Value.absent(),
    Value<String?> oldValuesJson = const Value.absent(),
    Value<String?> newValuesJson = const Value.absent(),
    DateTime? createdAt,
  }) => AuditLog(
    syncStatus: syncStatus ?? this.syncStatus,
    lastModifiedLocal: lastModifiedLocal ?? this.lastModifiedLocal,
    id: id ?? this.id,
    actorUserId: actorUserId.present ? actorUserId.value : this.actorUserId,
    actorName: actorName ?? this.actorName,
    action: action ?? this.action,
    entityType: entityType ?? this.entityType,
    entityId: entityId.present ? entityId.value : this.entityId,
    title: title ?? this.title,
    description: description ?? this.description,
    route: route.present ? route.value : this.route,
    oldValuesJson: oldValuesJson.present
        ? oldValuesJson.value
        : this.oldValuesJson,
    newValuesJson: newValuesJson.present
        ? newValuesJson.value
        : this.newValuesJson,
    createdAt: createdAt ?? this.createdAt,
  );
  AuditLog copyWithCompanion(AuditLogsCompanion data) {
    return AuditLog(
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastModifiedLocal: data.lastModifiedLocal.present
          ? data.lastModifiedLocal.value
          : this.lastModifiedLocal,
      id: data.id.present ? data.id.value : this.id,
      actorUserId: data.actorUserId.present
          ? data.actorUserId.value
          : this.actorUserId,
      actorName: data.actorName.present ? data.actorName.value : this.actorName,
      action: data.action.present ? data.action.value : this.action,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      route: data.route.present ? data.route.value : this.route,
      oldValuesJson: data.oldValuesJson.present
          ? data.oldValuesJson.value
          : this.oldValuesJson,
      newValuesJson: data.newValuesJson.present
          ? data.newValuesJson.value
          : this.newValuesJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditLog(')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedLocal: $lastModifiedLocal, ')
          ..write('id: $id, ')
          ..write('actorUserId: $actorUserId, ')
          ..write('actorName: $actorName, ')
          ..write('action: $action, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('route: $route, ')
          ..write('oldValuesJson: $oldValuesJson, ')
          ..write('newValuesJson: $newValuesJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    syncStatus,
    lastModifiedLocal,
    id,
    actorUserId,
    actorName,
    action,
    entityType,
    entityId,
    title,
    description,
    route,
    oldValuesJson,
    newValuesJson,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditLog &&
          other.syncStatus == this.syncStatus &&
          other.lastModifiedLocal == this.lastModifiedLocal &&
          other.id == this.id &&
          other.actorUserId == this.actorUserId &&
          other.actorName == this.actorName &&
          other.action == this.action &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.title == this.title &&
          other.description == this.description &&
          other.route == this.route &&
          other.oldValuesJson == this.oldValuesJson &&
          other.newValuesJson == this.newValuesJson &&
          other.createdAt == this.createdAt);
}

class AuditLogsCompanion extends UpdateCompanion<AuditLog> {
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> lastModifiedLocal;
  final Value<String> id;
  final Value<String?> actorUserId;
  final Value<String> actorName;
  final Value<String> action;
  final Value<String> entityType;
  final Value<String?> entityId;
  final Value<String> title;
  final Value<String> description;
  final Value<String?> route;
  final Value<String?> oldValuesJson;
  final Value<String?> newValuesJson;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AuditLogsCompanion({
    this.syncStatus = const Value.absent(),
    this.lastModifiedLocal = const Value.absent(),
    this.id = const Value.absent(),
    this.actorUserId = const Value.absent(),
    this.actorName = const Value.absent(),
    this.action = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.route = const Value.absent(),
    this.oldValuesJson = const Value.absent(),
    this.newValuesJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditLogsCompanion.insert({
    this.syncStatus = const Value.absent(),
    this.lastModifiedLocal = const Value.absent(),
    required String id,
    this.actorUserId = const Value.absent(),
    required String actorName,
    required String action,
    required String entityType,
    this.entityId = const Value.absent(),
    required String title,
    required String description,
    this.route = const Value.absent(),
    this.oldValuesJson = const Value.absent(),
    this.newValuesJson = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       actorName = Value(actorName),
       action = Value(action),
       entityType = Value(entityType),
       title = Value(title),
       description = Value(description),
       createdAt = Value(createdAt);
  static Insertable<AuditLog> custom({
    Expression<int>? syncStatus,
    Expression<DateTime>? lastModifiedLocal,
    Expression<String>? id,
    Expression<String>? actorUserId,
    Expression<String>? actorName,
    Expression<String>? action,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? route,
    Expression<String>? oldValuesJson,
    Expression<String>? newValuesJson,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastModifiedLocal != null) 'last_modified_local': lastModifiedLocal,
      if (id != null) 'id': id,
      if (actorUserId != null) 'actor_user_id': actorUserId,
      if (actorName != null) 'actor_name': actorName,
      if (action != null) 'action': action,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (route != null) 'route': route,
      if (oldValuesJson != null) 'old_values_json': oldValuesJson,
      if (newValuesJson != null) 'new_values_json': newValuesJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditLogsCompanion copyWith({
    Value<SyncStatus>? syncStatus,
    Value<DateTime>? lastModifiedLocal,
    Value<String>? id,
    Value<String?>? actorUserId,
    Value<String>? actorName,
    Value<String>? action,
    Value<String>? entityType,
    Value<String?>? entityId,
    Value<String>? title,
    Value<String>? description,
    Value<String?>? route,
    Value<String?>? oldValuesJson,
    Value<String?>? newValuesJson,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return AuditLogsCompanion(
      syncStatus: syncStatus ?? this.syncStatus,
      lastModifiedLocal: lastModifiedLocal ?? this.lastModifiedLocal,
      id: id ?? this.id,
      actorUserId: actorUserId ?? this.actorUserId,
      actorName: actorName ?? this.actorName,
      action: action ?? this.action,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      title: title ?? this.title,
      description: description ?? this.description,
      route: route ?? this.route,
      oldValuesJson: oldValuesJson ?? this.oldValuesJson,
      newValuesJson: newValuesJson ?? this.newValuesJson,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $AuditLogsTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (lastModifiedLocal.present) {
      map['last_modified_local'] = Variable<DateTime>(lastModifiedLocal.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (actorUserId.present) {
      map['actor_user_id'] = Variable<String>(actorUserId.value);
    }
    if (actorName.present) {
      map['actor_name'] = Variable<String>(actorName.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (route.present) {
      map['route'] = Variable<String>(route.value);
    }
    if (oldValuesJson.present) {
      map['old_values_json'] = Variable<String>(oldValuesJson.value);
    }
    if (newValuesJson.present) {
      map['new_values_json'] = Variable<String>(newValuesJson.value);
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
    return (StringBuffer('AuditLogsCompanion(')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedLocal: $lastModifiedLocal, ')
          ..write('id: $id, ')
          ..write('actorUserId: $actorUserId, ')
          ..write('actorName: $actorName, ')
          ..write('action: $action, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('route: $route, ')
          ..write('oldValuesJson: $oldValuesJson, ')
          ..write('newValuesJson: $newValuesJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookingPaymentsTable extends BookingPayments
    with TableInfo<$BookingPaymentsTable, BookingPayment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookingPaymentsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<SyncStatus>($BookingPaymentsTable.$convertersyncStatus);
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
  static const VerificationMeta _bookingIdMeta = const VerificationMeta(
    'bookingId',
  );
  @override
  late final GeneratedColumn<String> bookingId = GeneratedColumn<String>(
    'booking_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES summer_bookings (id)',
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
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('cash'),
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
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
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
    bookingId,
    amountEgp,
    paymentMethod,
    paymentDate,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'booking_payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookingPayment> instance, {
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
    if (data.containsKey('booking_id')) {
      context.handle(
        _bookingIdMeta,
        bookingId.isAcceptableOrUnknown(data['booking_id']!, _bookingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookingIdMeta);
    }
    if (data.containsKey('amount_egp')) {
      context.handle(
        _amountEgpMeta,
        amountEgp.isAcceptableOrUnknown(data['amount_egp']!, _amountEgpMeta),
      );
    } else if (isInserting) {
      context.missing(_amountEgpMeta);
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
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
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
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
  BookingPayment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookingPayment(
      syncStatus: $BookingPaymentsTable.$convertersyncStatus.fromSql(
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
      bookingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}booking_id'],
      )!,
      amountEgp: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount_egp'],
      )!,
      paymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method'],
      )!,
      paymentDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}payment_date'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BookingPaymentsTable createAlias(String alias) {
    return $BookingPaymentsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class BookingPayment extends DataClass implements Insertable<BookingPayment> {
  final SyncStatus syncStatus;
  final DateTime lastModifiedLocal;
  final String id;
  final String bookingId;
  final double amountEgp;
  final String paymentMethod;
  final DateTime paymentDate;
  final String? notes;
  final DateTime createdAt;
  const BookingPayment({
    required this.syncStatus,
    required this.lastModifiedLocal,
    required this.id,
    required this.bookingId,
    required this.amountEgp,
    required this.paymentMethod,
    required this.paymentDate,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['sync_status'] = Variable<int>(
        $BookingPaymentsTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['last_modified_local'] = Variable<DateTime>(lastModifiedLocal);
    map['id'] = Variable<String>(id);
    map['booking_id'] = Variable<String>(bookingId);
    map['amount_egp'] = Variable<double>(amountEgp);
    map['payment_method'] = Variable<String>(paymentMethod);
    map['payment_date'] = Variable<DateTime>(paymentDate);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BookingPaymentsCompanion toCompanion(bool nullToAbsent) {
    return BookingPaymentsCompanion(
      syncStatus: Value(syncStatus),
      lastModifiedLocal: Value(lastModifiedLocal),
      id: Value(id),
      bookingId: Value(bookingId),
      amountEgp: Value(amountEgp),
      paymentMethod: Value(paymentMethod),
      paymentDate: Value(paymentDate),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory BookingPayment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookingPayment(
      syncStatus: $BookingPaymentsTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
      lastModifiedLocal: serializer.fromJson<DateTime>(
        json['lastModifiedLocal'],
      ),
      id: serializer.fromJson<String>(json['id']),
      bookingId: serializer.fromJson<String>(json['bookingId']),
      amountEgp: serializer.fromJson<double>(json['amountEgp']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      paymentDate: serializer.fromJson<DateTime>(json['paymentDate']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncStatus': serializer.toJson<int>(
        $BookingPaymentsTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'lastModifiedLocal': serializer.toJson<DateTime>(lastModifiedLocal),
      'id': serializer.toJson<String>(id),
      'bookingId': serializer.toJson<String>(bookingId),
      'amountEgp': serializer.toJson<double>(amountEgp),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'paymentDate': serializer.toJson<DateTime>(paymentDate),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BookingPayment copyWith({
    SyncStatus? syncStatus,
    DateTime? lastModifiedLocal,
    String? id,
    String? bookingId,
    double? amountEgp,
    String? paymentMethod,
    DateTime? paymentDate,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => BookingPayment(
    syncStatus: syncStatus ?? this.syncStatus,
    lastModifiedLocal: lastModifiedLocal ?? this.lastModifiedLocal,
    id: id ?? this.id,
    bookingId: bookingId ?? this.bookingId,
    amountEgp: amountEgp ?? this.amountEgp,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    paymentDate: paymentDate ?? this.paymentDate,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  BookingPayment copyWithCompanion(BookingPaymentsCompanion data) {
    return BookingPayment(
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastModifiedLocal: data.lastModifiedLocal.present
          ? data.lastModifiedLocal.value
          : this.lastModifiedLocal,
      id: data.id.present ? data.id.value : this.id,
      bookingId: data.bookingId.present ? data.bookingId.value : this.bookingId,
      amountEgp: data.amountEgp.present ? data.amountEgp.value : this.amountEgp,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      paymentDate: data.paymentDate.present
          ? data.paymentDate.value
          : this.paymentDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookingPayment(')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedLocal: $lastModifiedLocal, ')
          ..write('id: $id, ')
          ..write('bookingId: $bookingId, ')
          ..write('amountEgp: $amountEgp, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    syncStatus,
    lastModifiedLocal,
    id,
    bookingId,
    amountEgp,
    paymentMethod,
    paymentDate,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookingPayment &&
          other.syncStatus == this.syncStatus &&
          other.lastModifiedLocal == this.lastModifiedLocal &&
          other.id == this.id &&
          other.bookingId == this.bookingId &&
          other.amountEgp == this.amountEgp &&
          other.paymentMethod == this.paymentMethod &&
          other.paymentDate == this.paymentDate &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class BookingPaymentsCompanion extends UpdateCompanion<BookingPayment> {
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> lastModifiedLocal;
  final Value<String> id;
  final Value<String> bookingId;
  final Value<double> amountEgp;
  final Value<String> paymentMethod;
  final Value<DateTime> paymentDate;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BookingPaymentsCompanion({
    this.syncStatus = const Value.absent(),
    this.lastModifiedLocal = const Value.absent(),
    this.id = const Value.absent(),
    this.bookingId = const Value.absent(),
    this.amountEgp = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.paymentDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookingPaymentsCompanion.insert({
    this.syncStatus = const Value.absent(),
    this.lastModifiedLocal = const Value.absent(),
    required String id,
    required String bookingId,
    required double amountEgp,
    this.paymentMethod = const Value.absent(),
    required DateTime paymentDate,
    this.notes = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       bookingId = Value(bookingId),
       amountEgp = Value(amountEgp),
       paymentDate = Value(paymentDate),
       createdAt = Value(createdAt);
  static Insertable<BookingPayment> custom({
    Expression<int>? syncStatus,
    Expression<DateTime>? lastModifiedLocal,
    Expression<String>? id,
    Expression<String>? bookingId,
    Expression<double>? amountEgp,
    Expression<String>? paymentMethod,
    Expression<DateTime>? paymentDate,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastModifiedLocal != null) 'last_modified_local': lastModifiedLocal,
      if (id != null) 'id': id,
      if (bookingId != null) 'booking_id': bookingId,
      if (amountEgp != null) 'amount_egp': amountEgp,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (paymentDate != null) 'payment_date': paymentDate,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookingPaymentsCompanion copyWith({
    Value<SyncStatus>? syncStatus,
    Value<DateTime>? lastModifiedLocal,
    Value<String>? id,
    Value<String>? bookingId,
    Value<double>? amountEgp,
    Value<String>? paymentMethod,
    Value<DateTime>? paymentDate,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return BookingPaymentsCompanion(
      syncStatus: syncStatus ?? this.syncStatus,
      lastModifiedLocal: lastModifiedLocal ?? this.lastModifiedLocal,
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      amountEgp: amountEgp ?? this.amountEgp,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentDate: paymentDate ?? this.paymentDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $BookingPaymentsTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (lastModifiedLocal.present) {
      map['last_modified_local'] = Variable<DateTime>(lastModifiedLocal.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bookingId.present) {
      map['booking_id'] = Variable<String>(bookingId.value);
    }
    if (amountEgp.present) {
      map['amount_egp'] = Variable<double>(amountEgp.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (paymentDate.present) {
      map['payment_date'] = Variable<DateTime>(paymentDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
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
    return (StringBuffer('BookingPaymentsCompanion(')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedLocal: $lastModifiedLocal, ')
          ..write('id: $id, ')
          ..write('bookingId: $bookingId, ')
          ..write('amountEgp: $amountEgp, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $BuildingsTable buildings = $BuildingsTable(this);
  late final $ApartmentsTable apartments = $ApartmentsTable(this);
  late final $SummerBookingsTable summerBookings = $SummerBookingsTable(this);
  late final $WinterContractsTable winterContracts = $WinterContractsTable(
    this,
  );
  late final $WinterPaymentsTable winterPayments = $WinterPaymentsTable(this);
  late final $MeterReadingsTable meterReadings = $MeterReadingsTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final $FinancialTransfersTable financialTransfers =
      $FinancialTransfersTable(this);
  late final $TechniciansTable technicians = $TechniciansTable(this);
  late final $CleaningSuppliesTable cleaningSupplies = $CleaningSuppliesTable(
    this,
  );
  late final $CleaningTransactionsTable cleaningTransactions =
      $CleaningTransactionsTable(this);
  late final $ApartmentInspectionsTable apartmentInspections =
      $ApartmentInspectionsTable(this);
  late final $MaintenanceRequestsTable maintenanceRequests =
      $MaintenanceRequestsTable(this);
  late final $AuditLogsTable auditLogs = $AuditLogsTable(this);
  late final $BookingPaymentsTable bookingPayments = $BookingPaymentsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userProfiles,
    buildings,
    apartments,
    summerBookings,
    winterContracts,
    winterPayments,
    meterReadings,
    expenses,
    financialTransfers,
    technicians,
    cleaningSupplies,
    cleaningTransactions,
    apartmentInspections,
    maintenanceRequests,
    auditLogs,
    bookingPayments,
  ];
}

typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<SyncStatus> syncStatus,
      Value<DateTime> lastModifiedLocal,
      required String id,
      required String email,
      Value<String?> fullName,
      Value<String?> phoneNumber,
      Value<String?> secondaryPhone,
      Value<String> role,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<SyncStatus> syncStatus,
      Value<DateTime> lastModifiedLocal,
      Value<String> id,
      Value<String> email,
      Value<String?> fullName,
      Value<String?> phoneNumber,
      Value<String?> secondaryPhone,
      Value<String> role,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
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

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get secondaryPhone => $composableBuilder(
    column: $table.secondaryPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
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
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
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

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get secondaryPhone => $composableBuilder(
    column: $table.secondaryPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
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
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
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

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get secondaryPhone => $composableBuilder(
    column: $table.secondaryPhone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTable,
          UserProfile,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (
            UserProfile,
            BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
          ),
          UserProfile,
          PrefetchHooks Function()
        > {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> lastModifiedLocal = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String?> fullName = const Value.absent(),
                Value<String?> phoneNumber = const Value.absent(),
                Value<String?> secondaryPhone = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProfilesCompanion(
                syncStatus: syncStatus,
                lastModifiedLocal: lastModifiedLocal,
                id: id,
                email: email,
                fullName: fullName,
                phoneNumber: phoneNumber,
                secondaryPhone: secondaryPhone,
                role: role,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> lastModifiedLocal = const Value.absent(),
                required String id,
                required String email,
                Value<String?> fullName = const Value.absent(),
                Value<String?> phoneNumber = const Value.absent(),
                Value<String?> secondaryPhone = const Value.absent(),
                Value<String> role = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => UserProfilesCompanion.insert(
                syncStatus: syncStatus,
                lastModifiedLocal: lastModifiedLocal,
                id: id,
                email: email,
                fullName: fullName,
                phoneNumber: phoneNumber,
                secondaryPhone: secondaryPhone,
                role: role,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTable,
      UserProfile,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (
        UserProfile,
        BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
      ),
      UserProfile,
      PrefetchHooks Function()
    >;
typedef $$BuildingsTableCreateCompanionBuilder =
    BuildingsCompanion Function({
      Value<SyncStatus> syncStatus,
      Value<DateTime> lastModifiedLocal,
      required String id,
      required String name,
      Value<String?> address,
      Value<double> annualRentEgp,
      Value<String?> rentInstallmentsDates,
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
      Value<double> annualRentEgp,
      Value<String?> rentInstallmentsDates,
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

  ColumnFilters<double> get annualRentEgp => $composableBuilder(
    column: $table.annualRentEgp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rentInstallmentsDates => $composableBuilder(
    column: $table.rentInstallmentsDates,
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

  ColumnOrderings<double> get annualRentEgp => $composableBuilder(
    column: $table.annualRentEgp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rentInstallmentsDates => $composableBuilder(
    column: $table.rentInstallmentsDates,
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

  GeneratedColumn<double> get annualRentEgp => $composableBuilder(
    column: $table.annualRentEgp,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rentInstallmentsDates => $composableBuilder(
    column: $table.rentInstallmentsDates,
    builder: (column) => column,
  );

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
                Value<double> annualRentEgp = const Value.absent(),
                Value<String?> rentInstallmentsDates = const Value.absent(),
                Value<int> totalApartments = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BuildingsCompanion(
                syncStatus: syncStatus,
                lastModifiedLocal: lastModifiedLocal,
                id: id,
                name: name,
                address: address,
                annualRentEgp: annualRentEgp,
                rentInstallmentsDates: rentInstallmentsDates,
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
                Value<double> annualRentEgp = const Value.absent(),
                Value<String?> rentInstallmentsDates = const Value.absent(),
                Value<int> totalApartments = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => BuildingsCompanion.insert(
                syncStatus: syncStatus,
                lastModifiedLocal: lastModifiedLocal,
                id: id,
                name: name,
                address: address,
                annualRentEgp: annualRentEgp,
                rentInstallmentsDates: rentInstallmentsDates,
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
      Value<String?> inventory,
      Value<String?> landlineNumber,
      Value<String?> landlineOwnerName,
      Value<String?> landlineNotes,
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
      Value<String?> inventory,
      Value<String?> landlineNumber,
      Value<String?> landlineOwnerName,
      Value<String?> landlineNotes,
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
    $ApartmentInspectionsTable,
    List<ApartmentInspection>
  >
  _apartmentInspectionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.apartmentInspections,
        aliasName: $_aliasNameGenerator(
          db.apartments.id,
          db.apartmentInspections.apartmentId,
        ),
      );

  $$ApartmentInspectionsTableProcessedTableManager
  get apartmentInspectionsRefs {
    final manager = $$ApartmentInspectionsTableTableManager(
      $_db,
      $_db.apartmentInspections,
    ).filter((f) => f.apartmentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _apartmentInspectionsRefsTable($_db),
    );
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

  ColumnFilters<String> get inventory => $composableBuilder(
    column: $table.inventory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get landlineNumber => $composableBuilder(
    column: $table.landlineNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get landlineOwnerName => $composableBuilder(
    column: $table.landlineOwnerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get landlineNotes => $composableBuilder(
    column: $table.landlineNotes,
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

  Expression<bool> apartmentInspectionsRefs(
    Expression<bool> Function($$ApartmentInspectionsTableFilterComposer f) f,
  ) {
    final $$ApartmentInspectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.apartmentInspections,
      getReferencedColumn: (t) => t.apartmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApartmentInspectionsTableFilterComposer(
            $db: $db,
            $table: $db.apartmentInspections,
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

  ColumnOrderings<String> get inventory => $composableBuilder(
    column: $table.inventory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get landlineNumber => $composableBuilder(
    column: $table.landlineNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get landlineOwnerName => $composableBuilder(
    column: $table.landlineOwnerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get landlineNotes => $composableBuilder(
    column: $table.landlineNotes,
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

  GeneratedColumn<String> get inventory =>
      $composableBuilder(column: $table.inventory, builder: (column) => column);

  GeneratedColumn<String> get landlineNumber => $composableBuilder(
    column: $table.landlineNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get landlineOwnerName => $composableBuilder(
    column: $table.landlineOwnerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get landlineNotes => $composableBuilder(
    column: $table.landlineNotes,
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

  Expression<T> apartmentInspectionsRefs<T extends Object>(
    Expression<T> Function($$ApartmentInspectionsTableAnnotationComposer a) f,
  ) {
    final $$ApartmentInspectionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.apartmentInspections,
          getReferencedColumn: (t) => t.apartmentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ApartmentInspectionsTableAnnotationComposer(
                $db: $db,
                $table: $db.apartmentInspections,
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
            bool apartmentInspectionsRefs,
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
                Value<String?> inventory = const Value.absent(),
                Value<String?> landlineNumber = const Value.absent(),
                Value<String?> landlineOwnerName = const Value.absent(),
                Value<String?> landlineNotes = const Value.absent(),
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
                inventory: inventory,
                landlineNumber: landlineNumber,
                landlineOwnerName: landlineOwnerName,
                landlineNotes: landlineNotes,
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
                Value<String?> inventory = const Value.absent(),
                Value<String?> landlineNumber = const Value.absent(),
                Value<String?> landlineOwnerName = const Value.absent(),
                Value<String?> landlineNotes = const Value.absent(),
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
                inventory: inventory,
                landlineNumber: landlineNumber,
                landlineOwnerName: landlineOwnerName,
                landlineNotes: landlineNotes,
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
                apartmentInspectionsRefs = false,
                maintenanceRequestsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (summerBookingsRefs) db.summerBookings,
                    if (winterContractsRefs) db.winterContracts,
                    if (meterReadingsRefs) db.meterReadings,
                    if (expensesRefs) db.expenses,
                    if (apartmentInspectionsRefs) db.apartmentInspections,
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
                      if (apartmentInspectionsRefs)
                        await $_getPrefetchedData<
                          Apartment,
                          $ApartmentsTable,
                          ApartmentInspection
                        >(
                          currentTable: table,
                          referencedTable: $$ApartmentsTableReferences
                              ._apartmentInspectionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ApartmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).apartmentInspectionsRefs,
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
        bool apartmentInspectionsRefs,
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
      Value<String> paymentMethod,
      Value<String?> brokerId,
      Value<String?> brokerName,
      Value<String> brokerCommissionType,
      Value<double> brokerCommissionPercentage,
      Value<double> brokerCommissionFixedEgp,
      Value<double?> brokerCommissionAmountEgp,
      Value<DateTime?> earlyCheckoutDate,
      Value<int> overstayDays,
      Value<double> overstayFeeEgp,
      Value<String?> nationalId,
      Value<String?> idFrontImage,
      Value<String?> idBackImage,
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
      Value<String> paymentMethod,
      Value<String?> brokerId,
      Value<String?> brokerName,
      Value<String> brokerCommissionType,
      Value<double> brokerCommissionPercentage,
      Value<double> brokerCommissionFixedEgp,
      Value<double?> brokerCommissionAmountEgp,
      Value<DateTime?> earlyCheckoutDate,
      Value<int> overstayDays,
      Value<double> overstayFeeEgp,
      Value<String?> nationalId,
      Value<String?> idFrontImage,
      Value<String?> idBackImage,
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

  static MultiTypedResultKey<$BookingPaymentsTable, List<BookingPayment>>
  _bookingPaymentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.bookingPayments,
    aliasName: $_aliasNameGenerator(
      db.summerBookings.id,
      db.bookingPayments.bookingId,
    ),
  );

  $$BookingPaymentsTableProcessedTableManager get bookingPaymentsRefs {
    final manager = $$BookingPaymentsTableTableManager(
      $_db,
      $_db.bookingPayments,
    ).filter((f) => f.bookingId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _bookingPaymentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
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

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brokerId => $composableBuilder(
    column: $table.brokerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brokerName => $composableBuilder(
    column: $table.brokerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brokerCommissionType => $composableBuilder(
    column: $table.brokerCommissionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get brokerCommissionPercentage => $composableBuilder(
    column: $table.brokerCommissionPercentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get brokerCommissionFixedEgp => $composableBuilder(
    column: $table.brokerCommissionFixedEgp,
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

  ColumnFilters<String> get nationalId => $composableBuilder(
    column: $table.nationalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idFrontImage => $composableBuilder(
    column: $table.idFrontImage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idBackImage => $composableBuilder(
    column: $table.idBackImage,
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

  Expression<bool> bookingPaymentsRefs(
    Expression<bool> Function($$BookingPaymentsTableFilterComposer f) f,
  ) {
    final $$BookingPaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookingPayments,
      getReferencedColumn: (t) => t.bookingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookingPaymentsTableFilterComposer(
            $db: $db,
            $table: $db.bookingPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
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

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brokerId => $composableBuilder(
    column: $table.brokerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brokerName => $composableBuilder(
    column: $table.brokerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brokerCommissionType => $composableBuilder(
    column: $table.brokerCommissionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get brokerCommissionPercentage => $composableBuilder(
    column: $table.brokerCommissionPercentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get brokerCommissionFixedEgp => $composableBuilder(
    column: $table.brokerCommissionFixedEgp,
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

  ColumnOrderings<String> get nationalId => $composableBuilder(
    column: $table.nationalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idFrontImage => $composableBuilder(
    column: $table.idFrontImage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idBackImage => $composableBuilder(
    column: $table.idBackImage,
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

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get brokerId =>
      $composableBuilder(column: $table.brokerId, builder: (column) => column);

  GeneratedColumn<String> get brokerName => $composableBuilder(
    column: $table.brokerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get brokerCommissionType => $composableBuilder(
    column: $table.brokerCommissionType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get brokerCommissionPercentage => $composableBuilder(
    column: $table.brokerCommissionPercentage,
    builder: (column) => column,
  );

  GeneratedColumn<double> get brokerCommissionFixedEgp => $composableBuilder(
    column: $table.brokerCommissionFixedEgp,
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

  GeneratedColumn<String> get nationalId => $composableBuilder(
    column: $table.nationalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get idFrontImage => $composableBuilder(
    column: $table.idFrontImage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get idBackImage => $composableBuilder(
    column: $table.idBackImage,
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

  Expression<T> bookingPaymentsRefs<T extends Object>(
    Expression<T> Function($$BookingPaymentsTableAnnotationComposer a) f,
  ) {
    final $$BookingPaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookingPayments,
      getReferencedColumn: (t) => t.bookingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookingPaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.bookingPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
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
          PrefetchHooks Function({bool apartmentId, bool bookingPaymentsRefs})
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
                Value<String> paymentMethod = const Value.absent(),
                Value<String?> brokerId = const Value.absent(),
                Value<String?> brokerName = const Value.absent(),
                Value<String> brokerCommissionType = const Value.absent(),
                Value<double> brokerCommissionPercentage = const Value.absent(),
                Value<double> brokerCommissionFixedEgp = const Value.absent(),
                Value<double?> brokerCommissionAmountEgp = const Value.absent(),
                Value<DateTime?> earlyCheckoutDate = const Value.absent(),
                Value<int> overstayDays = const Value.absent(),
                Value<double> overstayFeeEgp = const Value.absent(),
                Value<String?> nationalId = const Value.absent(),
                Value<String?> idFrontImage = const Value.absent(),
                Value<String?> idBackImage = const Value.absent(),
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
                paymentMethod: paymentMethod,
                brokerId: brokerId,
                brokerName: brokerName,
                brokerCommissionType: brokerCommissionType,
                brokerCommissionPercentage: brokerCommissionPercentage,
                brokerCommissionFixedEgp: brokerCommissionFixedEgp,
                brokerCommissionAmountEgp: brokerCommissionAmountEgp,
                earlyCheckoutDate: earlyCheckoutDate,
                overstayDays: overstayDays,
                overstayFeeEgp: overstayFeeEgp,
                nationalId: nationalId,
                idFrontImage: idFrontImage,
                idBackImage: idBackImage,
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
                Value<String> paymentMethod = const Value.absent(),
                Value<String?> brokerId = const Value.absent(),
                Value<String?> brokerName = const Value.absent(),
                Value<String> brokerCommissionType = const Value.absent(),
                Value<double> brokerCommissionPercentage = const Value.absent(),
                Value<double> brokerCommissionFixedEgp = const Value.absent(),
                Value<double?> brokerCommissionAmountEgp = const Value.absent(),
                Value<DateTime?> earlyCheckoutDate = const Value.absent(),
                Value<int> overstayDays = const Value.absent(),
                Value<double> overstayFeeEgp = const Value.absent(),
                Value<String?> nationalId = const Value.absent(),
                Value<String?> idFrontImage = const Value.absent(),
                Value<String?> idBackImage = const Value.absent(),
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
                paymentMethod: paymentMethod,
                brokerId: brokerId,
                brokerName: brokerName,
                brokerCommissionType: brokerCommissionType,
                brokerCommissionPercentage: brokerCommissionPercentage,
                brokerCommissionFixedEgp: brokerCommissionFixedEgp,
                brokerCommissionAmountEgp: brokerCommissionAmountEgp,
                earlyCheckoutDate: earlyCheckoutDate,
                overstayDays: overstayDays,
                overstayFeeEgp: overstayFeeEgp,
                nationalId: nationalId,
                idFrontImage: idFrontImage,
                idBackImage: idBackImage,
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
          prefetchHooksCallback:
              ({apartmentId = false, bookingPaymentsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (bookingPaymentsRefs) db.bookingPayments,
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
                                        $$SummerBookingsTableReferences
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
                    return [
                      if (bookingPaymentsRefs)
                        await $_getPrefetchedData<
                          SummerBooking,
                          $SummerBookingsTable,
                          BookingPayment
                        >(
                          currentTable: table,
                          referencedTable: $$SummerBookingsTableReferences
                              ._bookingPaymentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SummerBookingsTableReferences(
                                db,
                                table,
                                p0,
                              ).bookingPaymentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bookingId == item.id,
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
      PrefetchHooks Function({bool apartmentId, bool bookingPaymentsRefs})
    >;
typedef $$WinterContractsTableCreateCompanionBuilder =
    WinterContractsCompanion Function({
      Value<SyncStatus> syncStatus,
      Value<DateTime> lastModifiedLocal,
      required String id,
      required String apartmentId,
      Value<String> contractType,
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
      Value<bool> isElectricityOnStudent,
      Value<bool> isGasOnStudent,
      Value<bool> isWaterOnStudent,
      Value<String?> roommates,
      Value<String?> nationalId,
      Value<String?> idFrontImage,
      Value<String?> idBackImage,
      Value<String?> contractFrontImage,
      Value<String?> contractBackImage,
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
      Value<String> contractType,
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
      Value<bool> isElectricityOnStudent,
      Value<bool> isGasOnStudent,
      Value<bool> isWaterOnStudent,
      Value<String?> roommates,
      Value<String?> nationalId,
      Value<String?> idFrontImage,
      Value<String?> idBackImage,
      Value<String?> contractFrontImage,
      Value<String?> contractBackImage,
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

  ColumnFilters<String> get contractType => $composableBuilder(
    column: $table.contractType,
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

  ColumnFilters<bool> get isElectricityOnStudent => $composableBuilder(
    column: $table.isElectricityOnStudent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isGasOnStudent => $composableBuilder(
    column: $table.isGasOnStudent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isWaterOnStudent => $composableBuilder(
    column: $table.isWaterOnStudent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roommates => $composableBuilder(
    column: $table.roommates,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nationalId => $composableBuilder(
    column: $table.nationalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idFrontImage => $composableBuilder(
    column: $table.idFrontImage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idBackImage => $composableBuilder(
    column: $table.idBackImage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contractFrontImage => $composableBuilder(
    column: $table.contractFrontImage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contractBackImage => $composableBuilder(
    column: $table.contractBackImage,
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

  ColumnOrderings<String> get contractType => $composableBuilder(
    column: $table.contractType,
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

  ColumnOrderings<bool> get isElectricityOnStudent => $composableBuilder(
    column: $table.isElectricityOnStudent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isGasOnStudent => $composableBuilder(
    column: $table.isGasOnStudent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isWaterOnStudent => $composableBuilder(
    column: $table.isWaterOnStudent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roommates => $composableBuilder(
    column: $table.roommates,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nationalId => $composableBuilder(
    column: $table.nationalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idFrontImage => $composableBuilder(
    column: $table.idFrontImage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idBackImage => $composableBuilder(
    column: $table.idBackImage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contractFrontImage => $composableBuilder(
    column: $table.contractFrontImage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contractBackImage => $composableBuilder(
    column: $table.contractBackImage,
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

  GeneratedColumn<String> get contractType => $composableBuilder(
    column: $table.contractType,
    builder: (column) => column,
  );

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

  GeneratedColumn<bool> get isElectricityOnStudent => $composableBuilder(
    column: $table.isElectricityOnStudent,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isGasOnStudent => $composableBuilder(
    column: $table.isGasOnStudent,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isWaterOnStudent => $composableBuilder(
    column: $table.isWaterOnStudent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get roommates =>
      $composableBuilder(column: $table.roommates, builder: (column) => column);

  GeneratedColumn<String> get nationalId => $composableBuilder(
    column: $table.nationalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get idFrontImage => $composableBuilder(
    column: $table.idFrontImage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get idBackImage => $composableBuilder(
    column: $table.idBackImage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contractFrontImage => $composableBuilder(
    column: $table.contractFrontImage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contractBackImage => $composableBuilder(
    column: $table.contractBackImage,
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
                Value<String> contractType = const Value.absent(),
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
                Value<bool> isElectricityOnStudent = const Value.absent(),
                Value<bool> isGasOnStudent = const Value.absent(),
                Value<bool> isWaterOnStudent = const Value.absent(),
                Value<String?> roommates = const Value.absent(),
                Value<String?> nationalId = const Value.absent(),
                Value<String?> idFrontImage = const Value.absent(),
                Value<String?> idBackImage = const Value.absent(),
                Value<String?> contractFrontImage = const Value.absent(),
                Value<String?> contractBackImage = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WinterContractsCompanion(
                syncStatus: syncStatus,
                lastModifiedLocal: lastModifiedLocal,
                id: id,
                apartmentId: apartmentId,
                contractType: contractType,
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
                isElectricityOnStudent: isElectricityOnStudent,
                isGasOnStudent: isGasOnStudent,
                isWaterOnStudent: isWaterOnStudent,
                roommates: roommates,
                nationalId: nationalId,
                idFrontImage: idFrontImage,
                idBackImage: idBackImage,
                contractFrontImage: contractFrontImage,
                contractBackImage: contractBackImage,
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
                Value<String> contractType = const Value.absent(),
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
                Value<bool> isElectricityOnStudent = const Value.absent(),
                Value<bool> isGasOnStudent = const Value.absent(),
                Value<bool> isWaterOnStudent = const Value.absent(),
                Value<String?> roommates = const Value.absent(),
                Value<String?> nationalId = const Value.absent(),
                Value<String?> idFrontImage = const Value.absent(),
                Value<String?> idBackImage = const Value.absent(),
                Value<String?> contractFrontImage = const Value.absent(),
                Value<String?> contractBackImage = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => WinterContractsCompanion.insert(
                syncStatus: syncStatus,
                lastModifiedLocal: lastModifiedLocal,
                id: id,
                apartmentId: apartmentId,
                contractType: contractType,
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
                isElectricityOnStudent: isElectricityOnStudent,
                isGasOnStudent: isGasOnStudent,
                isWaterOnStudent: isWaterOnStudent,
                roommates: roommates,
                nationalId: nationalId,
                idFrontImage: idFrontImage,
                idBackImage: idBackImage,
                contractFrontImage: contractFrontImage,
                contractBackImage: contractBackImage,
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
      Value<String> paymentMethod,
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
      Value<String> paymentMethod,
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

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
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

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
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

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
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
                Value<String> paymentMethod = const Value.absent(),
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
                paymentMethod: paymentMethod,
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
                Value<String> paymentMethod = const Value.absent(),
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
                paymentMethod: paymentMethod,
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
      Value<String> paymentMethod,
      Value<String> season,
      Value<double> discountEgp,
      Value<String?> discountReason,
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
      Value<String> paymentMethod,
      Value<String> season,
      Value<double> discountEgp,
      Value<String?> discountReason,
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

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get season => $composableBuilder(
    column: $table.season,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get discountEgp => $composableBuilder(
    column: $table.discountEgp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get discountReason => $composableBuilder(
    column: $table.discountReason,
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

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get season => $composableBuilder(
    column: $table.season,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get discountEgp => $composableBuilder(
    column: $table.discountEgp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get discountReason => $composableBuilder(
    column: $table.discountReason,
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

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get season =>
      $composableBuilder(column: $table.season, builder: (column) => column);

  GeneratedColumn<double> get discountEgp => $composableBuilder(
    column: $table.discountEgp,
    builder: (column) => column,
  );

  GeneratedColumn<String> get discountReason => $composableBuilder(
    column: $table.discountReason,
    builder: (column) => column,
  );

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
                Value<String> paymentMethod = const Value.absent(),
                Value<String> season = const Value.absent(),
                Value<double> discountEgp = const Value.absent(),
                Value<String?> discountReason = const Value.absent(),
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
                paymentMethod: paymentMethod,
                season: season,
                discountEgp: discountEgp,
                discountReason: discountReason,
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
                Value<String> paymentMethod = const Value.absent(),
                Value<String> season = const Value.absent(),
                Value<double> discountEgp = const Value.absent(),
                Value<String?> discountReason = const Value.absent(),
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
                paymentMethod: paymentMethod,
                season: season,
                discountEgp: discountEgp,
                discountReason: discountReason,
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
typedef $$FinancialTransfersTableCreateCompanionBuilder =
    FinancialTransfersCompanion Function({
      Value<SyncStatus> syncStatus,
      Value<DateTime> lastModifiedLocal,
      required String id,
      required String fromAccount,
      required String toAccount,
      Value<String> transferType,
      Value<String> season,
      required double amountEgp,
      required DateTime transferDate,
      Value<String?> notes,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$FinancialTransfersTableUpdateCompanionBuilder =
    FinancialTransfersCompanion Function({
      Value<SyncStatus> syncStatus,
      Value<DateTime> lastModifiedLocal,
      Value<String> id,
      Value<String> fromAccount,
      Value<String> toAccount,
      Value<String> transferType,
      Value<String> season,
      Value<double> amountEgp,
      Value<DateTime> transferDate,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$FinancialTransfersTableFilterComposer
    extends Composer<_$AppDatabase, $FinancialTransfersTable> {
  $$FinancialTransfersTableFilterComposer({
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

  ColumnFilters<String> get fromAccount => $composableBuilder(
    column: $table.fromAccount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toAccount => $composableBuilder(
    column: $table.toAccount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transferType => $composableBuilder(
    column: $table.transferType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get season => $composableBuilder(
    column: $table.season,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amountEgp => $composableBuilder(
    column: $table.amountEgp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get transferDate => $composableBuilder(
    column: $table.transferDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FinancialTransfersTableOrderingComposer
    extends Composer<_$AppDatabase, $FinancialTransfersTable> {
  $$FinancialTransfersTableOrderingComposer({
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

  ColumnOrderings<String> get fromAccount => $composableBuilder(
    column: $table.fromAccount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toAccount => $composableBuilder(
    column: $table.toAccount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transferType => $composableBuilder(
    column: $table.transferType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get season => $composableBuilder(
    column: $table.season,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amountEgp => $composableBuilder(
    column: $table.amountEgp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get transferDate => $composableBuilder(
    column: $table.transferDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FinancialTransfersTableAnnotationComposer
    extends Composer<_$AppDatabase, $FinancialTransfersTable> {
  $$FinancialTransfersTableAnnotationComposer({
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

  GeneratedColumn<String> get fromAccount => $composableBuilder(
    column: $table.fromAccount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get toAccount =>
      $composableBuilder(column: $table.toAccount, builder: (column) => column);

  GeneratedColumn<String> get transferType => $composableBuilder(
    column: $table.transferType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get season =>
      $composableBuilder(column: $table.season, builder: (column) => column);

  GeneratedColumn<double> get amountEgp =>
      $composableBuilder(column: $table.amountEgp, builder: (column) => column);

  GeneratedColumn<DateTime> get transferDate => $composableBuilder(
    column: $table.transferDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FinancialTransfersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FinancialTransfersTable,
          FinancialTransfer,
          $$FinancialTransfersTableFilterComposer,
          $$FinancialTransfersTableOrderingComposer,
          $$FinancialTransfersTableAnnotationComposer,
          $$FinancialTransfersTableCreateCompanionBuilder,
          $$FinancialTransfersTableUpdateCompanionBuilder,
          (
            FinancialTransfer,
            BaseReferences<
              _$AppDatabase,
              $FinancialTransfersTable,
              FinancialTransfer
            >,
          ),
          FinancialTransfer,
          PrefetchHooks Function()
        > {
  $$FinancialTransfersTableTableManager(
    _$AppDatabase db,
    $FinancialTransfersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FinancialTransfersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FinancialTransfersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FinancialTransfersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> lastModifiedLocal = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> fromAccount = const Value.absent(),
                Value<String> toAccount = const Value.absent(),
                Value<String> transferType = const Value.absent(),
                Value<String> season = const Value.absent(),
                Value<double> amountEgp = const Value.absent(),
                Value<DateTime> transferDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FinancialTransfersCompanion(
                syncStatus: syncStatus,
                lastModifiedLocal: lastModifiedLocal,
                id: id,
                fromAccount: fromAccount,
                toAccount: toAccount,
                transferType: transferType,
                season: season,
                amountEgp: amountEgp,
                transferDate: transferDate,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> lastModifiedLocal = const Value.absent(),
                required String id,
                required String fromAccount,
                required String toAccount,
                Value<String> transferType = const Value.absent(),
                Value<String> season = const Value.absent(),
                required double amountEgp,
                required DateTime transferDate,
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => FinancialTransfersCompanion.insert(
                syncStatus: syncStatus,
                lastModifiedLocal: lastModifiedLocal,
                id: id,
                fromAccount: fromAccount,
                toAccount: toAccount,
                transferType: transferType,
                season: season,
                amountEgp: amountEgp,
                transferDate: transferDate,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FinancialTransfersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FinancialTransfersTable,
      FinancialTransfer,
      $$FinancialTransfersTableFilterComposer,
      $$FinancialTransfersTableOrderingComposer,
      $$FinancialTransfersTableAnnotationComposer,
      $$FinancialTransfersTableCreateCompanionBuilder,
      $$FinancialTransfersTableUpdateCompanionBuilder,
      (
        FinancialTransfer,
        BaseReferences<
          _$AppDatabase,
          $FinancialTransfersTable,
          FinancialTransfer
        >,
      ),
      FinancialTransfer,
      PrefetchHooks Function()
    >;
typedef $$TechniciansTableCreateCompanionBuilder =
    TechniciansCompanion Function({
      Value<SyncStatus> syncStatus,
      Value<DateTime> lastModifiedLocal,
      required String id,
      required String name,
      Value<String?> phone,
      Value<String?> secondaryPhone,
      required String specialty,
      Value<String?> notes,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$TechniciansTableUpdateCompanionBuilder =
    TechniciansCompanion Function({
      Value<SyncStatus> syncStatus,
      Value<DateTime> lastModifiedLocal,
      Value<String> id,
      Value<String> name,
      Value<String?> phone,
      Value<String?> secondaryPhone,
      Value<String> specialty,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$TechniciansTableReferences
    extends BaseReferences<_$AppDatabase, $TechniciansTable, Technician> {
  $$TechniciansTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $MaintenanceRequestsTable,
    List<MaintenanceRequest>
  >
  _maintenanceRequestsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.maintenanceRequests,
        aliasName: $_aliasNameGenerator(
          db.technicians.id,
          db.maintenanceRequests.technicianId,
        ),
      );

  $$MaintenanceRequestsTableProcessedTableManager get maintenanceRequestsRefs {
    final manager = $$MaintenanceRequestsTableTableManager(
      $_db,
      $_db.maintenanceRequests,
    ).filter((f) => f.technicianId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _maintenanceRequestsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TechniciansTableFilterComposer
    extends Composer<_$AppDatabase, $TechniciansTable> {
  $$TechniciansTableFilterComposer({
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

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get secondaryPhone => $composableBuilder(
    column: $table.secondaryPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get specialty => $composableBuilder(
    column: $table.specialty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> maintenanceRequestsRefs(
    Expression<bool> Function($$MaintenanceRequestsTableFilterComposer f) f,
  ) {
    final $$MaintenanceRequestsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.maintenanceRequests,
      getReferencedColumn: (t) => t.technicianId,
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

class $$TechniciansTableOrderingComposer
    extends Composer<_$AppDatabase, $TechniciansTable> {
  $$TechniciansTableOrderingComposer({
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

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get secondaryPhone => $composableBuilder(
    column: $table.secondaryPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get specialty => $composableBuilder(
    column: $table.specialty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TechniciansTableAnnotationComposer
    extends Composer<_$AppDatabase, $TechniciansTable> {
  $$TechniciansTableAnnotationComposer({
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

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get secondaryPhone => $composableBuilder(
    column: $table.secondaryPhone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get specialty =>
      $composableBuilder(column: $table.specialty, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> maintenanceRequestsRefs<T extends Object>(
    Expression<T> Function($$MaintenanceRequestsTableAnnotationComposer a) f,
  ) {
    final $$MaintenanceRequestsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.maintenanceRequests,
          getReferencedColumn: (t) => t.technicianId,
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

class $$TechniciansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TechniciansTable,
          Technician,
          $$TechniciansTableFilterComposer,
          $$TechniciansTableOrderingComposer,
          $$TechniciansTableAnnotationComposer,
          $$TechniciansTableCreateCompanionBuilder,
          $$TechniciansTableUpdateCompanionBuilder,
          (Technician, $$TechniciansTableReferences),
          Technician,
          PrefetchHooks Function({bool maintenanceRequestsRefs})
        > {
  $$TechniciansTableTableManager(_$AppDatabase db, $TechniciansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TechniciansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TechniciansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TechniciansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> lastModifiedLocal = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> secondaryPhone = const Value.absent(),
                Value<String> specialty = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TechniciansCompanion(
                syncStatus: syncStatus,
                lastModifiedLocal: lastModifiedLocal,
                id: id,
                name: name,
                phone: phone,
                secondaryPhone: secondaryPhone,
                specialty: specialty,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> lastModifiedLocal = const Value.absent(),
                required String id,
                required String name,
                Value<String?> phone = const Value.absent(),
                Value<String?> secondaryPhone = const Value.absent(),
                required String specialty,
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => TechniciansCompanion.insert(
                syncStatus: syncStatus,
                lastModifiedLocal: lastModifiedLocal,
                id: id,
                name: name,
                phone: phone,
                secondaryPhone: secondaryPhone,
                specialty: specialty,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TechniciansTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({maintenanceRequestsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (maintenanceRequestsRefs) db.maintenanceRequests,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (maintenanceRequestsRefs)
                    await $_getPrefetchedData<
                      Technician,
                      $TechniciansTable,
                      MaintenanceRequest
                    >(
                      currentTable: table,
                      referencedTable: $$TechniciansTableReferences
                          ._maintenanceRequestsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TechniciansTableReferences(
                            db,
                            table,
                            p0,
                          ).maintenanceRequestsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.technicianId == item.id,
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

typedef $$TechniciansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TechniciansTable,
      Technician,
      $$TechniciansTableFilterComposer,
      $$TechniciansTableOrderingComposer,
      $$TechniciansTableAnnotationComposer,
      $$TechniciansTableCreateCompanionBuilder,
      $$TechniciansTableUpdateCompanionBuilder,
      (Technician, $$TechniciansTableReferences),
      Technician,
      PrefetchHooks Function({bool maintenanceRequestsRefs})
    >;
typedef $$CleaningSuppliesTableCreateCompanionBuilder =
    CleaningSuppliesCompanion Function({
      Value<SyncStatus> syncStatus,
      Value<DateTime> lastModifiedLocal,
      required String id,
      required String name,
      Value<double> stockQuantity,
      Value<String> unit,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CleaningSuppliesTableUpdateCompanionBuilder =
    CleaningSuppliesCompanion Function({
      Value<SyncStatus> syncStatus,
      Value<DateTime> lastModifiedLocal,
      Value<String> id,
      Value<String> name,
      Value<double> stockQuantity,
      Value<String> unit,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$CleaningSuppliesTableReferences
    extends
        BaseReferences<_$AppDatabase, $CleaningSuppliesTable, CleaningSupply> {
  $$CleaningSuppliesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $CleaningTransactionsTable,
    List<CleaningTransaction>
  >
  _cleaningTransactionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.cleaningTransactions,
        aliasName: $_aliasNameGenerator(
          db.cleaningSupplies.id,
          db.cleaningTransactions.supplyId,
        ),
      );

  $$CleaningTransactionsTableProcessedTableManager
  get cleaningTransactionsRefs {
    final manager = $$CleaningTransactionsTableTableManager(
      $_db,
      $_db.cleaningTransactions,
    ).filter((f) => f.supplyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _cleaningTransactionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CleaningSuppliesTableFilterComposer
    extends Composer<_$AppDatabase, $CleaningSuppliesTable> {
  $$CleaningSuppliesTableFilterComposer({
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

  ColumnFilters<double> get stockQuantity => $composableBuilder(
    column: $table.stockQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
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

  Expression<bool> cleaningTransactionsRefs(
    Expression<bool> Function($$CleaningTransactionsTableFilterComposer f) f,
  ) {
    final $$CleaningTransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cleaningTransactions,
      getReferencedColumn: (t) => t.supplyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CleaningTransactionsTableFilterComposer(
            $db: $db,
            $table: $db.cleaningTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CleaningSuppliesTableOrderingComposer
    extends Composer<_$AppDatabase, $CleaningSuppliesTable> {
  $$CleaningSuppliesTableOrderingComposer({
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

  ColumnOrderings<double> get stockQuantity => $composableBuilder(
    column: $table.stockQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
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
}

class $$CleaningSuppliesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CleaningSuppliesTable> {
  $$CleaningSuppliesTableAnnotationComposer({
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

  GeneratedColumn<double> get stockQuantity => $composableBuilder(
    column: $table.stockQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> cleaningTransactionsRefs<T extends Object>(
    Expression<T> Function($$CleaningTransactionsTableAnnotationComposer a) f,
  ) {
    final $$CleaningTransactionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.cleaningTransactions,
          getReferencedColumn: (t) => t.supplyId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CleaningTransactionsTableAnnotationComposer(
                $db: $db,
                $table: $db.cleaningTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CleaningSuppliesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CleaningSuppliesTable,
          CleaningSupply,
          $$CleaningSuppliesTableFilterComposer,
          $$CleaningSuppliesTableOrderingComposer,
          $$CleaningSuppliesTableAnnotationComposer,
          $$CleaningSuppliesTableCreateCompanionBuilder,
          $$CleaningSuppliesTableUpdateCompanionBuilder,
          (CleaningSupply, $$CleaningSuppliesTableReferences),
          CleaningSupply,
          PrefetchHooks Function({bool cleaningTransactionsRefs})
        > {
  $$CleaningSuppliesTableTableManager(
    _$AppDatabase db,
    $CleaningSuppliesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CleaningSuppliesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CleaningSuppliesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CleaningSuppliesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> lastModifiedLocal = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> stockQuantity = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CleaningSuppliesCompanion(
                syncStatus: syncStatus,
                lastModifiedLocal: lastModifiedLocal,
                id: id,
                name: name,
                stockQuantity: stockQuantity,
                unit: unit,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> lastModifiedLocal = const Value.absent(),
                required String id,
                required String name,
                Value<double> stockQuantity = const Value.absent(),
                Value<String> unit = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CleaningSuppliesCompanion.insert(
                syncStatus: syncStatus,
                lastModifiedLocal: lastModifiedLocal,
                id: id,
                name: name,
                stockQuantity: stockQuantity,
                unit: unit,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CleaningSuppliesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cleaningTransactionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (cleaningTransactionsRefs) db.cleaningTransactions,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (cleaningTransactionsRefs)
                    await $_getPrefetchedData<
                      CleaningSupply,
                      $CleaningSuppliesTable,
                      CleaningTransaction
                    >(
                      currentTable: table,
                      referencedTable: $$CleaningSuppliesTableReferences
                          ._cleaningTransactionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CleaningSuppliesTableReferences(
                            db,
                            table,
                            p0,
                          ).cleaningTransactionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.supplyId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CleaningSuppliesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CleaningSuppliesTable,
      CleaningSupply,
      $$CleaningSuppliesTableFilterComposer,
      $$CleaningSuppliesTableOrderingComposer,
      $$CleaningSuppliesTableAnnotationComposer,
      $$CleaningSuppliesTableCreateCompanionBuilder,
      $$CleaningSuppliesTableUpdateCompanionBuilder,
      (CleaningSupply, $$CleaningSuppliesTableReferences),
      CleaningSupply,
      PrefetchHooks Function({bool cleaningTransactionsRefs})
    >;
typedef $$CleaningTransactionsTableCreateCompanionBuilder =
    CleaningTransactionsCompanion Function({
      Value<SyncStatus> syncStatus,
      Value<DateTime> lastModifiedLocal,
      required String id,
      required String supplyId,
      required String transactionType,
      required double quantity,
      Value<double> costEgp,
      required DateTime transactionDate,
      Value<String?> notes,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CleaningTransactionsTableUpdateCompanionBuilder =
    CleaningTransactionsCompanion Function({
      Value<SyncStatus> syncStatus,
      Value<DateTime> lastModifiedLocal,
      Value<String> id,
      Value<String> supplyId,
      Value<String> transactionType,
      Value<double> quantity,
      Value<double> costEgp,
      Value<DateTime> transactionDate,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$CleaningTransactionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CleaningTransactionsTable,
          CleaningTransaction
        > {
  $$CleaningTransactionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CleaningSuppliesTable _supplyIdTable(_$AppDatabase db) =>
      db.cleaningSupplies.createAlias(
        $_aliasNameGenerator(
          db.cleaningTransactions.supplyId,
          db.cleaningSupplies.id,
        ),
      );

  $$CleaningSuppliesTableProcessedTableManager get supplyId {
    final $_column = $_itemColumn<String>('supply_id')!;

    final manager = $$CleaningSuppliesTableTableManager(
      $_db,
      $_db.cleaningSupplies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_supplyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CleaningTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $CleaningTransactionsTable> {
  $$CleaningTransactionsTableFilterComposer({
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

  ColumnFilters<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costEgp => $composableBuilder(
    column: $table.costEgp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CleaningSuppliesTableFilterComposer get supplyId {
    final $$CleaningSuppliesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplyId,
      referencedTable: $db.cleaningSupplies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CleaningSuppliesTableFilterComposer(
            $db: $db,
            $table: $db.cleaningSupplies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CleaningTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CleaningTransactionsTable> {
  $$CleaningTransactionsTableOrderingComposer({
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

  ColumnOrderings<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costEgp => $composableBuilder(
    column: $table.costEgp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CleaningSuppliesTableOrderingComposer get supplyId {
    final $$CleaningSuppliesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplyId,
      referencedTable: $db.cleaningSupplies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CleaningSuppliesTableOrderingComposer(
            $db: $db,
            $table: $db.cleaningSupplies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CleaningTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CleaningTransactionsTable> {
  $$CleaningTransactionsTableAnnotationComposer({
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

  GeneratedColumn<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get costEgp =>
      $composableBuilder(column: $table.costEgp, builder: (column) => column);

  GeneratedColumn<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CleaningSuppliesTableAnnotationComposer get supplyId {
    final $$CleaningSuppliesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplyId,
      referencedTable: $db.cleaningSupplies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CleaningSuppliesTableAnnotationComposer(
            $db: $db,
            $table: $db.cleaningSupplies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CleaningTransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CleaningTransactionsTable,
          CleaningTransaction,
          $$CleaningTransactionsTableFilterComposer,
          $$CleaningTransactionsTableOrderingComposer,
          $$CleaningTransactionsTableAnnotationComposer,
          $$CleaningTransactionsTableCreateCompanionBuilder,
          $$CleaningTransactionsTableUpdateCompanionBuilder,
          (CleaningTransaction, $$CleaningTransactionsTableReferences),
          CleaningTransaction,
          PrefetchHooks Function({bool supplyId})
        > {
  $$CleaningTransactionsTableTableManager(
    _$AppDatabase db,
    $CleaningTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CleaningTransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CleaningTransactionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CleaningTransactionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> lastModifiedLocal = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> supplyId = const Value.absent(),
                Value<String> transactionType = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<double> costEgp = const Value.absent(),
                Value<DateTime> transactionDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CleaningTransactionsCompanion(
                syncStatus: syncStatus,
                lastModifiedLocal: lastModifiedLocal,
                id: id,
                supplyId: supplyId,
                transactionType: transactionType,
                quantity: quantity,
                costEgp: costEgp,
                transactionDate: transactionDate,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> lastModifiedLocal = const Value.absent(),
                required String id,
                required String supplyId,
                required String transactionType,
                required double quantity,
                Value<double> costEgp = const Value.absent(),
                required DateTime transactionDate,
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CleaningTransactionsCompanion.insert(
                syncStatus: syncStatus,
                lastModifiedLocal: lastModifiedLocal,
                id: id,
                supplyId: supplyId,
                transactionType: transactionType,
                quantity: quantity,
                costEgp: costEgp,
                transactionDate: transactionDate,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CleaningTransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({supplyId = false}) {
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
                    if (supplyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.supplyId,
                                referencedTable:
                                    $$CleaningTransactionsTableReferences
                                        ._supplyIdTable(db),
                                referencedColumn:
                                    $$CleaningTransactionsTableReferences
                                        ._supplyIdTable(db)
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

typedef $$CleaningTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CleaningTransactionsTable,
      CleaningTransaction,
      $$CleaningTransactionsTableFilterComposer,
      $$CleaningTransactionsTableOrderingComposer,
      $$CleaningTransactionsTableAnnotationComposer,
      $$CleaningTransactionsTableCreateCompanionBuilder,
      $$CleaningTransactionsTableUpdateCompanionBuilder,
      (CleaningTransaction, $$CleaningTransactionsTableReferences),
      CleaningTransaction,
      PrefetchHooks Function({bool supplyId})
    >;
typedef $$ApartmentInspectionsTableCreateCompanionBuilder =
    ApartmentInspectionsCompanion Function({
      Value<SyncStatus> syncStatus,
      Value<DateTime> lastModifiedLocal,
      required String id,
      required String apartmentId,
      required DateTime inspectionDate,
      Value<bool> isClean,
      Value<bool> hasDamages,
      Value<String?> damagesDescription,
      Value<double> tenantFineEgp,
      Value<double> ownerRepairCostEgp,
      required String inspectorName,
      Value<String?> notes,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ApartmentInspectionsTableUpdateCompanionBuilder =
    ApartmentInspectionsCompanion Function({
      Value<SyncStatus> syncStatus,
      Value<DateTime> lastModifiedLocal,
      Value<String> id,
      Value<String> apartmentId,
      Value<DateTime> inspectionDate,
      Value<bool> isClean,
      Value<bool> hasDamages,
      Value<String?> damagesDescription,
      Value<double> tenantFineEgp,
      Value<double> ownerRepairCostEgp,
      Value<String> inspectorName,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ApartmentInspectionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ApartmentInspectionsTable,
          ApartmentInspection
        > {
  $$ApartmentInspectionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ApartmentsTable _apartmentIdTable(_$AppDatabase db) =>
      db.apartments.createAlias(
        $_aliasNameGenerator(
          db.apartmentInspections.apartmentId,
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

class $$ApartmentInspectionsTableFilterComposer
    extends Composer<_$AppDatabase, $ApartmentInspectionsTable> {
  $$ApartmentInspectionsTableFilterComposer({
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

  ColumnFilters<DateTime> get inspectionDate => $composableBuilder(
    column: $table.inspectionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isClean => $composableBuilder(
    column: $table.isClean,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasDamages => $composableBuilder(
    column: $table.hasDamages,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get damagesDescription => $composableBuilder(
    column: $table.damagesDescription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tenantFineEgp => $composableBuilder(
    column: $table.tenantFineEgp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ownerRepairCostEgp => $composableBuilder(
    column: $table.ownerRepairCostEgp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inspectorName => $composableBuilder(
    column: $table.inspectorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
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

class $$ApartmentInspectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ApartmentInspectionsTable> {
  $$ApartmentInspectionsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get inspectionDate => $composableBuilder(
    column: $table.inspectionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isClean => $composableBuilder(
    column: $table.isClean,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasDamages => $composableBuilder(
    column: $table.hasDamages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get damagesDescription => $composableBuilder(
    column: $table.damagesDescription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tenantFineEgp => $composableBuilder(
    column: $table.tenantFineEgp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ownerRepairCostEgp => $composableBuilder(
    column: $table.ownerRepairCostEgp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inspectorName => $composableBuilder(
    column: $table.inspectorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
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

class $$ApartmentInspectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ApartmentInspectionsTable> {
  $$ApartmentInspectionsTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get inspectionDate => $composableBuilder(
    column: $table.inspectionDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isClean =>
      $composableBuilder(column: $table.isClean, builder: (column) => column);

  GeneratedColumn<bool> get hasDamages => $composableBuilder(
    column: $table.hasDamages,
    builder: (column) => column,
  );

  GeneratedColumn<String> get damagesDescription => $composableBuilder(
    column: $table.damagesDescription,
    builder: (column) => column,
  );

  GeneratedColumn<double> get tenantFineEgp => $composableBuilder(
    column: $table.tenantFineEgp,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ownerRepairCostEgp => $composableBuilder(
    column: $table.ownerRepairCostEgp,
    builder: (column) => column,
  );

  GeneratedColumn<String> get inspectorName => $composableBuilder(
    column: $table.inspectorName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

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

class $$ApartmentInspectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ApartmentInspectionsTable,
          ApartmentInspection,
          $$ApartmentInspectionsTableFilterComposer,
          $$ApartmentInspectionsTableOrderingComposer,
          $$ApartmentInspectionsTableAnnotationComposer,
          $$ApartmentInspectionsTableCreateCompanionBuilder,
          $$ApartmentInspectionsTableUpdateCompanionBuilder,
          (ApartmentInspection, $$ApartmentInspectionsTableReferences),
          ApartmentInspection,
          PrefetchHooks Function({bool apartmentId})
        > {
  $$ApartmentInspectionsTableTableManager(
    _$AppDatabase db,
    $ApartmentInspectionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ApartmentInspectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ApartmentInspectionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ApartmentInspectionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> lastModifiedLocal = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> apartmentId = const Value.absent(),
                Value<DateTime> inspectionDate = const Value.absent(),
                Value<bool> isClean = const Value.absent(),
                Value<bool> hasDamages = const Value.absent(),
                Value<String?> damagesDescription = const Value.absent(),
                Value<double> tenantFineEgp = const Value.absent(),
                Value<double> ownerRepairCostEgp = const Value.absent(),
                Value<String> inspectorName = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ApartmentInspectionsCompanion(
                syncStatus: syncStatus,
                lastModifiedLocal: lastModifiedLocal,
                id: id,
                apartmentId: apartmentId,
                inspectionDate: inspectionDate,
                isClean: isClean,
                hasDamages: hasDamages,
                damagesDescription: damagesDescription,
                tenantFineEgp: tenantFineEgp,
                ownerRepairCostEgp: ownerRepairCostEgp,
                inspectorName: inspectorName,
                notes: notes,
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
                required DateTime inspectionDate,
                Value<bool> isClean = const Value.absent(),
                Value<bool> hasDamages = const Value.absent(),
                Value<String?> damagesDescription = const Value.absent(),
                Value<double> tenantFineEgp = const Value.absent(),
                Value<double> ownerRepairCostEgp = const Value.absent(),
                required String inspectorName,
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ApartmentInspectionsCompanion.insert(
                syncStatus: syncStatus,
                lastModifiedLocal: lastModifiedLocal,
                id: id,
                apartmentId: apartmentId,
                inspectionDate: inspectionDate,
                isClean: isClean,
                hasDamages: hasDamages,
                damagesDescription: damagesDescription,
                tenantFineEgp: tenantFineEgp,
                ownerRepairCostEgp: ownerRepairCostEgp,
                inspectorName: inspectorName,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ApartmentInspectionsTableReferences(db, table, e),
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
                                    $$ApartmentInspectionsTableReferences
                                        ._apartmentIdTable(db),
                                referencedColumn:
                                    $$ApartmentInspectionsTableReferences
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

typedef $$ApartmentInspectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ApartmentInspectionsTable,
      ApartmentInspection,
      $$ApartmentInspectionsTableFilterComposer,
      $$ApartmentInspectionsTableOrderingComposer,
      $$ApartmentInspectionsTableAnnotationComposer,
      $$ApartmentInspectionsTableCreateCompanionBuilder,
      $$ApartmentInspectionsTableUpdateCompanionBuilder,
      (ApartmentInspection, $$ApartmentInspectionsTableReferences),
      ApartmentInspection,
      PrefetchHooks Function({bool apartmentId})
    >;
typedef $$MaintenanceRequestsTableCreateCompanionBuilder =
    MaintenanceRequestsCompanion Function({
      Value<SyncStatus> syncStatus,
      Value<DateTime> lastModifiedLocal,
      required String id,
      required String apartmentId,
      Value<String?> technicianId,
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
      Value<String?> technicianId,
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

  static $TechniciansTable _technicianIdTable(_$AppDatabase db) =>
      db.technicians.createAlias(
        $_aliasNameGenerator(
          db.maintenanceRequests.technicianId,
          db.technicians.id,
        ),
      );

  $$TechniciansTableProcessedTableManager? get technicianId {
    final $_column = $_itemColumn<String>('technician_id');
    if ($_column == null) return null;
    final manager = $$TechniciansTableTableManager(
      $_db,
      $_db.technicians,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_technicianIdTable($_db));
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

  $$TechniciansTableFilterComposer get technicianId {
    final $$TechniciansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.technicianId,
      referencedTable: $db.technicians,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TechniciansTableFilterComposer(
            $db: $db,
            $table: $db.technicians,
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

  $$TechniciansTableOrderingComposer get technicianId {
    final $$TechniciansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.technicianId,
      referencedTable: $db.technicians,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TechniciansTableOrderingComposer(
            $db: $db,
            $table: $db.technicians,
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

  $$TechniciansTableAnnotationComposer get technicianId {
    final $$TechniciansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.technicianId,
      referencedTable: $db.technicians,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TechniciansTableAnnotationComposer(
            $db: $db,
            $table: $db.technicians,
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
          PrefetchHooks Function({bool apartmentId, bool technicianId})
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
                Value<String?> technicianId = const Value.absent(),
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
                technicianId: technicianId,
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
                Value<String?> technicianId = const Value.absent(),
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
                technicianId: technicianId,
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
          prefetchHooksCallback: ({apartmentId = false, technicianId = false}) {
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
                    if (technicianId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.technicianId,
                                referencedTable:
                                    $$MaintenanceRequestsTableReferences
                                        ._technicianIdTable(db),
                                referencedColumn:
                                    $$MaintenanceRequestsTableReferences
                                        ._technicianIdTable(db)
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
      PrefetchHooks Function({bool apartmentId, bool technicianId})
    >;
typedef $$AuditLogsTableCreateCompanionBuilder =
    AuditLogsCompanion Function({
      Value<SyncStatus> syncStatus,
      Value<DateTime> lastModifiedLocal,
      required String id,
      Value<String?> actorUserId,
      required String actorName,
      required String action,
      required String entityType,
      Value<String?> entityId,
      required String title,
      required String description,
      Value<String?> route,
      Value<String?> oldValuesJson,
      Value<String?> newValuesJson,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$AuditLogsTableUpdateCompanionBuilder =
    AuditLogsCompanion Function({
      Value<SyncStatus> syncStatus,
      Value<DateTime> lastModifiedLocal,
      Value<String> id,
      Value<String?> actorUserId,
      Value<String> actorName,
      Value<String> action,
      Value<String> entityType,
      Value<String?> entityId,
      Value<String> title,
      Value<String> description,
      Value<String?> route,
      Value<String?> oldValuesJson,
      Value<String?> newValuesJson,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$AuditLogsTableFilterComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableFilterComposer({
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

  ColumnFilters<String> get actorUserId => $composableBuilder(
    column: $table.actorUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actorName => $composableBuilder(
    column: $table.actorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get route => $composableBuilder(
    column: $table.route,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oldValuesJson => $composableBuilder(
    column: $table.oldValuesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get newValuesJson => $composableBuilder(
    column: $table.newValuesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AuditLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableOrderingComposer({
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

  ColumnOrderings<String> get actorUserId => $composableBuilder(
    column: $table.actorUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actorName => $composableBuilder(
    column: $table.actorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get route => $composableBuilder(
    column: $table.route,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oldValuesJson => $composableBuilder(
    column: $table.oldValuesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get newValuesJson => $composableBuilder(
    column: $table.newValuesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AuditLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableAnnotationComposer({
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

  GeneratedColumn<String> get actorUserId => $composableBuilder(
    column: $table.actorUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actorName =>
      $composableBuilder(column: $table.actorName, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get route =>
      $composableBuilder(column: $table.route, builder: (column) => column);

  GeneratedColumn<String> get oldValuesJson => $composableBuilder(
    column: $table.oldValuesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get newValuesJson => $composableBuilder(
    column: $table.newValuesJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AuditLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuditLogsTable,
          AuditLog,
          $$AuditLogsTableFilterComposer,
          $$AuditLogsTableOrderingComposer,
          $$AuditLogsTableAnnotationComposer,
          $$AuditLogsTableCreateCompanionBuilder,
          $$AuditLogsTableUpdateCompanionBuilder,
          (AuditLog, BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>),
          AuditLog,
          PrefetchHooks Function()
        > {
  $$AuditLogsTableTableManager(_$AppDatabase db, $AuditLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> lastModifiedLocal = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String?> actorUserId = const Value.absent(),
                Value<String> actorName = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String?> entityId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String?> route = const Value.absent(),
                Value<String?> oldValuesJson = const Value.absent(),
                Value<String?> newValuesJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditLogsCompanion(
                syncStatus: syncStatus,
                lastModifiedLocal: lastModifiedLocal,
                id: id,
                actorUserId: actorUserId,
                actorName: actorName,
                action: action,
                entityType: entityType,
                entityId: entityId,
                title: title,
                description: description,
                route: route,
                oldValuesJson: oldValuesJson,
                newValuesJson: newValuesJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> lastModifiedLocal = const Value.absent(),
                required String id,
                Value<String?> actorUserId = const Value.absent(),
                required String actorName,
                required String action,
                required String entityType,
                Value<String?> entityId = const Value.absent(),
                required String title,
                required String description,
                Value<String?> route = const Value.absent(),
                Value<String?> oldValuesJson = const Value.absent(),
                Value<String?> newValuesJson = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => AuditLogsCompanion.insert(
                syncStatus: syncStatus,
                lastModifiedLocal: lastModifiedLocal,
                id: id,
                actorUserId: actorUserId,
                actorName: actorName,
                action: action,
                entityType: entityType,
                entityId: entityId,
                title: title,
                description: description,
                route: route,
                oldValuesJson: oldValuesJson,
                newValuesJson: newValuesJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AuditLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuditLogsTable,
      AuditLog,
      $$AuditLogsTableFilterComposer,
      $$AuditLogsTableOrderingComposer,
      $$AuditLogsTableAnnotationComposer,
      $$AuditLogsTableCreateCompanionBuilder,
      $$AuditLogsTableUpdateCompanionBuilder,
      (AuditLog, BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>),
      AuditLog,
      PrefetchHooks Function()
    >;
typedef $$BookingPaymentsTableCreateCompanionBuilder =
    BookingPaymentsCompanion Function({
      Value<SyncStatus> syncStatus,
      Value<DateTime> lastModifiedLocal,
      required String id,
      required String bookingId,
      required double amountEgp,
      Value<String> paymentMethod,
      required DateTime paymentDate,
      Value<String?> notes,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$BookingPaymentsTableUpdateCompanionBuilder =
    BookingPaymentsCompanion Function({
      Value<SyncStatus> syncStatus,
      Value<DateTime> lastModifiedLocal,
      Value<String> id,
      Value<String> bookingId,
      Value<double> amountEgp,
      Value<String> paymentMethod,
      Value<DateTime> paymentDate,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$BookingPaymentsTableReferences
    extends
        BaseReferences<_$AppDatabase, $BookingPaymentsTable, BookingPayment> {
  $$BookingPaymentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SummerBookingsTable _bookingIdTable(_$AppDatabase db) =>
      db.summerBookings.createAlias(
        $_aliasNameGenerator(
          db.bookingPayments.bookingId,
          db.summerBookings.id,
        ),
      );

  $$SummerBookingsTableProcessedTableManager get bookingId {
    final $_column = $_itemColumn<String>('booking_id')!;

    final manager = $$SummerBookingsTableTableManager(
      $_db,
      $_db.summerBookings,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BookingPaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $BookingPaymentsTable> {
  $$BookingPaymentsTableFilterComposer({
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

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SummerBookingsTableFilterComposer get bookingId {
    final $$SummerBookingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookingId,
      referencedTable: $db.summerBookings,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$BookingPaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $BookingPaymentsTable> {
  $$BookingPaymentsTableOrderingComposer({
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

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SummerBookingsTableOrderingComposer get bookingId {
    final $$SummerBookingsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookingId,
      referencedTable: $db.summerBookings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SummerBookingsTableOrderingComposer(
            $db: $db,
            $table: $db.summerBookings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookingPaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookingPaymentsTable> {
  $$BookingPaymentsTableAnnotationComposer({
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

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SummerBookingsTableAnnotationComposer get bookingId {
    final $$SummerBookingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookingId,
      referencedTable: $db.summerBookings,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$BookingPaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookingPaymentsTable,
          BookingPayment,
          $$BookingPaymentsTableFilterComposer,
          $$BookingPaymentsTableOrderingComposer,
          $$BookingPaymentsTableAnnotationComposer,
          $$BookingPaymentsTableCreateCompanionBuilder,
          $$BookingPaymentsTableUpdateCompanionBuilder,
          (BookingPayment, $$BookingPaymentsTableReferences),
          BookingPayment,
          PrefetchHooks Function({bool bookingId})
        > {
  $$BookingPaymentsTableTableManager(
    _$AppDatabase db,
    $BookingPaymentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookingPaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookingPaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookingPaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> lastModifiedLocal = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> bookingId = const Value.absent(),
                Value<double> amountEgp = const Value.absent(),
                Value<String> paymentMethod = const Value.absent(),
                Value<DateTime> paymentDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookingPaymentsCompanion(
                syncStatus: syncStatus,
                lastModifiedLocal: lastModifiedLocal,
                id: id,
                bookingId: bookingId,
                amountEgp: amountEgp,
                paymentMethod: paymentMethod,
                paymentDate: paymentDate,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> lastModifiedLocal = const Value.absent(),
                required String id,
                required String bookingId,
                required double amountEgp,
                Value<String> paymentMethod = const Value.absent(),
                required DateTime paymentDate,
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => BookingPaymentsCompanion.insert(
                syncStatus: syncStatus,
                lastModifiedLocal: lastModifiedLocal,
                id: id,
                bookingId: bookingId,
                amountEgp: amountEgp,
                paymentMethod: paymentMethod,
                paymentDate: paymentDate,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BookingPaymentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookingId = false}) {
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
                    if (bookingId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.bookingId,
                                referencedTable:
                                    $$BookingPaymentsTableReferences
                                        ._bookingIdTable(db),
                                referencedColumn:
                                    $$BookingPaymentsTableReferences
                                        ._bookingIdTable(db)
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

typedef $$BookingPaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookingPaymentsTable,
      BookingPayment,
      $$BookingPaymentsTableFilterComposer,
      $$BookingPaymentsTableOrderingComposer,
      $$BookingPaymentsTableAnnotationComposer,
      $$BookingPaymentsTableCreateCompanionBuilder,
      $$BookingPaymentsTableUpdateCompanionBuilder,
      (BookingPayment, $$BookingPaymentsTableReferences),
      BookingPayment,
      PrefetchHooks Function({bool bookingId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
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
  $$FinancialTransfersTableTableManager get financialTransfers =>
      $$FinancialTransfersTableTableManager(_db, _db.financialTransfers);
  $$TechniciansTableTableManager get technicians =>
      $$TechniciansTableTableManager(_db, _db.technicians);
  $$CleaningSuppliesTableTableManager get cleaningSupplies =>
      $$CleaningSuppliesTableTableManager(_db, _db.cleaningSupplies);
  $$CleaningTransactionsTableTableManager get cleaningTransactions =>
      $$CleaningTransactionsTableTableManager(_db, _db.cleaningTransactions);
  $$ApartmentInspectionsTableTableManager get apartmentInspections =>
      $$ApartmentInspectionsTableTableManager(_db, _db.apartmentInspections);
  $$MaintenanceRequestsTableTableManager get maintenanceRequests =>
      $$MaintenanceRequestsTableTableManager(_db, _db.maintenanceRequests);
  $$AuditLogsTableTableManager get auditLogs =>
      $$AuditLogsTableTableManager(_db, _db.auditLogs);
  $$BookingPaymentsTableTableManager get bookingPayments =>
      $$BookingPaymentsTableTableManager(_db, _db.bookingPayments);
}
