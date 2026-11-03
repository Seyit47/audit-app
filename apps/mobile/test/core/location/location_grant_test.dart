import 'package:audit_mobile/core/location/location_grant.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  test('only "all the time" and precise counts as granted', () {
    expect(grantOf(LocationPermission.always, approximate: false), LocationGrant.granted);
    expect(grantOf(LocationPermission.whileInUse, approximate: false), LocationGrant.whileInUse);
    expect(grantOf(LocationPermission.always, approximate: true), LocationGrant.approximate);
    expect(grantOf(LocationPermission.whileInUse, approximate: true), LocationGrant.approximate);
    expect(grantOf(LocationPermission.denied, approximate: false), LocationGrant.denied);
    expect(grantOf(LocationPermission.unableToDetermine, approximate: false), LocationGrant.denied);
    expect(grantOf(LocationPermission.deniedForever, approximate: false), LocationGrant.deniedForever);
  });
}
