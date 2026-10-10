/// Build-time configuration from `--dart-define-from-file=env/<flavor>.json`.
abstract final class AppConfig {
  /// The default API address; the login screen's server settings can replace it (`server_address.dart`).
  static const apiUrl = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:3000');

  /// PIN for the server settings on the login screen, from the git-ignored `env/secrets.json`. Empty hides them.
  static const settingsPin = String.fromEnvironment('SETTINGS_PIN');

  /// Device activation server: every launch checks this device's id there, and the app opens only once a
  /// moderator has activated it. The app account that registers devices comes from `env/secrets.json`.
  /// An empty URL turns activation off (tests, local development).
  static const activationUrl = String.fromEnvironment('ACTIVATION_URL');
  static const activationUsername = String.fromEnvironment('ACTIVATION_USERNAME');
  static const activationPassword = String.fromEnvironment('ACTIVATION_PASSWORD');

  /// Vector tiles (TileJSON URL) and label fonts for the map styles: the self-hosted Martin of infra/maptiles, or
  /// openfreemap when the build doesn't set them.
  static const mapTilesUrl = String.fromEnvironment('MAP_TILES_URL', defaultValue: 'https://tiles.openfreemap.org/planet');
  static const mapGlyphsUrl = String.fromEnvironment('MAP_GLYPHS_URL', defaultValue: 'https://tiles.openfreemap.org/fonts/{fontstack}/{range}.pbf');
}
