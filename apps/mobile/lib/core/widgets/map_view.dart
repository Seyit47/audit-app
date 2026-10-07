import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../config/app_config.dart';

/// A shop pin of `83:17636`: a colored ring with the facade photo and a pointer.
class MapMarker {
  const MapMarker({required this.id, required this.lat, required this.lng, required this.color, this.imageUrl});

  final String id;
  final double lat;
  final double lng;
  final Color color;
  final String? imageUrl;

  String get imageKey => 'pin-${color.toARGB32()}-${imageUrl ?? ''}';
}

/// Camera commands for the floating controls (zoom, recenter).
class AppMapController {
  MapLibreMapController? _map;

  Future<void> zoomIn() async => _map?.animateCamera(CameraUpdate.zoomIn());
  Future<void> zoomOut() async => _map?.animateCamera(CameraUpdate.zoomOut());
  Future<void> moveTo(double lat, double lng, {double zoom = 15}) async =>
      _map?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), zoom));
  Future<void> fit(List<(double, double)> points) async {
    if (points.isEmpty) return;
    if (points.length == 1) return moveTo(points.first.$1, points.first.$2);
    final lats = points.map((p) => p.$1);
    final lngs = points.map((p) => p.$2);
    await _map?.animateCamera(CameraUpdate.newLatLngBounds(
      LatLngBounds(southwest: LatLng(lats.reduce(math.min), lngs.reduce(math.min)), northeast: LatLng(lats.reduce(math.max), lngs.reduce(math.max))),
      left: 48, right: 48, top: 160, bottom: 120,
    ));
  }
}

/// MapLibre with the Figma-matched styles (`assets/map/style-{light,dark}.json`, T084).
class AppMapView extends StatefulWidget {
  const AppMapView({super.key, required this.markers, required this.controller, this.onMarkerTap, this.onMapTap, this.initial});

  final List<MapMarker> markers;
  final AppMapController controller;
  final ValueChanged<String>? onMarkerTap;
  final VoidCallback? onMapTap;
  /// Start position; the first markers are fitted otherwise.
  final (double, double)? initial;

  @override
  State<AppMapView> createState() => _AppMapViewState();
}

class _AppMapViewState extends State<AppMapView> {
  static final _styles = <Brightness, String>{};
  static final _photos = <String, ui.Image?>{};
  String? _style;
  Brightness? _brightness;
  bool _ready = false;
  final _symbols = <String, Symbol>{};
  final _added = <String>{};
  double _dpr = 3;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dpr = MediaQuery.devicePixelRatioOf(context);
    final b = Theme.of(context).brightness;
    if (b != _brightness) {
      _brightness = b;
      _ready = false;
      _loadStyle(b);
    }
  }

  Future<void> _loadStyle(Brightness b) async {
    final style = _styles[b] ??= await _patchedStyle(b);
    if (mounted) setState(() => _style = style);
  }

  static Future<String> _patchedStyle(Brightness b) async {
    final json = jsonDecode(await rootBundle.loadString('assets/map/style-${b == Brightness.dark ? 'dark' : 'light'}.json')) as Map<String, dynamic>;
    (json['sources'] as Map)['openmaptiles'] = {'type': 'vector', 'url': AppConfig.mapTilesUrl};
    return jsonEncode(json);
  }

  @override
  void didUpdateWidget(AppMapView old) {
    super.didUpdateWidget(old);
    if (_ready && !identical(old.markers, widget.markers)) _syncMarkers();
  }

  Future<void> _onStyleLoaded() async {
    final map = widget.controller._map!;
    await map.setSymbolIconAllowOverlap(true);
    _symbols.clear();
    _added.clear();
    _ready = true;
    await _syncMarkers();
    if (widget.initial == null) await widget.controller.fit([for (final m in widget.markers) (m.lat, m.lng)]);
  }

  Future<void> _syncMarkers() async {
    final map = widget.controller._map;
    if (map == null) return;
    final wanted = {for (final m in widget.markers) m.id: m};
    final gone = _symbols.keys.where((id) => !wanted.containsKey(id)).toList();
    if (gone.isNotEmpty) await map.removeSymbols([for (final id in gone) _symbols.remove(id)!]);
    for (final m in widget.markers) {
      if (!_added.contains(m.imageKey)) {
        await map.addImage(m.imageKey, await renderPin(m.color, await _photo(m.imageUrl)));
        _added.add(m.imageKey);
      }
      // MapLibre sizes icons in physical pixels: the 3x pin at devicePixelRatio / 3 is 37 dp wide.
      final options = SymbolOptions(geometry: LatLng(m.lat, m.lng), iconImage: m.imageKey, iconAnchor: 'bottom', iconSize: _dpr / _pinScale);
      final existing = _symbols[m.id];
      if (existing == null) {
        _symbols[m.id] = await map.addSymbol(options, {'id': m.id});
      } else {
        await map.updateSymbol(existing, options);
      }
    }
  }

  static Future<ui.Image?> _photo(String? url) async {
    if (url == null || url.isEmpty) return null;
    if (_photos.containsKey(url)) return _photos[url];
    try {
      final bytes = url.startsWith('/')
          ? await File(url).readAsBytes()
          : await (await (await HttpClient().getUrl(Uri.parse(url))).close()).fold<List<int>>(<int>[], (a, b) => a..addAll(b));
      final codec = await ui.instantiateImageCodec(Uint8List.fromList(bytes), targetWidth: 96);
      return _photos[url] = (await codec.getNextFrame()).image;
    } catch (_) {
      return _photos[url] = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _style;
    if (style == null) return ColoredBox(color: Theme.of(context).scaffoldBackgroundColor);
    final start = widget.initial ?? (widget.markers.isEmpty ? (37.95, 58.38) : (widget.markers.first.lat, widget.markers.first.lng));
    // A theme change swaps the style on the existing map (MapLibre reloads it in place and calls
    // _onStyleLoaded again) instead of destroying and recreating the native map view.
    return MapLibreMap(
      styleString: style,
      initialCameraPosition: CameraPosition(target: LatLng(start.$1, start.$2), zoom: 13),
      myLocationEnabled: true,
      myLocationRenderMode: MyLocationRenderMode.normal,
      compassEnabled: false,
      attributionButtonPosition: AttributionButtonPosition.bottomLeft,
      onMapCreated: (map) {
        widget.controller._map = map;
        map.onSymbolTapped.add((s) {
          final id = s.data?['id'];
          if (id is String) widget.onMarkerTap?.call(id);
        });
      },
      onStyleLoadedCallback: _onStyleLoaded,
      onMapClick: (_, _) => widget.onMapTap?.call(),
    );
  }
}

const _pinScale = 3.0;

/// Draws the `83:17686` pin at 3x: 37 px ring, 30.7 px photo with a white edge, pointer.
Future<Uint8List> renderPin(Color ring, ui.Image? photo) async {
  const s = _pinScale;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final paint = Paint()..color = ring;
  const r = 18.5 * s;
  canvas.drawCircle(const Offset(r, r), r, paint);
  final pointer = Path()
    ..moveTo(11.81 * s + 1, 31.49 * s)
    ..lineTo(25.19 * s - 1, 31.49 * s)
    ..lineTo(18.5 * s, 44.87 * s)
    ..close();
  canvas.drawPath(pointer, paint);
  const inner = Rect.fromLTWH(3.15 * s, 3.15 * s, 30.7 * s, 30.7 * s);
  canvas.drawCircle(inner.center, inner.width / 2 + s, Paint()..color = Colors.white);
  canvas.save();
  canvas.clipPath(Path()..addOval(inner));
  if (photo != null) {
    paintImage(canvas: canvas, rect: inner, image: photo, fit: BoxFit.cover);
  } else {
    canvas.drawRect(inner, Paint()..color = const Color(0xFFEDEDFB));
  }
  canvas.restore();
  final image = await recorder.endRecording().toImage((37 * s).ceil(), (44.87 * s).ceil());
  return (await image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
}
