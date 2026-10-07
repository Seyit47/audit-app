import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../features/audit/domain/geofence.dart';

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
abstract interface class Locator {
  Future<Fix?> current();
}

class CameraPhotoCapture implements PhotoCapture {
  CameraPhotoCapture({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<CapturedPhoto?> capture({Fix? fix}) async {
    final shot = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85, maxWidth: 2560, maxHeight: 2560);
    if (shot == null) return null;
    final takenAt = DateTime.now().toUtc();
    final id = const Uuid().v7();
    final dir = Directory(p.join((await getApplicationDocumentsDirectory()).path, 'photos'));
    await dir.create(recursive: true);
    final file = await File(shot.path).copy(p.join(dir.path, '$id.jpg'));
    final bytes = await file.readAsBytes();
    return CapturedPhoto(id: id, path: file.path, sizeBytes: bytes.length, sha256: sha256.convert(bytes).toString(), takenAt: takenAt, fix: fix);
  }
}
