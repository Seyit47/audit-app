import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/session_provider.dart';
import '../../../core/network/api_client.dart';
import '../domain/route_progress.dart';

/// A road route from the server (GraphHopper behind `GET /directions`).
class Directions {
  const Directions({required this.points, required this.distanceM, required this.durationS});

  final List<LatLngPoint> points;
  final double distanceM;
  final double durationS;
}

class DirectionsApi {
  DirectionsApi(this._api);

  final ApiClient _api;

  Future<Directions> route(LatLngPoint from, LatLngPoint to) async {
    final res = await _api.get<Map<String, dynamic>>('/directions', query: {'fromLat': from.$1, 'fromLng': from.$2, 'toLat': to.$1, 'toLng': to.$2});
    return Directions(
      points: [for (final p in (res['points'] as List).cast<List>()) ((p[0] as num).toDouble(), (p[1] as num).toDouble())],
      distanceM: (res['distanceM'] as num).toDouble(),
      durationS: (res['durationS'] as num).toDouble(),
    );
  }
}

final directionsApiProvider = Provider<DirectionsApi>((ref) => DirectionsApi(ref.watch(apiClientProvider)));
