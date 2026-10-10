import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Photos are kept on disk so they show offline and aren't downloaded again (each download is a billed storage
/// read). Presigned URLs change every hour while the object stays the same, so a photo is cached under its storage
/// path without the signature.
String photoCacheKey(String url) {
  final u = Uri.parse(url);
  return '${u.host}${u.path}';
}

/// Storage photos: up to 2000 kept for 30 days since last use.
final photoCache = CacheManager(Config('photos', stalePeriod: const Duration(days: 30), maxNrOfCacheObjects: 2000));
