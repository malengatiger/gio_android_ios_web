import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geo_monitor/library/api/prefs_og.dart';
import 'package:geo_monitor/library/cache_manager.dart';
import 'package:geo_monitor/library/data/activity_model.dart';
import 'package:geo_monitor/library/data/geofence_event.dart';
import 'package:geo_monitor/library/data/location_response.dart';
import 'package:geo_monitor/library/data/org_message.dart';
import 'package:geo_monitor/library/data/settings_model.dart';
import 'package:geo_monitor/library/ui/camera/video_player_mobile.dart';
import 'package:geo_monitor/library/ui/maps/location_response_map.dart';
import 'package:geo_monitor/ui/activity/activity_list_og.dart';
import 'package:geo_monitor/ui/audio/audio_player_og.dart';
import 'package:geo_monitor/ui/dashboard/user_dashboard.dart';
import 'package:page_transition/page_transition.dart';
import 'package:universal_platform/universal_platform.dart';

import '../../l10n/translation_handler.dart';
import '../../library/bloc/fcm_bloc.dart';
import '../../library/bloc/theme_bloc.dart';
import '../../library/data/audio.dart';
import '../../library/data/photo.dart';
import '../../library/data/project.dart';
import '../../library/data/project_polygon.dart';
import '../../library/data/project_position.dart';
import '../../library/data/user.dart';
import '../../library/data/video.dart';
import '../../library/functions.dart';
import '../../library/generic_functions.dart';
import '../../library/ui/maps/geofence_map_tablet.dart';
import '../../library/ui/maps/photo_map_tablet.dart';
import '../../library/ui/maps/project_map_main.dart';
import '../../library/ui/maps/project_map_mobile.dart';
import '../../library/ui/maps/project_polygon_map_mobile.dart';

class GeoActivityMobile extends StatefulWidget {
  const GeoActivityMobile({
    Key? key,
    this.user,
    this.project,
  }) : super(key: key);

  final User? user;
  final Project? project;

  @override
  GeoActivityMobileState createState() => GeoActivityMobileState();
}

class GeoActivityMobileState extends State<GeoActivityMobile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late StreamSubscription<Photo> photoSubscriptionFCM;
  late StreamSubscription<Video> videoSubscriptionFCM;
  late StreamSubscription<Audio> audioSubscriptionFCM;
  late StreamSubscription<ProjectPosition> projectPositionSubscriptionFCM;
  late StreamSubscription<ProjectPolygon> projectPolygonSubscriptionFCM;
  late StreamSubscription<Project> projectSubscriptionFCM;
  late StreamSubscription<SettingsModel> settingsSubscriptionFCM;
  late StreamSubscription<GeofenceEvent> geofenceSubscriptionFCM;
  late StreamSubscription<ActivityModel> activitySubscriptionFCM;

  ScrollController listScrollController = ScrollController();

  final mm = '❇️❇️❇️❇️❇️ GeoActivityMobile: ';

  bool busy = false;
  SettingsModel? settingsModel;
  String? arrivedAt;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _setTexts();
    _listenForFCM();
  }

  Future _setTexts() async {
    settingsModel = await prefsOGx.getSettings();
      arrivedAt = await translator.translate('memberArrived', settingsModel!.locale!);

  }

  int count = 0;

  void _listenForFCM() async {
    var android = UniversalPlatform.isAndroid;
    var ios = UniversalPlatform.isIOS;
    if (android || ios) {
      pp('$mm 🍎🍎 _listen to FCM message streams ... 🍎🍎 '
          'geofence stream via geofenceSubscriptionFCM...');

      geofenceSubscriptionFCM =
          fcmBloc.geofenceStream.listen((GeofenceEvent event) async {
        pp('$mm: 🍎geofenceSubscriptionFCM: 🍎 GeofenceEvent: '
            'user ${event.user!.name} arrived: ${event.projectName} ');
        _handleGeofenceEvent(event);

      });
      settingsSubscriptionFCM =
          fcmBloc.settingsStream.listen((event) {
            _handleNewSettings(event);
          });
    } else {
      pp('App is running on the Web 👿👿👿firebase messaging is OFF 👿👿👿');
    }
  }
  Future<void> _handleNewSettings(SettingsModel settings) async {
    Locale newLocale = Locale(settings.locale!);
    await _setTexts();
    final m = LocaleAndTheme(themeIndex: settings!.themeIndex!,
        locale: newLocale);
    themeBloc.themeStreamController.sink.add(m);
    settingsModel = settings;
    if (mounted) {
      setState(() {

      });
    }
  }

  Future<void> _handleGeofenceEvent(GeofenceEvent event) async {
    pp('$mm _handleGeofenceEvent ...');
    var settings = await prefsOGx.getSettings();
    var arr = await translator.translate('memberArrived', settings.locale!);
    if (event.projectName != null) {
      var arrivedAt = arr.replaceAll('\$project', event.projectName!);
      if (mounted) {
        showToast(
            duration: const Duration(seconds: 5),
            backgroundColor: Theme
                .of(context)
                .primaryColor,
            padding: 20,
            textStyle: myTextStyleMedium(context),
            message: arrivedAt,
            context: context);
      }
    }
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToPositionsMap(ProjectPosition position) async {
    var proj =
        await cacheManager.getProjectById(projectId: position.projectId!);
    if (proj != null) {
      if (mounted) {
        Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.scale,
                alignment: Alignment.topLeft,
                duration: const Duration(seconds: 1),
                child: ProjectMapMobile(
                  project: proj,
                )));
      }
    }
  }

  void _navigateToPolygonsMap(ProjectPolygon polygon) async {
    var proj = await cacheManager.getProjectById(projectId: polygon.projectId!);
    if (proj != null) {
      if (mounted) {
        Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.scale,
                alignment: Alignment.topLeft,
                duration: const Duration(seconds: 1),
                child: ProjectPolygonMapMobile(
                  project: proj,
                )));
      }
    }
  }

  void _navigateToGeofenceMap(GeofenceEvent event) async {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 1),
            child: GeofenceMapTablet(
              geofenceEvent: event,
            )));
  }

  void _navigateToPhotoMap(Photo photo) {
    pp('$mm _navigateToPhotoMap ...');

    if (mounted) {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.scale,
              alignment: Alignment.topLeft,
              duration: const Duration(milliseconds: 1000),
              child: PhotoMap(
                photo: photo,
              )));
    }
  }

  void _navigateToProjectMap(Project project) {
    pp('$mm _navigateToProjectMap ...');

    if (mounted) {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.scale,
              alignment: Alignment.topLeft,
              duration: const Duration(milliseconds: 1000),
              child: ProjectMapMain(
                project: project,
              )));
    }
  }

  void _navigateToLocationResponseMap(LocationResponse response) {
    pp('$mm _navigateToLocationResponseMap ...');

    if (mounted) {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.scale,
              alignment: Alignment.topLeft,
              duration: const Duration(milliseconds: 1000),
              child: LocationResponseMap(
                locationResponse: response,
              )));
    }
  }

  void _navigateToVideo(Video video) {
    pp('$mm _navigateToVideo ...');

    if (mounted) {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.scale,
              alignment: Alignment.topLeft,
              duration: const Duration(milliseconds: 1000),
              child: VideoPlayerMobilePage(
                video: video,
              )));
    }
  }

  void _navigateToAudio(Audio audio) {
    pp('$mm _navigateToAudio ...');

    if (mounted) {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.scale,
              alignment: Alignment.topLeft,
              duration: const Duration(milliseconds: 1000),
              child: AudioPlayerOG(
                audio: audio,
                onCloseRequested: () {
                  Navigator.of(context).pop();
                },
              )));
    }
  }

  void _navigateToUserDashboard(User user) {
    pp('$mm _navigateToUserDashboard ...');

    if (mounted) {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.scale,
              alignment: Alignment.topLeft,
              duration: const Duration(milliseconds: 1000),
              child: UserDashboard(
                user: user,
              )));
    }
  }

  void _navigateToMessage(OrgMessage message) {
    pp('$mm _navigateToUserDashboard ...');

    if (mounted) {
      // Navigator.push(
      //     context,
      //     PageTransition(
      //         type: PageTransitionType.scale,
      //         alignment: Alignment.topLeft,
      //         duration: const Duration(milliseconds: 1000),
      //         child: MessageMobile(
      //           user: user,
      //         )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ActivityListOg(
        user: widget.user,
        project: widget.project,
        onPhotoTapped: (photo) {
          _navigateToPhotoMap(photo);
        },
        onVideoTapped: (video) {
          _navigateToVideo(video);
        },
        onAudioTapped: (audio) {
          _navigateToAudio(audio);
        },
        onUserTapped: (user) {
          _navigateToUserDashboard(user);
        },
        onProjectTapped: (project) {},
        onProjectPositionTapped: (projectPosition) {
          _navigateToPositionsMap(projectPosition);
        },
        onPolygonTapped: (projectPolygon) {
          _navigateToPolygonsMap(projectPolygon);
        },
        onGeofenceEventTapped: (geofenceEvent) {
          _navigateToGeofenceMap(geofenceEvent);
        },
        onOrgMessage: (orgMessage) {},
        onLocationResponse: (locationResponse) {
          _navigateToLocationResponseMap(locationResponse);
        },
        onLocationRequest: (locationRequest) {},
      ),
    );
  }
}
