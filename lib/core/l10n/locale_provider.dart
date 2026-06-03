import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static final LocaleProvider instance = LocaleProvider._();
  LocaleProvider._();

  static const _key = 'app_locale';

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  static const List<({Locale locale, String label, String nativeLabel})>
  supportedLocales = [
    (locale: Locale('en'), label: 'English', nativeLabel: 'English'),
    (locale: Locale('fil'), label: 'Filipino', nativeLabel: 'Filipino'),
    (locale: Locale('ceb'), label: 'Cebuano', nativeLabel: 'Cebuano'),
  ];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key) ?? 'en';
    _locale = Locale(code);
    // No notifyListeners here — called before app is built.
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
  }
}
