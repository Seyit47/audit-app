import 'package:audit_mobile/core/network/photo_cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a photo keeps its cache key when its signed URL changes', () {
    const a = 'https://s3.eu-central-003.backblazeb2.com/audit/previews/p1-400.webp?X-Amz-Date=20261010T100000Z&X-Amz-Signature=aaa';
    const b = 'https://s3.eu-central-003.backblazeb2.com/audit/previews/p1-400.webp?X-Amz-Date=20261010T110000Z&X-Amz-Signature=bbb';
    expect(photoCacheKey(a), photoCacheKey(b));
    expect(photoCacheKey(a), isNot(photoCacheKey(a.replaceFirst('p1', 'p2'))));
  });
}
