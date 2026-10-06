/// Build-time configuration from `--dart-define-from-file=env/<flavor>.json`.
abstract final class AppConfig {
  static const apiUrl = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:3000');
}
