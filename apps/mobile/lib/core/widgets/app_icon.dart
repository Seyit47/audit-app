import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A Figma-exported SVG from `assets/icons`, at its Figma size. [color] tints single-color icons.
class AppIcon extends StatelessWidget {
  const AppIcon(this.name, {super.key, required this.width, required this.height, this.color});

  final String name;
  final double width;
  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) =>
      SvgPicture.asset('assets/icons/$name.svg', width: width, height: height, colorFilter: color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn));
}
