import 'version_info.dart';

/// Whether this app can work with the backend it is talking to.
sealed class Compatibility {
  const Compatibility();
}

class Compatible extends Compatibility {
  const Compatible(this.info);
  final VersionInfo info;
}

class UpdateRequired extends Compatibility {
  const UpdateRequired();
}

class Unreachable extends Compatibility {
  const Unreachable();
}

/// Compares the running app version with the minimum the server supports.
Compatibility evaluateCompatibility(String appVersion, VersionInfo info) {
  return _isLower(appVersion, info.minMobileVersion)
      ? const UpdateRequired()
      : Compatible(info);
}

bool _isLower(String a, String b) {
  List<int> parts(String v) =>
      v.split('+').first.split('.').map(int.parse).toList();
  final pa = parts(a);
  final pb = parts(b);
  for (var i = 0; i < 3; i++) {
    final diff = (i < pa.length ? pa[i] : 0) - (i < pb.length ? pb[i] : 0);
    if (diff != 0) return diff < 0;
  }
  return false;
}
