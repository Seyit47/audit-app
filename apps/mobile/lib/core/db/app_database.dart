import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

// Local store of the Agent role (data-model.md "Mobile local store"). Screens read only from here;
// the sync engine fills the mirrors and drains the outbox (contracts/sync.md).

// ---------- Mirrors ----------

class Shops extends Table {
  TextColumn get id => text()();
  TextColumn get code => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get address => text()();
  TextColumn get addressDetail => text().nullable()();
  TextColumn get regionId => text().nullable()();
  TextColumn get regionName => text().nullable()();
  RealColumn get lat => real()();
  RealColumn get lng => real()();
  IntColumn get auditRadiusM => integer()();
  TextColumn get ownerName => text().nullable()();
  TextColumn get facadeUrl => text().nullable()();
  TextColumn get status => text()();
  DateTimeColumn get lastVisitAt => dateTime().nullable()();
  DateTimeColumn get nextDueAt => dateTime().nullable()();
  /// Latest visits as served by `/shops` (shop details history), JSON array.
  TextColumn get latestVisitsJson => text().withDefault(const Constant('[]'))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class ShopContacts extends Table {
  TextColumn get id => text()();
  TextColumn get shopId => text().references(Shops, #id, onDelete: KeyAction.cascade)();
  TextColumn get phone => text()();
  TextColumn get label => text().nullable()();
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class Routes extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class RouteStops extends Table {
  TextColumn get id => text()();
  TextColumn get routeId => text().references(Routes, #id, onDelete: KeyAction.cascade)();
  TextColumn get shopId => text()();
  IntColumn get position => integer()();
  DateTimeColumn get plannedAt => dateTime()();
  BoolColumn get isAuditTask => boolean()();
  TextColumn get status => text()();
  TextColumn get auditId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// The agent's own audits (last 90 days), including ones not yet synced.
class Audits extends Table {
  TextColumn get id => text()();
  TextColumn get shopId => text()();
  TextColumn get routeStopId => text().nullable()();
  DateTimeColumn get startedAtDevice => dateTime()();
  DateTimeColumn get finishedAtDevice => dateTime()();
  RealColumn get lat => real()();
  RealColumn get lng => real()();
  RealColumn get gpsAccuracyM => real()();
  IntColumn get distanceM => integer().nullable()();
  BoolColumn get withinRadius => boolean().nullable()();
  TextColumn get comment => text()();
  BoolColumn get hasViolation => boolean().withDefault(const Constant(false))();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class Photos extends Table {
  TextColumn get id => text()();
  TextColumn get kind => text()();
  TextColumn get auditId => text().nullable()();
  TextColumn get shopId => text().nullable()();
  /// File in the app documents directory until the server confirms READY (+7 days).
  TextColumn get localPath => text().nullable()();
  TextColumn get url => text().nullable()();
  TextColumn get previewUrl => text().nullable()();
  TextColumn get mime => text()();
  IntColumn get sizeBytes => integer()();
  TextColumn get sha256 => text()();
  DateTimeColumn get takenAt => dateTime()();
  RealColumn get lat => real().nullable()();
  RealColumn get lng => real().nullable()();
  RealColumn get accuracyM => real().nullable()();
  TextColumn get status => text().withDefault(const Constant('PENDING_UPLOAD'))();
  DateTimeColumn get readyAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------- Outbox & buffers ----------

enum OutboxKind { photo, shopCreate, auditCreate, pings }

enum OutboxState { pending, failed, done }

class Outbox extends Table {
  TextColumn get id => text()();
  TextColumn get kind => textEnum<OutboxKind>()();
  TextColumn get payloadJson => text()();
  /// Outbox ids that must be done first, JSON array.
  TextColumn get dependsOn => text().withDefault(const Constant('[]'))();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();
  TextColumn get state => textEnum<OutboxState>().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

class PingsBuffer extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get recordedAt => dateTime()();
  RealColumn get lat => real()();
  RealColumn get lng => real()();
  RealColumn get accuracyM => real()();
  RealColumn get speedKmh => real().nullable()();
  IntColumn get batteryPct => integer().nullable()();
  TextColumn get trigger => text().withDefault(const Constant('HEARTBEAT'))();
}

class SyncCursors extends Table {
  TextColumn get name => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {name};
}

@DriftDatabase(tables: [Shops, ShopContacts, Routes, RouteStops, Audits, Photos, Outbox, PingsBuffer, SyncCursors])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _open());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(beforeOpen: (_) => customStatement('PRAGMA foreign_keys = ON'));

  /// Removes everything (sign-out wipe). Theme and locale live in shared preferences.
  Future<void> wipe() => transaction(() async {
        for (final table in allTables.toList().reversed) {
          await delete(table).go();
        }
      });

  static QueryExecutor _open() => LazyDatabase(() async {
        final dir = await getApplicationDocumentsDirectory();
        return NativeDatabase.createInBackground(File(p.join(dir.path, 'audit.sqlite')));
      });
}
