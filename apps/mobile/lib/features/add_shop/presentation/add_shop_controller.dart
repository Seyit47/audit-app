import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';
import '../../../core/settings/remote_config.dart';
import '../../../core/sync/sync_providers.dart';
import '../../../core/widgets/photo_capture.dart';
import '../../audit/domain/geofence.dart';
import '../../audit/presentation/audit_controller.dart';
import '../../../core/format/phone.dart';

class AddShopState {
  const AddShopState({this.name = '', this.address = '', this.owner = '', this.phone = '', this.fix, this.locating = true, this.photo, this.saving = false});

  final String name;
  final String address;
  final String owner;
  final String phone;
  final Fix? fix;
  final bool locating;
  final CapturedPhoto? photo;
  final bool saving;

  bool get nameOk => name.trim().isNotEmpty;
  bool get addressOk => address.trim().isNotEmpty;
  bool get ownerOk => owner.trim().isNotEmpty;
  bool get phoneOk => tmPhone(phone) != null;

  /// "Сохранить" (`252:26487` disabled, `252:26607` enabled): every field, a location and the photo.
  bool get canSave => nameOk && addressOk && ownerOk && phoneOk && fix != null && photo != null && !saving;

  AddShopState copyWith({
    String? name,
    String? address,
    String? owner,
    String? phone,
    Fix? fix,
    bool? locating,
    CapturedPhoto? photo,
    bool clearPhoto = false,
    bool? saving,
  }) => AddShopState(
    name: name ?? this.name,
    address: address ?? this.address,
    owner: owner ?? this.owner,
    phone: phone ?? this.phone,
    fix: fix ?? this.fix,
    locating: locating ?? this.locating,
    photo: clearPhoto ? null : (photo ?? this.photo),
    saving: saving ?? this.saving,
  );
}

/// Agent "Добавить Магазин" (T095): saved locally as PENDING_REVIEW and queued as PHOTO + SHOP_CREATE.
class AddShopController extends Notifier<AddShopState> {
  @override
  AddShopState build() {
    Future.microtask(locate);
    return const AddShopState();
  }

  void edit({String? name, String? address, String? owner, String? phone}) => state = state.copyWith(name: name, address: address, owner: owner, phone: phone);

  /// "Текущее местоположение" and "Проверить заново".
  Future<void> locate() async {
    state = state.copyWith(locating: true);
    final fix = await ref.read(locatorProvider).current();
    if (!ref.mounted) return;
    state = AddShopState(
      name: state.name,
      address: state.address,
      owner: state.owner,
      phone: state.phone,
      fix: fix,
      locating: false,
      photo: state.photo,
      saving: state.saving,
    );
  }

  Future<void> takePhoto() async {
    final photo = await ref.read(photoCaptureProvider).capture(fix: state.fix);
    if (photo != null && ref.mounted) {
      await _deleteFile(state.photo);
      state = state.copyWith(photo: photo);
    }
  }

  Future<void> removePhoto() async {
    await _deleteFile(state.photo);
    state = state.copyWith(clearPhoto: true);
  }

  Future<bool> save() async {
    final s = state;
    if (!s.canSave) return false;
    state = s.copyWith(saving: true);
    final db = ref.read(databaseProvider);
    final outbox = ref.read(outboxProvider);
    final config = ref.read(remoteConfigProvider).value ?? const RemoteConfig();
    final id = const Uuid().v7();
    final photo = s.photo!;
    final fix = s.fix!;
    await db.transaction(() async {
      await db
          .into(db.photos)
          .insert(
            PhotosCompanion.insert(
              id: photo.id,
              kind: 'FACADE',
              shopId: Value(id),
              localPath: Value(photo.path),
              mime: 'image/jpeg',
              sizeBytes: photo.sizeBytes,
              sha256: photo.sha256,
              takenAt: photo.takenAt,
              lat: Value(photo.fix?.lat),
              lng: Value(photo.fix?.lng),
              accuracyM: Value(photo.fix?.accuracyM),
            ),
          );
      final photoItem = await outbox.enqueue(OutboxKind.photo, {
        'id': photo.id,
        'kind': 'FACADE',
        'mime': 'image/jpeg',
        'sizeBytes': photo.sizeBytes,
        'sha256': photo.sha256,
        'takenAt': photo.takenAt.toIso8601String(),
        'lat': ?photo.fix?.lat,
        'lng': ?photo.fix?.lng,
        'accuracyM': ?photo.fix?.accuracyM,
        'localPath': photo.path,
      });
      await outbox.enqueue(
        OutboxKind.shopCreate,
        {
          'id': id,
          'name': s.name.trim(),
          'address': s.address.trim(),
          'ownerName': s.owner.trim(),
          'lat': fix.lat,
          'lng': fix.lng,
          'accuracyM': fix.accuracyM,
          'facadePhotoId': photo.id,
          'contacts': [
            {'phone': tmPhone(s.phone)!},
          ],
        },
        dependsOn: [photoItem],
      );
      final now = DateTime.now().toUtc();
      await db
          .into(db.shops)
          .insert(
            ShopsCompanion.insert(
              id: id,
              code: '—',
              name: s.name.trim(),
              type: 'OTHER',
              address: s.address.trim(),
              lat: fix.lat,
              lng: fix.lng,
              auditRadiusM: config.defaultAuditRadiusM,
              ownerName: Value(s.owner.trim()),
              facadeUrl: Value(photo.path),
              status: 'PENDING_REVIEW',
              updatedAt: now,
            ),
          );
      await db.into(db.shopContacts).insert(ShopContactsCompanion.insert(id: const Uuid().v7(), shopId: id, phone: tmPhone(s.phone)!, position: 0));
    });
    ref.read(syncTriggerProvider)();
    return true;
  }

  static Future<void> _deleteFile(CapturedPhoto? photo) async {
    if (photo == null) return;
    final f = File(photo.path);
    if (await f.exists()) await f.delete();
  }
}

final addShopControllerProvider = NotifierProvider.autoDispose<AddShopController, AddShopState>(AddShopController.new);
