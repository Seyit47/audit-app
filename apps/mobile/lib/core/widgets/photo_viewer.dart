import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';
import 'app_image.dart';

/// Full-screen photos over a black background: swipe between them, pinch or double-tap to zoom (the swipe
/// pauses while zoomed in), "3 / 7" at the top and a close button. Not a Figma frame (approved exception).
Future<void> showPhotoViewer(BuildContext context, List<String?> photos, {int initial = 0}) {
  if (photos.isEmpty) return Future.value();
  return Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.black,
      pageBuilder: (_, _, _) => PhotoViewer(photos: photos, initial: initial.clamp(0, photos.length - 1)),
      transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
    ),
  );
}

class PhotoViewer extends StatefulWidget {
  const PhotoViewer({super.key, required this.photos, this.initial = 0});

  final List<String?> photos;
  final int initial;

  @override
  State<PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<PhotoViewer> {
  late final _pages = PageController(initialPage: widget.initial);
  late int _index = widget.initial;
  bool _zoomed = false;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.photos.length;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pages,
            physics: _zoomed ? const NeverScrollableScrollPhysics() : const PageScrollPhysics(),
            itemCount: count,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) => _ZoomablePhoto(url: widget.photos[i], onZoomed: (z) => setState(() => _zoomed = z)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                  const Spacer(),
                  if (count > 1)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Text(
                        '${_index + 1} / $count',
                        style: const TextStyle(fontFamily: AppTextStyles.family, fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoomablePhoto extends StatefulWidget {
  const _ZoomablePhoto({required this.url, required this.onZoomed});

  final String? url;
  final ValueChanged<bool> onZoomed;

  @override
  State<_ZoomablePhoto> createState() => _ZoomablePhotoState();
}

class _ZoomablePhotoState extends State<_ZoomablePhoto> {
  final _transform = TransformationController();
  TapDownDetails? _doubleTap;
  bool _zoomed = false;

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  void _changed() {
    final zoomed = _transform.value.getMaxScaleOnAxis() > 1.01;
    if (zoomed == _zoomed) return;
    setState(() => _zoomed = zoomed);
    widget.onZoomed(zoomed);
  }

  /// Double tap: 2.5× around the tapped point, or back to fit.
  void _toggleZoom() {
    if (_zoomed) {
      _transform.value = Matrix4.identity();
    } else {
      final at = _doubleTap?.localPosition ?? Offset.zero;
      const scale = 2.5;
      _transform.value = Matrix4.identity()
        ..translateByDouble(-at.dx * (scale - 1), -at.dy * (scale - 1), 0, 1)
        ..scaleByDouble(scale, scale, 1, 1);
    }
    _changed();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: (d) => _doubleTap = d,
      onDoubleTap: _toggleZoom,
      child: InteractiveViewer(
        transformationController: _transform,
        maxScale: 5,
        // Panning only when zoomed in, so a one-finger swipe goes to the next photo.
        panEnabled: _zoomed,
        onInteractionEnd: (_) => _changed(),
        child: SizedBox.expand(child: AppImage(widget.url, radius: 0, fit: BoxFit.contain)),
      ),
    );
  }
}
