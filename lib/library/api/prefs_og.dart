import 'dart:convert';

import 'package:geo_monitor/library/data/questionnaire.dart';
import 'package:geo_monitor/library/data/subscription.dart';
import 'package:get_storage/get_storage.dart';

import '../data/country.dart';
import '../data/project.dart';
import '../data/settings_model.dart';
import '../data/user.dart';
import '../functions.dart';

late  PrefsOGx prefsOGx;
const String cacheName = 'GeoPreferences3';

class PrefsOGx {
  static const mm = '🔶🔶🔶🔶🔶🔶 PrefsOGx 🔶🔶 : ',
      bb = '🦠🦠🦠🦠🦠🦠🦠 PrefsOGx  🦠: ';

  final GetStorage box = GetStorage(cacheName);


  Future setDateRefreshed(String date) async {
    await box.write('dateRefreshed', date);
    pp("$mm setDateRefreshed SET to $date");
    return null;
  }

  Future<bool> shouldRefreshBePerformed() async {
    var refreshDate = await _getDateRefreshed();
    final rDate = DateTime.parse(refreshDate);
    final now = DateTime.now();
    final delta = now
        .difference(rDate)
        .inHours;
    if (delta >= 12) {
      return true;
    } else {
      return false;
    }
  }

  Future<String> _getDateRefreshed() async {
    pp('$mm ......... getting getDateRefreshed from cache! ...');
    String? date = box.read('dateRefreshed');
    if (date == null) {
      pp('$mm Date Refreshed does not exist in Prefs, '
          'create date from a year ago, just for kicks! 🍎🍎🍎!');
      date =
          DateTime.now().subtract(const Duration(days: 365)).toIso8601String();
      return date;
    } else {
      pp("$mm _getDateRefreshed: 🧩 🧩 🧩 🧩 🧩 date .. $date 🔴🔴");
      return date;
    }
  }

  Future setFCMSubscriptionFlag() async {
    await box.write('fcm', true);
    pp("\n\n$mm setFCMSubscription SET as true\n");
    return null;
  }

  Future resetFCMSubscriptionFlag() async {
    await box.write('fcm', false);
    pp("\n\n$mm setFCMSubscription RESET to false\n");
    return null;
  }

  Future<bool> getFCMSubscriptionFlag() async {
    pp('\n$mm ......... getting getFCMSubscription from cache! ...');
    bool? isSubscribed = box.read('fcm');
    if (isSubscribed == null || isSubscribed == false) {
      pp('$mm FCMSubscription flag does not exist in Prefs, '
          'one time isSubscribed, 🍎🍎🍎 next time not so much!');
      return false;
    } else {
      pp("$mm FCMSubscription flag: 🧩 🧩 🧩 🧩 🧩 retrieved .. $isSubscribed 🔴🔴");
      return isSubscribed;
    }
  }

  Future saveUser(User user) async {
    final s = jsonEncode(user.toJson());
    await box.write('user', s);
    pp("\n\n$mm saveUser SAVED: 🌽 ${user.name}\n");
    return null;
  }

  Future<User?> getUser() async {
    User? user;
    var mJson = box.read('user');
    if (mJson == null) {
      pp('$mm User does not exist in Prefs, '
          ' 🍎🍎🍎');
      return null;
    } else {
      user = User.fromJson(jsonDecode(mJson));
      // pp("$mm getUser 🧩🧩🧩🧩🧩 retrieved .. ${user.name}  🔴🔴");
      return user;
    }
  }

  Future saveSettings(SettingsModel settings) async {
    final s = jsonEncode(settings.toJson());
    await box.write('settings', s);
    pp("\n\n$mm saveSettings SAVED: 🌽 ${settings.toJson()}\n");
    return null;
  }

  Future<SettingsModel> getSettings() async {
    SettingsModel? settings;
    var mJson = box.read('settings');
    if (mJson == null) {
      pp('$mm Settings does not exist in Prefs, '
          ' 🍎🍎🍎 return default');
      var s = getBaseSettings();
      return s;
    } else {
      settings = SettingsModel.fromJson(jsonDecode(mJson));
      // pp("$mm getSettings 🧩🧩🧩🧩🧩 retrieved .. ${settings.created}  🔴🔴");
      return settings;
    }
  }

  Future deleteUser() async {
    await box.remove('user');
  }

  Future saveCountry(Country country) async {
    final s = jsonEncode(country.toJson());
    pp("$mm saveCountry to save: 🌽 $s\n");

    await box.write('country', s);
    pp("\n\n$mm saveCountry SAVED: 🌽 ${country.name}\n");
    return null;
  }

  Future<Country?> getCountry() async {
    Country? country;
    var mJson = box.read('country');
    if (mJson == null) {
      pp('$mm User does not exist in Prefs, '
          ' 🍎🍎🍎');
      return null;
    } else {
      country = Country.fromJson(jsonDecode(mJson));
      pp("$mm getCountry 🧩🧩🧩🧩🧩 retrieved .. ${country.name}  🔴🔴");
      return country;
    }
  }

  Future saveProject(Project project) async {
    final s = jsonEncode(project.toJson());
    pp("$mm saveProject to save: 🌽 $s\n");

    await box.write('project', s);
    pp("\n\n$mm saveProject SAVED: 🌽 ${project.name}\n");
    return null;
  }

  Future<Project?> getProject() async {
    Project? project;
    var mJson = box.read('project');
    if (mJson == null) {
      pp('$mm project does not exist in Prefs, '
          ' 🍎🍎🍎');
      return null;
    } else {
      project = Project.fromJson(jsonDecode(mJson));
      pp("$mm getProject 🧩🧩🧩🧩🧩 retrieved .. ${project.name}  🔴🔴");
      return project;
    }
  }

  Future saveGioSubscription(GioSubscription subscription) async {
    final s = jsonEncode(subscription.toJson());
    await box.write('GioSubscription', s);
    pp("\n\n$mm saveGioSubscription SAVED: 🌽 ${subscription.organizationName}\n");
    return null;
  }

  Future<GioSubscription?> getGioSubscription() async {
    GioSubscription? sub;
    var mJson = box.read('GioSubscription');
    if (mJson == null) {
      pp('$mm GioSubscription does not exist in Prefs, '
          ' 🍎🍎🍎');
      return null;
    } else {
      sub = GioSubscription.fromJson(jsonDecode(mJson));
      pp("$mm getGioSubscription 🧩🧩🧩🧩🧩 retrieved .. ${sub.organizationName}  🔴🔴");
      return sub;
    }
  }
}
