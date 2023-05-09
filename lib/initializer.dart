
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geo_monitor/device_location/device_location_bloc.dart';
import 'package:geo_monitor/library/api/data_api_og.dart';
import 'package:geo_monitor/library/bloc/isolate_handler.dart';
import 'package:geo_monitor/library/bloc/location_request_handler.dart';
import 'package:geo_monitor/library/bloc/organization_bloc.dart';
import 'package:geo_monitor/library/errors/error_handler.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:location/location.dart';

import 'library/api/prefs_og.dart';
import 'library/auth/app_auth.dart';
import 'library/bloc/data_refresher.dart';
import 'library/bloc/fcm_bloc.dart';
import 'library/bloc/geo_uploader.dart';
import 'library/bloc/project_bloc.dart';
import 'library/bloc/user_bloc.dart';
import 'library/cache_manager.dart';
import 'library/emojis.dart';
import 'library/functions.dart';
import 'library/geofence/the_great_geofencer.dart';
import 'package:http/http.dart' as http;

int themeIndex = 0;
final Initializer initializer = Initializer();

class Initializer {
  final mx = '✅✅✅✅✅ Initializer: ✅';

  Future<void> initializeGeo() async {
    pp('$mx initializeGeo: ... GET CACHED SETTINGS; set themeIndex .............. ');

    final start = DateTime.now();
    final settings = await prefsOGx.getSettings();

    locationBloc = DeviceLocationBloc(Location());
    cacheManager = CacheManager();
    final client = http.Client();
    appAuth = AppAuth(FirebaseAuth.instance);

    errorHandler = ErrorHandler(locationBloc, prefsOGx);
    dataApiDog =
        DataApiDog(client, appAuth, cacheManager, prefsOGx, errorHandler);
    dataRefresher =
        DataRefresher(appAuth, errorHandler, dataApiDog, client, cacheManager);
    geoUploader = GeoUploader(errorHandler, cacheManager, dataApiDog);

    organizationBloc = OrganizationBloc(dataApiDog, cacheManager);
    theGreatGeofencer = TheGreatGeofencer(dataApiDog, prefsOGx);

    dataHandler = IsolateDataHandler(prefsOGx, appAuth, cacheManager);

    projectBloc = ProjectBloc(dataApiDog, cacheManager, dataHandler);
    userBloc = UserBloc(dataApiDog, cacheManager, dataHandler);

    locationRequestHandler = LocationRequestHandler(dataApiDog);
    fcmBloc = FCMBloc(FirebaseMessaging.instance, cacheManager, locationRequestHandler);

    pp('$mx  '
        'initializeGeo: Hive initialized Gio services. 💜💜 Ready to rumble! Ali Bomaye!!');

    FirebaseMessaging.instance.requestPermission();

    heavyLifting(settings.numberOfDays!);
    pp('$mx ${E.heartGreen}${E.heartGreen}}${E.heartGreen} '
        'initializeGeo: App Settings are 🍎${settings.toJson()}🍎');

    final end = DateTime.now();
    pp('\n\n$mx ${E.appleRed}${E.appleRed}}${E.appleGreen} '
        ' initializeGeo: Time Elapsed: ${end.difference(start).inMilliseconds} milliseconds\n\n');
  }

  Future<void> heavyLifting(int numberOfDays) async {

    pp('$mx heavyLifting: fcm initialization starting .................');
    await Hive.initFlutter(hiveName);

    await cacheManager.initialize(forceInitialization: false);
    await fcmBloc.initialize();
    var settings = await prefsOGx.getSettings();
    if (settings.organizationId != null) {
      pp('$mx heavyLifting: manageMediaUploads starting ...............');
      geoUploader.manageMediaUploads();
      pp('$mx heavyLifting: _buildGeofences starting ..................');
      theGreatGeofencer.buildGeofences();
    }

    pp('$mx organizationDataRefresh starting ........................');
    pp('$mx start with delay of 5 seconds before data refresh ..............');

    Future.delayed(const Duration(seconds: 60 * 10)).then((value) async {
      pp('$mx start data refresh after delaying for 5 seconds');

      if (settings.organizationId != null) {
        dataHandler.getOrganizationData();
      }
    });
  }
}
