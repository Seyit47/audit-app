import 'package:audit_mobile/core/location/location_hub.dart';

/// No GPS in tests: screens and controllers may hold the hub without starting a platform stream.
class FakeLocationHub extends LocationHub {
  var users = 0;

  @override
  void acquire({bool background = false}) => users++;

  @override
  void release({bool background = false}) => users--;

  @override
  void restart() {}
}
