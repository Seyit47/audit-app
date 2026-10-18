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
import '../../shops/data/shops_local_repository.dart';
import '../../audit/presentation/audit_controller.dart';
import '../../../core/format/phone.dart';

class AddShopState {
  const AddShopState({
    this.name = '',
    this.address = '',
    this.owner = '',
    this.phone = '',
    this.districtId,
    this.fix,
    this.locating = true,
    this.photo,
    this.saving = false,
    this.maxAccuracyM = 50,
  });

  final String name;
  final String address;
  final String owner;
  final String phone;

  /// The shop's district; required once the districts are synced (none before the first sync).
  final String? districtId;
  final Fix? fix;
  final bool locating;
  final CapturedPhoto? photo;
  final bool saving;

  /// The company's GPS accuracy limit: the server refuses an agent's shop located less precisely.
  final int maxAccuracyM;

  bool get accurate => fix != null && !fix!.provisional && fix!.accuracyM <= maxAccuracyM;

  bool get nameOk => name.trim().isNotEmpty;

  /// Address, owner and phone are optional extra info; a phone, when given, must be a Turkmen number.
  bool get phoneOk => phone.trim().isEmpty || tmPhone(phone) != null;

  /// "Сохранить" (`252:26487` disabled, `252:26607` enabled): every field, a location and the photo.
  bool canSave({required bool districtsKnown}) => nameOk && phoneOk && (districtId != null || !districtsKnown) && accurate && photo != null && !saving;

  AddShopState copyWith({
    String? name,
    String? address,
    String? owner,
    String? phone,
    String? districtId,
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
    districtId: districtId ?? this.districtId,
    fix: fix ?? this.fix,
    locating: locating ?? this.locating,
    photo: clearPhoto ? null : (photo ?? this.photo),
    saving: saving ?? this.saving,
    maxAccuracyM: maxAccuracyM,
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

  void setDistrict(String? id) => state = state.copyWith(districtId: id);

  /// "Текущее местоположение" and "Проверить заново".
  Future<void> locate() async {
    state = state.copyWith(locating: true);
    // The last known position at once (shown as being refined), then the GPS fix when it answers.
    await for (final fix in ref.read(locatorProvider).watch()) {
      if (!ref.mounted) return;
      _apply(fix);
    }
  }

  void _apply(Fix? fix) {
    state = AddShopState(
      name: state.name,
      address: state.address,
      owner: state.owner,
      phone: state.phone,
      districtId: state.districtId,
      fix: fix,
      locating: fix?.provisional ?? false,
      photo: state.photo,
      saving: state.saving,
      maxAccuracyM: (ref.read(remoteConfigProvider).value ?? const RemoteConfig()).minGpsAccuracyM,
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

  /// Saves the shop and its photo to the outbox; returns the SHOP_CREATE item, or null when it can't be saved yet.
  Future<String?> save() async {
    final s = state;
    final districts = ref.read(districtsProvider).value ?? const <District>[];
    if (!s.canSave(districtsKnown: districts.isNotEmpty)) return null;
    state = s.copyWith(saving: true);
    final db = ref.read(databaseProvider);
    final outbox = ref.read(outboxProvider);
    final config = ref.read(remoteConfigProvider).value ?? const RemoteConfig();
    final id = const Uuid().v7();
    final photo = s.photo!;
    final fix = s.fix!;
    final phone = tmPhone(s.phone);
    late String shopItem;
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
      shopItem = await outbox.enqueue(
        OutboxKind.shopCreate,
        {
          'id': id,
          'name': s.name.trim(),
          'districtId': ?s.districtId,
          'address': s.address.trim(),
          'ownerName': s.owner.trim().isEmpty ? null : s.owner.trim(),
          'lat': fix.lat,
          'lng': fix.lng,
          'accuracyM': fix.accuracyM,
          'facadePhotoId': photo.id,
          'contacts': [
            if (phone != null) {'phone': phone},
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
              districtId: Value(s.districtId),
              districtName: Value(districts.where((d) => d.id == s.districtId).firstOrNull?.name),
              lat: fix.lat,
              lng: fix.lng,
              auditRadiusM: config.defaultAuditRadiusM,
              ownerName: Value(s.owner.trim().isEmpty ? null : s.owner.trim()),
              facadeUrl: Value(photo.path),
              status: 'PENDING_REVIEW',
              updatedAt: now,
            ),
          );
      if (phone != null) await db.into(db.shopContacts).insert(ShopContactsCompanion.insert(id: const Uuid().v7(), shopId: id, phone: phone, position: 0));
    });
    ref.read(syncTriggerProvider)();
    return shopItem;
  }

  static Future<void> _deleteFile(CapturedPhoto? photo) async {
    if (photo == null) return;
    final f = File(photo.path);
    if (await f.exists()) await f.delete();
  }
}

final addShopControllerProvider = NotifierProvider.autoDispose<AddShopController, AddShopState>(AddShopController.new);
