// Turkmen numbers, the same rules as the API (apps/api/src/lib/phone.ts): +993 and an 8-digit national
// number; mobile 6X, 71, 72; landlines start 1–5 (Ashgabat 12). Accepts +993…, 993…, 8… (domestic dialling)
// or the bare 8 digits; spaces, dashes and brackets are ignored.
import 'package:flutter/services.dart';

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

const _prefix = '+993 ';

/// The national digits typed so far (at most 8), and how many leading digits were dialling prefixes
/// (993, or the domestic 8): no Turkmen number starts with 8 or 9, so those are never part of it.
(String, int) _national(String text) {
  final all = text.replaceAll(RegExp(r'\D'), '');
  var d = all;
  while (true) {
    if (d.startsWith('993')) {
      d = d.substring(3);
    } else if (d.startsWith('8')) {
      d = d.substring(1);
    } else {
      break;
    }
  }
  return (d, all.length - d.length);
}

String _format(String national) {
  if (national.isEmpty) return '';
  return national.length <= 2 ? '$_prefix$national' : '$_prefix${national.substring(0, 2)} ${national.substring(2)}';
}

/// How a phone is shown in an input: `+993 65 123456`. Anything that is not a Turkmen number stays as it is.
String displayPhone(String stored) => tmPhone(stored) == null ? stored : _format(_national(stored).$1);

/// Phone inputs: shows `+993 65 123456` while typing, stops at the 8th digit, and lets backspace
/// step over the spaces and the fixed `+993 `. The value stays parseable by [tmPhone].
class TmPhoneFormatter extends TextInputFormatter {
  const TmPhoneFormatter();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    final cursor = newValue.selection.baseOffset.clamp(0, text.length);
    final (oldNational, _) = _national(oldValue.text);
    var (national, stripped) = _national(text);
    var at = (text.substring(0, cursor).replaceAll(RegExp(r'\D'), '').length - stripped).clamp(0, national.length);
    final deleting = text.length < oldValue.text.length;

    if (deleting && oldValue.text.startsWith(_prefix) && cursor < _prefix.length && RegExp(r'\d').hasMatch(text)) {
      // Backspace inside "+993 ": the prefix stays.
      national = oldNational;
      at = 0;
    } else if (deleting && national == oldNational && at > 0) {
      // Backspace over a space removes the digit before it.
      national = national.substring(0, at - 1) + national.substring(at);
      at--;
    }
    if (national.length > 8) {
      if (oldNational.length >= 8) return oldValue;
      national = national.substring(0, 8);
      at = at.clamp(0, 8);
    }

    final out = _format(national);
    final offset = national.isEmpty ? 0 : _prefix.length + at + (at > 2 ? 1 : 0);
    return TextEditingValue(
      text: out,
      selection: TextSelection.collapsed(offset: offset.clamp(0, out.length)),
    );
  }
}
