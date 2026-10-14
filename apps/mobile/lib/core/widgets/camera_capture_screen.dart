import 'dart:io';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_text_styles.dart';

/// The longest side a photo keeps (as before: 2560 px at 85 % JPEG quality).
const photoMaxSide = 2560;

/// The `minWidth`/`minHeight` box for [FlutterImageCompress]: it only shrinks, until the photo just covers the box,
/// so a 16:9 box in the photo's own orientation brings the longest side to [photoMaxSide].
(int, int) photoResizeBox(int width, int height) => width >= height ? (photoMaxSide, photoMaxSide * 9 ~/ 16) : (photoMaxSide * 9 ~/ 16, photoMaxSide);

/// Opens the in-app camera (always the back camera) and returns the photo, scaled to [photoMaxSide], or null when
/// the user closes it. A JPEG in the temporary directory; callers move it where it belongs.
Future<File?> takePhoto(NavigatorState navigator) async {
  final shot = await navigator.push<XFile>(MaterialPageRoute(fullscreenDialog: true, builder: (_) => const CameraCaptureScreen()));
  if (shot == null) return null;
  final bytes = await shot.readAsBytes();
  final descriptor = await ui.ImageDescriptor.encoded(await ui.ImmutableBuffer.fromUint8List(bytes));
  final (minWidth, minHeight) = photoResizeBox(descriptor.width, descriptor.height);
  descriptor.dispose();
  final target = p.join((await getTemporaryDirectory()).path, 'photo-${DateTime.now().microsecondsSinceEpoch}.jpg');
  final out = await FlutterImageCompress.compressAndGetFile(shot.path, target, minWidth: minWidth, minHeight: minHeight, quality: 85);
  await File(shot.path).delete().catchError((_) => File(shot.path));
  return out == null ? null : File(out.path);
}

/// Full-screen camera: preview from the back camera, a shutter, close and a flash switch (off / auto / on).
/// Pops with the captured [XFile]. Built from the app's existing styles; not a Figma frame (approved exception).
class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  bool _failed = false;
  bool _denied = false;
  bool _busy = false;
  FlashMode _flash = FlashMode.off;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _open();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  // The camera is released while the app is in the background and opened again on return, as the plugin requires.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (state == AppLifecycleState.inactive && controller != null) {
      _controller = null;
      controller.dispose();
      setState(() {});
    } else if (state == AppLifecycleState.resumed && _controller == null) {
      _open();
    }
  }

  Future<void> _open() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) throw CameraException('none', 'No camera');
      final back = cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.back, orElse: () => cameras.first);
      final controller = CameraController(back, ResolutionPreset.ultraHigh, enableAudio: false, imageFormatGroup: ImageFormatGroup.jpeg);
      await controller.initialize();
      await controller.setFlashMode(_flash);
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _failed = false;
        _denied = false;
      });
    } on CameraException catch (e) {
      if (!mounted) return;
      setState(() {
        _failed = true;
        _denied = e.code.contains('AccessDenied') || e.code.contains('Permission');
      });
    }
  }

  Future<void> _shoot() async {
    final controller = _controller;
    if (controller == null || _busy) return;
    setState(() => _busy = true);
    try {
      final shot = await controller.takePicture();
      if (mounted) Navigator.pop(context, shot);
    } on CameraException {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cycleFlash() async {
    final next = switch (_flash) {
      FlashMode.off => FlashMode.auto,
      FlashMode.auto => FlashMode.always,
      _ => FlashMode.off,
    };
    await _controller?.setFlashMode(next);
    setState(() => _flash = next);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = _controller;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: _failed
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _denied ? l10n.cameraDenied : l10n.cameraUnavailable,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                            ),
                            if (_denied) ...[
                              const SizedBox(height: 16),
                              OutlinedButton(
                                onPressed: Geolocator.openAppSettings,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white54),
                                ),
                                child: Text(l10n.permissionSettings),
                              ),
                            ],
                          ],
                        ),
                      )
                    : controller == null
                    ? const CircularProgressIndicator.adaptive()
                    : CameraPreview(controller),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    tooltip: l10n.cancel,
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  ),
                  Semantics(
                    button: true,
                    label: l10n.takePhoto,
                    child: GestureDetector(
                      onTap: controller == null ? null : _shoot,
                      child: Container(
                        width: 76,
                        height: 76,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          decoration: BoxDecoration(shape: BoxShape.circle, color: _busy || controller == null ? Colors.white38 : Colors.white),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.cameraFlash,
                    onPressed: controller == null ? null : _cycleFlash,
                    icon: Icon(
                      switch (_flash) {
                        FlashMode.auto => Icons.flash_auto,
                        FlashMode.always => Icons.flash_on,
                        _ => Icons.flash_off,
                      },
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
