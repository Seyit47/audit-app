import 'dart:convert';

import 'package:audit_mobile/core/db/app_database.dart';
import 'package:drift/drift.dart';

/// Demo data in the spirit of the Figma frames.
Future<void> seed(AppDatabase db) async {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  const names = ['Магазин Алтын', 'Sunrise Corner Shop', 'Магазин Хазар', 'Магазин Юнус', 'Bahar Market', 'Гастроном «У Дома №14»', 'Мир Текстиля'];
  for (final (i, name) in names.indexed) {
    final id = 's$i';
    await db
        .into(db.shops)
        .insert(
          ShopsCompanion.insert(
            id: id,
            code: 'CL-10$i',
            name: name,
            type: 'MARKET',
            address: 'г. Ашхабад, ул. Атамурата, ${24 + i}',
            regionName: Value(i.isEven ? 'Region 1 (Central Hub)' : 'Region 2 (West District)'),
            lat: 37.95 + i * 0.004,
            lng: 58.38 + i * 0.006,
            auditRadiusM: 100,
            status: 'ACTIVE',
            ownerName: const Value('Бахытжан'),
            lastVisitAt: Value(i == 2 ? null : today.subtract(Duration(days: i == 0 ? 7 : i)).add(const Duration(hours: 15, minutes: 17))),
            nextDueAt: Value(i == 0 ? today.subtract(const Duration(days: 2)) : today.add(Duration(days: i))),
            latestVisitsJson: Value(i == 0 ? jsonEncode(_visits(today)) : '[]'),
            updatedAt: now,
          ),
        );
    await db
        .into(db.shopContacts)
        .insert(ShopContactsCompanion.insert(id: 'c$i', shopId: id, phone: '+993 62 11233', label: const Value('Администратор'), position: 0));
  }
  for (var i = 0; i < 18; i++) {
    final taken = (i < 7 ? today : today.subtract(Duration(days: 3 + i ~/ 8))).add(Duration(hours: 9, minutes: i * 7));
    await db
        .into(db.photos)
        .insert(
          PhotosCompanion.insert(
            id: 'ph$i',
            kind: 'AUDIT',
            auditId: Value(i < 5 ? 'a1' : 'a$i'),
            shopId: const Value('s0'),
            mime: 'image/jpeg',
            sizeBytes: 1,
            sha256: 'x',
            takenAt: taken,
            status: const Value('READY'),
          ),
        );
  }
  await db.into(db.routes).insert(RoutesCompanion.insert(id: 'r1', date: today, updatedAt: now));
  for (final (i, shop) in ['s3', 's4', 's5'].indexed) {
    await db
        .into(db.routeStops)
        .insert(
          RouteStopsCompanion.insert(
            id: 'st$i',
            routeId: 'r1',
            shopId: shop,
            position: i,
            plannedAt: today.add(Duration(hours: 9 + i)),
            isAuditTask: true,
            status: 'PLANNED',
          ),
        );
  }
}

List<Map<String, Object?>> _visits(DateTime today) => [
  {
    'type': 'AUDIT',
    'id': 'a1',
    'at': today.subtract(const Duration(days: 7)).add(const Duration(hours: 15, minutes: 40)).toIso8601String(),
    'comment': 'Стойка напитков перекрыта коробками конкурентов. Сделано предписание исправить выкладку.',
    'hasViolation': true,
    'withinRadius': true,
    'lat': 43.238949,
    'lng': 76.889709,
    'gpsAccuracyM': 8,
    'photoCount': 5,
    'photos': [
      for (var i = 0; i < 5; i++) {'id': 'p$i', 'url': 'http://x/$i'},
    ],
  },
  {
    'type': 'AUDIT',
    'id': 'a2',
    'at': today.subtract(const Duration(days: 30)).add(const Duration(hours: 11, minutes: 15)).toIso8601String(),
    'comment': 'Все рекламные воблеры и ценники на месте. Замечаний нет.',
    'hasViolation': false,
    'withinRadius': true,
    'lat': 43.238949,
    'lng': 76.889709,
    'gpsAccuracyM': 6,
    'photoCount': 8,
    'photos': [
      for (var i = 0; i < 8; i++) {'id': 'q$i', 'url': 'http://x/$i'},
    ],
  },
];
