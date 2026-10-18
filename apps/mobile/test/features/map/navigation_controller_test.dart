import 'package:audit_mobile/features/map/data/directions.dart';
import 'package:audit_mobile/features/map/domain/route_progress.dart';
import 'package:audit_mobile/features/map/presentation/navigation_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Directions implements DirectionsApi {
  final asked = <LatLngPoint>[];
  var fail = false;

  @override
  Future<Directions> route(LatLngPoint from, LatLngPoint to) async {
    asked.add(from);
    if (fail) throw Exception('offline');
    return Directions(points: [from, (37.951, from.$2), to], distanceM: 200, durationS: 60);
  }
}

void main() {
  const shop = (37.951, 58.381);
  late _Directions api;
  late DateTime now;
  late ProviderContainer c;

  setUp(() {
    api = _Directions();
    now = DateTime(2026, 10, 18, 10);
    c = ProviderContainer(
      overrides: [
        directionsApiProvider.overrideWithValue(api),
        navigationProvider.overrideWith(() => NavigationController(clock: () => now)),
      ],
    );
    c.listen(navigationProvider, (_, _) {});
  });
  tearDown(() => c.dispose());

  NavigationController nav() => c.read(navigationProvider.notifier);
  NavigationState state() => c.read(navigationProvider)!;
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test('a chosen shop gets a road route; moving along it shortens what is left without asking again', () async {
    nav().start('s1', shop, 30, (37.950, 58.380));
    await settle();
    expect(api.asked, hasLength(1));
    expect(state().straight, isFalse);
    expect(state().line.last, shop);
    final before = state().remainingM!;

    now = now.add(const Duration(minutes: 1));
    nav().moved((37.9505, 58.380));
    expect(state().remainingM!, lessThan(before - 50));
    expect(state().remainingS, closeTo(60 * state().remainingM! / 200, 0.01));
    expect(api.asked, hasLength(1));
  });

  test('leaving the route asks for a new one, but not more often than every 15 s', () async {
    nav().start('s1', shop, 30, (37.950, 58.380));
    await settle();
    nav().moved((37.9505, 58.3795)); // ~44 m off, at once
    expect(api.asked, hasLength(1));
    now = now.add(const Duration(seconds: 20));
    nav().moved((37.9505, 58.3795));
    await settle();
    expect(api.asked, hasLength(2));
  });

  test('without a road route: a straight line to the shop, and another try a minute later', () async {
    api.fail = true;
    nav().start('s1', shop, 30, (37.950, 58.380));
    await settle();
    expect(state().straight, isTrue);
    expect(state().line, [(37.950, 58.380), shop]);

    api.fail = false;
    nav().moved((37.9502, 58.380));
    expect(api.asked, hasLength(1));
    now = now.add(const Duration(minutes: 1));
    nav().moved((37.9504, 58.380));
    await settle();
    expect(api.asked, hasLength(2));
    expect(state().straight, isFalse);
  });

  test('inside the shop radius counts as arrived', () async {
    nav().start('s1', shop, 30, (37.950, 58.380));
    await settle();
    nav().moved((37.95095, 58.38095));
    expect(state().arrived, isTrue);
  });
}
