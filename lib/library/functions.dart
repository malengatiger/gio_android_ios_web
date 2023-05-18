import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dot;
import 'package:geo_monitor/library/data/project_polygon.dart';
import 'package:geo_monitor/library/data/settings_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_utils/google_maps_utils.dart';
import 'package:image/image.dart' as img;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as vt;

import '../device_location/device_location_bloc.dart';
import '../l10n/translation_handler.dart';
import '../utilities/environment.dart';
import 'api/prefs_og.dart';
import 'cache_manager.dart';
import 'data/activity_model.dart';
import 'data/position.dart';
import 'data/project_position.dart';
import 'data/user.dart';

List<String> logs = [];
bool busy = false;
List<Color> _colors = [];
Random _rand = Random(DateTime.now().millisecondsSinceEpoch);

Color getRandomColor() {
  _colors.clear();
  _colors.add(Colors.deepOrange);
  _colors.add(Colors.indigo);
  _colors.add(Colors.pink);
  _colors.add(Colors.deepPurple);
  _colors.add(Colors.blue);
  _colors.add(Colors.teal);
  _colors.add(Colors.pink);
  _colors.add(Colors.indigo);
  _colors.add(Colors.teal);
  _colors.add(Colors.red);
  _colors.add(Colors.pink);
  _colors.add(Colors.orange);
  _colors.add(Colors.indigo);
  _colors.add(Colors.teal);
  _colors.add(Colors.pink);
  _colors.add(Colors.deepPurple);
  _colors.add(Colors.indigo);
  _colors.add(Colors.pink);
  _colors.add(Colors.deepOrange);

  _rand = Random(DateTime.now().millisecondsSinceEpoch * _rand.nextInt(10000));
  int index = _rand.nextInt(_colors.length - 1);
  return _colors.elementAt(index);
}

bool checkIfDarkMode() {
  final darkMode = WidgetsBinding.instance.window.platformBrightness;
  if (darkMode == Brightness.dark) {
    return true;
  }
  return false;

}

Color getRandomPastelColor() {
  _colors.clear();
  _colors.add(Colors.blue.shade50);
  _colors.add(Colors.grey.shade50);
  _colors.add(Colors.pink.shade50);
  _colors.add(Colors.teal.shade50);
  _colors.add(Colors.red.shade50);
  _colors.add(Colors.green.shade50);
  _colors.add(Colors.amber.shade50);
  _colors.add(Colors.indigo.shade50);
  _colors.add(Colors.lightBlue.shade50);
  _colors.add(Colors.lime.shade50);
  _colors.add(Colors.deepPurple.shade50);
  _colors.add(Colors.deepOrange.shade50);
  _colors.add(Colors.brown.shade50);
  _colors.add(Colors.cyan.shade50);

  _rand = Random(DateTime.now().millisecondsSinceEpoch * _rand.nextInt(10000));
  int index = _rand.nextInt(_colors.length - 1);
  return _colors.elementAt(index);
}

Future<bool> isLocationValid(
    {required ProjectPosition projectPosition,
    required double validDistance}) async {
  pp('😡😡😡😡😡😡 checking if user is within monitoring range of project: ${projectPosition.projectName} 😡😡');
  var distance = await locationBloc.getDistanceFromCurrentPosition(
      latitude: projectPosition.position!.coordinates[1],
      longitude: projectPosition.position!.coordinates[0]);

  if (distance <= validDistance) {
    pp('😡😡😡😡😡😡 user is cool! - within range ${projectPosition.projectName}');
    return true;
  }
  pp('😡😡😡😡😡😡 user is NOT cool! - NOT within range ${projectPosition.projectName}');
  return false;
}

TextStyle myTextStyleSmall(BuildContext context) {
  return GoogleFonts.lato(
    textStyle: Theme.of(context).textTheme.bodySmall,
  );
}
TextStyle myTextStyleSmallBlackBold(BuildContext context) {
  return GoogleFonts.roboto(
      textStyle: Theme.of(context).textTheme.bodySmall,
      // fontWeight: FontWeight.w200,
      color: Theme.of(context).primaryColor
  );
}

TextStyle myTextStyleSmallBold(BuildContext context) {
  return GoogleFonts.lato(
    textStyle: Theme.of(context).textTheme.bodySmall,
    fontWeight: FontWeight.w600,
  );
}

TextStyle myTextStyleSmallBoldPrimaryColor(BuildContext context) {
  return GoogleFonts.lato(
      textStyle: Theme.of(context).textTheme.bodySmall,
      fontWeight: FontWeight.w900,
      color: Theme.of(context).primaryColor);
}

TextStyle myTextStyleSmallPrimaryColor(BuildContext context) {
  return GoogleFonts.lato(
      textStyle: Theme.of(context).textTheme.bodySmall,
      fontWeight: FontWeight.normal,
      color: Theme.of(context).primaryColor);
}

TextStyle myTextStyleTiny(BuildContext context) {
  return GoogleFonts.lato(
    textStyle: Theme.of(context).textTheme.bodySmall,
    fontWeight: FontWeight.normal,
    fontSize: 10,
  );
}
TextStyle myTextStyleTiniest(BuildContext context) {
  return GoogleFonts.lato(
    textStyle: Theme.of(context).textTheme.bodySmall,
    fontWeight: FontWeight.normal,
    fontSize: 8,
  );
}

TextStyle myTextStyleTinyBold(BuildContext context) {
  return GoogleFonts.lato(
    textStyle: Theme.of(context).textTheme.bodySmall,
    fontWeight: FontWeight.bold,
    fontSize: 10,
  );
}

TextStyle myTextStyleTinyBoldPrimaryColor(BuildContext context) {
  return GoogleFonts.lato(
      textStyle: Theme.of(context).textTheme.bodySmall,
      fontWeight: FontWeight.bold,
      fontSize: 10,
      color: Theme.of(context).primaryColor);
}

TextStyle myTextStyleTinyPrimaryColor(BuildContext context) {
  return GoogleFonts.lato(
      textStyle: Theme.of(context).textTheme.bodySmall,
      fontWeight: FontWeight.normal,
      fontSize: 10,
      color: Theme.of(context).primaryColor);
}

TextStyle myTextStyleSmallBlack(BuildContext context) {
  return GoogleFonts.lato(
      textStyle: Theme.of(context).textTheme.bodySmall,
      fontWeight: FontWeight.normal,
      color: Colors.black);
}

TextStyle myTextStyleMedium(BuildContext context) {
  return GoogleFonts.lato(
    textStyle: Theme.of(context).textTheme.bodyMedium,
    fontWeight: FontWeight.normal,
  );
}

TextStyle myTextStyleSubtitle(BuildContext context) {
  return GoogleFonts.roboto(
    textStyle: Theme.of(context).textTheme.titleMedium,
    fontWeight: FontWeight.w600, fontSize: 20,

  );
}
TextStyle myTextStyleSubtitleSmall(BuildContext context) {
  return GoogleFonts.roboto(
    textStyle: Theme.of(context).textTheme.titleMedium,
    fontWeight: FontWeight.w600, fontSize: 12
  );
}

TextStyle myTextStyleMediumGrey(BuildContext context) {
  return GoogleFonts.lato(
      textStyle: Theme.of(context).textTheme.bodyMedium,
      fontWeight: FontWeight.normal,
      color: Colors.grey.shade600);
}

TextStyle myTextStyleMediumPrimaryColor(BuildContext context) {
  return GoogleFonts.lato(
      textStyle: Theme.of(context).textTheme.bodyMedium,
      fontWeight: FontWeight.normal,
      color: Theme.of(context).primaryColor);
}

TextStyle myTextStyleMediumBoldPrimaryColor(BuildContext context) {
  return GoogleFonts.lato(
      textStyle: Theme.of(context).textTheme.bodyMedium,
      fontWeight: FontWeight.w900,
      fontSize: 16,
      color: Theme.of(context).primaryColor);
}

TextStyle myTextStyleMediumBold(BuildContext context) {
  return GoogleFonts.lato(
    textStyle: Theme.of(context).textTheme.headlineMedium,
    fontWeight: FontWeight.w900,
    fontSize: 16.0,
  );
}

TextStyle myTextStyleMediumBoldGrey(BuildContext context) {
  return GoogleFonts.lato(
    textStyle: Theme.of(context).textTheme.bodyMedium,
    fontWeight: FontWeight.w900,
    color: Colors.grey.shade600,
    fontSize: 13.0,
  );
}

TextStyle myTextStyleLarge(BuildContext context) {
  return GoogleFonts.roboto(
      textStyle: Theme.of(context).textTheme.headlineLarge,
      fontWeight: FontWeight.w900,
      fontSize: 28);
}
TextStyle myTextStyleMediumLarge(BuildContext context) {
  return GoogleFonts.roboto(
      textStyle: Theme.of(context).textTheme.headlineLarge,
      fontWeight: FontWeight.w900, color: const Color(0xFF424343),
      fontSize: 24);
}
TextStyle myTextStyleMediumLargeWithOpacity(BuildContext context, double opacity) {
  return GoogleFonts.roboto(
      textStyle: Theme.of(context).textTheme.bodyMedium,
      fontWeight: FontWeight.normal, color: Theme.of(context).primaryColor.withOpacity(opacity),
      fontSize: 16);
}
TextStyle myTextStyleMediumLargePrimaryColor(BuildContext context) {
  return GoogleFonts.roboto(
      textStyle: Theme.of(context).textTheme.headlineLarge,
      fontWeight: FontWeight.w900, color: Theme.of(context).primaryColor,
      fontSize: 24);
}
TextStyle myTextStyleTitlePrimaryColor(BuildContext context) {
  return GoogleFonts.roboto(
      textStyle: Theme.of(context).textTheme.headlineLarge,
      fontWeight: FontWeight.w900, color: Theme.of(context).primaryColor,
      fontSize: 20);
}
TextStyle myTextStyleHeader(BuildContext context) {
  return GoogleFonts.roboto(
      textStyle: Theme.of(context).textTheme.headlineLarge,
      fontWeight: FontWeight.w900,
      fontSize: 34);
}

TextStyle myTextStyleLargePrimaryColor(BuildContext context) {
  return GoogleFonts.roboto(
      textStyle: Theme.of(context).textTheme.headlineLarge,
      fontWeight: FontWeight.w900,
      color: Theme.of(context).primaryColor);
}

TextStyle myTextStyleLargerPrimaryColor(BuildContext context) {
  return GoogleFonts.roboto(
      textStyle: Theme.of(context).textTheme.headlineLarge,
      fontWeight: FontWeight.w900,
      fontSize: 32,
      color: Theme.of(context).primaryColor);
}

TextStyle myNumberStyleSmall(BuildContext context) {
  return GoogleFonts.secularOne(
    textStyle: Theme.of(context).textTheme.bodyMedium,
    fontWeight: FontWeight.w900,
  );
}

TextStyle myNumberStyleMedium(BuildContext context) {
  return GoogleFonts.secularOne(
    textStyle: Theme.of(context).textTheme.bodyMedium,
    fontWeight: FontWeight.w900,
  );
}

TextStyle myNumberStyleMediumPrimaryColor(BuildContext context) {
  return GoogleFonts.secularOne(
      textStyle: Theme.of(context).textTheme.bodyMedium,
      fontWeight: FontWeight.w900,
      color: Theme.of(context).primaryColor);
}

TextStyle myNumberStyleLarge(BuildContext context) {
  return GoogleFonts.secularOne(
    textStyle: Theme.of(context).textTheme.bodyLarge,
    fontWeight: FontWeight.w900,
  );
}

TextStyle myNumberStyleLargerPrimaryColor(BuildContext context) {
  return GoogleFonts.secularOne(
      textStyle: Theme.of(context).textTheme.titleLarge,
      color: Theme.of(context).primaryColor,
      fontWeight: FontWeight.w900,
      fontSize: 28);
}

TextStyle myNumberStyleLargerPrimaryColorLight(BuildContext context) {
  return GoogleFonts.secularOne(
      textStyle: Theme.of(context).textTheme.titleLarge,
      fontWeight: FontWeight.w900,
      color: Theme.of(context).primaryColorLight,
      fontSize: 28);
}
TextStyle myNumberStyleLargerPrimaryColorDark(BuildContext context) {
  return GoogleFonts.secularOne(
      textStyle: Theme.of(context).textTheme.titleLarge,
      fontWeight: FontWeight.w900,
      color: Theme.of(context).primaryColorDark,
      fontSize: 28);
}


TextStyle myNumberStyleLargest(BuildContext context) {
  return GoogleFonts.secularOne(
      textStyle: Theme.of(context).textTheme.headlineLarge,
      fontWeight: FontWeight.w900,
      fontSize: 36);
}

TextStyle myNumberStyleBig(BuildContext context) {
  return GoogleFonts.secularOne(
      textStyle: Theme.of(context).textTheme.titleLarge,
      fontWeight: FontWeight.w900);
}

class Styles {
  static const reallyTiny = 10.0;
  static const tiny = 12.0;
  static const small = 14.0;
  static const medium = 20.0;
  static const large = 32.0;
  static const reallyLarge = 52.0;

  static TextStyle greyLabelTiny = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: tiny,
    color: Colors.grey,
  );
  static TextStyle greyLabelSmall = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: small,
    color: Colors.grey,
  );

  static TextStyle greyLabelMedium = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: medium,
    color: Colors.grey,
  );
  static TextStyle greyLabelLarge = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: large,
    color: Colors.grey,
  );
  static TextStyle yellowBoldSmall = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: small,
    color: Colors.yellow,
  );
  static TextStyle yellowBoldMedium = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: medium,
    color: Colors.yellow,
  );
  static TextStyle yellowMedium = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: medium,
    color: Colors.yellow,
  );
  static TextStyle yellowBoldLarge = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: large,
    color: Colors.yellow,
  );
  static TextStyle yellowBoldReallyLarge = const TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: reallyLarge,
    color: Colors.yellow,
  );
  static TextStyle yellowLarge = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: large,
    color: Colors.yellow,
  );
  static TextStyle yellowReallyLarge = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: reallyLarge,
    color: Colors.yellow,
  );

  /////
  static TextStyle blackBoldSmall = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: small,
    color: Colors.black,
  );
  static TextStyle blackSmall = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: small,
    color: Colors.black,
  );
  static TextStyle blackTiny = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: tiny,
    color: Colors.black,
  );
  static TextStyle blackReallyTiny = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: reallyTiny,
    color: Colors.black,
  );
  static TextStyle blackBoldMedium = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: medium,
    color: Colors.black,
  );
  static TextStyle blackMedium = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: medium,
    color: Colors.black,
  );
  static TextStyle blackBoldLarge = const TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: large,
    color: Colors.black,
  );
  static TextStyle blackBoldDash = const TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: 48,
    color: Colors.black,
  );
  static TextStyle blackBoldReallyLarge = const TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: reallyLarge,
    color: Colors.black,
  );
  static TextStyle blackLarge = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: large,
    color: Colors.black,
  );
  static TextStyle blackReallyLarge = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: reallyLarge,
    color: Colors.black,
  );

  ////////
  static TextStyle pinkBoldSmall = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: small,
    color: Colors.pink,
  );
  static TextStyle pinkTiny = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: tiny,
    color: Colors.pink,
  );
  static TextStyle pinkBoldMedium = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: medium,
    color: Colors.pink,
  );
  static TextStyle pinkMedium = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: medium,
    color: Colors.pink,
  );
  static TextStyle pinkBoldLarge = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: large,
    color: Colors.pink,
  );
  static TextStyle pinkBoldReallyLarge = const TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: reallyLarge,
    color: Colors.pink,
  );
  static TextStyle pinkLarge = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: large,
    color: Colors.pink,
  );
  static TextStyle pinkReallyLarge = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: reallyLarge,
    color: Colors.pink,
  );

  /////////
  static TextStyle purpleBoldSmall = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: small,
    color: Colors.purple,
  );
  static TextStyle purpleTiny = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: tiny,
    color: Colors.purple,
  );
  static TextStyle purpleBoldMedium = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: medium,
    color: Colors.purple,
  );
  static TextStyle purpleMedium = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: medium,
    color: Colors.purple,
  );
  static TextStyle purpleSmall = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: small,
    color: Colors.purple,
  );
  static TextStyle purpleBoldLarge = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: large,
    color: Colors.purple,
  );
  static TextStyle purpleBoldReallyLarge = const TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: reallyLarge,
    color: Colors.purple,
  );
  static TextStyle purpleLarge = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: large,
    color: Colors.purple,
  );
  static TextStyle purpleReallyLarge = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: reallyLarge,
    color: Colors.purple,
  );

  ///////
  static TextStyle blueBoldSmall = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: small,
    color: Colors.blue,
  );
  static TextStyle blueSmall = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: small,
    color: Colors.blue,
  );
  static TextStyle blueTiny = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: tiny,
    color: Colors.blue,
  );
  static TextStyle blueBoldMedium = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: medium,
    color: Colors.blue,
  );
  static TextStyle blueMedium = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: medium,
    color: Colors.blue,
  );
  static TextStyle blueBoldLarge = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: large,
    color: Colors.blue,
  );
  static TextStyle blueBoldReallyLarge = const TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: reallyLarge,
    color: Colors.blue,
  );
  static TextStyle blueLarge = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: large,
    color: Colors.blue,
  );
  static TextStyle blueReallyLarge = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: reallyLarge,
    color: Colors.blue,
  );

  ////
  static TextStyle brownBoldSmall = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: small,
    color: Colors.brown,
  );
  static TextStyle brownBoldMedium = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: medium,
    color: Colors.brown,
  );
  static TextStyle brownMedium = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: medium,
    color: Colors.brown,
  );
  static TextStyle brownBoldLarge = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: large,
    color: Colors.brown,
  );
  static TextStyle brownBoldReallyLarge = const TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: reallyLarge,
    color: Colors.brown,
  );
  static TextStyle brownLarge = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: large,
    color: Colors.brown,
  );
  static TextStyle brownReallyLarge = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: reallyLarge,
    color: Colors.brown,
  );

  ///////
  static TextStyle whiteBoldSmall = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: small,
    color: Colors.white,
  );
  static TextStyle whiteBoldMedium = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: medium,
    color: Colors.white,
  );
  static TextStyle whiteMedium = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: medium,
    color: Colors.white,
  );
  static TextStyle whiteSmall = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: small,
    color: Colors.white,
  );
  static TextStyle whiteTiny = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: tiny,
    color: Colors.white,
  );
  static TextStyle whiteBoldLarge = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: large,
    color: Colors.white,
  );
  static TextStyle whiteBoldReallyLarge = const TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: reallyLarge,
    color: Colors.white,
  );
  static TextStyle whiteLarge = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: large,
    color: Colors.white,
  );
  static TextStyle whiteReallyLarge = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: reallyLarge,
    color: Colors.white,
  );

  /////
  static TextStyle tealBoldSmall = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: small,
    color: Colors.teal,
  );
  static TextStyle tealBoldMedium = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: medium,
    color: Colors.teal,
  );
  static TextStyle tealMedium = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: medium,
    color: Colors.teal,
  );
  static TextStyle tealBoldLarge = const TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: large,
    color: Colors.teal,
  );
  static TextStyle tealBoldReallyLarge = const TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: reallyLarge,
    color: Colors.teal,
  );
  static TextStyle tealLarge = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: large,
    color: Colors.teal,
  );
  static TextStyle tealReallyLarge = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: reallyLarge,
    color: Colors.teal,
  );

  static Color white = Colors.white;
  static Color black = Colors.black;
  static Color yellow = Colors.yellow;
  static Color lightGreen = Colors.lightGreen;
  static Color lightBlue = Colors.lightBlue;
  static Color brown = Colors.brown;
  static Color pink = Colors.pink;
  static Color teal = Colors.teal;
  static Color purple = Colors.purple;
  static Color blue = Colors.blue;
}

prettyPrint(Map map, String name) {
  pp('$name \t{\n');

  map.forEach((key, val) {
    pp('\t$key : $val ,\n');
  });
  pp('}\n\n');
}

Future<File> getImageFileFromAssets(String path) async {
  final byteData = await rootBundle.load('assets/$path');

  final file = File('${(await getTemporaryDirectory()).path}/$path');
  await file.writeAsBytes(byteData.buffer
      .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

  return file;
}

Future<String> getStringFromAssets(String path) async {
  pp('getStringFromAssets: locale: $path');
  final stringData = await rootBundle.loadString('assets/l10n/$path.json');
  return stringData;
}

LatLngBounds boundsFromLatLngList(List<LatLng> list) {
  assert(list.isNotEmpty);
  double? x0, x1, y0, y1;
  for (LatLng latLng in list) {
    if (x0 == null) {
      x0 = x1 = latLng.latitude;
      y0 = y1 = latLng.longitude;
    } else {
      if (latLng.latitude > x1!) x1 = latLng.latitude;
      if (latLng.latitude < x0) x0 = latLng.latitude;
      if (latLng.longitude > y1!) y1 = latLng.longitude;
      if (latLng.longitude < y0!) y0 = latLng.longitude;
    }
  }
  return LatLngBounds(northeast: LatLng(x1!, y1!), southwest: LatLng(x0!, y0!));
}

Future<File> getPhotoThumbnail({required File file}) async {
  final Directory directory = await getApplicationDocumentsDirectory();

  img.Image? image = img.decodeImage(file.readAsBytesSync());
  var thumbnail = img.copyResize(image!, width: 160);
  const slash = '/thumbnail_';

  final File mFile = File(
      '${directory.path}$slash${DateTime.now().millisecondsSinceEpoch}.jpg');
  var thumb = mFile..writeAsBytesSync(img.encodeJpg(thumbnail, quality: 100));
  var len = await thumb.length();
  pp('🔷🔷 photo thumbnail generated: 😡 ${(len / 1024).toStringAsFixed(1)} KB');
  return thumb;
}

Future<File> getVideoThumbnail(File file) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  var path = 'possibleVideoThumb_${DateTime.now().toIso8601String()}.jpg';
  const slash = '/';
  final thumbFile = File('${directory.path}$slash$path');

  try {
    final data = await vt.VideoThumbnail.thumbnailData(
      video: file.path,
      imageFormat: vt.ImageFormat.JPEG,
      maxWidth: 128,
      quality: 100,
    );
    await thumbFile.writeAsBytes(data!);
    pp('🔷🔷Video thumbnail created. length: ${await thumbFile.length()} 🔷🔷🔷');
    return thumbFile;
  } catch (e) {
    pp('ERROR: $e');
    var m = await getImageFileFromAssets('assets/intro/small.jpg');
    return m;
  }
}

String getThisDeviceType() {
  final data = MediaQueryData.fromWindow(WidgetsBinding.instance.window);
  return data.size.shortestSide < 600 ? 'phone' : 'tablet';
}

String getFileSizeString({required int bytes, int decimals = 0}) {
  const suffixes = [" bytes", " KB", " MB", " GB", " TB"];
  var i = (log(bytes) / log(1024)).floor();
  return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + suffixes[i];
}

double getFileSizeInMB({required int bytes, int decimals = 0}) {
  var i = (log(bytes) / log(1024)).floor();
  var size = (bytes / pow(1024, i));
  return size;
}


showSnackBar(
    {required String message,
      required BuildContext context,
      Color? backgroundColor,
      TextStyle? textStyle,
      Duration? duration,
      double? padding,
      double? elevation
    }) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    duration: duration ?? const Duration(seconds: 5),
    backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
    showCloseIcon: true,
    elevation: elevation ?? 8,
    content: Padding(
      padding: EdgeInsets.all(padding ?? 8),
      child: Text(
        message,
        style: textStyle ?? myTextStyleMediumBold(context),
      ),
    ),
  ));

}
Future<Map<String, String>> getStartEndDates({int? numberOfDays}) async {
  int numberOfDays = 7;
  var settings = await prefsOGx.getSettings();
  numberOfDays = settings.numberOfDays!;
  var startDate = DateTime.now()
      .subtract(Duration(days: numberOfDays))
      .toUtc()
      .toIso8601String();

  var endDate = DateTime.now().toUtc().toIso8601String();
  var map = <String, String>{};
  map['startDate'] = startDate;
  map['endDate'] = endDate;

  return map;
}

void sortActivitiesDescending(List<ActivityModel> models) {
  models.sort((a, b) => DateTime.parse(b.date!)
      .millisecondsSinceEpoch
      .compareTo(DateTime.parse(a.date!).millisecondsSinceEpoch));
}
void sortActivitiesAscending(List<ActivityModel> models) {
  models.sort((a, b) => DateTime.parse(a.date!)
      .millisecondsSinceEpoch
      .compareTo(DateTime.parse(b.date!).millisecondsSinceEpoch));
}

Future<String?> getTranslatedUserType(String type) async {
  String? translated;
  final sett = await prefsOGx.getSettings();

  switch (type) {
    case UserType.fieldMonitor:
      translated = await translator.translate('fieldMonitor', sett!.locale!);
      break;
    case UserType.orgAdministrator:
      translated = await translator.translate('administrator', sett!.locale!);
      break;
    case UserType.orgExecutive:
      translated = await translator.translate('executive', sett!.locale!);
      break;
  }
  return translated;
}

SettingsModel getBaseSettings() {
  var model = SettingsModel(
      distanceFromProject: 500,
      photoSize: 1,
      maxVideoLengthInSeconds: 120,
      maxAudioLengthInMinutes: 15,
      themeIndex: 0,
      settingsId: const Uuid().v4(),
      created: DateTime.now().toUtc().toIso8601String(),
      organizationId: null,
      projectId: null,
      activityStreamHours: 24,
      numberOfDays: 30,
      translatedMessage: null,
      translatedTitle: null,
      locale: 'en');

  return model;
}

Future<String> getFCMMessageTitle() async {
  final sett = await cacheManager.getSettings();
  final m = await translator.translate('messageFromGeo', sett.locale!);
  final messageFromGeo = m.replaceAll('\$geo', 'Gio');
  return messageFromGeo;
}
Future<String> getFCMMessage(String key) async {
  final sett = await cacheManager.getSettings();
  final m = await translator.translate(key, sett.locale!);
  return m;
}

pp(dynamic msg) {
  var time = getFormattedDateHourMinSec(DateTime.now().toString());
  if (kReleaseMode) {
    return;
  }
  if (kDebugMode) {
    if (msg is String) {
      debugPrint('$time ==> $msg');
    } else {
      print('$time ==> $msg');
    }
  }
}

List<Image> getImages()  {
  final images = <Image>[];
  images.add(Image.asset('assets/projects/proj1.jpg'));
  images.add(Image.asset('assets/projects/proj2.jpg'));
  images.add(Image.asset('assets/projects/proj3.jpg'));
  images.add(Image.asset('assets/projects/proj4.jpg'));
  images.add(Image.asset('assets/projects/proj5.jpg'));
  return images;
}

String getUrl()  {

    pp('functions:getUrl 🐤🐤🐤🐤 Getting url via .env settings');
    late String url;
    if (GioEnv.currentStatus == 'dev') {
      url = GioEnv.devUrl;
    } else {
      url = GioEnv.prodUrl;
    }
    pp('functions: getUrl 🐤🐤🐤🐤 url from GioEnv: $url');

    return url;
}

bool checkIfDateWithinRange(
    {required String date,
    required String startDate,
    required String endDate}) {
  final userDate = DateTime.parse(date);
  final sDate = DateTime.parse(startDate);
  final eDate = DateTime.parse(endDate);
  if (userDate.millisecondsSinceEpoch >= sDate.millisecondsSinceEpoch &&
      userDate.millisecondsSinceEpoch <= eDate.millisecondsSinceEpoch) {
    return true;
  }
  return false;
}

getRoundedBorder({required double radius}) {
  return RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
}

String getFmtDate(String date, String locale) {
  initializeDateFormatting();
  String mLocale = getValidLocale(locale);
  Future.delayed(const Duration(milliseconds: 10));

  DateTime now = DateTime.parse(date).toLocal();
  final format = DateFormat("EEEE dd MMMM yyyy  HH:mm:ss", mLocale);
  final formatUS = DateFormat("EEEE MMMM dd yyyy  HH:mm:ss", mLocale);
  if (mLocale.contains('en_US')) {
    final String result = formatUS.format(now);
    return result;
  } else {
    final String result = format.format(now);
    return result;
  }
}
String getFmtDateShort(String date, String locale) {
  initializeDateFormatting();
  String mLocale = getValidLocale(locale);
  Future.delayed(const Duration(milliseconds: 10));

  DateTime now = DateTime.parse(date).toLocal();
  final format = DateFormat("dd MM yyyy  HH:mm", mLocale);
  final formatUS = DateFormat("MM dd yyyy  HH:mm", mLocale);
  if (mLocale.contains('en_US')) {
    final String result = formatUS.format(now);
    return result;
  } else {
    final String result = format.format(now);
    return result;
  }
}
String getFmtDateShortWithSlash(String date, String locale) {
  initializeDateFormatting();
  String mLocale = getValidLocale(locale);
  Future.delayed(const Duration(milliseconds: 10));

  DateTime now = DateTime.parse(date).toLocal();
  final format = DateFormat("dd/MM/yyyy", mLocale);
  final formatUS = DateFormat("MM/dd/yyyy", mLocale);
  if (mLocale.contains('en_US')) {
    final String result = formatUS.format(now);
    return result;
  } else {
    final String result = format.format(now);
    return result;
  }
}

String getValidLocale(String locale) {
  switch (locale) {
    case 'af':
      return 'af_ZA';
    case 'en':
      return 'en';
    case 'es':
      return 'es';
    case 'pt':
      return 'pt';
    case 'fr':
      return 'fr';
    case 'st':
      return 'en_ZA';
    case 'ts':
      return 'en_ZA';
    case 'xh':
      return 'en_ZA';
    case 'zu':
      return 'zu_ZA';
    case 'sn':
      return 'en_GB';
    case 'yo':
      return 'en_NG';
    case 'sw':
      return 'sw_KE';
    case 'de':
      return 'de';
    case 'zh':
      return 'zh';
    default:
      return 'en_US';
  }
}

String getHourMinuteSecond(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  var s = "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  return s;
}

String getFormattedDateLongWithTime(String date, BuildContext context) {
  Locale myLocale = Localizations.localeOf(context);

  initializeDateFormatting();
  var format = DateFormat('EEEE, dd MMMM yyyy HH:mm', myLocale.toString());
  try {
    if (date.contains('GMT')) {
      var mDate = getLocalDateFromGMT(date, context);
      return format.format(mDate.toLocal());
    } else {
      var mDate = DateTime.parse(date);
      return format.format(mDate.toLocal());
    }
  } catch (e) {
    pp(e);
    return 'NoDate';
  }
}

String getFormattedDateShortWithTime(String date, BuildContext context) {
  Locale myLocale = Localizations.localeOf(context);

  initializeDateFormatting();
  var format = DateFormat('dd MMMM yyyy HH:mm:ss', myLocale.toString());
  try {
    if (date.contains('GMT')) {
      var mDate = getLocalDateFromGMT(date, context);
      return format.format(mDate.toLocal());
    } else {
      var mDate = DateTime.parse(date);
      return format.format(mDate.toLocal());
    }
  } catch (e) {
    pp(e);
    return 'NoDate';
  }
}

String getFormattedDateLong(String date, BuildContext context) {
//  pp('\getFormattedDateLong $date'); //Sun, 28 Oct 2018 23:59:49 GMT
  Locale myLocale = Localizations.localeOf(context);

  initializeDateFormatting();
  var format = DateFormat('EEEE, dd MMMM yyyy', myLocale.toString());
  try {
    if (date.contains('GMT')) {
      var mDate = getLocalDateFromGMT(date, context);
      pp('++++++++++++++ Formatted date with locale == ${format.format(mDate.toLocal())}');
      return format.format(mDate.toLocal());
    } else {
      var mDate = DateTime.parse(date);
      return format.format(mDate.toLocal());
    }
  } catch (e) {
    pp(e);
    return 'NoDate';
  }
}

String getFormattedDateShort(String date, BuildContext context) {
  Locale myLocale = Localizations.localeOf(context);

  initializeDateFormatting();
  var format = DateFormat('dd MMMM yyyy', myLocale.toString());
  try {
    if (date.contains('GMT')) {
      var mDate = getLocalDateFromGMT(date, context);
      pp('++++++++++++++ Formatted date with locale == ${format.format(mDate)}');
      return format.format(mDate);
    } else {
      var mDate = DateTime.parse(date);
      return format.format(mDate.toLocal());
    }
  } catch (e) {
    pp(e);
    return 'NoDate';
  }
}

String getFormattedDateShortest(String date, BuildContext context) {
  Locale myLocale = Localizations.localeOf(context);

  initializeDateFormatting();
  var format = DateFormat('dd-MM-yyyy', myLocale.toString());
  try {
    if (date.contains('GMT')) {
      var mDate = getLocalDateFromGMT(date, context);
      pp('++++++++++++++ Formatted date with locale == ${format.format(mDate)}');
      return format.format(mDate);
    } else {
      var mDate = DateTime.parse(date);
      return format.format(mDate.toLocal());
    }
  } catch (e) {
    pp(e);
    return 'NoDate';
  }
}

String getFormattedDateShortestWithTime(String date, BuildContext context) {
  Locale myLocale = Localizations.localeOf(context);

  initializeDateFormatting();
  var format = DateFormat('dd-MM-yyyy HH:mm', myLocale.toString());
  try {
    if (date.contains('GMT')) {
      var mDate = getLocalDateFromGMT(date, context);
      return format.format(mDate);
    } else {
      var mDate = DateTime.parse(date);
      return format.format(mDate.toLocal());
    }
  } catch (e) {
    pp(e);
    return 'NoDate';
  }
}

int getIntDate(String date, BuildContext context) {
  pp('\n---------------> getIntDate $date'); //Sun, 28 Oct 2018 23:59:49 GMT
  initializeDateFormatting();
  try {
    if (date.contains('GMT')) {
      var mDate = getLocalDateFromGMT(date, context);
      return mDate.millisecondsSinceEpoch;
    } else {
      var mDate = DateTime.parse(date);
      return mDate.millisecondsSinceEpoch;
    }
  } catch (e) {
    pp(e);
    return 0;
  }
}

String getFormattedDateHourMinute(
    {required DateTime date, required BuildContext? context}) {
  initializeDateFormatting();

  try {
    if (context == null) {
      var dateFormat = DateFormat('HH:mm');
      return dateFormat.format(date);
    } else {
      Locale myLocale = Localizations.localeOf(context);
      var dateFormat = DateFormat('HH:mm', myLocale.toString());
      return dateFormat.format(date);
    }
  } catch (e) {
    pp(e);
    return 'NoDate';
  }
}

String getFormattedDateHourMinuteSecond(
    {required DateTime date, required BuildContext? context}) {
  initializeDateFormatting();

  try {
    if (context == null) {
      var dateFormat = DateFormat('HH:mm:ss');
      return dateFormat.format(date);
    } else {
      Locale myLocale = Localizations.localeOf(context);
      var dateFormat = DateFormat('HH:mm:ss', myLocale.toString());
      return dateFormat.format(date);
    }
  } catch (e) {
    pp(e);
    return 'NoDate';
  }
}

DateTime getLocalDateFromGMT(String date, BuildContext context) {
  //pp('getLocalDateFromGMT string: $date'); //Sun, 28 Oct 2018 23:59:49 GMT

  //pp('+++++++++++++++ locale: ${myLocale.toString()}');
  initializeDateFormatting();
  try {
    var mDate = translateGMTString(date);
    return mDate.toLocal();
  } catch (e) {
    pp(e);
    rethrow;
  }
}

DateTime translateGMTString(String date) {
  var strings = date.split(' ');
  var day = int.parse(strings[1]);
  var mth = strings[2];
  var year = int.parse(strings[3]);
  var time = strings[4].split(':');
  var hour = int.parse(time[0]);
  var min = int.parse(time[1]);
  var sec = int.parse(time[2]);
  var cc = DateTime.utc(year, getMonth(mth), day, hour, min, sec);

  //pp('##### translated date: ${cc.toIso8601String()}');
  //pp('##### translated local: ${cc.toLocal().toIso8601String()}');

  return cc;
}

int getMonth(String mth) {
  switch (mth) {
    case 'Jan':
      return 1;
    case 'Feb':
      return 2;
    case 'Mar':
      return 3;
    case 'Apr':
      return 4;
    case 'Jun':
      return 6;
    case 'Jul':
      return 7;
    case 'Aug':
      return 8;
    case 'Sep':
      return 9;
    case 'Oct':
      return 10;
    case 'Nov':
      return 11;
    case 'Dec':
      return 12;
  }
  return 0;
}

String getUTCDate() {
  initializeDateFormatting();
  String now = DateTime.now().toUtc().toIso8601String();
  return now;
}

String getUTC(DateTime date) {
  initializeDateFormatting();
  String now = date.toUtc().toIso8601String();
  return now;
}

String getFormattedDate(String date) {
  try {
    DateTime d = DateTime.parse(date);
    var format = DateFormat.yMMMd();
    return format.format(d);
  } catch (e) {
    return date;
  }
}

String getFormattedDateHour(String date) {
  try {
    DateTime d = DateTime.parse(date);
    var format = DateFormat.Hms();
    return format.format(d.toUtc());
  } catch (e) {
    DateTime d = DateTime.now();
    var format = DateFormat.Hm();
    return format.format(d);
  }
}

String getFormattedDateHourMinSec(String date) {
  try {
    DateTime d = DateTime.parse(date);
    var format = DateFormat.Hms();
    return format.format(d.toUtc());
  } catch (e) {
    DateTime d = DateTime.now();
    var format = DateFormat.Hm();
    return format.format(d);
  }
}

String getFormattedNumber(int number, BuildContext context) {
  Locale myLocale = Localizations.localeOf(context);
  var val = '${myLocale.languageCode}_${myLocale.countryCode!}';
  final oCcy = NumberFormat("###,###,###,###,###", val);

  return oCcy.format(number);
}

String getFormattedDouble(double number, BuildContext context) {
  Locale myLocale = Localizations.localeOf(context);
  var val = '${myLocale.languageCode}_${myLocale.countryCode!}';
  final oCcy = NumberFormat("###,###,###,###,##0.0", val);

  return oCcy.format(number);
}

String getFormattedAmount(String amount, BuildContext context) {
  Locale myLocale = Localizations.localeOf(context);
  var val = '${myLocale.languageCode}_${myLocale.countryCode!}';
  //pp('getFormattedAmount ----------- locale is  $val');
  final oCcy = NumberFormat("#,##0.00", val);
  try {
    double m = double.parse(amount);
    return oCcy.format(m);
  } catch (e) {
    return amount;
  }
}

bool get isInDebugMode {
  bool inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}

const lorem =
    'Having a centralized platform to collect multimedia information and build video, audio, and photo timelines '
    'can be a valuable tool for managers and executives to monitor long-running field operations. '
    'This can provide a visual representation of the progress and status of field operations and help in '
    'tracking changes over time. Timelines can also be used to identify any bottlenecks or issues that arise during field operations, allowing for quick and effective problem-solving. '
    'The multimedia information collected can also be used for training and review purposes, allowing for '
    'continuous improvement and optimization of field operations. Overall, building multimedia timelines '
    'can provide valuable insights and information for managers and executives to make informed decisions and improve '
    'the overall efficiency of field operations.\n\nThere are many use cases for monitoring and managing initiatives '
    'using mobile devices and cloud platforms. The combination of mobile devices and cloud-based solutions can greatly improve '
    'the efficiency and effectiveness of various initiatives, including infrastructure building projects, events, conferences, '
    'school facilities, and ongoing activities of all types. By using mobile devices, field workers can collect and share multimedia information in real-time, '
    'allowing for better coordination and communication. The use of cloud platforms can also provide additional benefits, '
    'such as field worker authentication, cloud push messaging systems, data storage, and databases. This can help in centralizing information, '
    'reducing the reliance on manual processes and paperwork, and improving the ability to make informed decisions and respond to changes in real-time. '
    'Overall, utilizing mobile devices and cloud platforms can provide a '
    'powerful solution for monitoring and managing various initiatives in a more efficient and effective manner.';

const chatGPT1 =
    'Offering a monthly or annual subscription model for a cloud-based field worker collaboration and '
    'management solution can be a cost-effective solution for clients who want to improve their monitoring capabilities. '
    'The subscription model can provide clients with access to powerful tools and features, such as real-time multimedia '
    'sharing, a centralized command post, real-time notifications, and multimedia timelines, for a relatively low monthly '
    'expense. This can help clients to reduce the costs associated with traditional manual processes and improve the '
    'efficiency and effectiveness of their operations. Additionally, by offering the service as a subscription model, '
    'the company can have the option to hire young people and students to perform digital field work, providing them with '
    'valuable experience and training. Overall, the subscription model can provide a cost-effective and scalable '
    'solution for clients, '
    'while also providing opportunities for young people and students to gain hands-on experience in the field.';

abstract class SnackBarListener {
  onActionPressed(int action);
}

ProjectPolygon? getPolygonUserIsWithin(
    {required List<ProjectPolygon> polygons,
    required double latitude,
    required double longitude}) {
  pp('🍎🍎 getPolygonUserIsWithin: location: 🍎 lat: $latitude lng: $longitude ');

  ProjectPolygon? polygon;
  for (var p in polygons) {
    var isWithinPolygon = checkIfLocationIsWithinPolygon(
        positions: p.positions, latitude: latitude, longitude: longitude);
    if (isWithinPolygon) {
      polygon = p;
    }
  }

  if (polygon != null) {
    pp('🍎🍎 project p FOUND! 🥬🥬🥬 ');
  } else {
    pp('🍎🍎 project p NOT FOUND!  🔴🔴🔴 ');
  }

  return polygon;
}

bool checkIfLocationIsWithinPolygons(
    {required List<ProjectPolygon> polygons,
    required double latitude,
    required double longitude}) {
  pp('🍎🍎 checkIfLocationIsWithinPolygons: location: 🍎 lat: $latitude lng: $longitude ');
  int positiveCount = 0;
  for (var polygon in polygons) {
    var isWithinPolygon = checkIfLocationIsWithinPolygon(
        positions: polygon.positions, latitude: latitude, longitude: longitude);
    if (isWithinPolygon) {
      positiveCount++;
    }
  }
  pp('🍎🍎 checkIfLocationIsWithinPolygons: location found in any of the projects 🍎 '
      'polygons; positiveCount: $positiveCount - 🍎 expects to be 1 if things are cool!');

  if (positiveCount == 1) {
    pp('🍎🍎 checkIfLocationIsWithinPolygons: location found within one of the projects polygons 🥬🥬🥬 ');
    return true;
  }
  pp('🍎🍎 checkIfLocationIsWithinPolygons: location NOT found within any of the projects polygons 🔴🔴🔴 ');

  return false;
}

bool checkIfLocationIsWithinPolygon(
    {required List<Position> positions,
    required double latitude,
    required double longitude}) {
  var polygonPoints = <Point>[];
  var point = Point(latitude, longitude);
  for (var position in positions) {
    polygonPoints.add(Point(position.coordinates[1], position.coordinates[0]));
  }
  return _isWithinPolygon(polygonPoints: polygonPoints, point: point);
}

bool _isWithinPolygon(
    {required List<Point> polygonPoints, required Point point}) {
  bool contains = PolyUtils.containsLocationPoly(point, polygonPoints);
  pp('🔵🔵🔵 isWithinPolygon: point is inside polygon?: $contains');

  return contains;
}

const chatGPT2 =
    'Geo is a powerful tool to monitor the construction and maintenance of '
    'infrastructure and facilities, especially in areas where youth unemployment is high '
    'and corruption is a problem. With Geo, they can track progress and quality in real-time, '
    'ensure that projects are being completed on time and within budget, and '
    'identify and address potential issues before they become major problems. '
    'By leveraging Geo\'s multimedia monitoring capabilities, the agency can also '
    'improve transparency and accountability, which can help combat corruption and '
    'build trust with the community. Ultimately, Geo can help the agency maximize the impact '
    'of its investments in infrastructure and other facilities, '
    'while also creating opportunities for unemployed youth to participate in monitoring '
    'and contributing to the development of their communities.';

const chatGPTYouth =
    'Given the prevalence of smartphones and digital media use among young people, '
    'Geo could be a valuable tool for engaging and employing youth in community development projects. '
    'Field worker positions could be specifically targeted towards youth who are comfortable '
    'using smartphones and digital media, and who may have been previously unemployed'
    'Furthermore, involvement with Geo could provide youth with valuable job skills '
    'and work experience, which could increase their employability in the future. '
    'In addition, by engaging with youth and involving them in community development projects, '
    'Geo could help to foster a sense of pride and ownership in their communities, '
    'which could lead to increased engagement and participation in the future.';

const chatGPTGov =
    'Government agencies and officials can benefit from Geo in several ways. '
    'First, Geo can help in the efficient and effective management of infrastructure projects '
    'by providing real-time multimedia monitoring and reporting, which can help identify and '
    'address any issues that may arise during the project. Second, Geo can help to combat corruption '
    'by providing an objective and verifiable record of project progress and expenses, '
    'which can help to prevent or detect fraudulent activities. '
    'Third, Geo can provide valuable insights into the needs and priorities of communities, '
    'which can help government agencies to better target their resources and efforts to where '
    'they are needed most. Finally, by engaging and '
    'empowering young people in the process of monitoring and reporting on infrastructure projects, '
    'Geo can help to build a sense of ownership and responsibility among youth, while also providing them '
    'with valuable skills and experience that can help to improve their employment prospects.';

const chatGPTCommunity =
    'Community groups can get involved with Geo by using the platform to '
    'monitor and manage their community-based projects, such as community clean-up campaigns, '
    'volunteer initiatives, or fundraising events. The platform can also be used to track the '
    'progress of these projects and ensure that resources are being allocated effectively. '
    'Additionally, community groups can use Geo to report incidents or issues in their community, '
    'such as crime or environmental hazards, and track the response of relevant authorities. '
    'This can help to improve community safety and promote greater collaboration between community members '
    'and local government agencies. Finally, community groups can also use Geo to coordinate volunteer '
    'efforts during emergencies, '
    'such as natural disasters, and ensure that resources are being distributed to those in need.';
