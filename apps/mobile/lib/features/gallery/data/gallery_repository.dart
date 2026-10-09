import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';

class GalleryPhoto {
  const GalleryPhoto({required this.photo, this.shop});

  final Photo photo;
  final Shop? shop;

  /// The preview URL, or the local file while it is not uploaded.
  String? get image => photo.previewUrl ?? photo.localPath ?? photo.url;

  /// Full resolution: the file taken on this device, or the uploaded original.
  String? get full {
    final local = photo.localPath;
    if (local != null && File(local).existsSync()) return local;
    return photo.url ?? image;
  }
}

class PhotoDetails {
  const PhotoDetails({required this.photo, this.shop, this.comment = '', this.hasViolation = false, this.related = const []});

  final GalleryPhoto photo;
  final Shop? shop;
  final String comment;
  final bool hasViolation;
  final List<GalleryPhoto> related;
}

/// The agent's own audit photos (pulled and taken on the device), newest first. Storefront photos of shops they
/// added stay out of the gallery, as on the web.
class GalleryRepository {
  GalleryRepository(this._db);

  final AppDatabase _db;

  Stream<List<GalleryPhoto>> watchAll() {
    final q = _db.select(_db.photos)
      ..where((p) => p.kind.equals('AUDIT') & p.status.isNotValue('DRAFT'))
      ..orderBy([(p) => OrderingTerm.desc(p.takenAt)]);
    return q.watch().asyncMap((photos) async {
      final shops = {for (final s in await _db.select(_db.shops).get()) s.id: s};
      return [for (final p in photos) GalleryPhoto(photo: p, shop: shops[p.shopId])];
    });
  }

  Future<PhotoDetails?> details(String id) async {
    final p = await (_db.select(_db.photos)..where((x) => x.id.equals(id))).getSingleOrNull();
    if (p == null) return null;
    final shop = p.shopId == null ? null : await (_db.select(_db.shops)..where((s) => s.id.equals(p.shopId!))).getSingleOrNull();
    var comment = '';
    var violation = false;
    final auditId = p.auditId;
    if (auditId != null) {
      final local = await (_db.select(_db.audits)..where((a) => a.id.equals(auditId))).getSingleOrNull();
      if (local != null) {
        comment = local.comment;
        violation = local.hasViolation;
      } else if (shop != null) {
        for (final v in (jsonDecode(shop.latestVisitsJson) as List).cast<Map<String, dynamic>>()) {
          if (v['id'] == auditId) {
            comment = (v['comment'] as String?) ?? '';
            violation = (v['hasViolation'] as bool?) ?? false;
          }
        }
      }
    }
    final related = auditId == null
        ? [p]
        : await (_db.select(_db.photos)
                ..where((x) => x.auditId.equals(auditId))
                ..orderBy([(x) => OrderingTerm(expression: x.takenAt)]))
              .get();
    return PhotoDetails(
      photo: GalleryPhoto(photo: p, shop: shop),
      shop: shop,
      comment: comment,
      hasViolation: violation,
      related: [for (final r in related) GalleryPhoto(photo: r, shop: shop)],
    );
  }
}

final galleryRepositoryProvider = Provider<GalleryRepository>((ref) => GalleryRepository(ref.watch(databaseProvider)));
final galleryProvider = StreamProvider<List<GalleryPhoto>>((ref) => ref.watch(galleryRepositoryProvider).watchAll());
final photoDetailsProvider = FutureProvider.family<PhotoDetails?, String>((ref, id) => ref.watch(galleryRepositoryProvider).details(id));
