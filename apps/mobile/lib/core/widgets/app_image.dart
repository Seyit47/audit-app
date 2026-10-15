import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../network/photo_cache.dart';
import '../theme/app_colors.dart';

/// A photo from a presigned URL, or a local file (`/…`) not yet uploaded; a tinted box while
/// loading, offline or missing.
class AppImage extends StatelessWidget {
  const AppImage(this.source, {super.key, this.width, this.height, this.radius = 8, this.fit = BoxFit.cover, this.fallback});

  final String? source;

  /// Shown when [source] can't be loaded (a full-size photo whose link expired): its preview, usually
  /// already on the phone, instead of an empty box.
  final String? fallback;
  final double? width;
  final double? height;
  final double radius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final empty = Container(width: width, height: height, color: context.colors.darkAccent);
    final other = fallback;
    final failed = other == null || other == source ? empty : AppImage(other, width: width, height: height, radius: 0, fit: fit);
    final placeholder = empty;
    final src = source;
    Widget image;
    if (src == null || src.isEmpty) {
      image = failed;
    } else if (src.startsWith('/')) {
      image = Image.file(File(src), width: width, height: height, fit: fit, errorBuilder: (_, _, _) => failed);
    } else {
      // Kept on disk under the storage path: shown offline, not downloaded again when the signature changes.
      image = CachedNetworkImage(
        imageUrl: src,
        cacheKey: photoCacheKey(src),
        cacheManager: photoCache,
        width: width,
        height: height,
        fit: fit,
        fadeInDuration: const Duration(milliseconds: 150),
        placeholder: (_, _) => placeholder,
        errorWidget: (_, _, _) => failed,
      );
    }
    return ClipRRect(borderRadius: BorderRadius.circular(radius), child: image);
  }
}
