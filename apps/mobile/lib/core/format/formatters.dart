import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

String _tag(BuildContext context) => Localizations.localeOf(context).languageCode;

/// "14 сент. 15:17" (`83:16884`).
String shortDateTime(BuildContext context, DateTime d) => DateFormat('d MMM HH:mm', _tag(context)).format(d.toLocal());

/// "14 сентября 2026, 15:40" (`83:17057` history).
String longDateTime(BuildContext context, DateTime d) => DateFormat('d MMMM y, HH:mm', _tag(context)).format(d.toLocal());

/// "14 сентября" (`83:17057` last visit).
String dayMonth(BuildContext context, DateTime d) => DateFormat('d MMMM', _tag(context)).format(d.toLocal());

/// "15:17"
String hhmm(DateTime d) => DateFormat('HH:mm').format(d.toLocal());

/// "43.238949, 76.889709"
String coords(double lat, double lng) => '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';

/// "1,2 км" / "350 м" from meters.
String distance(BuildContext context, double meters) {
  final ru = _tag(context) == 'ru';
  if (meters < 1000) return '${meters.round()} ${ru ? 'м' : 'm'}';
  return '${NumberFormat('0.0', _tag(context)).format(meters / 1000)} ${ru ? 'км' : 'km'}';
}
