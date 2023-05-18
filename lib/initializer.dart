
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geo_monitor/device_location/device_location_bloc.dart';
import 'package:geo_monitor/library/api/data_api_og.dart';
import 'package:geo_monitor/library/bloc/isolate_handler.dart';
import 'package:geo_monitor/library/bloc/location_request_handler.dart';
import 'package:geo_monitor/library/bloc/organization_bloc.dart';
import 'package:geo_monitor/library/errors/error_handler.dart';
import 'package:get_storage/get_storage.dart';
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

  Future initializeGeo() async {
    pp('$mx initializeGeo: ... setting up resources and blocs etc .............. ');

    pp('$mx initializeGeo: setting up GetStorage ...');
    await GetStorage.init(cacheName);
    prefsOGx = PrefsOGx();
    locationBloc = DeviceLocationBloc(Location());
    await Hive.initFlutter(hiveName);
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
    locationRequestHandler = LocationRequestHandler(dataApiDog);

    dataHandler = IsolateDataHandler(prefsOGx, appAuth, cacheManager);

    projectBloc = ProjectBloc(dataApiDog, cacheManager, dataHandler);
    userBloc = UserBloc(dataApiDog, cacheManager, dataHandler);

    fcmBloc = FCMBloc(FirebaseMessaging.instance, cacheManager, locationRequestHandler);

    FirebaseMessaging.instance.requestPermission();

    await heavyLifting();
    return 0;
  }

  Future heavyLifting() async {
    pp('$mx Heavy lifting starting ....');
    final start = DateTime.now();
    final settings = await prefsOGx.getSettings();

    pp('$mx heavyLifting: cacheManager initialization starting .................');
    await cacheManager.initialize();

    pp('$mx heavyLifting: cacheManager done  ✅; fcm initialization starting .................');
    await fcmBloc.initialize();

    final token = await appAuth.getAuthToken();

    pp('$mx heavyLifting: token:\n$token\n');
    if (settings.organizationId != null) {
      pp('$mx heavyLifting: _buildGeofences starting ..................');
      theGreatGeofencer.buildGeofences();
    }

    pp('$mx organizationDataRefresh starting ........................');
    pp('$mx start with delay of 5 seconds before data refresh ..............');

    final list = await cacheManager.getCountries();
    for (var country in list) {
      pp('$mx country: ${country.name}');
    }

    if (settings.organizationId != null) {
      pp('$mx heavyLifting: manageMediaUploads starting ...............');
      geoUploader.manageMediaUploads();
    }
    pp('\n\n$mx  '
        'initializeGeo: Hive initialized Gio services. '
        '💜💜 Ready to rumble! Ali Bomaye!!');
    final end = DateTime.now();
    pp('$mx initializeGeo, heavyLifting: Time Elapsed: ${end.difference(start).inMilliseconds} milliseconds\n\n');

  }
}
