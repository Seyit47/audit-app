import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Overridden in `main` with the loaded instance.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());

const _themeKey = 'theme_mode';
const _localeKey = 'locale';
const supportedLocales = [Locale('ru'), Locale('en')];

/// Theme mode from the Home toggle; follows the system until the user picks one.
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => switch (ref.watch(sharedPreferencesProvider).getString(_themeKey)) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await ref.read(sharedPreferencesProvider).setString(_themeKey, mode.name);
  }
}

/// App language from the Home RU/EN switch; Russian when nothing is chosen.
final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() => ref.watch(sharedPreferencesProvider).getString(_localeKey) == 'en' ? const Locale('en') : const Locale('ru');

  Future<void> set(Locale locale) async {
    state = locale;
    await ref.read(sharedPreferencesProvider).setString(_localeKey, locale.languageCode);
  }
}
