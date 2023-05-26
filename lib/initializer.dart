import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geo_monitor/device_location/device_location_bloc.dart';
import 'package:geo_monitor/library/api/data_api_og.dart';
import 'package:geo_monitor/library/bloc/isolate_handler.dart';
import 'package:geo_monitor/library/bloc/location_request_handler.dart';
import 'package:geo_monitor/library/bloc/organization_bloc.dart';
import 'package:geo_monitor/library/errors/error_handler.dart';
import 'package:geo_monitor/library/providers/dio_service.dart';
import 'package:geo_monitor/stitch/stitch_service.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

import 'firebase_options.dart';
import 'library/api/prefs_og.dart';
import 'library/auth/app_auth.dart';
import 'library/bloc/data_refresher.dart';
import 'library/bloc/fcm_bloc.dart';
import 'library/bloc/geo_uploader.dart';
import 'library/bloc/project_bloc.dart';
import 'library/bloc/user_bloc.dart';
import 'library/cache_manager.dart';
import 'library/functions.dart';
import 'library/geofence/the_great_geofencer.dart';
import 'main.dart';

int themeIndex = 0;
final Initializer initializer = Initializer();

class Initializer {
  final mx = '✅✅✅✅✅ Initializer: ✅';

  Future setupGio() async {
    pp('\n\n$mx setupGio: ... setting up resources and blocs etc .............. ');

    await initializeGioServices();
    await heavyLifting();
    return 0;
  }

  Future<void> initializeGioServices() async {
    pp('\n\n$mx initializeGioServices: ... setting up resources and blocs etc .............. ');
    firebaseApp = await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    pp('$mx initializeGioServices: '
        ' Firebase App has been initialized: ${firebaseApp.name}, checking for authed current user');
    fbAuthedUser = FirebaseAuth.instance.currentUser;
    pp('$mx initializeGioServices: setting up GetStorage, Prefs, Location etc...');
    await GetStorage.init(cacheName);
    prefsOGx = PrefsOGx();
    locationBloc = DeviceLocationBloc(Location());
    await Hive.initFlutter(hiveName);
    cacheManager = CacheManager();

    final client = http.Client();
    appAuth = AppAuth(FirebaseAuth.instance);

    dioService =  DioService(Dio(), appAuth);
    stitchService = StitchService(http.Client());

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

    fcmBloc = FCMBloc(
        FirebaseMessaging.instance, cacheManager, locationRequestHandler);

    pp('$mx initializeGioServices: ...resources and blocs etc set up ok!  \n\n');

  }

  Future heavyLifting() async {
    pp('$mx Heavy lifting starting ....');

    final start = DateTime.now();

    final settings = await prefsOGx.getSettings();

    FirebaseMessaging.instance.requestPermission();

    pp('$mx heavyLifting: cacheManager initialization starting .................');
    await cacheManager.initialize();

    pp('$mx heavyLifting: cacheManager done  ✅; fcm initialization starting .................');
    await fcmBloc.initialize();

    final token = await appAuth.getAuthToken();
    pp('$mx heavyLifting: Firebase auth token:\n$token\n');

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
    pp('$mx initializeGeo, heavyLifting: Time Elapsed: ${end.difference(start).inMilliseconds} '
        'milliseconds\n\n');
    final sett = await prefsOGx.getSettings();
    final m = await getStartEndDates(numberOfDays: sett.numberOfDays!);

    Future.delayed(const Duration(seconds: 15)).then((value) {
      pp('$mx initializeGeo, heavyLifting: refreshing org data after delay of 15 seconds');
      organizationBloc.getOrganizationData(
          organizationId: sett.organizationId!,
          forceRefresh: true,
          startDate: m['startDate']!,
          endDate: m['endDate']!);
    });
  }
}
