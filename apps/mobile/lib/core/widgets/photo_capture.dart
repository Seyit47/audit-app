import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../features/audit/domain/geofence.dart';
import 'camera_capture_screen.dart';

/// A photo saved to the app documents directory with its time and position, before anything
/// else happens to it (contracts/sync.md principle 2).
class CapturedPhoto {
  const CapturedPhoto({required this.id, required this.path, required this.sizeBytes, required this.sha256, required this.takenAt, this.fix});

  final String id;
  final String path;
  final int sizeBytes;
  final String sha256;
  final DateTime takenAt;
  final Fix? fix;
}

/// Where photos come from; tests use a fake.
abstract interface class PhotoCapture {
  /// Opens the camera (never the gallery). Null when the user cancels.
  Future<CapturedPhoto?> capture({Fix? fix});
}

/// Gets the current position for the audit and for photos.
abstract class Locator {
  /// The position to use (the last value of [watch]).
  Future<Fix?> current();

  /// At once the phone's last known position ([Fix.provisional]) when there is a recent one, then the
  /// GPS fix the moment it answers; null when there is none.
  Stream<Fix?> watch() async* {
    yield await current();
  }
}

/// Photos from the in-app camera ([takePhoto]): always the back camera, whatever the phone's camera app last used.
class CameraPhotoCapture implements PhotoCapture {
  CameraPhotoCapture(this._navigator);

  final NavigatorState? Function() _navigator;

  @override
  Future<CapturedPhoto?> capture({Fix? fix}) async {
    final navigator = _navigator();
    if (navigator == null) return null;
    final shot = await takePhoto(navigator);
    if (shot == null) return null;
    final takenAt = DateTime.now().toUtc();
    final id = const Uuid().v7();
    final dir = Directory(p.join((await getApplicationDocumentsDirectory()).path, 'photos'));
    await dir.create(recursive: true);
    final file = await shot.rename(p.join(dir.path, '$id.jpg')).catchError((_) => shot.copy(p.join(dir.path, '$id.jpg')));
    final bytes = await file.readAsBytes();
    return CapturedPhoto(id: id, path: file.path, sizeBytes: bytes.length, sha256: sha256.convert(bytes).toString(), takenAt: takenAt, fix: fix);
  }
}
