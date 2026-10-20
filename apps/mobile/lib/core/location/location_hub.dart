import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// The app's one position stream. On Android geolocator keeps a single stream per app: a second
/// `getPositionStream` gets the first one, with the first caller's settings. So the tracker, the
/// "N m from you" distances and the audit / new-shop checks all listen here instead of each starting
/// their own (the tracker could run without its foreground service, or the screens on its 25 m filter).
///
/// Best accuracy (GPS, fused with Wi-Fi and cell), every reading (no distance filter), every 5 s; the
/// listeners filter. While the tracker needs it in the background, Android's foreground-service
/// notification keeps it running with the screen off.
class LocationHub {
  final _out = StreamController<Position>.broadcast();
  StreamSubscription<Position>? _sub;
  Timer? _retry;
  int _users = 0;
  int _background = 0;
  bool _runningBackground = false;

  /// Android refused the stream with the foreground service (tracking mode): the screens still get positions
  /// from a plain stream until tracking stops and starts again.
  bool _backgroundFailed = false;

  /// The newest reading, if the stream has delivered one.
  Position? latest;

  Stream<Position> get positions => _out.stream;

  static const interval = Duration(seconds: 5);

  /// Starts the stream for one more listener; [background]: with the foreground service (tracking).
  void acquire({bool background = false}) {
    _users++;
    if (background) _background++;
    _sync();
  }

  void release({bool background = false}) {
    if (_users > 0) _users--;
    if (background && _background > 0) _background--;
    if (_background == 0) _backgroundFailed = false;
    _sync();
  }

  /// Starts the stream again ("Проверить заново"): after location was switched on, or a stream that stopped
  /// delivering.
  void restart() {
    if (_users == 0) return;
    _stop();
    _start();
  }

  bool get _wantBackground => _background > 0 && !_backgroundFailed;

  void _sync() {
    if (_users == 0) {
      _stop();
      return;
    }
    // Settings change (foreground service on / off): geolocator only applies them to a new stream.
    if (_sub != null && _runningBackground == _wantBackground) return;
    _stop();
    _start();
  }

  void _start() {
    _runningBackground = _wantBackground;
    _sub = Geolocator.getPositionStream(locationSettings: _settings(_runningBackground)).listen(
      (p) {
        latest = p;
        _out.add(p);
      },
      onError: (Object _) {
        _stop();
        if (_runningBackground) {
          // The foreground service could not start: carry on without it at once, so no screen is left
          // without a position.
          _backgroundFailed = true;
          _start();
          return;
        }
        // Location switched off or permission withdrawn: try again shortly while someone needs it.
        _retry = Timer(const Duration(seconds: 10), _sync);
      },
    );
  }

  void _stop() {
    _retry?.cancel();
    _retry = null;
    _sub?.cancel();
    _sub = null;
  }

  static LocationSettings _settings(bool background) {
    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
        intervalDuration: interval,
        foregroundNotificationConfig: background
            ? const ForegroundNotificationConfig(notificationTitle: 'Аудит', notificationText: 'Рабочее время: отслеживание маршрута', enableWakeLock: true)
            : null,
      );
    }
    return AppleSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 0,
      activityType: ActivityType.otherNavigation,
      pauseLocationUpdatesAutomatically: false,
      showBackgroundLocationIndicator: background,
      allowBackgroundLocationUpdates: background,
    );
  }
}

final locationHubProvider = Provider<LocationHub>((ref) => LocationHub());
