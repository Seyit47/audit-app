import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/app_database.dart';
import '../db/database_provider.dart';
import '../sync/pull_service.dart';

/// The company settings subset from `/me`, kept on the device by the pull (contracts/sync.md).
class RemoteConfig {
  const RemoteConfig({
    this.companyName = '',
    this.defaultAuditRadiusM = 100,
    this.minGpsAccuracyM = 50,
    this.workStart = '08:00',
    this.workEnd = '19:00',
    this.timezone = 'Asia/Ashgabat',
    this.workStatus = 'ACTIVE',
  });

  factory RemoteConfig.fromMe(Map<String, dynamic> me) {
    final c = (me['config'] as Map?)?.cast<String, dynamic>() ?? const {};
    final agent = (me['agent'] as Map?)?.cast<String, dynamic>();
    return RemoteConfig(
      companyName: c['companyName'] as String? ?? '',
      defaultAuditRadiusM: c['defaultAuditRadiusM'] as int? ?? 100,
      minGpsAccuracyM: c['minGpsAccuracyM'] as int? ?? 50,
      workStart: c['workStart'] as String? ?? '08:00',
      workEnd: c['workEnd'] as String? ?? '19:00',
      timezone: c['timezone'] as String? ?? 'Asia/Ashgabat',
      workStatus: agent?['workStatus'] as String? ?? 'ACTIVE',
    );
  }

  final String companyName;
  final int defaultAuditRadiusM;
  final int minGpsAccuracyM;
  final String workStart;
  final String workEnd;
  final String timezone;
  final String workStatus;
}

Stream<RemoteConfig> watchRemoteConfig(AppDatabase db) => (db.select(db.syncCursors)..where((c) => c.name.equals(PullService.meCursor)))
    .watchSingleOrNull()
    .map((row) => row == null ? const RemoteConfig() : RemoteConfig.fromMe(jsonDecode(row.value) as Map<String, dynamic>));

final remoteConfigProvider = StreamProvider<RemoteConfig>((ref) => watchRemoteConfig(ref.watch(databaseProvider)));
