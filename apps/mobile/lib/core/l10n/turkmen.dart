import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_custom.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/date_symbols.dart';
import 'package:intl/date_time_patterns.dart';

// Turkmen has no locale data in `intl` and no Material/Cupertino translations in Flutter. Dates use the
// Russian patterns (same day–month order and 24-hour clock) with Turkmen month and weekday names, numbers
// use Russian grouping, and the built-in widget strings (date pickers, text selection menus) fall back to
// Russian.

const _months = ['ýanwar', 'fewral', 'mart', 'aprel', 'maý', 'iýun', 'iýul', 'awgust', 'sentýabr', 'oktýabr', 'noýabr', 'dekabr'];
const _shortMonths = ['ýan', 'few', 'mar', 'apr', 'maý', 'iýun', 'iýul', 'awg', 'sen', 'okt', 'noý', 'dek'];
const _narrowMonths = ['Ý', 'F', 'M', 'A', 'M', 'I', 'I', 'A', 'S', 'O', 'N', 'D'];
const _weekdays = ['ýekşenbe', 'duşenbe', 'sişenbe', 'çarşenbe', 'penşenbe', 'anna', 'şenbe'];
const _shortWeekdays = ['ýek', 'duş', 'siş', 'çar', 'pen', 'ann', 'şen'];
const _narrowWeekdays = ['Ý', 'D', 'S', 'Ç', 'P', 'A', 'Ş'];

void _registerTurkmenDates() {
  final symbols = dateTimeSymbolMap()['ru'] as DateSymbols;
  final map = symbols.serializeToMap()
    ..addAll({
      'NAME': 'tk',
      'MONTHS': _months,
      'STANDALONEMONTHS': _months,
      'SHORTMONTHS': _shortMonths,
      'STANDALONESHORTMONTHS': _shortMonths,
      'NARROWMONTHS': _narrowMonths,
      'STANDALONENARROWMONTHS': _narrowMonths,
      'WEEKDAYS': _weekdays,
      'STANDALONEWEEKDAYS': _weekdays,
      'SHORTWEEKDAYS': _shortWeekdays,
      'STANDALONESHORTWEEKDAYS': _shortWeekdays,
      'NARROWWEEKDAYS': _narrowWeekdays,
      'STANDALONENARROWWEEKDAYS': _narrowWeekdays,
    });
  final patterns = {for (final e in dateTimePatternMap()['ru']!.entries) e.key: e.value.replaceAll(" 'г'.", '')};
  initializeDateFormattingCustom(locale: 'tk', symbols: DateSymbols.deserializeFromMap(map), patterns: patterns);
}

/// Locale for `NumberFormat`, which has no Turkmen data.
String numberLocale(String languageCode) => languageCode == 'tk' ? 'ru' : languageCode;

/// Loads the Russian Material/Cupertino strings for Turkmen; the Material one also registers the Turkmen
/// date names, so `DateFormat(..., 'tk')` works wherever Turkmen is the app language.
class _TurkmenFallback<T> extends LocalizationsDelegate<T> {
  const _TurkmenFallback(this.russian, {this.dates = false});

  final LocalizationsDelegate<T> russian;
  final bool dates;

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'tk';

  @override
  Future<T> load(Locale locale) {
    if (dates) _registerTurkmenDates();
    return russian.load(const Locale('ru'));
  }

  @override
  bool shouldReload(_TurkmenFallback<T> old) => false;
}

const turkmenFallbackDelegates = <LocalizationsDelegate<dynamic>>[
  _TurkmenFallback<MaterialLocalizations>(GlobalMaterialLocalizations.delegate, dates: true),
  _TurkmenFallback<CupertinoLocalizations>(GlobalCupertinoLocalizations.delegate),
];
