import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:geo_monitor/l10n/my_keys.dart';
import 'package:geo_monitor/library/data/settings_model.dart';

import '../library/functions.dart';

final TranslationHandler translator = TranslationHandler._instance;

class TranslationHandler {
  static final TranslationHandler _instance = TranslationHandler._internal();

  factory TranslationHandler() {
    return _instance;
  }

  TranslationHandler._internal() {
    // initialization logic
  }
  final android = Platform.isAndroid;
  var localeMap = HashMap<String, String>();
  static const mm = '🌎🔵 mtX: ';
  String? currentLocale;
  SettingsModel? settingsModel;

  Future<String> translate(String key, String locale) async {

    if (localeMap.isEmpty) {
      await _loadFile(locale);
    } else {
      if (locale != currentLocale) {
        await _loadFile(locale);
      }
    }

    final value = localeMap[key];
    if (value == null) {
      return 'UNAVAILABLE KEY: $key';
    }
    // pp('$mm translate $key using locale: 🌎$locale result: $value 🌎');
    return value;
  }

  _loadFile(String locale) async {
    pp('$mm loading locale strings for $locale, will clear current locale $currentLocale strings');

    localeMap.clear();
    var start = DateTime.now();
    var s = await getStringFromAssets(locale);
    var mJson = jsonDecode(s);

    final translationKeys = MyKeys.getKeys();

    translationKeys.forEach((key, value) {
      try {
        if (mJson[key] == null) {
          pp('$mm key error, 🔴🔴 this key not found in json file: $key 🔴🔴');
        } else {
          localeMap[key] = mJson[key];
        }
      } catch (e) {
        pp('$mm $e key with error: $key');
        rethrow;
      }
    });
    currentLocale = locale;
    pp('$mm LOCALE MAP built ..... from file contents: ${s.length} bytes');
    var end = DateTime.now();
    pp('$mm currentLocale $locale '
        'has ${localeMap.length} translation strings; 🔵 '
        'time elapsed: ${end.difference(start).inMilliseconds} milliseconds');
  }
}
