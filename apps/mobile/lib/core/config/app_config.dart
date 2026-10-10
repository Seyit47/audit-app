/// Build-time configuration from `--dart-define-from-file=env/<flavor>.json`.
abstract final class AppConfig {
  /// The default API address; the login screen's server settings can replace it (`server_address.dart`).
  static const apiUrl = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:3000');

  /// PIN for the server settings on the login screen, from the git-ignored `env/secrets.json`. Empty hides them.
  static const settingsPin = String.fromEnvironment('SETTINGS_PIN');

  /// Vector tiles for the map styles (TileJSON URL, research R-12).
  static const mapTilesUrl = String.fromEnvironment('MAP_TILES_URL', defaultValue: 'https://tiles.openfreemap.org/planet');
}
