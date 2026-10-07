/// Build-time configuration from `--dart-define-from-file=env/<flavor>.json`.
abstract final class AppConfig {
  static const apiUrl = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:3000');
  /// Vector tiles for the map styles (TileJSON URL, research R-12).
  static const mapTilesUrl = String.fromEnvironment('MAP_TILES_URL', defaultValue: 'https://tiles.openfreemap.org/planet');
}
