import 'package:audit_mobile/core/network/api_client.dart';
import 'package:audit_mobile/core/network/api_exception.dart';
import 'package:audit_mobile/features/system/data/system_repository.dart';
import 'package:audit_mobile/features/system/domain/compatibility.dart';
import 'package:audit_mobile/features/system/domain/version_info.dart';
import 'package:audit_mobile/features/system/presentation/compatibility_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSystemRepository extends Mock implements SystemRepository {}

const _info = VersionInfo(
  serverVersion: '1.2.3',
  minMobileVersion: '0.2.0',
  minAdminWebVersion: '0.1.0',
  environment: 'development',
);

void main() {
  group('evaluateCompatibility', () {
    test('is compatible when the app version equals the minimum', () {
      expect(evaluateCompatibility('0.2.0', _info), isA<Compatible>());
    });

    test('is compatible when the app version is newer', () {
      expect(evaluateCompatibility('0.10.0', _info), isA<Compatible>());
    });

    test('requires an update when the app version is older', () {
      expect(evaluateCompatibility('0.1.9', _info), isA<UpdateRequired>());
    });
  });

  group('compatibilityProvider', () {
    late _MockSystemRepository repository;
    late ProviderContainer container;

    setUp(() {
      repository = _MockSystemRepository();
      container = ProviderContainer(
        overrides: [
          systemRepositoryProvider.overrideWithValue(repository),
          appVersionProvider.overrideWith((ref) async => '0.2.0'),
        ],
      );
      addTearDown(container.dispose);
    });

    test('reports compatible with the server info', () async {
      when(() => repository.getVersion()).thenAnswer((_) async => _info);
      final result = await container.read(compatibilityProvider.future);
      expect(result, isA<Compatible>().having((c) => c.info, 'info', _info));
    });

    test(
      'reports unreachable when the API call fails, and retry checks again',
      () async {
        when(() => repository.getVersion())
            .thenThrow(const ApiException(code: 'NETWORK_ERROR'));
        expect(
          await container.read(compatibilityProvider.future),
          isA<Unreachable>(),
        );

        when(() => repository.getVersion()).thenAnswer((_) async => _info);
        await container.read(compatibilityProvider.notifier).retry();
        expect(container.read(compatibilityProvider).value, isA<Compatible>());
      },
    );
  });
}
