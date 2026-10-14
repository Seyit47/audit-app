import 'package:audit_mobile/core/widgets/camera_capture_screen.dart';
import 'package:flutter_test/flutter_test.dart';

/// What the compressor does with the box: shrink only, until the photo just covers it.
(int, int) resized(int w, int h) {
  final (bw, bh) = photoResizeBox(w, h);
  final s = [w / bw, h / bh].reduce((a, b) => a < b ? a : b);
  final scale = s < 1 ? 1.0 : s;
  return ((w / scale).round(), (h / scale).round());
}

void main() {
  test('photos keep a 2560 px longest side in either orientation and aspect', () {
    expect(resized(3840, 2160), (2560, 1440)); // 4K landscape
    expect(resized(2160, 3840), (1440, 2560)); // 4K portrait
    expect(resized(4000, 3000), (2560, 1920)); // 4:3 sensor
    expect(resized(1920, 1080), (1920, 1080)); // smaller: never enlarged
  });
}
