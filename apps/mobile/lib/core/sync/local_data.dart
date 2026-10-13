import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../db/app_database.dart';
import '../db/database_provider.dart';
import 'background_sync.dart';

/// Removes everything cached for a signed-in user: background sync, the local database and captured photo files.
/// Theme, locale, server address and activation live in shared preferences and stay.
Future<void> wipeLocalData(AppDatabase db) async {
  await cancelBackgroundSync().catchError((_) {});
  await db.wipe();
  final photos = Directory('${(await getApplicationDocumentsDirectory()).path}/photos');
  if (await photos.exists()) await photos.delete(recursive: true);
}

/// [wipeLocalData] for the signed-in user's database (sign-out, and sign-in by someone else or on another server).
final wipeLocalDataProvider = Provider<Future<void> Function()>(
  (ref) =>
      () => wipeLocalData(ref.read(databaseProvider)),
);
