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

/// Who is signed in, from the same `/me` response: the agent's name with code and phone, or an admin's email.
class Profile {
  const Profile({required this.name, this.detail});

  /// Null until the first pull has stored `/me`.
  static Profile? fromMe(Map<String, dynamic> me) {
    final user = (me['user'] as Map?)?.cast<String, dynamic>() ?? const {};
    final agent = (me['agent'] as Map?)?.cast<String, dynamic>();
    if (agent != null) {
      return Profile(name: agent['fullName'] as String? ?? '', detail: [agent['code'], agent['phone']].whereType<String>().join(' · '));
    }
    final login = user['email'] as String? ?? user['phone'] as String?;
    return login == null ? null : Profile(name: login);
  }

  final String name;
  final String? detail;
}

final profileProvider = StreamProvider<Profile?>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.syncCursors)..where((c) => c.name.equals(PullService.meCursor))).watchSingleOrNull().map(
    (row) => row == null ? null : Profile.fromMe(jsonDecode(row.value) as Map<String, dynamic>),
  );
});
