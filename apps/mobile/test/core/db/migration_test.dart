import 'package:audit_mobile/core/db/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('v2 → v3: region columns become district ones and the shops are pulled again', () async {
    // `setup` runs on the raw database before drift reads its version: the parts of version 2 the upgrade touches.
    final db = AppDatabase(
      NativeDatabase.memory(
        setup: (raw) => raw
          ..execute('''
            CREATE TABLE shops (id TEXT NOT NULL PRIMARY KEY, code TEXT NOT NULL, name TEXT NOT NULL, type TEXT NOT NULL,
              address TEXT NOT NULL, address_detail TEXT NULL, region_id TEXT NULL, region_name TEXT NULL, lat REAL NOT NULL,
              lng REAL NOT NULL, audit_radius_m INTEGER NOT NULL, owner_name TEXT NULL, facade_url TEXT NULL, status TEXT NOT NULL,
              last_visit_at INTEGER NULL, next_due_at INTEGER NULL, latest_visits_json TEXT NOT NULL DEFAULT '[]', updated_at INTEGER NOT NULL)''')
          ..execute('CREATE TABLE sync_cursors (name TEXT NOT NULL PRIMARY KEY, value TEXT NOT NULL, updated_at INTEGER NOT NULL)')
          ..execute(
            "INSERT INTO shops (id, code, name, type, address, region_id, region_name, lat, lng, audit_radius_m, status, updated_at) "
            "VALUES ('s1', 'C1', 'Shop', 'OTHER', 'Street', 'r1', 'Old', 37.9, 58.3, 100, 'ACTIVE', 0)",
          )
          ..execute("INSERT INTO sync_cursors VALUES ('shops', '2026-10-01T00:00:00Z', 0), ('me', '{}', 0)")
          ..execute('PRAGMA user_version = 2'),
      ),
    );
    addTearDown(db.close);

    final shop = await db.select(db.shops).getSingle();
    expect((shop.id, shop.districtId, shop.districtName), ('s1', 'r1', 'Old'));
    expect(await db.select(db.districts).get(), isEmpty);
    expect((await db.select(db.syncCursors).get()).map((c) => c.name), ['me']);
  });
}
