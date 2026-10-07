// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ShopsTable extends Shops with TableInfo<$ShopsTable, Shop> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShopsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addressDetailMeta = const VerificationMeta(
    'addressDetail',
  );
  @override
  late final GeneratedColumn<String> addressDetail = GeneratedColumn<String>(
    'address_detail',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _regionIdMeta = const VerificationMeta(
    'regionId',
  );
  @override
  late final GeneratedColumn<String> regionId = GeneratedColumn<String>(
    'region_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _regionNameMeta = const VerificationMeta(
    'regionName',
  );
  @override
  late final GeneratedColumn<String> regionName = GeneratedColumn<String>(
    'region_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _auditRadiusMMeta = const VerificationMeta(
    'auditRadiusM',
  );
  @override
  late final GeneratedColumn<int> auditRadiusM = GeneratedColumn<int>(
    'audit_radius_m',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerNameMeta = const VerificationMeta(
    'ownerName',
  );
  @override
  late final GeneratedColumn<String> ownerName = GeneratedColumn<String>(
    'owner_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _facadeUrlMeta = const VerificationMeta(
    'facadeUrl',
  );
  @override
  late final GeneratedColumn<String> facadeUrl = GeneratedColumn<String>(
    'facade_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastVisitAtMeta = const VerificationMeta(
    'lastVisitAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastVisitAt = GeneratedColumn<DateTime>(
    'last_visit_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextDueAtMeta = const VerificationMeta(
    'nextDueAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextDueAt = GeneratedColumn<DateTime>(
    'next_due_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latestVisitsJsonMeta = const VerificationMeta(
    'latestVisitsJson',
  );
  @override
  late final GeneratedColumn<String> latestVisitsJson = GeneratedColumn<String>(
    'latest_visits_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
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
    id,
    code,
    name,
    type,
    address,
    addressDetail,
    regionId,
    regionName,
    lat,
    lng,
    auditRadiusM,
    ownerName,
    facadeUrl,
    status,
    lastVisitAt,
    nextDueAt,
    latestVisitsJson,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shops';
  @override
  VerificationContext validateIntegrity(
    Insertable<Shop> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('address_detail')) {
      context.handle(
        _addressDetailMeta,
        addressDetail.isAcceptableOrUnknown(
          data['address_detail']!,
          _addressDetailMeta,
        ),
      );
    }
    if (data.containsKey('region_id')) {
      context.handle(
        _regionIdMeta,
        regionId.isAcceptableOrUnknown(data['region_id']!, _regionIdMeta),
      );
    }
    if (data.containsKey('region_name')) {
      context.handle(
        _regionNameMeta,
        regionName.isAcceptableOrUnknown(data['region_name']!, _regionNameMeta),
      );
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    } else if (isInserting) {
      context.missing(_lngMeta);
    }
    if (data.containsKey('audit_radius_m')) {
      context.handle(
        _auditRadiusMMeta,
        auditRadiusM.isAcceptableOrUnknown(
          data['audit_radius_m']!,
          _auditRadiusMMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_auditRadiusMMeta);
    }
    if (data.containsKey('owner_name')) {
      context.handle(
        _ownerNameMeta,
        ownerName.isAcceptableOrUnknown(data['owner_name']!, _ownerNameMeta),
      );
    }
    if (data.containsKey('facade_url')) {
      context.handle(
        _facadeUrlMeta,
        facadeUrl.isAcceptableOrUnknown(data['facade_url']!, _facadeUrlMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('last_visit_at')) {
      context.handle(
        _lastVisitAtMeta,
        lastVisitAt.isAcceptableOrUnknown(
          data['last_visit_at']!,
          _lastVisitAtMeta,
        ),
      );
    }
    if (data.containsKey('next_due_at')) {
      context.handle(
        _nextDueAtMeta,
        nextDueAt.isAcceptableOrUnknown(data['next_due_at']!, _nextDueAtMeta),
      );
    }
    if (data.containsKey('latest_visits_json')) {
      context.handle(
        _latestVisitsJsonMeta,
        latestVisitsJson.isAcceptableOrUnknown(
          data['latest_visits_json']!,
          _latestVisitsJsonMeta,
        ),
      );
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
  Shop map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Shop(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      addressDetail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address_detail'],
      ),
      regionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}region_id'],
      ),
      regionName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}region_name'],
      ),
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      )!,
      lng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng'],
      )!,
      auditRadiusM: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}audit_radius_m'],
      )!,
      ownerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_name'],
      ),
      facadeUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}facade_url'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      lastVisitAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_visit_at'],
      ),
      nextDueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_due_at'],
      ),
      latestVisitsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}latest_visits_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ShopsTable createAlias(String alias) {
    return $ShopsTable(attachedDatabase, alias);
  }
}

class Shop extends DataClass implements Insertable<Shop> {
  final String id;
  final String code;
  final String name;
  final String type;
  final String address;
  final String? addressDetail;
  final String? regionId;
  final String? regionName;
  final double lat;
  final double lng;
  final int auditRadiusM;
  final String? ownerName;
  final String? facadeUrl;
  final String status;
  final DateTime? lastVisitAt;
  final DateTime? nextDueAt;

  /// Latest visits as served by `/shops` (shop details history), JSON array.
  final String latestVisitsJson;
  final DateTime updatedAt;
  const Shop({
    required this.id,
    required this.code,
    required this.name,
    required this.type,
    required this.address,
    this.addressDetail,
    this.regionId,
    this.regionName,
    required this.lat,
    required this.lng,
    required this.auditRadiusM,
    this.ownerName,
    this.facadeUrl,
    required this.status,
    this.lastVisitAt,
    this.nextDueAt,
    required this.latestVisitsJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['address'] = Variable<String>(address);
    if (!nullToAbsent || addressDetail != null) {
      map['address_detail'] = Variable<String>(addressDetail);
    }
    if (!nullToAbsent || regionId != null) {
      map['region_id'] = Variable<String>(regionId);
    }
    if (!nullToAbsent || regionName != null) {
      map['region_name'] = Variable<String>(regionName);
    }
    map['lat'] = Variable<double>(lat);
    map['lng'] = Variable<double>(lng);
    map['audit_radius_m'] = Variable<int>(auditRadiusM);
    if (!nullToAbsent || ownerName != null) {
      map['owner_name'] = Variable<String>(ownerName);
    }
    if (!nullToAbsent || facadeUrl != null) {
      map['facade_url'] = Variable<String>(facadeUrl);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || lastVisitAt != null) {
      map['last_visit_at'] = Variable<DateTime>(lastVisitAt);
    }
    if (!nullToAbsent || nextDueAt != null) {
      map['next_due_at'] = Variable<DateTime>(nextDueAt);
    }
    map['latest_visits_json'] = Variable<String>(latestVisitsJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ShopsCompanion toCompanion(bool nullToAbsent) {
    return ShopsCompanion(
      id: Value(id),
      code: Value(code),
      name: Value(name),
      type: Value(type),
      address: Value(address),
      addressDetail: addressDetail == null && nullToAbsent
          ? const Value.absent()
          : Value(addressDetail),
      regionId: regionId == null && nullToAbsent
          ? const Value.absent()
          : Value(regionId),
      regionName: regionName == null && nullToAbsent
          ? const Value.absent()
          : Value(regionName),
      lat: Value(lat),
      lng: Value(lng),
      auditRadiusM: Value(auditRadiusM),
      ownerName: ownerName == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerName),
      facadeUrl: facadeUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(facadeUrl),
      status: Value(status),
      lastVisitAt: lastVisitAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastVisitAt),
      nextDueAt: nextDueAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextDueAt),
      latestVisitsJson: Value(latestVisitsJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory Shop.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Shop(
      id: serializer.fromJson<String>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      address: serializer.fromJson<String>(json['address']),
      addressDetail: serializer.fromJson<String?>(json['addressDetail']),
      regionId: serializer.fromJson<String?>(json['regionId']),
      regionName: serializer.fromJson<String?>(json['regionName']),
      lat: serializer.fromJson<double>(json['lat']),
      lng: serializer.fromJson<double>(json['lng']),
      auditRadiusM: serializer.fromJson<int>(json['auditRadiusM']),
      ownerName: serializer.fromJson<String?>(json['ownerName']),
      facadeUrl: serializer.fromJson<String?>(json['facadeUrl']),
      status: serializer.fromJson<String>(json['status']),
      lastVisitAt: serializer.fromJson<DateTime?>(json['lastVisitAt']),
      nextDueAt: serializer.fromJson<DateTime?>(json['nextDueAt']),
      latestVisitsJson: serializer.fromJson<String>(json['latestVisitsJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'address': serializer.toJson<String>(address),
      'addressDetail': serializer.toJson<String?>(addressDetail),
      'regionId': serializer.toJson<String?>(regionId),
      'regionName': serializer.toJson<String?>(regionName),
      'lat': serializer.toJson<double>(lat),
      'lng': serializer.toJson<double>(lng),
      'auditRadiusM': serializer.toJson<int>(auditRadiusM),
      'ownerName': serializer.toJson<String?>(ownerName),
      'facadeUrl': serializer.toJson<String?>(facadeUrl),
      'status': serializer.toJson<String>(status),
      'lastVisitAt': serializer.toJson<DateTime?>(lastVisitAt),
      'nextDueAt': serializer.toJson<DateTime?>(nextDueAt),
      'latestVisitsJson': serializer.toJson<String>(latestVisitsJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Shop copyWith({
    String? id,
    String? code,
    String? name,
    String? type,
    String? address,
    Value<String?> addressDetail = const Value.absent(),
    Value<String?> regionId = const Value.absent(),
    Value<String?> regionName = const Value.absent(),
    double? lat,
    double? lng,
    int? auditRadiusM,
    Value<String?> ownerName = const Value.absent(),
    Value<String?> facadeUrl = const Value.absent(),
    String? status,
    Value<DateTime?> lastVisitAt = const Value.absent(),
    Value<DateTime?> nextDueAt = const Value.absent(),
    String? latestVisitsJson,
    DateTime? updatedAt,
  }) => Shop(
    id: id ?? this.id,
    code: code ?? this.code,
    name: name ?? this.name,
    type: type ?? this.type,
    address: address ?? this.address,
    addressDetail: addressDetail.present
        ? addressDetail.value
        : this.addressDetail,
    regionId: regionId.present ? regionId.value : this.regionId,
    regionName: regionName.present ? regionName.value : this.regionName,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
    auditRadiusM: auditRadiusM ?? this.auditRadiusM,
    ownerName: ownerName.present ? ownerName.value : this.ownerName,
    facadeUrl: facadeUrl.present ? facadeUrl.value : this.facadeUrl,
    status: status ?? this.status,
    lastVisitAt: lastVisitAt.present ? lastVisitAt.value : this.lastVisitAt,
    nextDueAt: nextDueAt.present ? nextDueAt.value : this.nextDueAt,
    latestVisitsJson: latestVisitsJson ?? this.latestVisitsJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Shop copyWithCompanion(ShopsCompanion data) {
    return Shop(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      address: data.address.present ? data.address.value : this.address,
      addressDetail: data.addressDetail.present
          ? data.addressDetail.value
          : this.addressDetail,
      regionId: data.regionId.present ? data.regionId.value : this.regionId,
      regionName: data.regionName.present
          ? data.regionName.value
          : this.regionName,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      auditRadiusM: data.auditRadiusM.present
          ? data.auditRadiusM.value
          : this.auditRadiusM,
      ownerName: data.ownerName.present ? data.ownerName.value : this.ownerName,
      facadeUrl: data.facadeUrl.present ? data.facadeUrl.value : this.facadeUrl,
      status: data.status.present ? data.status.value : this.status,
      lastVisitAt: data.lastVisitAt.present
          ? data.lastVisitAt.value
          : this.lastVisitAt,
      nextDueAt: data.nextDueAt.present ? data.nextDueAt.value : this.nextDueAt,
      latestVisitsJson: data.latestVisitsJson.present
          ? data.latestVisitsJson.value
          : this.latestVisitsJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Shop(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('address: $address, ')
          ..write('addressDetail: $addressDetail, ')
          ..write('regionId: $regionId, ')
          ..write('regionName: $regionName, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('auditRadiusM: $auditRadiusM, ')
          ..write('ownerName: $ownerName, ')
          ..write('facadeUrl: $facadeUrl, ')
          ..write('status: $status, ')
          ..write('lastVisitAt: $lastVisitAt, ')
          ..write('nextDueAt: $nextDueAt, ')
          ..write('latestVisitsJson: $latestVisitsJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    code,
    name,
    type,
    address,
    addressDetail,
    regionId,
    regionName,
    lat,
    lng,
    auditRadiusM,
    ownerName,
    facadeUrl,
    status,
    lastVisitAt,
    nextDueAt,
    latestVisitsJson,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Shop &&
          other.id == this.id &&
          other.code == this.code &&
          other.name == this.name &&
          other.type == this.type &&
          other.address == this.address &&
          other.addressDetail == this.addressDetail &&
          other.regionId == this.regionId &&
          other.regionName == this.regionName &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.auditRadiusM == this.auditRadiusM &&
          other.ownerName == this.ownerName &&
          other.facadeUrl == this.facadeUrl &&
          other.status == this.status &&
          other.lastVisitAt == this.lastVisitAt &&
          other.nextDueAt == this.nextDueAt &&
          other.latestVisitsJson == this.latestVisitsJson &&
          other.updatedAt == this.updatedAt);
}

class ShopsCompanion extends UpdateCompanion<Shop> {
  final Value<String> id;
  final Value<String> code;
  final Value<String> name;
  final Value<String> type;
  final Value<String> address;
  final Value<String?> addressDetail;
  final Value<String?> regionId;
  final Value<String?> regionName;
  final Value<double> lat;
  final Value<double> lng;
  final Value<int> auditRadiusM;
  final Value<String?> ownerName;
  final Value<String?> facadeUrl;
  final Value<String> status;
  final Value<DateTime?> lastVisitAt;
  final Value<DateTime?> nextDueAt;
  final Value<String> latestVisitsJson;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ShopsCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.address = const Value.absent(),
    this.addressDetail = const Value.absent(),
    this.regionId = const Value.absent(),
    this.regionName = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.auditRadiusM = const Value.absent(),
    this.ownerName = const Value.absent(),
    this.facadeUrl = const Value.absent(),
    this.status = const Value.absent(),
    this.lastVisitAt = const Value.absent(),
    this.nextDueAt = const Value.absent(),
    this.latestVisitsJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShopsCompanion.insert({
    required String id,
    required String code,
    required String name,
    required String type,
    required String address,
    this.addressDetail = const Value.absent(),
    this.regionId = const Value.absent(),
    this.regionName = const Value.absent(),
    required double lat,
    required double lng,
    required int auditRadiusM,
    this.ownerName = const Value.absent(),
    this.facadeUrl = const Value.absent(),
    required String status,
    this.lastVisitAt = const Value.absent(),
    this.nextDueAt = const Value.absent(),
    this.latestVisitsJson = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       code = Value(code),
       name = Value(name),
       type = Value(type),
       address = Value(address),
       lat = Value(lat),
       lng = Value(lng),
       auditRadiusM = Value(auditRadiusM),
       status = Value(status),
       updatedAt = Value(updatedAt);
  static Insertable<Shop> custom({
    Expression<String>? id,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? address,
    Expression<String>? addressDetail,
    Expression<String>? regionId,
    Expression<String>? regionName,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<int>? auditRadiusM,
    Expression<String>? ownerName,
    Expression<String>? facadeUrl,
    Expression<String>? status,
    Expression<DateTime>? lastVisitAt,
    Expression<DateTime>? nextDueAt,
    Expression<String>? latestVisitsJson,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (address != null) 'address': address,
      if (addressDetail != null) 'address_detail': addressDetail,
      if (regionId != null) 'region_id': regionId,
      if (regionName != null) 'region_name': regionName,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (auditRadiusM != null) 'audit_radius_m': auditRadiusM,
      if (ownerName != null) 'owner_name': ownerName,
      if (facadeUrl != null) 'facade_url': facadeUrl,
      if (status != null) 'status': status,
      if (lastVisitAt != null) 'last_visit_at': lastVisitAt,
      if (nextDueAt != null) 'next_due_at': nextDueAt,
      if (latestVisitsJson != null) 'latest_visits_json': latestVisitsJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShopsCompanion copyWith({
    Value<String>? id,
    Value<String>? code,
    Value<String>? name,
    Value<String>? type,
    Value<String>? address,
    Value<String?>? addressDetail,
    Value<String?>? regionId,
    Value<String?>? regionName,
    Value<double>? lat,
    Value<double>? lng,
    Value<int>? auditRadiusM,
    Value<String?>? ownerName,
    Value<String?>? facadeUrl,
    Value<String>? status,
    Value<DateTime?>? lastVisitAt,
    Value<DateTime?>? nextDueAt,
    Value<String>? latestVisitsJson,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ShopsCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      type: type ?? this.type,
      address: address ?? this.address,
      addressDetail: addressDetail ?? this.addressDetail,
      regionId: regionId ?? this.regionId,
      regionName: regionName ?? this.regionName,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      auditRadiusM: auditRadiusM ?? this.auditRadiusM,
      ownerName: ownerName ?? this.ownerName,
      facadeUrl: facadeUrl ?? this.facadeUrl,
      status: status ?? this.status,
      lastVisitAt: lastVisitAt ?? this.lastVisitAt,
      nextDueAt: nextDueAt ?? this.nextDueAt,
      latestVisitsJson: latestVisitsJson ?? this.latestVisitsJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (addressDetail.present) {
      map['address_detail'] = Variable<String>(addressDetail.value);
    }
    if (regionId.present) {
      map['region_id'] = Variable<String>(regionId.value);
    }
    if (regionName.present) {
      map['region_name'] = Variable<String>(regionName.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (auditRadiusM.present) {
      map['audit_radius_m'] = Variable<int>(auditRadiusM.value);
    }
    if (ownerName.present) {
      map['owner_name'] = Variable<String>(ownerName.value);
    }
    if (facadeUrl.present) {
      map['facade_url'] = Variable<String>(facadeUrl.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (lastVisitAt.present) {
      map['last_visit_at'] = Variable<DateTime>(lastVisitAt.value);
    }
    if (nextDueAt.present) {
      map['next_due_at'] = Variable<DateTime>(nextDueAt.value);
    }
    if (latestVisitsJson.present) {
      map['latest_visits_json'] = Variable<String>(latestVisitsJson.value);
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
    return (StringBuffer('ShopsCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('address: $address, ')
          ..write('addressDetail: $addressDetail, ')
          ..write('regionId: $regionId, ')
          ..write('regionName: $regionName, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('auditRadiusM: $auditRadiusM, ')
          ..write('ownerName: $ownerName, ')
          ..write('facadeUrl: $facadeUrl, ')
          ..write('status: $status, ')
          ..write('lastVisitAt: $lastVisitAt, ')
          ..write('nextDueAt: $nextDueAt, ')
          ..write('latestVisitsJson: $latestVisitsJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShopContactsTable extends ShopContacts
    with TableInfo<$ShopContactsTable, ShopContact> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShopContactsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shopIdMeta = const VerificationMeta('shopId');
  @override
  late final GeneratedColumn<String> shopId = GeneratedColumn<String>(
    'shop_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES shops (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, shopId, phone, label, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shop_contacts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShopContact> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shop_id')) {
      context.handle(
        _shopIdMeta,
        shopId.isAcceptableOrUnknown(data['shop_id']!, _shopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shopIdMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShopContact map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShopContact(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      shopId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shop_id'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $ShopContactsTable createAlias(String alias) {
    return $ShopContactsTable(attachedDatabase, alias);
  }
}

class ShopContact extends DataClass implements Insertable<ShopContact> {
  final String id;
  final String shopId;
  final String phone;
  final String? label;
  final int position;
  const ShopContact({
    required this.id,
    required this.shopId,
    required this.phone,
    this.label,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shop_id'] = Variable<String>(shopId);
    map['phone'] = Variable<String>(phone);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    map['position'] = Variable<int>(position);
    return map;
  }

  ShopContactsCompanion toCompanion(bool nullToAbsent) {
    return ShopContactsCompanion(
      id: Value(id),
      shopId: Value(shopId),
      phone: Value(phone),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
      position: Value(position),
    );
  }

  factory ShopContact.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShopContact(
      id: serializer.fromJson<String>(json['id']),
      shopId: serializer.fromJson<String>(json['shopId']),
      phone: serializer.fromJson<String>(json['phone']),
      label: serializer.fromJson<String?>(json['label']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shopId': serializer.toJson<String>(shopId),
      'phone': serializer.toJson<String>(phone),
      'label': serializer.toJson<String?>(label),
      'position': serializer.toJson<int>(position),
    };
  }

  ShopContact copyWith({
    String? id,
    String? shopId,
    String? phone,
    Value<String?> label = const Value.absent(),
    int? position,
  }) => ShopContact(
    id: id ?? this.id,
    shopId: shopId ?? this.shopId,
    phone: phone ?? this.phone,
    label: label.present ? label.value : this.label,
    position: position ?? this.position,
  );
  ShopContact copyWithCompanion(ShopContactsCompanion data) {
    return ShopContact(
      id: data.id.present ? data.id.value : this.id,
      shopId: data.shopId.present ? data.shopId.value : this.shopId,
      phone: data.phone.present ? data.phone.value : this.phone,
      label: data.label.present ? data.label.value : this.label,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShopContact(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('phone: $phone, ')
          ..write('label: $label, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, shopId, phone, label, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShopContact &&
          other.id == this.id &&
          other.shopId == this.shopId &&
          other.phone == this.phone &&
          other.label == this.label &&
          other.position == this.position);
}

class ShopContactsCompanion extends UpdateCompanion<ShopContact> {
  final Value<String> id;
  final Value<String> shopId;
  final Value<String> phone;
  final Value<String?> label;
  final Value<int> position;
  final Value<int> rowid;
  const ShopContactsCompanion({
    this.id = const Value.absent(),
    this.shopId = const Value.absent(),
    this.phone = const Value.absent(),
    this.label = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShopContactsCompanion.insert({
    required String id,
    required String shopId,
    required String phone,
    this.label = const Value.absent(),
    required int position,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shopId = Value(shopId),
       phone = Value(phone),
       position = Value(position);
  static Insertable<ShopContact> custom({
    Expression<String>? id,
    Expression<String>? shopId,
    Expression<String>? phone,
    Expression<String>? label,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopId != null) 'shop_id': shopId,
      if (phone != null) 'phone': phone,
      if (label != null) 'label': label,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShopContactsCompanion copyWith({
    Value<String>? id,
    Value<String>? shopId,
    Value<String>? phone,
    Value<String?>? label,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return ShopContactsCompanion(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      phone: phone ?? this.phone,
      label: label ?? this.label,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shopId.present) {
      map['shop_id'] = Variable<String>(shopId.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShopContactsCompanion(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('phone: $phone, ')
          ..write('label: $label, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoutesTable extends Routes with TableInfo<$RoutesTable, Route> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
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
  List<GeneratedColumn> get $columns => [id, date, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Route> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
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
  Route map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Route(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RoutesTable createAlias(String alias) {
    return $RoutesTable(attachedDatabase, alias);
  }
}

class Route extends DataClass implements Insertable<Route> {
  final String id;
  final DateTime date;
  final DateTime updatedAt;
  const Route({required this.id, required this.date, required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<DateTime>(date);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RoutesCompanion toCompanion(bool nullToAbsent) {
    return RoutesCompanion(
      id: Value(id),
      date: Value(date),
      updatedAt: Value(updatedAt),
    );
  }

  factory Route.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Route(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<DateTime>(date),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Route copyWith({String? id, DateTime? date, DateTime? updatedAt}) => Route(
    id: id ?? this.id,
    date: date ?? this.date,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Route copyWithCompanion(RoutesCompanion data) {
    return Route(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Route(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Route &&
          other.id == this.id &&
          other.date == this.date &&
          other.updatedAt == this.updatedAt);
}

class RoutesCompanion extends UpdateCompanion<Route> {
  final Value<String> id;
  final Value<DateTime> date;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RoutesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoutesCompanion.insert({
    required String id,
    required DateTime date,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       date = Value(date),
       updatedAt = Value(updatedAt);
  static Insertable<Route> custom({
    Expression<String>? id,
    Expression<DateTime>? date,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? date,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return RoutesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
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
    return (StringBuffer('RoutesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RouteStopsTable extends RouteStops
    with TableInfo<$RouteStopsTable, RouteStop> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RouteStopsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _routeIdMeta = const VerificationMeta(
    'routeId',
  );
  @override
  late final GeneratedColumn<String> routeId = GeneratedColumn<String>(
    'route_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES routes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _shopIdMeta = const VerificationMeta('shopId');
  @override
  late final GeneratedColumn<String> shopId = GeneratedColumn<String>(
    'shop_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plannedAtMeta = const VerificationMeta(
    'plannedAt',
  );
  @override
  late final GeneratedColumn<DateTime> plannedAt = GeneratedColumn<DateTime>(
    'planned_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isAuditTaskMeta = const VerificationMeta(
    'isAuditTask',
  );
  @override
  late final GeneratedColumn<bool> isAuditTask = GeneratedColumn<bool>(
    'is_audit_task',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_audit_task" IN (0, 1))',
    ),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _auditIdMeta = const VerificationMeta(
    'auditId',
  );
  @override
  late final GeneratedColumn<String> auditId = GeneratedColumn<String>(
    'audit_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    routeId,
    shopId,
    position,
    plannedAt,
    isAuditTask,
    status,
    auditId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'route_stops';
  @override
  VerificationContext validateIntegrity(
    Insertable<RouteStop> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('route_id')) {
      context.handle(
        _routeIdMeta,
        routeId.isAcceptableOrUnknown(data['route_id']!, _routeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_routeIdMeta);
    }
    if (data.containsKey('shop_id')) {
      context.handle(
        _shopIdMeta,
        shopId.isAcceptableOrUnknown(data['shop_id']!, _shopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shopIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('planned_at')) {
      context.handle(
        _plannedAtMeta,
        plannedAt.isAcceptableOrUnknown(data['planned_at']!, _plannedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_plannedAtMeta);
    }
    if (data.containsKey('is_audit_task')) {
      context.handle(
        _isAuditTaskMeta,
        isAuditTask.isAcceptableOrUnknown(
          data['is_audit_task']!,
          _isAuditTaskMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_isAuditTaskMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('audit_id')) {
      context.handle(
        _auditIdMeta,
        auditId.isAcceptableOrUnknown(data['audit_id']!, _auditIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RouteStop map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RouteStop(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      routeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}route_id'],
      )!,
      shopId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shop_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      plannedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}planned_at'],
      )!,
      isAuditTask: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_audit_task'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      auditId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audit_id'],
      ),
    );
  }

  @override
  $RouteStopsTable createAlias(String alias) {
    return $RouteStopsTable(attachedDatabase, alias);
  }
}

class RouteStop extends DataClass implements Insertable<RouteStop> {
  final String id;
  final String routeId;
  final String shopId;
  final int position;
  final DateTime plannedAt;
  final bool isAuditTask;
  final String status;
  final String? auditId;
  const RouteStop({
    required this.id,
    required this.routeId,
    required this.shopId,
    required this.position,
    required this.plannedAt,
    required this.isAuditTask,
    required this.status,
    this.auditId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['route_id'] = Variable<String>(routeId);
    map['shop_id'] = Variable<String>(shopId);
    map['position'] = Variable<int>(position);
    map['planned_at'] = Variable<DateTime>(plannedAt);
    map['is_audit_task'] = Variable<bool>(isAuditTask);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || auditId != null) {
      map['audit_id'] = Variable<String>(auditId);
    }
    return map;
  }

  RouteStopsCompanion toCompanion(bool nullToAbsent) {
    return RouteStopsCompanion(
      id: Value(id),
      routeId: Value(routeId),
      shopId: Value(shopId),
      position: Value(position),
      plannedAt: Value(plannedAt),
      isAuditTask: Value(isAuditTask),
      status: Value(status),
      auditId: auditId == null && nullToAbsent
          ? const Value.absent()
          : Value(auditId),
    );
  }

  factory RouteStop.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RouteStop(
      id: serializer.fromJson<String>(json['id']),
      routeId: serializer.fromJson<String>(json['routeId']),
      shopId: serializer.fromJson<String>(json['shopId']),
      position: serializer.fromJson<int>(json['position']),
      plannedAt: serializer.fromJson<DateTime>(json['plannedAt']),
      isAuditTask: serializer.fromJson<bool>(json['isAuditTask']),
      status: serializer.fromJson<String>(json['status']),
      auditId: serializer.fromJson<String?>(json['auditId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'routeId': serializer.toJson<String>(routeId),
      'shopId': serializer.toJson<String>(shopId),
      'position': serializer.toJson<int>(position),
      'plannedAt': serializer.toJson<DateTime>(plannedAt),
      'isAuditTask': serializer.toJson<bool>(isAuditTask),
      'status': serializer.toJson<String>(status),
      'auditId': serializer.toJson<String?>(auditId),
    };
  }

  RouteStop copyWith({
    String? id,
    String? routeId,
    String? shopId,
    int? position,
    DateTime? plannedAt,
    bool? isAuditTask,
    String? status,
    Value<String?> auditId = const Value.absent(),
  }) => RouteStop(
    id: id ?? this.id,
    routeId: routeId ?? this.routeId,
    shopId: shopId ?? this.shopId,
    position: position ?? this.position,
    plannedAt: plannedAt ?? this.plannedAt,
    isAuditTask: isAuditTask ?? this.isAuditTask,
    status: status ?? this.status,
    auditId: auditId.present ? auditId.value : this.auditId,
  );
  RouteStop copyWithCompanion(RouteStopsCompanion data) {
    return RouteStop(
      id: data.id.present ? data.id.value : this.id,
      routeId: data.routeId.present ? data.routeId.value : this.routeId,
      shopId: data.shopId.present ? data.shopId.value : this.shopId,
      position: data.position.present ? data.position.value : this.position,
      plannedAt: data.plannedAt.present ? data.plannedAt.value : this.plannedAt,
      isAuditTask: data.isAuditTask.present
          ? data.isAuditTask.value
          : this.isAuditTask,
      status: data.status.present ? data.status.value : this.status,
      auditId: data.auditId.present ? data.auditId.value : this.auditId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RouteStop(')
          ..write('id: $id, ')
          ..write('routeId: $routeId, ')
          ..write('shopId: $shopId, ')
          ..write('position: $position, ')
          ..write('plannedAt: $plannedAt, ')
          ..write('isAuditTask: $isAuditTask, ')
          ..write('status: $status, ')
          ..write('auditId: $auditId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    routeId,
    shopId,
    position,
    plannedAt,
    isAuditTask,
    status,
    auditId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RouteStop &&
          other.id == this.id &&
          other.routeId == this.routeId &&
          other.shopId == this.shopId &&
          other.position == this.position &&
          other.plannedAt == this.plannedAt &&
          other.isAuditTask == this.isAuditTask &&
          other.status == this.status &&
          other.auditId == this.auditId);
}

class RouteStopsCompanion extends UpdateCompanion<RouteStop> {
  final Value<String> id;
  final Value<String> routeId;
  final Value<String> shopId;
  final Value<int> position;
  final Value<DateTime> plannedAt;
  final Value<bool> isAuditTask;
  final Value<String> status;
  final Value<String?> auditId;
  final Value<int> rowid;
  const RouteStopsCompanion({
    this.id = const Value.absent(),
    this.routeId = const Value.absent(),
    this.shopId = const Value.absent(),
    this.position = const Value.absent(),
    this.plannedAt = const Value.absent(),
    this.isAuditTask = const Value.absent(),
    this.status = const Value.absent(),
    this.auditId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RouteStopsCompanion.insert({
    required String id,
    required String routeId,
    required String shopId,
    required int position,
    required DateTime plannedAt,
    required bool isAuditTask,
    required String status,
    this.auditId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       routeId = Value(routeId),
       shopId = Value(shopId),
       position = Value(position),
       plannedAt = Value(plannedAt),
       isAuditTask = Value(isAuditTask),
       status = Value(status);
  static Insertable<RouteStop> custom({
    Expression<String>? id,
    Expression<String>? routeId,
    Expression<String>? shopId,
    Expression<int>? position,
    Expression<DateTime>? plannedAt,
    Expression<bool>? isAuditTask,
    Expression<String>? status,
    Expression<String>? auditId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routeId != null) 'route_id': routeId,
      if (shopId != null) 'shop_id': shopId,
      if (position != null) 'position': position,
      if (plannedAt != null) 'planned_at': plannedAt,
      if (isAuditTask != null) 'is_audit_task': isAuditTask,
      if (status != null) 'status': status,
      if (auditId != null) 'audit_id': auditId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RouteStopsCompanion copyWith({
    Value<String>? id,
    Value<String>? routeId,
    Value<String>? shopId,
    Value<int>? position,
    Value<DateTime>? plannedAt,
    Value<bool>? isAuditTask,
    Value<String>? status,
    Value<String?>? auditId,
    Value<int>? rowid,
  }) {
    return RouteStopsCompanion(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      shopId: shopId ?? this.shopId,
      position: position ?? this.position,
      plannedAt: plannedAt ?? this.plannedAt,
      isAuditTask: isAuditTask ?? this.isAuditTask,
      status: status ?? this.status,
      auditId: auditId ?? this.auditId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (routeId.present) {
      map['route_id'] = Variable<String>(routeId.value);
    }
    if (shopId.present) {
      map['shop_id'] = Variable<String>(shopId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (plannedAt.present) {
      map['planned_at'] = Variable<DateTime>(plannedAt.value);
    }
    if (isAuditTask.present) {
      map['is_audit_task'] = Variable<bool>(isAuditTask.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (auditId.present) {
      map['audit_id'] = Variable<String>(auditId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RouteStopsCompanion(')
          ..write('id: $id, ')
          ..write('routeId: $routeId, ')
          ..write('shopId: $shopId, ')
          ..write('position: $position, ')
          ..write('plannedAt: $plannedAt, ')
          ..write('isAuditTask: $isAuditTask, ')
          ..write('status: $status, ')
          ..write('auditId: $auditId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuditsTable extends Audits with TableInfo<$AuditsTable, Audit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shopIdMeta = const VerificationMeta('shopId');
  @override
  late final GeneratedColumn<String> shopId = GeneratedColumn<String>(
    'shop_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _routeStopIdMeta = const VerificationMeta(
    'routeStopId',
  );
  @override
  late final GeneratedColumn<String> routeStopId = GeneratedColumn<String>(
    'route_stop_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedAtDeviceMeta = const VerificationMeta(
    'startedAtDevice',
  );
  @override
  late final GeneratedColumn<DateTime> startedAtDevice =
      GeneratedColumn<DateTime>(
        'started_at_device',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _finishedAtDeviceMeta = const VerificationMeta(
    'finishedAtDevice',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAtDevice =
      GeneratedColumn<DateTime>(
        'finished_at_device',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gpsAccuracyMMeta = const VerificationMeta(
    'gpsAccuracyM',
  );
  @override
  late final GeneratedColumn<double> gpsAccuracyM = GeneratedColumn<double>(
    'gps_accuracy_m',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _distanceMMeta = const VerificationMeta(
    'distanceM',
  );
  @override
  late final GeneratedColumn<int> distanceM = GeneratedColumn<int>(
    'distance_m',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _withinRadiusMeta = const VerificationMeta(
    'withinRadius',
  );
  @override
  late final GeneratedColumn<bool> withinRadius = GeneratedColumn<bool>(
    'within_radius',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("within_radius" IN (0, 1))',
    ),
  );
  static const VerificationMeta _commentMeta = const VerificationMeta(
    'comment',
  );
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
    'comment',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hasViolationMeta = const VerificationMeta(
    'hasViolation',
  );
  @override
  late final GeneratedColumn<bool> hasViolation = GeneratedColumn<bool>(
    'has_violation',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_violation" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shopId,
    routeStopId,
    startedAtDevice,
    finishedAtDevice,
    lat,
    lng,
    gpsAccuracyM,
    distanceM,
    withinRadius,
    comment,
    hasViolation,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audits';
  @override
  VerificationContext validateIntegrity(
    Insertable<Audit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shop_id')) {
      context.handle(
        _shopIdMeta,
        shopId.isAcceptableOrUnknown(data['shop_id']!, _shopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shopIdMeta);
    }
    if (data.containsKey('route_stop_id')) {
      context.handle(
        _routeStopIdMeta,
        routeStopId.isAcceptableOrUnknown(
          data['route_stop_id']!,
          _routeStopIdMeta,
        ),
      );
    }
    if (data.containsKey('started_at_device')) {
      context.handle(
        _startedAtDeviceMeta,
        startedAtDevice.isAcceptableOrUnknown(
          data['started_at_device']!,
          _startedAtDeviceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startedAtDeviceMeta);
    }
    if (data.containsKey('finished_at_device')) {
      context.handle(
        _finishedAtDeviceMeta,
        finishedAtDevice.isAcceptableOrUnknown(
          data['finished_at_device']!,
          _finishedAtDeviceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_finishedAtDeviceMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    } else if (isInserting) {
      context.missing(_lngMeta);
    }
    if (data.containsKey('gps_accuracy_m')) {
      context.handle(
        _gpsAccuracyMMeta,
        gpsAccuracyM.isAcceptableOrUnknown(
          data['gps_accuracy_m']!,
          _gpsAccuracyMMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_gpsAccuracyMMeta);
    }
    if (data.containsKey('distance_m')) {
      context.handle(
        _distanceMMeta,
        distanceM.isAcceptableOrUnknown(data['distance_m']!, _distanceMMeta),
      );
    }
    if (data.containsKey('within_radius')) {
      context.handle(
        _withinRadiusMeta,
        withinRadius.isAcceptableOrUnknown(
          data['within_radius']!,
          _withinRadiusMeta,
        ),
      );
    }
    if (data.containsKey('comment')) {
      context.handle(
        _commentMeta,
        comment.isAcceptableOrUnknown(data['comment']!, _commentMeta),
      );
    } else if (isInserting) {
      context.missing(_commentMeta);
    }
    if (data.containsKey('has_violation')) {
      context.handle(
        _hasViolationMeta,
        hasViolation.isAcceptableOrUnknown(
          data['has_violation']!,
          _hasViolationMeta,
        ),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Audit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Audit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      shopId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shop_id'],
      )!,
      routeStopId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}route_stop_id'],
      ),
      startedAtDevice: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at_device'],
      )!,
      finishedAtDevice: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at_device'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      )!,
      lng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng'],
      )!,
      gpsAccuracyM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gps_accuracy_m'],
      )!,
      distanceM: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}distance_m'],
      ),
      withinRadius: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}within_radius'],
      ),
      comment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comment'],
      )!,
      hasViolation: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_violation'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $AuditsTable createAlias(String alias) {
    return $AuditsTable(attachedDatabase, alias);
  }
}

class Audit extends DataClass implements Insertable<Audit> {
  final String id;
  final String shopId;
  final String? routeStopId;
  final DateTime startedAtDevice;
  final DateTime finishedAtDevice;
  final double lat;
  final double lng;
  final double gpsAccuracyM;
  final int? distanceM;
  final bool? withinRadius;
  final String comment;
  final bool hasViolation;
  final bool synced;
  const Audit({
    required this.id,
    required this.shopId,
    this.routeStopId,
    required this.startedAtDevice,
    required this.finishedAtDevice,
    required this.lat,
    required this.lng,
    required this.gpsAccuracyM,
    this.distanceM,
    this.withinRadius,
    required this.comment,
    required this.hasViolation,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shop_id'] = Variable<String>(shopId);
    if (!nullToAbsent || routeStopId != null) {
      map['route_stop_id'] = Variable<String>(routeStopId);
    }
    map['started_at_device'] = Variable<DateTime>(startedAtDevice);
    map['finished_at_device'] = Variable<DateTime>(finishedAtDevice);
    map['lat'] = Variable<double>(lat);
    map['lng'] = Variable<double>(lng);
    map['gps_accuracy_m'] = Variable<double>(gpsAccuracyM);
    if (!nullToAbsent || distanceM != null) {
      map['distance_m'] = Variable<int>(distanceM);
    }
    if (!nullToAbsent || withinRadius != null) {
      map['within_radius'] = Variable<bool>(withinRadius);
    }
    map['comment'] = Variable<String>(comment);
    map['has_violation'] = Variable<bool>(hasViolation);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  AuditsCompanion toCompanion(bool nullToAbsent) {
    return AuditsCompanion(
      id: Value(id),
      shopId: Value(shopId),
      routeStopId: routeStopId == null && nullToAbsent
          ? const Value.absent()
          : Value(routeStopId),
      startedAtDevice: Value(startedAtDevice),
      finishedAtDevice: Value(finishedAtDevice),
      lat: Value(lat),
      lng: Value(lng),
      gpsAccuracyM: Value(gpsAccuracyM),
      distanceM: distanceM == null && nullToAbsent
          ? const Value.absent()
          : Value(distanceM),
      withinRadius: withinRadius == null && nullToAbsent
          ? const Value.absent()
          : Value(withinRadius),
      comment: Value(comment),
      hasViolation: Value(hasViolation),
      synced: Value(synced),
    );
  }

  factory Audit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Audit(
      id: serializer.fromJson<String>(json['id']),
      shopId: serializer.fromJson<String>(json['shopId']),
      routeStopId: serializer.fromJson<String?>(json['routeStopId']),
      startedAtDevice: serializer.fromJson<DateTime>(json['startedAtDevice']),
      finishedAtDevice: serializer.fromJson<DateTime>(json['finishedAtDevice']),
      lat: serializer.fromJson<double>(json['lat']),
      lng: serializer.fromJson<double>(json['lng']),
      gpsAccuracyM: serializer.fromJson<double>(json['gpsAccuracyM']),
      distanceM: serializer.fromJson<int?>(json['distanceM']),
      withinRadius: serializer.fromJson<bool?>(json['withinRadius']),
      comment: serializer.fromJson<String>(json['comment']),
      hasViolation: serializer.fromJson<bool>(json['hasViolation']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shopId': serializer.toJson<String>(shopId),
      'routeStopId': serializer.toJson<String?>(routeStopId),
      'startedAtDevice': serializer.toJson<DateTime>(startedAtDevice),
      'finishedAtDevice': serializer.toJson<DateTime>(finishedAtDevice),
      'lat': serializer.toJson<double>(lat),
      'lng': serializer.toJson<double>(lng),
      'gpsAccuracyM': serializer.toJson<double>(gpsAccuracyM),
      'distanceM': serializer.toJson<int?>(distanceM),
      'withinRadius': serializer.toJson<bool?>(withinRadius),
      'comment': serializer.toJson<String>(comment),
      'hasViolation': serializer.toJson<bool>(hasViolation),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  Audit copyWith({
    String? id,
    String? shopId,
    Value<String?> routeStopId = const Value.absent(),
    DateTime? startedAtDevice,
    DateTime? finishedAtDevice,
    double? lat,
    double? lng,
    double? gpsAccuracyM,
    Value<int?> distanceM = const Value.absent(),
    Value<bool?> withinRadius = const Value.absent(),
    String? comment,
    bool? hasViolation,
    bool? synced,
  }) => Audit(
    id: id ?? this.id,
    shopId: shopId ?? this.shopId,
    routeStopId: routeStopId.present ? routeStopId.value : this.routeStopId,
    startedAtDevice: startedAtDevice ?? this.startedAtDevice,
    finishedAtDevice: finishedAtDevice ?? this.finishedAtDevice,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
    gpsAccuracyM: gpsAccuracyM ?? this.gpsAccuracyM,
    distanceM: distanceM.present ? distanceM.value : this.distanceM,
    withinRadius: withinRadius.present ? withinRadius.value : this.withinRadius,
    comment: comment ?? this.comment,
    hasViolation: hasViolation ?? this.hasViolation,
    synced: synced ?? this.synced,
  );
  Audit copyWithCompanion(AuditsCompanion data) {
    return Audit(
      id: data.id.present ? data.id.value : this.id,
      shopId: data.shopId.present ? data.shopId.value : this.shopId,
      routeStopId: data.routeStopId.present
          ? data.routeStopId.value
          : this.routeStopId,
      startedAtDevice: data.startedAtDevice.present
          ? data.startedAtDevice.value
          : this.startedAtDevice,
      finishedAtDevice: data.finishedAtDevice.present
          ? data.finishedAtDevice.value
          : this.finishedAtDevice,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      gpsAccuracyM: data.gpsAccuracyM.present
          ? data.gpsAccuracyM.value
          : this.gpsAccuracyM,
      distanceM: data.distanceM.present ? data.distanceM.value : this.distanceM,
      withinRadius: data.withinRadius.present
          ? data.withinRadius.value
          : this.withinRadius,
      comment: data.comment.present ? data.comment.value : this.comment,
      hasViolation: data.hasViolation.present
          ? data.hasViolation.value
          : this.hasViolation,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Audit(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('routeStopId: $routeStopId, ')
          ..write('startedAtDevice: $startedAtDevice, ')
          ..write('finishedAtDevice: $finishedAtDevice, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('gpsAccuracyM: $gpsAccuracyM, ')
          ..write('distanceM: $distanceM, ')
          ..write('withinRadius: $withinRadius, ')
          ..write('comment: $comment, ')
          ..write('hasViolation: $hasViolation, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shopId,
    routeStopId,
    startedAtDevice,
    finishedAtDevice,
    lat,
    lng,
    gpsAccuracyM,
    distanceM,
    withinRadius,
    comment,
    hasViolation,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Audit &&
          other.id == this.id &&
          other.shopId == this.shopId &&
          other.routeStopId == this.routeStopId &&
          other.startedAtDevice == this.startedAtDevice &&
          other.finishedAtDevice == this.finishedAtDevice &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.gpsAccuracyM == this.gpsAccuracyM &&
          other.distanceM == this.distanceM &&
          other.withinRadius == this.withinRadius &&
          other.comment == this.comment &&
          other.hasViolation == this.hasViolation &&
          other.synced == this.synced);
}

class AuditsCompanion extends UpdateCompanion<Audit> {
  final Value<String> id;
  final Value<String> shopId;
  final Value<String?> routeStopId;
  final Value<DateTime> startedAtDevice;
  final Value<DateTime> finishedAtDevice;
  final Value<double> lat;
  final Value<double> lng;
  final Value<double> gpsAccuracyM;
  final Value<int?> distanceM;
  final Value<bool?> withinRadius;
  final Value<String> comment;
  final Value<bool> hasViolation;
  final Value<bool> synced;
  final Value<int> rowid;
  const AuditsCompanion({
    this.id = const Value.absent(),
    this.shopId = const Value.absent(),
    this.routeStopId = const Value.absent(),
    this.startedAtDevice = const Value.absent(),
    this.finishedAtDevice = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.gpsAccuracyM = const Value.absent(),
    this.distanceM = const Value.absent(),
    this.withinRadius = const Value.absent(),
    this.comment = const Value.absent(),
    this.hasViolation = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditsCompanion.insert({
    required String id,
    required String shopId,
    this.routeStopId = const Value.absent(),
    required DateTime startedAtDevice,
    required DateTime finishedAtDevice,
    required double lat,
    required double lng,
    required double gpsAccuracyM,
    this.distanceM = const Value.absent(),
    this.withinRadius = const Value.absent(),
    required String comment,
    this.hasViolation = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shopId = Value(shopId),
       startedAtDevice = Value(startedAtDevice),
       finishedAtDevice = Value(finishedAtDevice),
       lat = Value(lat),
       lng = Value(lng),
       gpsAccuracyM = Value(gpsAccuracyM),
       comment = Value(comment);
  static Insertable<Audit> custom({
    Expression<String>? id,
    Expression<String>? shopId,
    Expression<String>? routeStopId,
    Expression<DateTime>? startedAtDevice,
    Expression<DateTime>? finishedAtDevice,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<double>? gpsAccuracyM,
    Expression<int>? distanceM,
    Expression<bool>? withinRadius,
    Expression<String>? comment,
    Expression<bool>? hasViolation,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopId != null) 'shop_id': shopId,
      if (routeStopId != null) 'route_stop_id': routeStopId,
      if (startedAtDevice != null) 'started_at_device': startedAtDevice,
      if (finishedAtDevice != null) 'finished_at_device': finishedAtDevice,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (gpsAccuracyM != null) 'gps_accuracy_m': gpsAccuracyM,
      if (distanceM != null) 'distance_m': distanceM,
      if (withinRadius != null) 'within_radius': withinRadius,
      if (comment != null) 'comment': comment,
      if (hasViolation != null) 'has_violation': hasViolation,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditsCompanion copyWith({
    Value<String>? id,
    Value<String>? shopId,
    Value<String?>? routeStopId,
    Value<DateTime>? startedAtDevice,
    Value<DateTime>? finishedAtDevice,
    Value<double>? lat,
    Value<double>? lng,
    Value<double>? gpsAccuracyM,
    Value<int?>? distanceM,
    Value<bool?>? withinRadius,
    Value<String>? comment,
    Value<bool>? hasViolation,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return AuditsCompanion(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      routeStopId: routeStopId ?? this.routeStopId,
      startedAtDevice: startedAtDevice ?? this.startedAtDevice,
      finishedAtDevice: finishedAtDevice ?? this.finishedAtDevice,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      gpsAccuracyM: gpsAccuracyM ?? this.gpsAccuracyM,
      distanceM: distanceM ?? this.distanceM,
      withinRadius: withinRadius ?? this.withinRadius,
      comment: comment ?? this.comment,
      hasViolation: hasViolation ?? this.hasViolation,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shopId.present) {
      map['shop_id'] = Variable<String>(shopId.value);
    }
    if (routeStopId.present) {
      map['route_stop_id'] = Variable<String>(routeStopId.value);
    }
    if (startedAtDevice.present) {
      map['started_at_device'] = Variable<DateTime>(startedAtDevice.value);
    }
    if (finishedAtDevice.present) {
      map['finished_at_device'] = Variable<DateTime>(finishedAtDevice.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (gpsAccuracyM.present) {
      map['gps_accuracy_m'] = Variable<double>(gpsAccuracyM.value);
    }
    if (distanceM.present) {
      map['distance_m'] = Variable<int>(distanceM.value);
    }
    if (withinRadius.present) {
      map['within_radius'] = Variable<bool>(withinRadius.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (hasViolation.present) {
      map['has_violation'] = Variable<bool>(hasViolation.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditsCompanion(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('routeStopId: $routeStopId, ')
          ..write('startedAtDevice: $startedAtDevice, ')
          ..write('finishedAtDevice: $finishedAtDevice, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('gpsAccuracyM: $gpsAccuracyM, ')
          ..write('distanceM: $distanceM, ')
          ..write('withinRadius: $withinRadius, ')
          ..write('comment: $comment, ')
          ..write('hasViolation: $hasViolation, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PhotosTable extends Photos with TableInfo<$PhotosTable, Photo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _auditIdMeta = const VerificationMeta(
    'auditId',
  );
  @override
  late final GeneratedColumn<String> auditId = GeneratedColumn<String>(
    'audit_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shopIdMeta = const VerificationMeta('shopId');
  @override
  late final GeneratedColumn<String> shopId = GeneratedColumn<String>(
    'shop_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _previewUrlMeta = const VerificationMeta(
    'previewUrl',
  );
  @override
  late final GeneratedColumn<String> previewUrl = GeneratedColumn<String>(
    'preview_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mimeMeta = const VerificationMeta('mime');
  @override
  late final GeneratedColumn<String> mime = GeneratedColumn<String>(
    'mime',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _takenAtMeta = const VerificationMeta(
    'takenAt',
  );
  @override
  late final GeneratedColumn<DateTime> takenAt = GeneratedColumn<DateTime>(
    'taken_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accuracyMMeta = const VerificationMeta(
    'accuracyM',
  );
  @override
  late final GeneratedColumn<double> accuracyM = GeneratedColumn<double>(
    'accuracy_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PENDING_UPLOAD'),
  );
  static const VerificationMeta _readyAtMeta = const VerificationMeta(
    'readyAt',
  );
  @override
  late final GeneratedColumn<DateTime> readyAt = GeneratedColumn<DateTime>(
    'ready_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    auditId,
    shopId,
    localPath,
    url,
    previewUrl,
    mime,
    sizeBytes,
    sha256,
    takenAt,
    lat,
    lng,
    accuracyM,
    status,
    readyAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Photo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('audit_id')) {
      context.handle(
        _auditIdMeta,
        auditId.isAcceptableOrUnknown(data['audit_id']!, _auditIdMeta),
      );
    }
    if (data.containsKey('shop_id')) {
      context.handle(
        _shopIdMeta,
        shopId.isAcceptableOrUnknown(data['shop_id']!, _shopIdMeta),
      );
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    if (data.containsKey('preview_url')) {
      context.handle(
        _previewUrlMeta,
        previewUrl.isAcceptableOrUnknown(data['preview_url']!, _previewUrlMeta),
      );
    }
    if (data.containsKey('mime')) {
      context.handle(
        _mimeMeta,
        mime.isAcceptableOrUnknown(data['mime']!, _mimeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    if (data.containsKey('taken_at')) {
      context.handle(
        _takenAtMeta,
        takenAt.isAcceptableOrUnknown(data['taken_at']!, _takenAtMeta),
      );
    } else if (isInserting) {
      context.missing(_takenAtMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    }
    if (data.containsKey('accuracy_m')) {
      context.handle(
        _accuracyMMeta,
        accuracyM.isAcceptableOrUnknown(data['accuracy_m']!, _accuracyMMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('ready_at')) {
      context.handle(
        _readyAtMeta,
        readyAt.isAcceptableOrUnknown(data['ready_at']!, _readyAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Photo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Photo(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      auditId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audit_id'],
      ),
      shopId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shop_id'],
      ),
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      ),
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      ),
      previewUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preview_url'],
      ),
      mime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      )!,
      takenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}taken_at'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      ),
      lng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng'],
      ),
      accuracyM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy_m'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      readyAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ready_at'],
      ),
    );
  }

  @override
  $PhotosTable createAlias(String alias) {
    return $PhotosTable(attachedDatabase, alias);
  }
}

class Photo extends DataClass implements Insertable<Photo> {
  final String id;
  final String kind;
  final String? auditId;
  final String? shopId;

  /// File in the app documents directory until the server confirms READY (+7 days).
  final String? localPath;
  final String? url;
  final String? previewUrl;
  final String mime;
  final int sizeBytes;
  final String sha256;
  final DateTime takenAt;
  final double? lat;
  final double? lng;
  final double? accuracyM;
  final String status;
  final DateTime? readyAt;
  const Photo({
    required this.id,
    required this.kind,
    this.auditId,
    this.shopId,
    this.localPath,
    this.url,
    this.previewUrl,
    required this.mime,
    required this.sizeBytes,
    required this.sha256,
    required this.takenAt,
    this.lat,
    this.lng,
    this.accuracyM,
    required this.status,
    this.readyAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || auditId != null) {
      map['audit_id'] = Variable<String>(auditId);
    }
    if (!nullToAbsent || shopId != null) {
      map['shop_id'] = Variable<String>(shopId);
    }
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    if (!nullToAbsent || previewUrl != null) {
      map['preview_url'] = Variable<String>(previewUrl);
    }
    map['mime'] = Variable<String>(mime);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['sha256'] = Variable<String>(sha256);
    map['taken_at'] = Variable<DateTime>(takenAt);
    if (!nullToAbsent || lat != null) {
      map['lat'] = Variable<double>(lat);
    }
    if (!nullToAbsent || lng != null) {
      map['lng'] = Variable<double>(lng);
    }
    if (!nullToAbsent || accuracyM != null) {
      map['accuracy_m'] = Variable<double>(accuracyM);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || readyAt != null) {
      map['ready_at'] = Variable<DateTime>(readyAt);
    }
    return map;
  }

  PhotosCompanion toCompanion(bool nullToAbsent) {
    return PhotosCompanion(
      id: Value(id),
      kind: Value(kind),
      auditId: auditId == null && nullToAbsent
          ? const Value.absent()
          : Value(auditId),
      shopId: shopId == null && nullToAbsent
          ? const Value.absent()
          : Value(shopId),
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
      previewUrl: previewUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(previewUrl),
      mime: Value(mime),
      sizeBytes: Value(sizeBytes),
      sha256: Value(sha256),
      takenAt: Value(takenAt),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lng: lng == null && nullToAbsent ? const Value.absent() : Value(lng),
      accuracyM: accuracyM == null && nullToAbsent
          ? const Value.absent()
          : Value(accuracyM),
      status: Value(status),
      readyAt: readyAt == null && nullToAbsent
          ? const Value.absent()
          : Value(readyAt),
    );
  }

  factory Photo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Photo(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      auditId: serializer.fromJson<String?>(json['auditId']),
      shopId: serializer.fromJson<String?>(json['shopId']),
      localPath: serializer.fromJson<String?>(json['localPath']),
      url: serializer.fromJson<String?>(json['url']),
      previewUrl: serializer.fromJson<String?>(json['previewUrl']),
      mime: serializer.fromJson<String>(json['mime']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      sha256: serializer.fromJson<String>(json['sha256']),
      takenAt: serializer.fromJson<DateTime>(json['takenAt']),
      lat: serializer.fromJson<double?>(json['lat']),
      lng: serializer.fromJson<double?>(json['lng']),
      accuracyM: serializer.fromJson<double?>(json['accuracyM']),
      status: serializer.fromJson<String>(json['status']),
      readyAt: serializer.fromJson<DateTime?>(json['readyAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'auditId': serializer.toJson<String?>(auditId),
      'shopId': serializer.toJson<String?>(shopId),
      'localPath': serializer.toJson<String?>(localPath),
      'url': serializer.toJson<String?>(url),
      'previewUrl': serializer.toJson<String?>(previewUrl),
      'mime': serializer.toJson<String>(mime),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'sha256': serializer.toJson<String>(sha256),
      'takenAt': serializer.toJson<DateTime>(takenAt),
      'lat': serializer.toJson<double?>(lat),
      'lng': serializer.toJson<double?>(lng),
      'accuracyM': serializer.toJson<double?>(accuracyM),
      'status': serializer.toJson<String>(status),
      'readyAt': serializer.toJson<DateTime?>(readyAt),
    };
  }

  Photo copyWith({
    String? id,
    String? kind,
    Value<String?> auditId = const Value.absent(),
    Value<String?> shopId = const Value.absent(),
    Value<String?> localPath = const Value.absent(),
    Value<String?> url = const Value.absent(),
    Value<String?> previewUrl = const Value.absent(),
    String? mime,
    int? sizeBytes,
    String? sha256,
    DateTime? takenAt,
    Value<double?> lat = const Value.absent(),
    Value<double?> lng = const Value.absent(),
    Value<double?> accuracyM = const Value.absent(),
    String? status,
    Value<DateTime?> readyAt = const Value.absent(),
  }) => Photo(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    auditId: auditId.present ? auditId.value : this.auditId,
    shopId: shopId.present ? shopId.value : this.shopId,
    localPath: localPath.present ? localPath.value : this.localPath,
    url: url.present ? url.value : this.url,
    previewUrl: previewUrl.present ? previewUrl.value : this.previewUrl,
    mime: mime ?? this.mime,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    sha256: sha256 ?? this.sha256,
    takenAt: takenAt ?? this.takenAt,
    lat: lat.present ? lat.value : this.lat,
    lng: lng.present ? lng.value : this.lng,
    accuracyM: accuracyM.present ? accuracyM.value : this.accuracyM,
    status: status ?? this.status,
    readyAt: readyAt.present ? readyAt.value : this.readyAt,
  );
  Photo copyWithCompanion(PhotosCompanion data) {
    return Photo(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      auditId: data.auditId.present ? data.auditId.value : this.auditId,
      shopId: data.shopId.present ? data.shopId.value : this.shopId,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      url: data.url.present ? data.url.value : this.url,
      previewUrl: data.previewUrl.present
          ? data.previewUrl.value
          : this.previewUrl,
      mime: data.mime.present ? data.mime.value : this.mime,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      takenAt: data.takenAt.present ? data.takenAt.value : this.takenAt,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      accuracyM: data.accuracyM.present ? data.accuracyM.value : this.accuracyM,
      status: data.status.present ? data.status.value : this.status,
      readyAt: data.readyAt.present ? data.readyAt.value : this.readyAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Photo(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('auditId: $auditId, ')
          ..write('shopId: $shopId, ')
          ..write('localPath: $localPath, ')
          ..write('url: $url, ')
          ..write('previewUrl: $previewUrl, ')
          ..write('mime: $mime, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('sha256: $sha256, ')
          ..write('takenAt: $takenAt, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('accuracyM: $accuracyM, ')
          ..write('status: $status, ')
          ..write('readyAt: $readyAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    auditId,
    shopId,
    localPath,
    url,
    previewUrl,
    mime,
    sizeBytes,
    sha256,
    takenAt,
    lat,
    lng,
    accuracyM,
    status,
    readyAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Photo &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.auditId == this.auditId &&
          other.shopId == this.shopId &&
          other.localPath == this.localPath &&
          other.url == this.url &&
          other.previewUrl == this.previewUrl &&
          other.mime == this.mime &&
          other.sizeBytes == this.sizeBytes &&
          other.sha256 == this.sha256 &&
          other.takenAt == this.takenAt &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.accuracyM == this.accuracyM &&
          other.status == this.status &&
          other.readyAt == this.readyAt);
}

class PhotosCompanion extends UpdateCompanion<Photo> {
  final Value<String> id;
  final Value<String> kind;
  final Value<String?> auditId;
  final Value<String?> shopId;
  final Value<String?> localPath;
  final Value<String?> url;
  final Value<String?> previewUrl;
  final Value<String> mime;
  final Value<int> sizeBytes;
  final Value<String> sha256;
  final Value<DateTime> takenAt;
  final Value<double?> lat;
  final Value<double?> lng;
  final Value<double?> accuracyM;
  final Value<String> status;
  final Value<DateTime?> readyAt;
  final Value<int> rowid;
  const PhotosCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.auditId = const Value.absent(),
    this.shopId = const Value.absent(),
    this.localPath = const Value.absent(),
    this.url = const Value.absent(),
    this.previewUrl = const Value.absent(),
    this.mime = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.accuracyM = const Value.absent(),
    this.status = const Value.absent(),
    this.readyAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PhotosCompanion.insert({
    required String id,
    required String kind,
    this.auditId = const Value.absent(),
    this.shopId = const Value.absent(),
    this.localPath = const Value.absent(),
    this.url = const Value.absent(),
    this.previewUrl = const Value.absent(),
    required String mime,
    required int sizeBytes,
    required String sha256,
    required DateTime takenAt,
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.accuracyM = const Value.absent(),
    this.status = const Value.absent(),
    this.readyAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind),
       mime = Value(mime),
       sizeBytes = Value(sizeBytes),
       sha256 = Value(sha256),
       takenAt = Value(takenAt);
  static Insertable<Photo> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? auditId,
    Expression<String>? shopId,
    Expression<String>? localPath,
    Expression<String>? url,
    Expression<String>? previewUrl,
    Expression<String>? mime,
    Expression<int>? sizeBytes,
    Expression<String>? sha256,
    Expression<DateTime>? takenAt,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<double>? accuracyM,
    Expression<String>? status,
    Expression<DateTime>? readyAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (auditId != null) 'audit_id': auditId,
      if (shopId != null) 'shop_id': shopId,
      if (localPath != null) 'local_path': localPath,
      if (url != null) 'url': url,
      if (previewUrl != null) 'preview_url': previewUrl,
      if (mime != null) 'mime': mime,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (sha256 != null) 'sha256': sha256,
      if (takenAt != null) 'taken_at': takenAt,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (accuracyM != null) 'accuracy_m': accuracyM,
      if (status != null) 'status': status,
      if (readyAt != null) 'ready_at': readyAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PhotosCompanion copyWith({
    Value<String>? id,
    Value<String>? kind,
    Value<String?>? auditId,
    Value<String?>? shopId,
    Value<String?>? localPath,
    Value<String?>? url,
    Value<String?>? previewUrl,
    Value<String>? mime,
    Value<int>? sizeBytes,
    Value<String>? sha256,
    Value<DateTime>? takenAt,
    Value<double?>? lat,
    Value<double?>? lng,
    Value<double?>? accuracyM,
    Value<String>? status,
    Value<DateTime?>? readyAt,
    Value<int>? rowid,
  }) {
    return PhotosCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      auditId: auditId ?? this.auditId,
      shopId: shopId ?? this.shopId,
      localPath: localPath ?? this.localPath,
      url: url ?? this.url,
      previewUrl: previewUrl ?? this.previewUrl,
      mime: mime ?? this.mime,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      sha256: sha256 ?? this.sha256,
      takenAt: takenAt ?? this.takenAt,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      accuracyM: accuracyM ?? this.accuracyM,
      status: status ?? this.status,
      readyAt: readyAt ?? this.readyAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (auditId.present) {
      map['audit_id'] = Variable<String>(auditId.value);
    }
    if (shopId.present) {
      map['shop_id'] = Variable<String>(shopId.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (previewUrl.present) {
      map['preview_url'] = Variable<String>(previewUrl.value);
    }
    if (mime.present) {
      map['mime'] = Variable<String>(mime.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (takenAt.present) {
      map['taken_at'] = Variable<DateTime>(takenAt.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (accuracyM.present) {
      map['accuracy_m'] = Variable<double>(accuracyM.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (readyAt.present) {
      map['ready_at'] = Variable<DateTime>(readyAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhotosCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('auditId: $auditId, ')
          ..write('shopId: $shopId, ')
          ..write('localPath: $localPath, ')
          ..write('url: $url, ')
          ..write('previewUrl: $previewUrl, ')
          ..write('mime: $mime, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('sha256: $sha256, ')
          ..write('takenAt: $takenAt, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('accuracyM: $accuracyM, ')
          ..write('status: $status, ')
          ..write('readyAt: $readyAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuditDraftsTable extends AuditDrafts
    with TableInfo<$AuditDraftsTable, AuditDraft> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditDraftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _shopIdMeta = const VerificationMeta('shopId');
  @override
  late final GeneratedColumn<String> shopId = GeneratedColumn<String>(
    'shop_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _auditIdMeta = const VerificationMeta(
    'auditId',
  );
  @override
  late final GeneratedColumn<String> auditId = GeneratedColumn<String>(
    'audit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _routeStopIdMeta = const VerificationMeta(
    'routeStopId',
  );
  @override
  late final GeneratedColumn<String> routeStopId = GeneratedColumn<String>(
    'route_stop_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _commentMeta = const VerificationMeta(
    'comment',
  );
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
    'comment',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _hasViolationMeta = const VerificationMeta(
    'hasViolation',
  );
  @override
  late final GeneratedColumn<bool> hasViolation = GeneratedColumn<bool>(
    'has_violation',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_violation" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    shopId,
    auditId,
    routeStopId,
    startedAt,
    comment,
    hasViolation,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_drafts';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuditDraft> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('shop_id')) {
      context.handle(
        _shopIdMeta,
        shopId.isAcceptableOrUnknown(data['shop_id']!, _shopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shopIdMeta);
    }
    if (data.containsKey('audit_id')) {
      context.handle(
        _auditIdMeta,
        auditId.isAcceptableOrUnknown(data['audit_id']!, _auditIdMeta),
      );
    } else if (isInserting) {
      context.missing(_auditIdMeta);
    }
    if (data.containsKey('route_stop_id')) {
      context.handle(
        _routeStopIdMeta,
        routeStopId.isAcceptableOrUnknown(
          data['route_stop_id']!,
          _routeStopIdMeta,
        ),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('comment')) {
      context.handle(
        _commentMeta,
        comment.isAcceptableOrUnknown(data['comment']!, _commentMeta),
      );
    }
    if (data.containsKey('has_violation')) {
      context.handle(
        _hasViolationMeta,
        hasViolation.isAcceptableOrUnknown(
          data['has_violation']!,
          _hasViolationMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {shopId};
  @override
  AuditDraft map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditDraft(
      shopId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shop_id'],
      )!,
      auditId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audit_id'],
      )!,
      routeStopId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}route_stop_id'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      comment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comment'],
      )!,
      hasViolation: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_violation'],
      )!,
    );
  }

  @override
  $AuditDraftsTable createAlias(String alias) {
    return $AuditDraftsTable(attachedDatabase, alias);
  }
}

class AuditDraft extends DataClass implements Insertable<AuditDraft> {
  final String shopId;
  final String auditId;
  final String? routeStopId;
  final DateTime startedAt;
  final String comment;
  final bool hasViolation;
  const AuditDraft({
    required this.shopId,
    required this.auditId,
    this.routeStopId,
    required this.startedAt,
    required this.comment,
    required this.hasViolation,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['shop_id'] = Variable<String>(shopId);
    map['audit_id'] = Variable<String>(auditId);
    if (!nullToAbsent || routeStopId != null) {
      map['route_stop_id'] = Variable<String>(routeStopId);
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    map['comment'] = Variable<String>(comment);
    map['has_violation'] = Variable<bool>(hasViolation);
    return map;
  }

  AuditDraftsCompanion toCompanion(bool nullToAbsent) {
    return AuditDraftsCompanion(
      shopId: Value(shopId),
      auditId: Value(auditId),
      routeStopId: routeStopId == null && nullToAbsent
          ? const Value.absent()
          : Value(routeStopId),
      startedAt: Value(startedAt),
      comment: Value(comment),
      hasViolation: Value(hasViolation),
    );
  }

  factory AuditDraft.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditDraft(
      shopId: serializer.fromJson<String>(json['shopId']),
      auditId: serializer.fromJson<String>(json['auditId']),
      routeStopId: serializer.fromJson<String?>(json['routeStopId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      comment: serializer.fromJson<String>(json['comment']),
      hasViolation: serializer.fromJson<bool>(json['hasViolation']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'shopId': serializer.toJson<String>(shopId),
      'auditId': serializer.toJson<String>(auditId),
      'routeStopId': serializer.toJson<String?>(routeStopId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'comment': serializer.toJson<String>(comment),
      'hasViolation': serializer.toJson<bool>(hasViolation),
    };
  }

  AuditDraft copyWith({
    String? shopId,
    String? auditId,
    Value<String?> routeStopId = const Value.absent(),
    DateTime? startedAt,
    String? comment,
    bool? hasViolation,
  }) => AuditDraft(
    shopId: shopId ?? this.shopId,
    auditId: auditId ?? this.auditId,
    routeStopId: routeStopId.present ? routeStopId.value : this.routeStopId,
    startedAt: startedAt ?? this.startedAt,
    comment: comment ?? this.comment,
    hasViolation: hasViolation ?? this.hasViolation,
  );
  AuditDraft copyWithCompanion(AuditDraftsCompanion data) {
    return AuditDraft(
      shopId: data.shopId.present ? data.shopId.value : this.shopId,
      auditId: data.auditId.present ? data.auditId.value : this.auditId,
      routeStopId: data.routeStopId.present
          ? data.routeStopId.value
          : this.routeStopId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      comment: data.comment.present ? data.comment.value : this.comment,
      hasViolation: data.hasViolation.present
          ? data.hasViolation.value
          : this.hasViolation,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditDraft(')
          ..write('shopId: $shopId, ')
          ..write('auditId: $auditId, ')
          ..write('routeStopId: $routeStopId, ')
          ..write('startedAt: $startedAt, ')
          ..write('comment: $comment, ')
          ..write('hasViolation: $hasViolation')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    shopId,
    auditId,
    routeStopId,
    startedAt,
    comment,
    hasViolation,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditDraft &&
          other.shopId == this.shopId &&
          other.auditId == this.auditId &&
          other.routeStopId == this.routeStopId &&
          other.startedAt == this.startedAt &&
          other.comment == this.comment &&
          other.hasViolation == this.hasViolation);
}

class AuditDraftsCompanion extends UpdateCompanion<AuditDraft> {
  final Value<String> shopId;
  final Value<String> auditId;
  final Value<String?> routeStopId;
  final Value<DateTime> startedAt;
  final Value<String> comment;
  final Value<bool> hasViolation;
  final Value<int> rowid;
  const AuditDraftsCompanion({
    this.shopId = const Value.absent(),
    this.auditId = const Value.absent(),
    this.routeStopId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.comment = const Value.absent(),
    this.hasViolation = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditDraftsCompanion.insert({
    required String shopId,
    required String auditId,
    this.routeStopId = const Value.absent(),
    required DateTime startedAt,
    this.comment = const Value.absent(),
    this.hasViolation = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : shopId = Value(shopId),
       auditId = Value(auditId),
       startedAt = Value(startedAt);
  static Insertable<AuditDraft> custom({
    Expression<String>? shopId,
    Expression<String>? auditId,
    Expression<String>? routeStopId,
    Expression<DateTime>? startedAt,
    Expression<String>? comment,
    Expression<bool>? hasViolation,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (shopId != null) 'shop_id': shopId,
      if (auditId != null) 'audit_id': auditId,
      if (routeStopId != null) 'route_stop_id': routeStopId,
      if (startedAt != null) 'started_at': startedAt,
      if (comment != null) 'comment': comment,
      if (hasViolation != null) 'has_violation': hasViolation,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditDraftsCompanion copyWith({
    Value<String>? shopId,
    Value<String>? auditId,
    Value<String?>? routeStopId,
    Value<DateTime>? startedAt,
    Value<String>? comment,
    Value<bool>? hasViolation,
    Value<int>? rowid,
  }) {
    return AuditDraftsCompanion(
      shopId: shopId ?? this.shopId,
      auditId: auditId ?? this.auditId,
      routeStopId: routeStopId ?? this.routeStopId,
      startedAt: startedAt ?? this.startedAt,
      comment: comment ?? this.comment,
      hasViolation: hasViolation ?? this.hasViolation,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (shopId.present) {
      map['shop_id'] = Variable<String>(shopId.value);
    }
    if (auditId.present) {
      map['audit_id'] = Variable<String>(auditId.value);
    }
    if (routeStopId.present) {
      map['route_stop_id'] = Variable<String>(routeStopId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (hasViolation.present) {
      map['has_violation'] = Variable<bool>(hasViolation.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditDraftsCompanion(')
          ..write('shopId: $shopId, ')
          ..write('auditId: $auditId, ')
          ..write('routeStopId: $routeStopId, ')
          ..write('startedAt: $startedAt, ')
          ..write('comment: $comment, ')
          ..write('hasViolation: $hasViolation, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxTable extends Outbox with TableInfo<$OutboxTable, OutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<OutboxKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<OutboxKind>($OutboxTable.$converterkind);
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dependsOnMeta = const VerificationMeta(
    'dependsOn',
  );
  @override
  late final GeneratedColumn<String> dependsOn = GeneratedColumn<String>(
    'depends_on',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
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
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextAttemptAtMeta = const VerificationMeta(
    'nextAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>(
        'next_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  late final GeneratedColumnWithTypeConverter<OutboxState, String> state =
      GeneratedColumn<String>(
        'state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('pending'),
      ).withConverter<OutboxState>($OutboxTable.$converterstate);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    payloadJson,
    dependsOn,
    createdAt,
    attempts,
    lastError,
    nextAttemptAt,
    state,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('depends_on')) {
      context.handle(
        _dependsOnMeta,
        dependsOn.isAcceptableOrUnknown(data['depends_on']!, _dependsOnMeta),
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
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
        _nextAttemptAtMeta,
        nextAttemptAt.isAcceptableOrUnknown(
          data['next_attempt_at']!,
          _nextAttemptAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: $OutboxTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      dependsOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}depends_on'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_attempt_at'],
      ),
      state: $OutboxTable.$converterstate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}state'],
        )!,
      ),
    );
  }

  @override
  $OutboxTable createAlias(String alias) {
    return $OutboxTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<OutboxKind, String, String> $converterkind =
      const EnumNameConverter<OutboxKind>(OutboxKind.values);
  static JsonTypeConverter2<OutboxState, String, String> $converterstate =
      const EnumNameConverter<OutboxState>(OutboxState.values);
}

class OutboxData extends DataClass implements Insertable<OutboxData> {
  final String id;
  final OutboxKind kind;
  final String payloadJson;

  /// Outbox ids that must be done first, JSON array.
  final String dependsOn;
  final DateTime createdAt;
  final int attempts;
  final String? lastError;
  final DateTime? nextAttemptAt;
  final OutboxState state;
  const OutboxData({
    required this.id,
    required this.kind,
    required this.payloadJson,
    required this.dependsOn,
    required this.createdAt,
    required this.attempts,
    this.lastError,
    this.nextAttemptAt,
    required this.state,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['kind'] = Variable<String>($OutboxTable.$converterkind.toSql(kind));
    }
    map['payload_json'] = Variable<String>(payloadJson);
    map['depends_on'] = Variable<String>(dependsOn);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    }
    {
      map['state'] = Variable<String>(
        $OutboxTable.$converterstate.toSql(state),
      );
    }
    return map;
  }

  OutboxCompanion toCompanion(bool nullToAbsent) {
    return OutboxCompanion(
      id: Value(id),
      kind: Value(kind),
      payloadJson: Value(payloadJson),
      dependsOn: Value(dependsOn),
      createdAt: Value(createdAt),
      attempts: Value(attempts),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
      state: Value(state),
    );
  }

  factory OutboxData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxData(
      id: serializer.fromJson<String>(json['id']),
      kind: $OutboxTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      dependsOn: serializer.fromJson<String>(json['dependsOn']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      nextAttemptAt: serializer.fromJson<DateTime?>(json['nextAttemptAt']),
      state: $OutboxTable.$converterstate.fromJson(
        serializer.fromJson<String>(json['state']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(
        $OutboxTable.$converterkind.toJson(kind),
      ),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'dependsOn': serializer.toJson<String>(dependsOn),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'attempts': serializer.toJson<int>(attempts),
      'lastError': serializer.toJson<String?>(lastError),
      'nextAttemptAt': serializer.toJson<DateTime?>(nextAttemptAt),
      'state': serializer.toJson<String>(
        $OutboxTable.$converterstate.toJson(state),
      ),
    };
  }

  OutboxData copyWith({
    String? id,
    OutboxKind? kind,
    String? payloadJson,
    String? dependsOn,
    DateTime? createdAt,
    int? attempts,
    Value<String?> lastError = const Value.absent(),
    Value<DateTime?> nextAttemptAt = const Value.absent(),
    OutboxState? state,
  }) => OutboxData(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    payloadJson: payloadJson ?? this.payloadJson,
    dependsOn: dependsOn ?? this.dependsOn,
    createdAt: createdAt ?? this.createdAt,
    attempts: attempts ?? this.attempts,
    lastError: lastError.present ? lastError.value : this.lastError,
    nextAttemptAt: nextAttemptAt.present
        ? nextAttemptAt.value
        : this.nextAttemptAt,
    state: state ?? this.state,
  );
  OutboxData copyWithCompanion(OutboxCompanion data) {
    return OutboxData(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      dependsOn: data.dependsOn.present ? data.dependsOn.value : this.dependsOn,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      state: data.state.present ? data.state.value : this.state,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxData(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('dependsOn: $dependsOn, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('state: $state')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    payloadJson,
    dependsOn,
    createdAt,
    attempts,
    lastError,
    nextAttemptAt,
    state,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxData &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.payloadJson == this.payloadJson &&
          other.dependsOn == this.dependsOn &&
          other.createdAt == this.createdAt &&
          other.attempts == this.attempts &&
          other.lastError == this.lastError &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.state == this.state);
}

class OutboxCompanion extends UpdateCompanion<OutboxData> {
  final Value<String> id;
  final Value<OutboxKind> kind;
  final Value<String> payloadJson;
  final Value<String> dependsOn;
  final Value<DateTime> createdAt;
  final Value<int> attempts;
  final Value<String?> lastError;
  final Value<DateTime?> nextAttemptAt;
  final Value<OutboxState> state;
  final Value<int> rowid;
  const OutboxCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.dependsOn = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.state = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutboxCompanion.insert({
    required String id,
    required OutboxKind kind,
    required String payloadJson,
    this.dependsOn = const Value.absent(),
    required DateTime createdAt,
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.state = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt);
  static Insertable<OutboxData> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? payloadJson,
    Expression<String>? dependsOn,
    Expression<DateTime>? createdAt,
    Expression<int>? attempts,
    Expression<String>? lastError,
    Expression<DateTime>? nextAttemptAt,
    Expression<String>? state,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (dependsOn != null) 'depends_on': dependsOn,
      if (createdAt != null) 'created_at': createdAt,
      if (attempts != null) 'attempts': attempts,
      if (lastError != null) 'last_error': lastError,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (state != null) 'state': state,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutboxCompanion copyWith({
    Value<String>? id,
    Value<OutboxKind>? kind,
    Value<String>? payloadJson,
    Value<String>? dependsOn,
    Value<DateTime>? createdAt,
    Value<int>? attempts,
    Value<String?>? lastError,
    Value<DateTime?>? nextAttemptAt,
    Value<OutboxState>? state,
    Value<int>? rowid,
  }) {
    return OutboxCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      payloadJson: payloadJson ?? this.payloadJson,
      dependsOn: dependsOn ?? this.dependsOn,
      createdAt: createdAt ?? this.createdAt,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      state: state ?? this.state,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $OutboxTable.$converterkind.toSql(kind.value),
      );
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (dependsOn.present) {
      map['depends_on'] = Variable<String>(dependsOn.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(
        $OutboxTable.$converterstate.toSql(state.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('dependsOn: $dependsOn, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('state: $state, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PingsBufferTable extends PingsBuffer
    with TableInfo<$PingsBufferTable, PingsBufferData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PingsBufferTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accuracyMMeta = const VerificationMeta(
    'accuracyM',
  );
  @override
  late final GeneratedColumn<double> accuracyM = GeneratedColumn<double>(
    'accuracy_m',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speedKmhMeta = const VerificationMeta(
    'speedKmh',
  );
  @override
  late final GeneratedColumn<double> speedKmh = GeneratedColumn<double>(
    'speed_kmh',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _batteryPctMeta = const VerificationMeta(
    'batteryPct',
  );
  @override
  late final GeneratedColumn<int> batteryPct = GeneratedColumn<int>(
    'battery_pct',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _triggerMeta = const VerificationMeta(
    'trigger',
  );
  @override
  late final GeneratedColumn<String> trigger = GeneratedColumn<String>(
    'trigger',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('HEARTBEAT'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recordedAt,
    lat,
    lng,
    accuracyM,
    speedKmh,
    batteryPct,
    trigger,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pings_buffer';
  @override
  VerificationContext validateIntegrity(
    Insertable<PingsBufferData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    } else if (isInserting) {
      context.missing(_lngMeta);
    }
    if (data.containsKey('accuracy_m')) {
      context.handle(
        _accuracyMMeta,
        accuracyM.isAcceptableOrUnknown(data['accuracy_m']!, _accuracyMMeta),
      );
    } else if (isInserting) {
      context.missing(_accuracyMMeta);
    }
    if (data.containsKey('speed_kmh')) {
      context.handle(
        _speedKmhMeta,
        speedKmh.isAcceptableOrUnknown(data['speed_kmh']!, _speedKmhMeta),
      );
    }
    if (data.containsKey('battery_pct')) {
      context.handle(
        _batteryPctMeta,
        batteryPct.isAcceptableOrUnknown(data['battery_pct']!, _batteryPctMeta),
      );
    }
    if (data.containsKey('trigger')) {
      context.handle(
        _triggerMeta,
        trigger.isAcceptableOrUnknown(data['trigger']!, _triggerMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PingsBufferData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PingsBufferData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      )!,
      lng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng'],
      )!,
      accuracyM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy_m'],
      )!,
      speedKmh: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}speed_kmh'],
      ),
      batteryPct: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}battery_pct'],
      ),
      trigger: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trigger'],
      )!,
    );
  }

  @override
  $PingsBufferTable createAlias(String alias) {
    return $PingsBufferTable(attachedDatabase, alias);
  }
}

class PingsBufferData extends DataClass implements Insertable<PingsBufferData> {
  final int id;
  final DateTime recordedAt;
  final double lat;
  final double lng;
  final double accuracyM;
  final double? speedKmh;
  final int? batteryPct;
  final String trigger;
  const PingsBufferData({
    required this.id,
    required this.recordedAt,
    required this.lat,
    required this.lng,
    required this.accuracyM,
    this.speedKmh,
    this.batteryPct,
    required this.trigger,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    map['lat'] = Variable<double>(lat);
    map['lng'] = Variable<double>(lng);
    map['accuracy_m'] = Variable<double>(accuracyM);
    if (!nullToAbsent || speedKmh != null) {
      map['speed_kmh'] = Variable<double>(speedKmh);
    }
    if (!nullToAbsent || batteryPct != null) {
      map['battery_pct'] = Variable<int>(batteryPct);
    }
    map['trigger'] = Variable<String>(trigger);
    return map;
  }

  PingsBufferCompanion toCompanion(bool nullToAbsent) {
    return PingsBufferCompanion(
      id: Value(id),
      recordedAt: Value(recordedAt),
      lat: Value(lat),
      lng: Value(lng),
      accuracyM: Value(accuracyM),
      speedKmh: speedKmh == null && nullToAbsent
          ? const Value.absent()
          : Value(speedKmh),
      batteryPct: batteryPct == null && nullToAbsent
          ? const Value.absent()
          : Value(batteryPct),
      trigger: Value(trigger),
    );
  }

  factory PingsBufferData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PingsBufferData(
      id: serializer.fromJson<int>(json['id']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      lat: serializer.fromJson<double>(json['lat']),
      lng: serializer.fromJson<double>(json['lng']),
      accuracyM: serializer.fromJson<double>(json['accuracyM']),
      speedKmh: serializer.fromJson<double?>(json['speedKmh']),
      batteryPct: serializer.fromJson<int?>(json['batteryPct']),
      trigger: serializer.fromJson<String>(json['trigger']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'lat': serializer.toJson<double>(lat),
      'lng': serializer.toJson<double>(lng),
      'accuracyM': serializer.toJson<double>(accuracyM),
      'speedKmh': serializer.toJson<double?>(speedKmh),
      'batteryPct': serializer.toJson<int?>(batteryPct),
      'trigger': serializer.toJson<String>(trigger),
    };
  }

  PingsBufferData copyWith({
    int? id,
    DateTime? recordedAt,
    double? lat,
    double? lng,
    double? accuracyM,
    Value<double?> speedKmh = const Value.absent(),
    Value<int?> batteryPct = const Value.absent(),
    String? trigger,
  }) => PingsBufferData(
    id: id ?? this.id,
    recordedAt: recordedAt ?? this.recordedAt,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
    accuracyM: accuracyM ?? this.accuracyM,
    speedKmh: speedKmh.present ? speedKmh.value : this.speedKmh,
    batteryPct: batteryPct.present ? batteryPct.value : this.batteryPct,
    trigger: trigger ?? this.trigger,
  );
  PingsBufferData copyWithCompanion(PingsBufferCompanion data) {
    return PingsBufferData(
      id: data.id.present ? data.id.value : this.id,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      accuracyM: data.accuracyM.present ? data.accuracyM.value : this.accuracyM,
      speedKmh: data.speedKmh.present ? data.speedKmh.value : this.speedKmh,
      batteryPct: data.batteryPct.present
          ? data.batteryPct.value
          : this.batteryPct,
      trigger: data.trigger.present ? data.trigger.value : this.trigger,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PingsBufferData(')
          ..write('id: $id, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('accuracyM: $accuracyM, ')
          ..write('speedKmh: $speedKmh, ')
          ..write('batteryPct: $batteryPct, ')
          ..write('trigger: $trigger')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    recordedAt,
    lat,
    lng,
    accuracyM,
    speedKmh,
    batteryPct,
    trigger,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PingsBufferData &&
          other.id == this.id &&
          other.recordedAt == this.recordedAt &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.accuracyM == this.accuracyM &&
          other.speedKmh == this.speedKmh &&
          other.batteryPct == this.batteryPct &&
          other.trigger == this.trigger);
}

class PingsBufferCompanion extends UpdateCompanion<PingsBufferData> {
  final Value<int> id;
  final Value<DateTime> recordedAt;
  final Value<double> lat;
  final Value<double> lng;
  final Value<double> accuracyM;
  final Value<double?> speedKmh;
  final Value<int?> batteryPct;
  final Value<String> trigger;
  const PingsBufferCompanion({
    this.id = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.accuracyM = const Value.absent(),
    this.speedKmh = const Value.absent(),
    this.batteryPct = const Value.absent(),
    this.trigger = const Value.absent(),
  });
  PingsBufferCompanion.insert({
    this.id = const Value.absent(),
    required DateTime recordedAt,
    required double lat,
    required double lng,
    required double accuracyM,
    this.speedKmh = const Value.absent(),
    this.batteryPct = const Value.absent(),
    this.trigger = const Value.absent(),
  }) : recordedAt = Value(recordedAt),
       lat = Value(lat),
       lng = Value(lng),
       accuracyM = Value(accuracyM);
  static Insertable<PingsBufferData> custom({
    Expression<int>? id,
    Expression<DateTime>? recordedAt,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<double>? accuracyM,
    Expression<double>? speedKmh,
    Expression<int>? batteryPct,
    Expression<String>? trigger,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (accuracyM != null) 'accuracy_m': accuracyM,
      if (speedKmh != null) 'speed_kmh': speedKmh,
      if (batteryPct != null) 'battery_pct': batteryPct,
      if (trigger != null) 'trigger': trigger,
    });
  }

  PingsBufferCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? recordedAt,
    Value<double>? lat,
    Value<double>? lng,
    Value<double>? accuracyM,
    Value<double?>? speedKmh,
    Value<int?>? batteryPct,
    Value<String>? trigger,
  }) {
    return PingsBufferCompanion(
      id: id ?? this.id,
      recordedAt: recordedAt ?? this.recordedAt,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      accuracyM: accuracyM ?? this.accuracyM,
      speedKmh: speedKmh ?? this.speedKmh,
      batteryPct: batteryPct ?? this.batteryPct,
      trigger: trigger ?? this.trigger,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (accuracyM.present) {
      map['accuracy_m'] = Variable<double>(accuracyM.value);
    }
    if (speedKmh.present) {
      map['speed_kmh'] = Variable<double>(speedKmh.value);
    }
    if (batteryPct.present) {
      map['battery_pct'] = Variable<int>(batteryPct.value);
    }
    if (trigger.present) {
      map['trigger'] = Variable<String>(trigger.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PingsBufferCompanion(')
          ..write('id: $id, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('accuracyM: $accuracyM, ')
          ..write('speedKmh: $speedKmh, ')
          ..write('batteryPct: $batteryPct, ')
          ..write('trigger: $trigger')
          ..write(')'))
        .toString();
  }
}

class $SyncCursorsTable extends SyncCursors
    with TableInfo<$SyncCursorsTable, SyncCursor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncCursorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  List<GeneratedColumn> get $columns => [name, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_cursors';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncCursor> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
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
  Set<GeneratedColumn> get $primaryKey => {name};
  @override
  SyncCursor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncCursor(
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SyncCursorsTable createAlias(String alias) {
    return $SyncCursorsTable(attachedDatabase, alias);
  }
}

class SyncCursor extends DataClass implements Insertable<SyncCursor> {
  final String name;
  final String value;
  final DateTime updatedAt;
  const SyncCursor({
    required this.name,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SyncCursorsCompanion toCompanion(bool nullToAbsent) {
    return SyncCursorsCompanion(
      name: Value(name),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory SyncCursor.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncCursor(
      name: serializer.fromJson<String>(json['name']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SyncCursor copyWith({String? name, String? value, DateTime? updatedAt}) =>
      SyncCursor(
        name: name ?? this.name,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SyncCursor copyWithCompanion(SyncCursorsCompanion data) {
    return SyncCursor(
      name: data.name.present ? data.name.value : this.name,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursor(')
          ..write('name: $name, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(name, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncCursor &&
          other.name == this.name &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class SyncCursorsCompanion extends UpdateCompanion<SyncCursor> {
  final Value<String> name;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SyncCursorsCompanion({
    this.name = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncCursorsCompanion.insert({
    required String name,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<SyncCursor> custom({
    Expression<String>? name,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncCursorsCompanion copyWith({
    Value<String>? name,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SyncCursorsCompanion(
      name: name ?? this.name,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
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
    return (StringBuffer('SyncCursorsCompanion(')
          ..write('name: $name, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ShopsTable shops = $ShopsTable(this);
  late final $ShopContactsTable shopContacts = $ShopContactsTable(this);
  late final $RoutesTable routes = $RoutesTable(this);
  late final $RouteStopsTable routeStops = $RouteStopsTable(this);
  late final $AuditsTable audits = $AuditsTable(this);
  late final $PhotosTable photos = $PhotosTable(this);
  late final $AuditDraftsTable auditDrafts = $AuditDraftsTable(this);
  late final $OutboxTable outbox = $OutboxTable(this);
  late final $PingsBufferTable pingsBuffer = $PingsBufferTable(this);
  late final $SyncCursorsTable syncCursors = $SyncCursorsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    shops,
    shopContacts,
    routes,
    routeStops,
    audits,
    photos,
    auditDrafts,
    outbox,
    pingsBuffer,
    syncCursors,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'shops',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('shop_contacts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'routes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('route_stops', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ShopsTableCreateCompanionBuilder = ShopsCompanion Function({
  required String id,
  required String code,
  required String name,
  required String type,
  required String address,
  Value<String?> addressDetail,
  Value<String?> regionId,
  Value<String?> regionName,
  required double lat,
  required double lng,
  required int auditRadiusM,
  Value<String?> ownerName,
  Value<String?> facadeUrl,
  required String status,
  Value<DateTime?> lastVisitAt,
  Value<DateTime?> nextDueAt,
  Value<String> latestVisitsJson,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$ShopsTableUpdateCompanionBuilder = ShopsCompanion Function({
  Value<String> id,
  Value<String> code,
  Value<String> name,
  Value<String> type,
  Value<String> address,
  Value<String?> addressDetail,
  Value<String?> regionId,
  Value<String?> regionName,
  Value<double> lat,
  Value<double> lng,
  Value<int> auditRadiusM,
  Value<String?> ownerName,
  Value<String?> facadeUrl,
  Value<String> status,
  Value<DateTime?> lastVisitAt,
  Value<DateTime?> nextDueAt,
  Value<String> latestVisitsJson,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$ShopsTableReferences
    extends BaseReferences<_$AppDatabase, $ShopsTable, Shop> {
  $$ShopsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ShopContactsTable, List<ShopContact>>
  _shopContactsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.shopContacts,
    aliasName: 'shops__id__shop_contacts__shop_id',
  );

  $$ShopContactsTableProcessedTableManager get shopContactsRefs {
    final manager = $$ShopContactsTableTableManager(
      $_db,
      $_db.shopContacts,
    ).filter((f) => f.shopId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_shopContactsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ShopsTableFilterComposer extends Composer<_$AppDatabase, $ShopsTable> {
  $$ShopsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get addressDetail => $composableBuilder(
    column: $table.addressDetail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get regionId => $composableBuilder(
    column: $table.regionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get regionName => $composableBuilder(
    column: $table.regionName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get auditRadiusM => $composableBuilder(
    column: $table.auditRadiusM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerName => $composableBuilder(
    column: $table.ownerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get facadeUrl => $composableBuilder(
    column: $table.facadeUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastVisitAt => $composableBuilder(
    column: $table.lastVisitAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextDueAt => $composableBuilder(
    column: $table.nextDueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get latestVisitsJson => $composableBuilder(
    column: $table.latestVisitsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> shopContactsRefs(
    Expression<bool> Function($$ShopContactsTableFilterComposer f) f,
  ) {
    final $$ShopContactsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shopContacts,
      getReferencedColumn: (t) => t.shopId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShopContactsTableFilterComposer(
            $db: $db,
            $table: $db.shopContacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ShopsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShopsTable> {
  $$ShopsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get addressDetail => $composableBuilder(
    column: $table.addressDetail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get regionId => $composableBuilder(
    column: $table.regionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get regionName => $composableBuilder(
    column: $table.regionName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get auditRadiusM => $composableBuilder(
    column: $table.auditRadiusM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerName => $composableBuilder(
    column: $table.ownerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get facadeUrl => $composableBuilder(
    column: $table.facadeUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastVisitAt => $composableBuilder(
    column: $table.lastVisitAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextDueAt => $composableBuilder(
    column: $table.nextDueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get latestVisitsJson => $composableBuilder(
    column: $table.latestVisitsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShopsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShopsTable> {
  $$ShopsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get addressDetail => $composableBuilder(
    column: $table.addressDetail,
    builder: (column) => column,
  );

  GeneratedColumn<String> get regionId =>
      $composableBuilder(column: $table.regionId, builder: (column) => column);

  GeneratedColumn<String> get regionName => $composableBuilder(
    column: $table.regionName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<int> get auditRadiusM => $composableBuilder(
    column: $table.auditRadiusM,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerName =>
      $composableBuilder(column: $table.ownerName, builder: (column) => column);

  GeneratedColumn<String> get facadeUrl =>
      $composableBuilder(column: $table.facadeUrl, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get lastVisitAt => $composableBuilder(
    column: $table.lastVisitAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextDueAt =>
      $composableBuilder(column: $table.nextDueAt, builder: (column) => column);

  GeneratedColumn<String> get latestVisitsJson => $composableBuilder(
    column: $table.latestVisitsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> shopContactsRefs<T extends Object>(
    Expression<T> Function($$ShopContactsTableAnnotationComposer a) f,
  ) {
    final $$ShopContactsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shopContacts,
      getReferencedColumn: (t) => t.shopId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShopContactsTableAnnotationComposer(
            $db: $db,
            $table: $db.shopContacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ShopsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShopsTable,
          Shop,
          $$ShopsTableFilterComposer,
          $$ShopsTableOrderingComposer,
          $$ShopsTableAnnotationComposer,
          $$ShopsTableCreateCompanionBuilder,
          $$ShopsTableUpdateCompanionBuilder,
          (Shop, $$ShopsTableReferences),
          Shop,
          PrefetchHooks Function({bool shopContactsRefs})
        > {
  $$ShopsTableTableManager(_$AppDatabase db, $ShopsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShopsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShopsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShopsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String?> addressDetail = const Value.absent(),
                Value<String?> regionId = const Value.absent(),
                Value<String?> regionName = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lng = const Value.absent(),
                Value<int> auditRadiusM = const Value.absent(),
                Value<String?> ownerName = const Value.absent(),
                Value<String?> facadeUrl = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> lastVisitAt = const Value.absent(),
                Value<DateTime?> nextDueAt = const Value.absent(),
                Value<String> latestVisitsJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShopsCompanion(
                id: id,
                code: code,
                name: name,
                type: type,
                address: address,
                addressDetail: addressDetail,
                regionId: regionId,
                regionName: regionName,
                lat: lat,
                lng: lng,
                auditRadiusM: auditRadiusM,
                ownerName: ownerName,
                facadeUrl: facadeUrl,
                status: status,
                lastVisitAt: lastVisitAt,
                nextDueAt: nextDueAt,
                latestVisitsJson: latestVisitsJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String code,
                required String name,
                required String type,
                required String address,
                Value<String?> addressDetail = const Value.absent(),
                Value<String?> regionId = const Value.absent(),
                Value<String?> regionName = const Value.absent(),
                required double lat,
                required double lng,
                required int auditRadiusM,
                Value<String?> ownerName = const Value.absent(),
                Value<String?> facadeUrl = const Value.absent(),
                required String status,
                Value<DateTime?> lastVisitAt = const Value.absent(),
                Value<DateTime?> nextDueAt = const Value.absent(),
                Value<String> latestVisitsJson = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ShopsCompanion.insert(
                id: id,
                code: code,
                name: name,
                type: type,
                address: address,
                addressDetail: addressDetail,
                regionId: regionId,
                regionName: regionName,
                lat: lat,
                lng: lng,
                auditRadiusM: auditRadiusM,
                ownerName: ownerName,
                facadeUrl: facadeUrl,
                status: status,
                lastVisitAt: lastVisitAt,
                nextDueAt: nextDueAt,
                latestVisitsJson: latestVisitsJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ShopsTable, Shop>(table),
                  $$ShopsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({shopContactsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (shopContactsRefs) db.shopContacts],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (shopContactsRefs)
                    await $_getPrefetchedData<Shop, $ShopsTable, ShopContact>(
                      currentTable: table,
                      referencedTable: $$ShopsTableReferences
                          ._shopContactsRefsTable(db),
                      managerFromTypedResult: (p0) => $$ShopsTableReferences(
                        db,
                        table,
                        p0,
                      ).shopContactsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.shopId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ShopsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShopsTable,
      Shop,
      $$ShopsTableFilterComposer,
      $$ShopsTableOrderingComposer,
      $$ShopsTableAnnotationComposer,
      $$ShopsTableCreateCompanionBuilder,
      $$ShopsTableUpdateCompanionBuilder,
      (Shop, $$ShopsTableReferences),
      Shop,
      PrefetchHooks Function({bool shopContactsRefs})
    >;
typedef $$ShopContactsTableCreateCompanionBuilder =
    ShopContactsCompanion Function({
      required String id,
      required String shopId,
      required String phone,
      Value<String?> label,
      required int position,
      Value<int> rowid,
    });
typedef $$ShopContactsTableUpdateCompanionBuilder =
    ShopContactsCompanion Function({
      Value<String> id,
      Value<String> shopId,
      Value<String> phone,
      Value<String?> label,
      Value<int> position,
      Value<int> rowid,
    });

final class $$ShopContactsTableReferences
    extends BaseReferences<_$AppDatabase, $ShopContactsTable, ShopContact> {
  $$ShopContactsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ShopsTable _shopIdTable(_$AppDatabase db) =>
      db.shops.createAlias('shop_contacts__shop_id__shops__id');

  $$ShopsTableProcessedTableManager get shopId {
    final $_column = $_itemColumn<String>('shop_id')!;

    final manager = $$ShopsTableTableManager(
      $_db,
      $_db.shops,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_shopIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ShopContactsTableFilterComposer
    extends Composer<_$AppDatabase, $ShopContactsTable> {
  $$ShopContactsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  $$ShopsTableFilterComposer get shopId {
    final $$ShopsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShopsTableFilterComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShopContactsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShopContactsTable> {
  $$ShopContactsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$ShopsTableOrderingComposer get shopId {
    final $$ShopsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShopsTableOrderingComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShopContactsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShopContactsTable> {
  $$ShopContactsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$ShopsTableAnnotationComposer get shopId {
    final $$ShopsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShopsTableAnnotationComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShopContactsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShopContactsTable,
          ShopContact,
          $$ShopContactsTableFilterComposer,
          $$ShopContactsTableOrderingComposer,
          $$ShopContactsTableAnnotationComposer,
          $$ShopContactsTableCreateCompanionBuilder,
          $$ShopContactsTableUpdateCompanionBuilder,
          (ShopContact, $$ShopContactsTableReferences),
          ShopContact,
          PrefetchHooks Function({bool shopId})
        > {
  $$ShopContactsTableTableManager(_$AppDatabase db, $ShopContactsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShopContactsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShopContactsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShopContactsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shopId = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShopContactsCompanion(
                id: id,
                shopId: shopId,
                phone: phone,
                label: label,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shopId,
                required String phone,
                Value<String?> label = const Value.absent(),
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => ShopContactsCompanion.insert(
                id: id,
                shopId: shopId,
                phone: phone,
                label: label,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ShopContactsTable, ShopContact>(table),
                  $$ShopContactsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({shopId = false}) {
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
                    if (shopId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.shopId,
                        referencedTable: $$ShopContactsTableReferences
                            ._shopIdTable(db),
                        referencedColumn: $$ShopContactsTableReferences
                            ._shopIdTable(db)
                            .id,
                      ) as T;
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

typedef $$ShopContactsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShopContactsTable,
      ShopContact,
      $$ShopContactsTableFilterComposer,
      $$ShopContactsTableOrderingComposer,
      $$ShopContactsTableAnnotationComposer,
      $$ShopContactsTableCreateCompanionBuilder,
      $$ShopContactsTableUpdateCompanionBuilder,
      (ShopContact, $$ShopContactsTableReferences),
      ShopContact,
      PrefetchHooks Function({bool shopId})
    >;
typedef $$RoutesTableCreateCompanionBuilder = RoutesCompanion Function({
  required String id,
  required DateTime date,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$RoutesTableUpdateCompanionBuilder = RoutesCompanion Function({
  Value<String> id,
  Value<DateTime> date,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$RoutesTableReferences
    extends BaseReferences<_$AppDatabase, $RoutesTable, Route> {
  $$RoutesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RouteStopsTable, List<RouteStop>>
  _routeStopsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.routeStops,
    aliasName: 'routes__id__route_stops__route_id',
  );

  $$RouteStopsTableProcessedTableManager get routeStopsRefs {
    final manager = $$RouteStopsTableTableManager(
      $_db,
      $_db.routeStops,
    ).filter((f) => f.routeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_routeStopsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RoutesTableFilterComposer
    extends Composer<_$AppDatabase, $RoutesTable> {
  $$RoutesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> routeStopsRefs(
    Expression<bool> Function($$RouteStopsTableFilterComposer f) f,
  ) {
    final $$RouteStopsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routeStops,
      getReferencedColumn: (t) => t.routeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RouteStopsTableFilterComposer(
            $db: $db,
            $table: $db.routeStops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutesTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutesTable> {
  $$RoutesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoutesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutesTable> {
  $$RoutesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> routeStopsRefs<T extends Object>(
    Expression<T> Function($$RouteStopsTableAnnotationComposer a) f,
  ) {
    final $$RouteStopsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routeStops,
      getReferencedColumn: (t) => t.routeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RouteStopsTableAnnotationComposer(
            $db: $db,
            $table: $db.routeStops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutesTable,
          Route,
          $$RoutesTableFilterComposer,
          $$RoutesTableOrderingComposer,
          $$RoutesTableAnnotationComposer,
          $$RoutesTableCreateCompanionBuilder,
          $$RoutesTableUpdateCompanionBuilder,
          (Route, $$RoutesTableReferences),
          Route,
          PrefetchHooks Function({bool routeStopsRefs})
        > {
  $$RoutesTableTableManager(_$AppDatabase db, $RoutesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutesCompanion(
                id: id,
                date: date,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime date,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => RoutesCompanion.insert(
                id: id,
                date: date,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RoutesTable, Route>(table),
                  $$RoutesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({routeStopsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (routeStopsRefs) db.routeStops],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (routeStopsRefs)
                    await $_getPrefetchedData<Route, $RoutesTable, RouteStop>(
                      currentTable: table,
                      referencedTable: $$RoutesTableReferences
                          ._routeStopsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$RoutesTableReferences(db, table, p0).routeStopsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.routeId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RoutesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutesTable,
      Route,
      $$RoutesTableFilterComposer,
      $$RoutesTableOrderingComposer,
      $$RoutesTableAnnotationComposer,
      $$RoutesTableCreateCompanionBuilder,
      $$RoutesTableUpdateCompanionBuilder,
      (Route, $$RoutesTableReferences),
      Route,
      PrefetchHooks Function({bool routeStopsRefs})
    >;
typedef $$RouteStopsTableCreateCompanionBuilder = RouteStopsCompanion Function({
  required String id,
  required String routeId,
  required String shopId,
  required int position,
  required DateTime plannedAt,
  required bool isAuditTask,
  required String status,
  Value<String?> auditId,
  Value<int> rowid,
});
typedef $$RouteStopsTableUpdateCompanionBuilder = RouteStopsCompanion Function({
  Value<String> id,
  Value<String> routeId,
  Value<String> shopId,
  Value<int> position,
  Value<DateTime> plannedAt,
  Value<bool> isAuditTask,
  Value<String> status,
  Value<String?> auditId,
  Value<int> rowid,
});

final class $$RouteStopsTableReferences
    extends BaseReferences<_$AppDatabase, $RouteStopsTable, RouteStop> {
  $$RouteStopsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RoutesTable _routeIdTable(_$AppDatabase db) =>
      db.routes.createAlias('route_stops__route_id__routes__id');

  $$RoutesTableProcessedTableManager get routeId {
    final $_column = $_itemColumn<String>('route_id')!;

    final manager = $$RoutesTableTableManager(
      $_db,
      $_db.routes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_routeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RouteStopsTableFilterComposer
    extends Composer<_$AppDatabase, $RouteStopsTable> {
  $$RouteStopsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shopId => $composableBuilder(
    column: $table.shopId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get plannedAt => $composableBuilder(
    column: $table.plannedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAuditTask => $composableBuilder(
    column: $table.isAuditTask,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get auditId => $composableBuilder(
    column: $table.auditId,
    builder: (column) => ColumnFilters(column),
  );

  $$RoutesTableFilterComposer get routeId {
    final $$RoutesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routeId,
      referencedTable: $db.routes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutesTableFilterComposer(
            $db: $db,
            $table: $db.routes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RouteStopsTableOrderingComposer
    extends Composer<_$AppDatabase, $RouteStopsTable> {
  $$RouteStopsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shopId => $composableBuilder(
    column: $table.shopId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get plannedAt => $composableBuilder(
    column: $table.plannedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAuditTask => $composableBuilder(
    column: $table.isAuditTask,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get auditId => $composableBuilder(
    column: $table.auditId,
    builder: (column) => ColumnOrderings(column),
  );

  $$RoutesTableOrderingComposer get routeId {
    final $$RoutesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routeId,
      referencedTable: $db.routes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutesTableOrderingComposer(
            $db: $db,
            $table: $db.routes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RouteStopsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RouteStopsTable> {
  $$RouteStopsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shopId =>
      $composableBuilder(column: $table.shopId, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<DateTime> get plannedAt =>
      $composableBuilder(column: $table.plannedAt, builder: (column) => column);

  GeneratedColumn<bool> get isAuditTask => $composableBuilder(
    column: $table.isAuditTask,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get auditId =>
      $composableBuilder(column: $table.auditId, builder: (column) => column);

  $$RoutesTableAnnotationComposer get routeId {
    final $$RoutesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routeId,
      referencedTable: $db.routes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutesTableAnnotationComposer(
            $db: $db,
            $table: $db.routes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RouteStopsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RouteStopsTable,
          RouteStop,
          $$RouteStopsTableFilterComposer,
          $$RouteStopsTableOrderingComposer,
          $$RouteStopsTableAnnotationComposer,
          $$RouteStopsTableCreateCompanionBuilder,
          $$RouteStopsTableUpdateCompanionBuilder,
          (RouteStop, $$RouteStopsTableReferences),
          RouteStop,
          PrefetchHooks Function({bool routeId})
        > {
  $$RouteStopsTableTableManager(_$AppDatabase db, $RouteStopsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RouteStopsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RouteStopsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RouteStopsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> routeId = const Value.absent(),
                Value<String> shopId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<DateTime> plannedAt = const Value.absent(),
                Value<bool> isAuditTask = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> auditId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RouteStopsCompanion(
                id: id,
                routeId: routeId,
                shopId: shopId,
                position: position,
                plannedAt: plannedAt,
                isAuditTask: isAuditTask,
                status: status,
                auditId: auditId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String routeId,
                required String shopId,
                required int position,
                required DateTime plannedAt,
                required bool isAuditTask,
                required String status,
                Value<String?> auditId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RouteStopsCompanion.insert(
                id: id,
                routeId: routeId,
                shopId: shopId,
                position: position,
                plannedAt: plannedAt,
                isAuditTask: isAuditTask,
                status: status,
                auditId: auditId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RouteStopsTable, RouteStop>(table),
                  $$RouteStopsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({routeId = false}) {
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
                    if (routeId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.routeId,
                        referencedTable: $$RouteStopsTableReferences
                            ._routeIdTable(db),
                        referencedColumn: $$RouteStopsTableReferences
                            ._routeIdTable(db)
                            .id,
                      ) as T;
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

typedef $$RouteStopsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RouteStopsTable,
      RouteStop,
      $$RouteStopsTableFilterComposer,
      $$RouteStopsTableOrderingComposer,
      $$RouteStopsTableAnnotationComposer,
      $$RouteStopsTableCreateCompanionBuilder,
      $$RouteStopsTableUpdateCompanionBuilder,
      (RouteStop, $$RouteStopsTableReferences),
      RouteStop,
      PrefetchHooks Function({bool routeId})
    >;
typedef $$AuditsTableCreateCompanionBuilder = AuditsCompanion Function({
  required String id,
  required String shopId,
  Value<String?> routeStopId,
  required DateTime startedAtDevice,
  required DateTime finishedAtDevice,
  required double lat,
  required double lng,
  required double gpsAccuracyM,
  Value<int?> distanceM,
  Value<bool?> withinRadius,
  required String comment,
  Value<bool> hasViolation,
  Value<bool> synced,
  Value<int> rowid,
});
typedef $$AuditsTableUpdateCompanionBuilder = AuditsCompanion Function({
  Value<String> id,
  Value<String> shopId,
  Value<String?> routeStopId,
  Value<DateTime> startedAtDevice,
  Value<DateTime> finishedAtDevice,
  Value<double> lat,
  Value<double> lng,
  Value<double> gpsAccuracyM,
  Value<int?> distanceM,
  Value<bool?> withinRadius,
  Value<String> comment,
  Value<bool> hasViolation,
  Value<bool> synced,
  Value<int> rowid,
});

class $$AuditsTableFilterComposer
    extends Composer<_$AppDatabase, $AuditsTable> {
  $$AuditsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shopId => $composableBuilder(
    column: $table.shopId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get routeStopId => $composableBuilder(
    column: $table.routeStopId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAtDevice => $composableBuilder(
    column: $table.startedAtDevice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAtDevice => $composableBuilder(
    column: $table.finishedAtDevice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gpsAccuracyM => $composableBuilder(
    column: $table.gpsAccuracyM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get distanceM => $composableBuilder(
    column: $table.distanceM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get withinRadius => $composableBuilder(
    column: $table.withinRadius,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasViolation => $composableBuilder(
    column: $table.hasViolation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AuditsTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditsTable> {
  $$AuditsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shopId => $composableBuilder(
    column: $table.shopId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get routeStopId => $composableBuilder(
    column: $table.routeStopId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAtDevice => $composableBuilder(
    column: $table.startedAtDevice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAtDevice => $composableBuilder(
    column: $table.finishedAtDevice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gpsAccuracyM => $composableBuilder(
    column: $table.gpsAccuracyM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get distanceM => $composableBuilder(
    column: $table.distanceM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get withinRadius => $composableBuilder(
    column: $table.withinRadius,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasViolation => $composableBuilder(
    column: $table.hasViolation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AuditsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditsTable> {
  $$AuditsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shopId =>
      $composableBuilder(column: $table.shopId, builder: (column) => column);

  GeneratedColumn<String> get routeStopId => $composableBuilder(
    column: $table.routeStopId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAtDevice => $composableBuilder(
    column: $table.startedAtDevice,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get finishedAtDevice => $composableBuilder(
    column: $table.finishedAtDevice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<double> get gpsAccuracyM => $composableBuilder(
    column: $table.gpsAccuracyM,
    builder: (column) => column,
  );

  GeneratedColumn<int> get distanceM =>
      $composableBuilder(column: $table.distanceM, builder: (column) => column);

  GeneratedColumn<bool> get withinRadius => $composableBuilder(
    column: $table.withinRadius,
    builder: (column) => column,
  );

  GeneratedColumn<String> get comment =>
      $composableBuilder(column: $table.comment, builder: (column) => column);

  GeneratedColumn<bool> get hasViolation => $composableBuilder(
    column: $table.hasViolation,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$AuditsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuditsTable,
          Audit,
          $$AuditsTableFilterComposer,
          $$AuditsTableOrderingComposer,
          $$AuditsTableAnnotationComposer,
          $$AuditsTableCreateCompanionBuilder,
          $$AuditsTableUpdateCompanionBuilder,
          (Audit, BaseReferences<_$AppDatabase, $AuditsTable, Audit>),
          Audit,
          PrefetchHooks Function()
        > {
  $$AuditsTableTableManager(_$AppDatabase db, $AuditsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shopId = const Value.absent(),
                Value<String?> routeStopId = const Value.absent(),
                Value<DateTime> startedAtDevice = const Value.absent(),
                Value<DateTime> finishedAtDevice = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lng = const Value.absent(),
                Value<double> gpsAccuracyM = const Value.absent(),
                Value<int?> distanceM = const Value.absent(),
                Value<bool?> withinRadius = const Value.absent(),
                Value<String> comment = const Value.absent(),
                Value<bool> hasViolation = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditsCompanion(
                id: id,
                shopId: shopId,
                routeStopId: routeStopId,
                startedAtDevice: startedAtDevice,
                finishedAtDevice: finishedAtDevice,
                lat: lat,
                lng: lng,
                gpsAccuracyM: gpsAccuracyM,
                distanceM: distanceM,
                withinRadius: withinRadius,
                comment: comment,
                hasViolation: hasViolation,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shopId,
                Value<String?> routeStopId = const Value.absent(),
                required DateTime startedAtDevice,
                required DateTime finishedAtDevice,
                required double lat,
                required double lng,
                required double gpsAccuracyM,
                Value<int?> distanceM = const Value.absent(),
                Value<bool?> withinRadius = const Value.absent(),
                required String comment,
                Value<bool> hasViolation = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditsCompanion.insert(
                id: id,
                shopId: shopId,
                routeStopId: routeStopId,
                startedAtDevice: startedAtDevice,
                finishedAtDevice: finishedAtDevice,
                lat: lat,
                lng: lng,
                gpsAccuracyM: gpsAccuracyM,
                distanceM: distanceM,
                withinRadius: withinRadius,
                comment: comment,
                hasViolation: hasViolation,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AuditsTable, Audit>(table),
                  BaseReferences<_$AppDatabase, $AuditsTable, Audit>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AuditsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuditsTable,
      Audit,
      $$AuditsTableFilterComposer,
      $$AuditsTableOrderingComposer,
      $$AuditsTableAnnotationComposer,
      $$AuditsTableCreateCompanionBuilder,
      $$AuditsTableUpdateCompanionBuilder,
      (Audit, BaseReferences<_$AppDatabase, $AuditsTable, Audit>),
      Audit,
      PrefetchHooks Function()
    >;
typedef $$PhotosTableCreateCompanionBuilder = PhotosCompanion Function({
  required String id,
  required String kind,
  Value<String?> auditId,
  Value<String?> shopId,
  Value<String?> localPath,
  Value<String?> url,
  Value<String?> previewUrl,
  required String mime,
  required int sizeBytes,
  required String sha256,
  required DateTime takenAt,
  Value<double?> lat,
  Value<double?> lng,
  Value<double?> accuracyM,
  Value<String> status,
  Value<DateTime?> readyAt,
  Value<int> rowid,
});
typedef $$PhotosTableUpdateCompanionBuilder = PhotosCompanion Function({
  Value<String> id,
  Value<String> kind,
  Value<String?> auditId,
  Value<String?> shopId,
  Value<String?> localPath,
  Value<String?> url,
  Value<String?> previewUrl,
  Value<String> mime,
  Value<int> sizeBytes,
  Value<String> sha256,
  Value<DateTime> takenAt,
  Value<double?> lat,
  Value<double?> lng,
  Value<double?> accuracyM,
  Value<String> status,
  Value<DateTime?> readyAt,
  Value<int> rowid,
});

class $$PhotosTableFilterComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get auditId => $composableBuilder(
    column: $table.auditId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shopId => $composableBuilder(
    column: $table.shopId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get previewUrl => $composableBuilder(
    column: $table.previewUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mime => $composableBuilder(
    column: $table.mime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accuracyM => $composableBuilder(
    column: $table.accuracyM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get readyAt => $composableBuilder(
    column: $table.readyAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get auditId => $composableBuilder(
    column: $table.auditId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shopId => $composableBuilder(
    column: $table.shopId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get previewUrl => $composableBuilder(
    column: $table.previewUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mime => $composableBuilder(
    column: $table.mime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracyM => $composableBuilder(
    column: $table.accuracyM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get readyAt => $composableBuilder(
    column: $table.readyAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get auditId =>
      $composableBuilder(column: $table.auditId, builder: (column) => column);

  GeneratedColumn<String> get shopId =>
      $composableBuilder(column: $table.shopId, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get previewUrl => $composableBuilder(
    column: $table.previewUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mime =>
      $composableBuilder(column: $table.mime, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<DateTime> get takenAt =>
      $composableBuilder(column: $table.takenAt, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<double> get accuracyM =>
      $composableBuilder(column: $table.accuracyM, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get readyAt =>
      $composableBuilder(column: $table.readyAt, builder: (column) => column);
}

class $$PhotosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PhotosTable,
          Photo,
          $$PhotosTableFilterComposer,
          $$PhotosTableOrderingComposer,
          $$PhotosTableAnnotationComposer,
          $$PhotosTableCreateCompanionBuilder,
          $$PhotosTableUpdateCompanionBuilder,
          (Photo, BaseReferences<_$AppDatabase, $PhotosTable, Photo>),
          Photo,
          PrefetchHooks Function()
        > {
  $$PhotosTableTableManager(_$AppDatabase db, $PhotosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> auditId = const Value.absent(),
                Value<String?> shopId = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<String?> previewUrl = const Value.absent(),
                Value<String> mime = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<String> sha256 = const Value.absent(),
                Value<DateTime> takenAt = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lng = const Value.absent(),
                Value<double?> accuracyM = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> readyAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhotosCompanion(
                id: id,
                kind: kind,
                auditId: auditId,
                shopId: shopId,
                localPath: localPath,
                url: url,
                previewUrl: previewUrl,
                mime: mime,
                sizeBytes: sizeBytes,
                sha256: sha256,
                takenAt: takenAt,
                lat: lat,
                lng: lng,
                accuracyM: accuracyM,
                status: status,
                readyAt: readyAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String kind,
                Value<String?> auditId = const Value.absent(),
                Value<String?> shopId = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<String?> previewUrl = const Value.absent(),
                required String mime,
                required int sizeBytes,
                required String sha256,
                required DateTime takenAt,
                Value<double?> lat = const Value.absent(),
                Value<double?> lng = const Value.absent(),
                Value<double?> accuracyM = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> readyAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhotosCompanion.insert(
                id: id,
                kind: kind,
                auditId: auditId,
                shopId: shopId,
                localPath: localPath,
                url: url,
                previewUrl: previewUrl,
                mime: mime,
                sizeBytes: sizeBytes,
                sha256: sha256,
                takenAt: takenAt,
                lat: lat,
                lng: lng,
                accuracyM: accuracyM,
                status: status,
                readyAt: readyAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PhotosTable, Photo>(table),
                  BaseReferences<_$AppDatabase, $PhotosTable, Photo>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PhotosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PhotosTable,
      Photo,
      $$PhotosTableFilterComposer,
      $$PhotosTableOrderingComposer,
      $$PhotosTableAnnotationComposer,
      $$PhotosTableCreateCompanionBuilder,
      $$PhotosTableUpdateCompanionBuilder,
      (Photo, BaseReferences<_$AppDatabase, $PhotosTable, Photo>),
      Photo,
      PrefetchHooks Function()
    >;
typedef $$AuditDraftsTableCreateCompanionBuilder =
    AuditDraftsCompanion Function({
      required String shopId,
      required String auditId,
      Value<String?> routeStopId,
      required DateTime startedAt,
      Value<String> comment,
      Value<bool> hasViolation,
      Value<int> rowid,
    });
typedef $$AuditDraftsTableUpdateCompanionBuilder =
    AuditDraftsCompanion Function({
      Value<String> shopId,
      Value<String> auditId,
      Value<String?> routeStopId,
      Value<DateTime> startedAt,
      Value<String> comment,
      Value<bool> hasViolation,
      Value<int> rowid,
    });

class $$AuditDraftsTableFilterComposer
    extends Composer<_$AppDatabase, $AuditDraftsTable> {
  $$AuditDraftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get shopId => $composableBuilder(
    column: $table.shopId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get auditId => $composableBuilder(
    column: $table.auditId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get routeStopId => $composableBuilder(
    column: $table.routeStopId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasViolation => $composableBuilder(
    column: $table.hasViolation,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AuditDraftsTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditDraftsTable> {
  $$AuditDraftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get shopId => $composableBuilder(
    column: $table.shopId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get auditId => $composableBuilder(
    column: $table.auditId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get routeStopId => $composableBuilder(
    column: $table.routeStopId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasViolation => $composableBuilder(
    column: $table.hasViolation,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AuditDraftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditDraftsTable> {
  $$AuditDraftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get shopId =>
      $composableBuilder(column: $table.shopId, builder: (column) => column);

  GeneratedColumn<String> get auditId =>
      $composableBuilder(column: $table.auditId, builder: (column) => column);

  GeneratedColumn<String> get routeStopId => $composableBuilder(
    column: $table.routeStopId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<String> get comment =>
      $composableBuilder(column: $table.comment, builder: (column) => column);

  GeneratedColumn<bool> get hasViolation => $composableBuilder(
    column: $table.hasViolation,
    builder: (column) => column,
  );
}

class $$AuditDraftsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuditDraftsTable,
          AuditDraft,
          $$AuditDraftsTableFilterComposer,
          $$AuditDraftsTableOrderingComposer,
          $$AuditDraftsTableAnnotationComposer,
          $$AuditDraftsTableCreateCompanionBuilder,
          $$AuditDraftsTableUpdateCompanionBuilder,
          (
            AuditDraft,
            BaseReferences<_$AppDatabase, $AuditDraftsTable, AuditDraft>,
          ),
          AuditDraft,
          PrefetchHooks Function()
        > {
  $$AuditDraftsTableTableManager(_$AppDatabase db, $AuditDraftsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditDraftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditDraftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditDraftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> shopId = const Value.absent(),
                Value<String> auditId = const Value.absent(),
                Value<String?> routeStopId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<String> comment = const Value.absent(),
                Value<bool> hasViolation = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditDraftsCompanion(
                shopId: shopId,
                auditId: auditId,
                routeStopId: routeStopId,
                startedAt: startedAt,
                comment: comment,
                hasViolation: hasViolation,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String shopId,
                required String auditId,
                Value<String?> routeStopId = const Value.absent(),
                required DateTime startedAt,
                Value<String> comment = const Value.absent(),
                Value<bool> hasViolation = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditDraftsCompanion.insert(
                shopId: shopId,
                auditId: auditId,
                routeStopId: routeStopId,
                startedAt: startedAt,
                comment: comment,
                hasViolation: hasViolation,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AuditDraftsTable, AuditDraft>(table),
                  BaseReferences<_$AppDatabase, $AuditDraftsTable, AuditDraft>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AuditDraftsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuditDraftsTable,
      AuditDraft,
      $$AuditDraftsTableFilterComposer,
      $$AuditDraftsTableOrderingComposer,
      $$AuditDraftsTableAnnotationComposer,
      $$AuditDraftsTableCreateCompanionBuilder,
      $$AuditDraftsTableUpdateCompanionBuilder,
      (
        AuditDraft,
        BaseReferences<_$AppDatabase, $AuditDraftsTable, AuditDraft>,
      ),
      AuditDraft,
      PrefetchHooks Function()
    >;
typedef $$OutboxTableCreateCompanionBuilder = OutboxCompanion Function({
  required String id,
  required OutboxKind kind,
  required String payloadJson,
  Value<String> dependsOn,
  required DateTime createdAt,
  Value<int> attempts,
  Value<String?> lastError,
  Value<DateTime?> nextAttemptAt,
  Value<OutboxState> state,
  Value<int> rowid,
});
typedef $$OutboxTableUpdateCompanionBuilder = OutboxCompanion Function({
  Value<String> id,
  Value<OutboxKind> kind,
  Value<String> payloadJson,
  Value<String> dependsOn,
  Value<DateTime> createdAt,
  Value<int> attempts,
  Value<String?> lastError,
  Value<DateTime?> nextAttemptAt,
  Value<OutboxState> state,
  Value<int> rowid,
});

class $$OutboxTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<OutboxKind, OutboxKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dependsOn => $composableBuilder(
    column: $table.dependsOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<OutboxState, OutboxState, String> get state =>
      $composableBuilder(
        column: $table.state,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$OutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dependsOn => $composableBuilder(
    column: $table.dependsOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<OutboxKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dependsOn =>
      $composableBuilder(column: $table.dependsOn, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<OutboxState, String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);
}

class $$OutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxTable,
          OutboxData,
          $$OutboxTableFilterComposer,
          $$OutboxTableOrderingComposer,
          $$OutboxTableAnnotationComposer,
          $$OutboxTableCreateCompanionBuilder,
          $$OutboxTableUpdateCompanionBuilder,
          (OutboxData, BaseReferences<_$AppDatabase, $OutboxTable, OutboxData>),
          OutboxData,
          PrefetchHooks Function()
        > {
  $$OutboxTableTableManager(_$AppDatabase db, $OutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<OutboxKind> kind = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String> dependsOn = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<OutboxState> state = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxCompanion(
                id: id,
                kind: kind,
                payloadJson: payloadJson,
                dependsOn: dependsOn,
                createdAt: createdAt,
                attempts: attempts,
                lastError: lastError,
                nextAttemptAt: nextAttemptAt,
                state: state,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required OutboxKind kind,
                required String payloadJson,
                Value<String> dependsOn = const Value.absent(),
                required DateTime createdAt,
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<OutboxState> state = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxCompanion.insert(
                id: id,
                kind: kind,
                payloadJson: payloadJson,
                dependsOn: dependsOn,
                createdAt: createdAt,
                attempts: attempts,
                lastError: lastError,
                nextAttemptAt: nextAttemptAt,
                state: state,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OutboxTable, OutboxData>(table),
                  BaseReferences<_$AppDatabase, $OutboxTable, OutboxData>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxTable,
      OutboxData,
      $$OutboxTableFilterComposer,
      $$OutboxTableOrderingComposer,
      $$OutboxTableAnnotationComposer,
      $$OutboxTableCreateCompanionBuilder,
      $$OutboxTableUpdateCompanionBuilder,
      (OutboxData, BaseReferences<_$AppDatabase, $OutboxTable, OutboxData>),
      OutboxData,
      PrefetchHooks Function()
    >;
typedef $$PingsBufferTableCreateCompanionBuilder =
    PingsBufferCompanion Function({
      Value<int> id,
      required DateTime recordedAt,
      required double lat,
      required double lng,
      required double accuracyM,
      Value<double?> speedKmh,
      Value<int?> batteryPct,
      Value<String> trigger,
    });
typedef $$PingsBufferTableUpdateCompanionBuilder =
    PingsBufferCompanion Function({
      Value<int> id,
      Value<DateTime> recordedAt,
      Value<double> lat,
      Value<double> lng,
      Value<double> accuracyM,
      Value<double?> speedKmh,
      Value<int?> batteryPct,
      Value<String> trigger,
    });

class $$PingsBufferTableFilterComposer
    extends Composer<_$AppDatabase, $PingsBufferTable> {
  $$PingsBufferTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accuracyM => $composableBuilder(
    column: $table.accuracyM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get speedKmh => $composableBuilder(
    column: $table.speedKmh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get batteryPct => $composableBuilder(
    column: $table.batteryPct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trigger => $composableBuilder(
    column: $table.trigger,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PingsBufferTableOrderingComposer
    extends Composer<_$AppDatabase, $PingsBufferTable> {
  $$PingsBufferTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracyM => $composableBuilder(
    column: $table.accuracyM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get speedKmh => $composableBuilder(
    column: $table.speedKmh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get batteryPct => $composableBuilder(
    column: $table.batteryPct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trigger => $composableBuilder(
    column: $table.trigger,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PingsBufferTableAnnotationComposer
    extends Composer<_$AppDatabase, $PingsBufferTable> {
  $$PingsBufferTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<double> get accuracyM =>
      $composableBuilder(column: $table.accuracyM, builder: (column) => column);

  GeneratedColumn<double> get speedKmh =>
      $composableBuilder(column: $table.speedKmh, builder: (column) => column);

  GeneratedColumn<int> get batteryPct => $composableBuilder(
    column: $table.batteryPct,
    builder: (column) => column,
  );

  GeneratedColumn<String> get trigger =>
      $composableBuilder(column: $table.trigger, builder: (column) => column);
}

class $$PingsBufferTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PingsBufferTable,
          PingsBufferData,
          $$PingsBufferTableFilterComposer,
          $$PingsBufferTableOrderingComposer,
          $$PingsBufferTableAnnotationComposer,
          $$PingsBufferTableCreateCompanionBuilder,
          $$PingsBufferTableUpdateCompanionBuilder,
          (
            PingsBufferData,
            BaseReferences<_$AppDatabase, $PingsBufferTable, PingsBufferData>,
          ),
          PingsBufferData,
          PrefetchHooks Function()
        > {
  $$PingsBufferTableTableManager(_$AppDatabase db, $PingsBufferTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PingsBufferTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PingsBufferTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PingsBufferTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lng = const Value.absent(),
                Value<double> accuracyM = const Value.absent(),
                Value<double?> speedKmh = const Value.absent(),
                Value<int?> batteryPct = const Value.absent(),
                Value<String> trigger = const Value.absent(),
              }) => PingsBufferCompanion(
                id: id,
                recordedAt: recordedAt,
                lat: lat,
                lng: lng,
                accuracyM: accuracyM,
                speedKmh: speedKmh,
                batteryPct: batteryPct,
                trigger: trigger,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime recordedAt,
                required double lat,
                required double lng,
                required double accuracyM,
                Value<double?> speedKmh = const Value.absent(),
                Value<int?> batteryPct = const Value.absent(),
                Value<String> trigger = const Value.absent(),
              }) => PingsBufferCompanion.insert(
                id: id,
                recordedAt: recordedAt,
                lat: lat,
                lng: lng,
                accuracyM: accuracyM,
                speedKmh: speedKmh,
                batteryPct: batteryPct,
                trigger: trigger,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PingsBufferTable, PingsBufferData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PingsBufferTable,
                    PingsBufferData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PingsBufferTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PingsBufferTable,
      PingsBufferData,
      $$PingsBufferTableFilterComposer,
      $$PingsBufferTableOrderingComposer,
      $$PingsBufferTableAnnotationComposer,
      $$PingsBufferTableCreateCompanionBuilder,
      $$PingsBufferTableUpdateCompanionBuilder,
      (
        PingsBufferData,
        BaseReferences<_$AppDatabase, $PingsBufferTable, PingsBufferData>,
      ),
      PingsBufferData,
      PrefetchHooks Function()
    >;
typedef $$SyncCursorsTableCreateCompanionBuilder =
    SyncCursorsCompanion Function({
      required String name,
      required String value,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SyncCursorsTableUpdateCompanionBuilder =
    SyncCursorsCompanion Function({
      Value<String> name,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SyncCursorsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncCursorsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncCursorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SyncCursorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncCursorsTable,
          SyncCursor,
          $$SyncCursorsTableFilterComposer,
          $$SyncCursorsTableOrderingComposer,
          $$SyncCursorsTableAnnotationComposer,
          $$SyncCursorsTableCreateCompanionBuilder,
          $$SyncCursorsTableUpdateCompanionBuilder,
          (
            SyncCursor,
            BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursor>,
          ),
          SyncCursor,
          PrefetchHooks Function()
        > {
  $$SyncCursorsTableTableManager(_$AppDatabase db, $SyncCursorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncCursorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncCursorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncCursorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> name = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion(
                name: name,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String name,
                required String value,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion.insert(
                name: name,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncCursorsTable, SyncCursor>(table),
                  BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursor>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncCursorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncCursorsTable,
      SyncCursor,
      $$SyncCursorsTableFilterComposer,
      $$SyncCursorsTableOrderingComposer,
      $$SyncCursorsTableAnnotationComposer,
      $$SyncCursorsTableCreateCompanionBuilder,
      $$SyncCursorsTableUpdateCompanionBuilder,
      (
        SyncCursor,
        BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursor>,
      ),
      SyncCursor,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ShopsTableTableManager get shops =>
      $$ShopsTableTableManager(_db, _db.shops);
  $$ShopContactsTableTableManager get shopContacts =>
      $$ShopContactsTableTableManager(_db, _db.shopContacts);
  $$RoutesTableTableManager get routes =>
      $$RoutesTableTableManager(_db, _db.routes);
  $$RouteStopsTableTableManager get routeStops =>
      $$RouteStopsTableTableManager(_db, _db.routeStops);
  $$AuditsTableTableManager get audits =>
      $$AuditsTableTableManager(_db, _db.audits);
  $$PhotosTableTableManager get photos =>
      $$PhotosTableTableManager(_db, _db.photos);
  $$AuditDraftsTableTableManager get auditDrafts =>
      $$AuditDraftsTableTableManager(_db, _db.auditDrafts);
  $$OutboxTableTableManager get outbox =>
      $$OutboxTableTableManager(_db, _db.outbox);
  $$PingsBufferTableTableManager get pingsBuffer =>
      $$PingsBufferTableTableManager(_db, _db.pingsBuffer);
  $$SyncCursorsTableTableManager get syncCursors =>
      $$SyncCursorsTableTableManager(_db, _db.syncCursors);
}
