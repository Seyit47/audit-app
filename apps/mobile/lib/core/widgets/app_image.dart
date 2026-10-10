import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../network/photo_cache.dart';
import '../theme/app_colors.dart';

/// A photo from a presigned URL, or a local file (`/…`) not yet uploaded; a tinted box while
/// loading, offline or missing.
class AppImage extends StatelessWidget {
  const AppImage(this.source, {super.key, this.width, this.height, this.radius = 8, this.fit = BoxFit.cover});

  final String? source;
  final double? width;
  final double? height;
  final double radius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(width: width, height: height, color: context.colors.darkAccent);
    final src = source;
    Widget image;
    if (src == null || src.isEmpty) {
      image = placeholder;
    } else if (src.startsWith('/')) {
      image = Image.file(File(src), width: width, height: height, fit: fit, errorBuilder: (_, _, _) => placeholder);
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
        errorWidget: (_, _, _) => placeholder,
      );
    }
    return ClipRRect(borderRadius: BorderRadius.circular(radius), child: image);
  }
}
