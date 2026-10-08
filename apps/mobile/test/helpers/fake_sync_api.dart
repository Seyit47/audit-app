import 'package:audit_mobile/core/network/api_exception.dart';
import 'package:audit_mobile/core/sync/sync_api.dart';

/// Records calls in order. `fail` maps a call name to the error it throws (once per entry).
class FakeApi implements SyncApi {
  final calls = <String>[];
  final fail = <String, List<ApiException>>{};
  var shopsPage = const ShopsPage(items: [], tombstones: [], cursor: 'c1');

  Future<void> _record(String call) async {
    calls.add(call);
    final queue = fail[call];
    if (queue != null && queue.isNotEmpty) throw queue.removeAt(0);
  }

  @override
  Future<UploadTarget> createUpload(Map<String, Object?> body) async {
    await _record('createUpload:${body['id']}');
    return const UploadTarget(ready: false, url: 'http://s3/put', headers: {});
  }

  @override
  Future<void> putFile(UploadTarget target, String path, String mime) => _record('put:$path');

  @override
  Future<void> completeUpload(String id) => _record('complete:$id');

  @override
  Future<void> createShop(Map<String, Object?> body) => _record('createShop:${body['id']}');

  @override
  Future<void> createAudit(Map<String, Object?> body) => _record('createAudit:${body['id']}');

  @override
  Future<void> sendPings(List<Map<String, Object?>> pings) => _record('pings:${pings.length}');

  @override
  Future<ShopsPage> shops({String? updatedAfter}) async {
    calls.add('shops:$updatedAfter');
    return shopsPage;
  }

  Map<String, Object?> route = const {'id': null, 'date': '2026-10-06', 'stops': []};

  @override
  Future<Map<String, Object?>> routeToday() async {
    calls.add('routeToday');
    return route;
  }

  Map<String, Object?> meJson = const {
    'config': {'companyName': 'Co', 'defaultAuditRadiusM': 100, 'minGpsAccuracyM': 50, 'workStart': '08:00', 'workEnd': '19:00', 'timezone': 'Asia/Ashgabat'},
  };

  @override
  Future<Map<String, Object?>> me() async {
    calls.add('me');
    return meJson;
  }

  List<Map<String, Object?>> photos = const [];

  @override
  Future<List<Map<String, Object?>>> myPhotos() async {
    calls.add('photos');
    return photos;
  }
}
