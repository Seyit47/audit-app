// Turkmen numbers, the same rules as the API (apps/api/src/lib/phone.ts): +993 and an 8-digit national
// number; mobile 6X, 71, 72; landlines start 1–5 (Ashgabat 12). Accepts +993…, 993…, 8… (domestic dialling)
// or the bare 8 digits; spaces, dashes and brackets are ignored.
final _mobile = RegExp(r'^(6\d|7[12])\d{6}$');
final _any = RegExp(r'^[1-7]\d{7}$');

/// `+993XXXXXXXX`, or null when [input] is not a Turkmen number ([mobile]: mobile numbers only).
String? tmPhone(String input, {bool mobile = false}) {
  var d = input.replaceAll(RegExp(r'[\s().-]'), '');
  if (d.startsWith('+993')) {
    d = d.substring(4);
  } else if (d.startsWith('993') && d.length == 11) {
    d = d.substring(3);
  } else if (d.startsWith('8') && d.length == 9) {
    d = d.substring(1);
  }
  if (!RegExp(r'^\d{8}$').hasMatch(d)) return null;
  return (mobile ? _mobile : _any).hasMatch(d) ? '+993$d' : null;
}
