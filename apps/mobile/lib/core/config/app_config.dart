/// Build-time configuration passed with `--dart-define-from-file=env/<env>.json`.
class AppConfig {
  const AppConfig({required this.apiBaseUrl, required this.environment});

  factory AppConfig.fromEnvironment() {
    const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
    const environment = String.fromEnvironment(
      'APP_ENV',
      defaultValue: 'development',
    );
    if (apiBaseUrl.isEmpty) {
      throw StateError(
        'API_BASE_URL is not set. Run with --dart-define-from-file=env/dev.json.',
      );
    }
    return const AppConfig(apiBaseUrl: apiBaseUrl, environment: environment);
  }

  final String apiBaseUrl;
  final String environment;
}
