import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:geo_monitor/dashboard_khaya/xd_dashboard.dart';
import 'package:geo_monitor/library/api/prefs_og.dart';
import 'package:geo_monitor/library/bloc/isolate_handler.dart';
import 'package:geo_monitor/library/functions.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../l10n/translation_handler.dart';
import '../../library/api/data_api_og.dart';
import '../../library/bloc/cloud_storage_bloc.dart';
import '../../library/bloc/fcm_bloc.dart';
import '../../library/bloc/geo_uploader.dart';
import '../../library/bloc/organization_bloc.dart';
import '../../library/bloc/project_bloc.dart';
import '../../library/bloc/refresh_bloc.dart';
import '../../library/cache_manager.dart';
import '../../library/data/user.dart';
import '../../library/generic_functions.dart';
import '../../library/geofence/the_great_geofencer.dart';
import '../../stitch/stitch_service.dart';

class DashboardMain extends StatefulWidget {
  const DashboardMain({
    Key? key,
    required this.dataApiDog,
    required this.fcmBloc,
    required this.organizationBloc,
    required this.projectBloc,
    required this.prefsOGx,
    required this.cacheManager,
    required this.dataHandler,
    required this.geoUploader,
    required this.cloudStorageBloc,
    required this.firebaseAuth, required this.stitchService, required this.refreshBloc,
  }) : super(key: key);
  final DataApiDog dataApiDog;
  final FCMBloc fcmBloc;
  final OrganizationBloc organizationBloc;
  final ProjectBloc projectBloc;
  final PrefsOGx prefsOGx;
  final CacheManager cacheManager;
  final IsolateDataHandler dataHandler;
  final GeoUploader geoUploader;
  final CloudStorageBloc cloudStorageBloc;
  final auth.FirebaseAuth firebaseAuth;
  final StitchService stitchService;
  final RefreshBloc refreshBloc;



  @override
  DashboardMainState createState() => DashboardMainState();
}

class DashboardMainState extends State<DashboardMain>
    with SingleTickerProviderStateMixin {
  User? user;
  static const mm = '🌎🌎🌎🌎🌎🌎DashboardMain: 🔵🔵🔵';
  bool initializing = false;
  String? initializingText, geoRunning, tapToReturn;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() async {
    setState(() {
      initializing = true;
    });
    try {
      //await initializer.initializeGeo();
      final sett = await prefsOGx.getSettings();
      initializingText =
          await translator.translate('initializing', sett.locale!);
      final gr = await translator.translate('geoRunning', sett.locale!);
      final tap = await translator.translate('tapToReturn', sett.locale!);
      geoRunning = gr.replaceAll('\$geo', 'Geo');
      tapToReturn = tap.replaceAll('\$geo', 'Geo');
      pp('$mm initializingText: $initializingText');
      setState(() {});
      await Future.delayed(const Duration(milliseconds: 100));
      await _getUser();
    } catch (e) {
      pp(e);
      if (mounted) {
        showToast(message: '$e', context: context);
      }
    }
    setState(() {
      initializing = false;
    });
  }

  Future _getUser() async {
    user = await prefsOGx.getUser();
    pp('$mm starting to cook with Gas!');
    setState(() {});
  }

  void _refreshWhileInBackground() async {
    dataHandler.getOrganizationData();

    pp('$mm Background data refresh completed');
  }

  @override
  Widget build(BuildContext context) {
    if (initializing) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: 360,
            height: 240,
            child: Card(
              elevation: 8,
              shape: getRoundedBorder(radius: 16),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 48,
                      ),
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 4,
                          backgroundColor: Colors.pink,
                        ),
                      ),
                      const SizedBox(
                        height: 48,
                      ),
                      Text(
                        initializingText == null
                            ? '...........'
                            : initializingText!,
                        style: myTextStyleSmall(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return user == null
          ? const SizedBox()
          : WillStartForegroundTask(
              onWillStart: () async {
                pp('\n\n$mm WillStartForegroundTask: onWillStart '
                    '🌎 what do we do now, Boss? 🌎🌎🌎🌎🌎🌎try data refresh? ... ');
               // _refreshWhileInBackground();
                return geofenceService.isRunningService;
              },
              androidNotificationOptions: AndroidNotificationOptions(
                  channelId: 'geofence_service_notification_channel',
                  channelName: 'Geofence Service Notification',
                  channelDescription:
                      'This notification appears when the geofence service is running in the background.',
                  channelImportance: NotificationChannelImportance.DEFAULT,
                  priority: NotificationPriority.DEFAULT,
                  isSticky: false,
                  playSound: false,
                  enableVibration: false,
                  showWhen: false),
              iosNotificationOptions: const IOSNotificationOptions(),
              notificationTitle:
                  geoRunning == null ? 'Geo service is running' : geoRunning!,
              notificationText:
                  tapToReturn == null ? 'Tap to return to Geo' : tapToReturn!,
              foregroundTaskOptions: const ForegroundTaskOptions(
                interval: 5000,
                isOnceEvent: false,
                autoRunOnBoot: true,
                allowWakeLock: true,
                allowWifiLock: true,
              ),
              callback: () {
                pp('$mm callback from WillStartForegroundTask fired! 🍎 WHY?');
              },
              child: ScreenTypeLayout(
                mobile: DashboardKhaya(
                  dataApiDog: widget.dataApiDog,
                  dataHandler: widget.dataHandler,
                  fcmBloc: widget.fcmBloc,
                  organizationBloc: widget.organizationBloc,
                  projectBloc: widget.projectBloc,
                  geoUploader: widget.geoUploader,
                  firebaseAuth: widget.firebaseAuth,
                  stitchService: widget.stitchService,
                  cloudStorageBloc: widget.cloudStorageBloc,
                  refreshBloc: widget.refreshBloc,
                  prefsOGx: widget.prefsOGx,
                  cacheManager: widget.cacheManager,
                ),
                tablet: OrientationLayoutBuilder(
                  portrait: (context) {
                    return DashboardKhaya(
                      dataApiDog: widget.dataApiDog,
                      dataHandler: widget.dataHandler,
                      fcmBloc: widget.fcmBloc,
                      projectBloc: widget.projectBloc,
                      prefsOGx: widget.prefsOGx,
                      geoUploader: widget.geoUploader,
                      cloudStorageBloc: widget.cloudStorageBloc,
                      firebaseAuth: widget.firebaseAuth,
                      organizationBloc: widget.organizationBloc,
                      refreshBloc: widget.refreshBloc,
                      cacheManager: widget.cacheManager,
                      stitchService: widget.stitchService,
                    );
                  },
                  landscape: (context) {
                    return DashboardKhaya(
                      dataApiDog: widget.dataApiDog,
                      dataHandler: widget.dataHandler,
                      fcmBloc: widget.fcmBloc,
                      organizationBloc: widget.organizationBloc,
                      projectBloc: widget.projectBloc,
                      firebaseAuth: widget.firebaseAuth,
                      geoUploader: widget.geoUploader,
                      cloudStorageBloc: widget.cloudStorageBloc,
                      stitchService: widget.stitchService,
                      prefsOGx: widget.prefsOGx,
                      refreshBloc: widget.refreshBloc,
                      cacheManager: widget.cacheManager,
                    );
                  },
                ),
              ),
            );
    }
  }
}
