import 'dart:async';
import 'dart:core';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geo_monitor/dashboard_khaya/project_list.dart';
import 'package:geo_monitor/dashboard_khaya/recent_event_list.dart';
import 'package:geo_monitor/dashboard_khaya/xd_header.dart';
import 'package:geo_monitor/library/api/prefs_og.dart';
import 'package:geo_monitor/library/bloc/organization_bloc.dart';
import 'package:geo_monitor/library/bloc/refresh_bloc.dart';
import 'package:geo_monitor/library/data/activity_model.dart';
import 'package:geo_monitor/library/data/audio.dart';
import 'package:geo_monitor/library/data/geofence_event.dart';
import 'package:geo_monitor/library/data/location_request.dart';
import 'package:geo_monitor/library/data/location_response.dart';
import 'package:geo_monitor/library/data/org_message.dart';
import 'package:geo_monitor/library/data/photo.dart';
import 'package:geo_monitor/library/data/project_polygon.dart';
import 'package:geo_monitor/library/data/project_position.dart';
import 'package:geo_monitor/library/data/user.dart';
import 'package:geo_monitor/library/data/video.dart';
import 'package:geo_monitor/library/functions.dart';
import 'package:geo_monitor/library/generic_functions.dart';
import 'package:geo_monitor/library/ui/camera/gio_video_player.dart';
import 'package:geo_monitor/library/ui/maps/project_map_mobile.dart';
import 'package:geo_monitor/library/ui/media/time_line/project_media_timeline.dart';
import 'package:geo_monitor/library/ui/project_list/gio_projects.dart';
import 'package:geo_monitor/library/users/edit/user_edit_main.dart';
import 'package:geo_monitor/library/users/list/geo_user_list.dart';
import 'package:geo_monitor/ui/activity/gio_activities.dart';
import 'package:geo_monitor/ui/audio/gio_audio_player.dart';
import 'package:geo_monitor/ui/dashboard/photo_frame.dart';
import 'package:geo_monitor/ui/intro/intro_main.dart';
import 'package:geo_monitor/ui/subscription/subscription_selection.dart';
import 'package:geo_monitor/utilities/transitions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:universal_platform/universal_platform.dart';

import '../l10n/translation_handler.dart';
import '../library/api/data_api_og.dart';
import '../library/bloc/cloud_storage_bloc.dart';
import '../library/bloc/fcm_bloc.dart';
import '../library/bloc/geo_uploader.dart';
import '../library/bloc/isolate_handler.dart';
import '../library/bloc/project_bloc.dart';
import '../library/bloc/theme_bloc.dart';
import '../library/cache_manager.dart';
import '../library/data/activity_type_enum.dart';
import '../library/data/data_bag.dart';
import '../library/data/project.dart';
import '../library/data/settings_model.dart';
import '../library/ui/loading_card.dart';
import '../library/ui/maps/geofence_map_tablet.dart';
import '../library/ui/maps/org_map_mobile.dart';
import '../library/ui/maps/project_polygon_map_mobile.dart';
import '../library/ui/settings/settings_main.dart';
import '../stitch/stitch_service.dart';
import 'member_list.dart';

class DashboardKhaya extends StatefulWidget {
  const DashboardKhaya(
      {Key? key,
      required this.dataApiDog,
      required this.fcmBloc,
      required this.organizationBloc,
      required this.projectBloc,
      required this.prefsOGx,
      required this.cacheManager,
      required this.dataHandler,
      required this.geoUploader,
      required this.cloudStorageBloc,
      required this.firebaseAuth,
      required this.stitchService})
      : super(key: key);

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

  @override
  State<DashboardKhaya> createState() => DashboardKhayaState();
}

class DashboardKhayaState extends State<DashboardKhaya> {
  var totalEvents = 0;
  var totalProjects = 0;
  var totalUsers = 0;
  User? user;
  String? dashboardText;
  String? eventsText, recentEventsText;
  String? projectsText;
  String? membersText, loadingDataText;
  bool busy = false;

  var projects = <Project>[];
  var events = <ActivityModel>[];
  var users = <User>[];
  late StreamSubscription<Photo> photoSubscriptionFCM;
  late StreamSubscription<Video> videoSubscriptionFCM;
  late StreamSubscription<Audio> audioSubscriptionFCM;
  late StreamSubscription<ProjectPosition> projectPositionSubscriptionFCM;
  late StreamSubscription<ProjectPolygon> projectPolygonSubscriptionFCM;
  late StreamSubscription<Project> projectSubscriptionFCM;
  late StreamSubscription<GeofenceEvent> geofenceSubscriptionFCM;
  late StreamSubscription<User> userSubscriptionFCM;
  late StreamSubscription<SettingsModel> settingsSubscriptionFCM;
  late StreamSubscription<String> killSubscriptionFCM;
  late StreamSubscription<bool> connectionSubscription;
  late StreamSubscription<GeofenceEvent> geofenceSubscription;

  //
  late StreamSubscription<Photo> photoSubscription;
  late StreamSubscription<Video> videoSubscription;
  late StreamSubscription<Audio> audioSubscription;
  late StreamSubscription<ProjectPosition> projectPositionSubscription;
  late StreamSubscription<ProjectPolygon> projectPolygonSubscription;
  late StreamSubscription<Project> projectSubscription;

  late StreamSubscription<SettingsModel> settingsSubscription;
  late StreamSubscription<ActivityModel> activitySubscription;

  late StreamSubscription<DataBag> dataBagSubscription;
  static const mm = '🥬🥬🥬🥬🥬🥬DashboardKhaya: 🥬🥬';

  @override
  void initState() {
    super.initState();
    _listenForFCM();
    _getUser();
  }

  @override
  void dispose() {
    settingsSubscription.cancel();
    activitySubscription.cancel();
    dataBagSubscription.cancel();
    audioSubscription.cancel();
    photoSubscription.cancel();
    videoSubscription.cancel();
    settingsSubscriptionFCM.cancel();
    userSubscriptionFCM.cancel();
    geofenceSubscription.cancel();
    projectPositionSubscription.cancel();
    projectPositionSubscriptionFCM.cancel();
    projectPolygonSubscription.cancel();
    projectPolygonSubscriptionFCM.cancel();
    super.dispose();
  }

  Future<void> _handleGeofenceEvent(GeofenceEvent event) async {
    pp('$mm _handleGeofenceEvent ... ');
    //events.insert(0, event);
    var settings = await prefsOGx.getSettings();
    var arr = await translator.translate('memberArrived', settings.locale!);


    if (event.projectName != null) {
      var arrivedAt = arr.replaceAll('\$project', event.projectName!);
      if (mounted) {
        var color = getTextColorForBackground(Theme.of(context).primaryColor);
        var brightness = MediaQuery.of(context).platformBrightness;
        bool isDarkMode = brightness == Brightness.dark;

        if (!isDarkMode) {
          color = Colors.white;
        }
        showToast(
            duration: const Duration(seconds: 5),
            backgroundColor: Theme.of(context).primaryColor,
            padding: 20,
            toastGravity: ToastGravity.TOP,
            textStyle: myTextStyleMediumWithColor(context, color),
            message: arrivedAt,
            context: context);
      }
    }
  }

  Future<void> _handleNewSettings(SettingsModel settings) async {
    Locale newLocale = Locale(settings.locale!);
    _setTexts();
    final m =
        LocaleAndTheme(themeIndex: settings.themeIndex!, locale: newLocale);
    themeBloc.themeStreamController.sink.add(m);
    _getData();
  }

  void _listenForFCM() async {
    var android = UniversalPlatform.isAndroid;
    var ios = UniversalPlatform.isIOS;
    // if (android || ios) {
    pp('$mm 🍎 🍎 _listen to FCM message streams ... 🍎 🍎');
    geofenceSubscriptionFCM =
        widget.fcmBloc.geofenceStream.listen((GeofenceEvent event) async {
      pp('$mm: 🍎geofenceSubscriptionFCM: 🍎 GeofenceEvent: '
          'user ${event.user!.name} arrived: ${event.projectName} ');
      _handleGeofenceEvent(event);
    });

    activitySubscription =
        widget.fcmBloc.activityStream.listen((ActivityModel event) async {
      pp('\n\n$mm: 🍎activitySubscription delivered 🍎 ActivityModel: '
          ' ${event.date} \n');
      events.insert(0, event);
      totalEvents++;
      if (mounted) {
        setState(() {});
      }
    });

    projectSubscriptionFCM =
        widget.fcmBloc.projectStream.listen((Project project) async {
      _getCachedData();
      if (mounted) {
        pp('$mm: 🍎 🍎 project arrived: ${project.name} ... 🍎 🍎');
        setState(() {});
      }
    });

    settingsSubscriptionFCM =
        widget.fcmBloc.settingsStream.listen((settings) async {
      pp('$mm: 🍎🍎 settingsSubscriptionFCM: settings arrived with themeIndex: ${settings.themeIndex}... 🍎🍎');
      _handleNewSettings(settings);
    });

    userSubscriptionFCM = widget.fcmBloc.userStream.listen((u) async {
      pp('$mm: 🍎 🍎 user arrived... 🍎 🍎');
      if (u.userId == user!.userId!) {
        user = u;
      }
      _getCachedData();
    });

    photoSubscriptionFCM = widget.fcmBloc.photoStream.listen((photo) async {
      pp('$mm: 🍎 🍎 photoSubscriptionFCM photo arrived... 🍎 🍎');
      _getCachedData();
    });

    videoSubscriptionFCM =
        widget.fcmBloc.videoStream.listen((Video message) async {
      pp('$mm: 🍎 🍎 videoSubscriptionFCM video arrived... 🍎 🍎');
      _getCachedData();
    });

    audioSubscriptionFCM =
        widget.fcmBloc.audioStream.listen((Audio message) async {
      pp('$mm: 🍎 🍎 audioSubscriptionFCM audio arrived... 🍎 🍎');
      _getCachedData();
    });

    projectPositionSubscriptionFCM = widget.fcmBloc.projectPositionStream
        .listen((ProjectPosition message) async {
      pp('$mm: 🍎 🍎 projectPositionSubscriptionFCM position arrived... 🍎 🍎');
      _getCachedData();
    });

    projectPolygonSubscriptionFCM = widget.fcmBloc.projectPolygonStream
        .listen((ProjectPolygon message) async {
      pp('$mm: 🍎 🍎 projectPolygonSubscriptionFCM polygon arrived... 🍎 🍎');
      _getCachedData();
      if (mounted) {}
    });

    dataBagSubscription =
        widget.organizationBloc.dataBagStream.listen((DataBag bag) async {
      pp('$mm: 🍎 🍎 dataBagStream bag arrived... 🍎 🍎');
      if (bag.projects != null) {
        projects = bag.projects!;
        totalProjects = projects.length;
      }
      if (bag.users != null) {
        users = bag.users!;
        totalUsers = users.length;
      }
      if (bag.activityModels != null) {
        events = bag.activityModels!;
        totalEvents = events.length;
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  var images = <Image>[];
  late SettingsModel settingsModel;

  void _getUser() async {
    user = await widget.prefsOGx.getUser();
    settingsModel = await widget.prefsOGx.getSettings();
    setState(() {});
    _setTexts();
    _getCachedData();
  }

  void _getCachedData() async {
    try {
      setState(() {
        busy = true;
      });
      pp('$mm _getCachedData .... ');
      final m =
          await getStartEndDates(numberOfDays: settingsModel.numberOfDays);
      users = await widget.organizationBloc.getUsers(
          organizationId: settingsModel.organizationId!, forceRefresh: false);
      projects = await widget.organizationBloc.getOrganizationProjects(
          organizationId: settingsModel.organizationId!, forceRefresh: false);

      events = await widget.organizationBloc.getOrganizationActivity(
          organizationId: settingsModel.organizationId!,
          hours: settingsModel.activityStreamHours!,
          forceRefresh: false);

      setState(() {
        busy = false;
      });
      // events = await organizationBloc.getCachedOrganizationActivity(
      //     organizationId: settingsModel.organizationId!, hours: settingsModel.activityStreamHours!);

      pp('$mm _getCachedData .... projects: ${projects.length} users: ${users.length} events: ${events.length}');
      totalEvents = events.length;
      totalUsers = users.length;
      totalProjects = projects.length;

      setState(() {
        busy = false;
      });
      // _getData(false);
    } catch (e) {
      if (mounted) {
        pp('$mm showSnack');
        showSnackBar(
            message: serverProblem == null ? 'Server Problem' : serverProblem!,
            context: context,
            backgroundColor: Theme.of(context).primaryColorDark,
            duration: const Duration(seconds: 15),
            padding: 16);
      }
    }
    setState(() {
      busy = false;
    });
  }

  void _getData() async {
    try {
      pp('$mm _getData ...................................... forceRefresh: $forceRefresh  ');
      setState(() {
        busy = true;
      });
      final m =
          await getStartEndDates(numberOfDays: settingsModel.numberOfDays!);
      final bag = await widget.organizationBloc.getOrganizationData(
          organizationId: user!.organizationId!,
          forceRefresh: true,
          startDate: m['startDate']!,
          endDate: m['endDate']!);
      projects = bag.projects!;
      events = await organizationBloc.getCachedOrganizationActivity(
          organizationId: settingsModel.organizationId!,
          hours: settingsModel.activityStreamHours!);
      users = bag.users!;

      totalEvents = events.length;
      totalUsers = users.length;
      totalProjects = projects.length;
    } catch (e) {
      if (mounted) {
        pp('$mm showSnack with error : $e');
        showSnackBar(
            message: serverProblem == null ? 'Server Problem' : serverProblem!,
            context: context,
            backgroundColor: Theme.of(context).primaryColorDark,
            duration: const Duration(seconds: 15),
            padding: 16);
      }
    }
    setState(() {
      busy = false;
    });
  }

  String? serverProblem, videoTitle;
  late String deviceType;
  late SettingsModel settings;

  void _setTexts() async {
    settings = await widget.prefsOGx.getSettings();
    loadingDataText =
        await translator.translate('loadingActivities', settings.locale!);
    dashboardText = await translator.translate('dashboard', settings.locale!);
    eventsText = await translator.translate('events', settings.locale!);
    projectsText = await translator.translate('projects', settings.locale!);
    membersText = await translator.translate('members', settings.locale!);
    videoTitle = await translator.translate('videos', settings.locale!);

    recentEventsText =
        await translator.translate('recentEvents', settings.locale!);
    serverProblem =
        await translator.translate('serverProblem', settings.locale!);

    deviceType = getThisDeviceType();
    setState(() {});
  }

  bool refreshRequired = false;

  void _navigateToSettings() {
    pp(' 🌀🌀🌀🌀 .................. _navigateToSettings to Settings ....');
    navigateWithScale(
        SettingsMain(
          dataHandler: widget.dataHandler,
          dataApiDog: widget.dataApiDog,
          prefsOGx: widget.prefsOGx,
          cacheManager: widget.cacheManager,
          project: null,
          fcmBloc: widget.fcmBloc,
          geoUploader: widget.geoUploader,
          cloudStorageBloc: widget.cloudStorageBloc,
          organizationBloc: widget.organizationBloc,
          projectBloc: widget.projectBloc,
        ),
        context);
  }

  void _navigateToActivities() {
    pp(' 🌀🌀🌀🌀 .................. _navigateToActivities  ....');
    navigateWithScale(
        GioActivities(
          fcmBloc: widget.fcmBloc,
          organizationBloc: widget.organizationBloc,
          projectBloc: widget.projectBloc,
          dataApiDog: widget.dataApiDog,
          geoUploader: widget.geoUploader,
          cloudStorageBloc: widget.cloudStorageBloc,
          project: null,
          onPhotoTapped: onPhotoTapped,
          onVideoTapped: onVideoTapped,
          onAudioTapped: onAudioTapped,
          onUserTapped: onUserTapped,
          onProjectTapped: onProjectTapped,
          onProjectPositionTapped: onProjectPositionTapped,
          onPolygonTapped: onPolygonTapped,
          onGeofenceEventTapped: onGeofenceEventTapped,
          onOrgMessage: onOrgMessage,
          onLocationResponse: onLocationResponse,
          onLocationRequest: onLocationRequest,
          prefsOGx: widget.prefsOGx,
          cacheManager: widget.cacheManager,
        ),
        context);
  }

  void navigateToIntro() {
    navigateWithScale(
        IntroMain(
          prefsOGx: widget.prefsOGx,
          dataApiDog: widget.dataApiDog,
          cacheManager: widget.cacheManager,
          isolateHandler: widget.dataHandler,
          fcmBloc: widget.fcmBloc,
          organizationBloc: widget.organizationBloc,
          geoUploader: widget.geoUploader,
          cloudStorageBloc: widget.cloudStorageBloc,
          stitchService: widget.stitchService,
          projectBloc: widget.projectBloc,
          firebaseAuth: widget.firebaseAuth,
        ),
        context);
  }

  void navigateToSubscription() {
    navigateWithScale(
        SubscriptionSelection(
          prefsOGx: widget.prefsOGx,
          dataApiDog: widget.dataApiDog,
          stitchService: widget.stitchService,
        ),
        context);
  }

  void _navigateToProjects() {
    pp(' 🌀🌀🌀🌀 .................. _navigateToSettings to Settings ....');

    navigateWithScale(
        GioProjects(
          projectBloc: widget.projectBloc,
          organizationBloc: widget.organizationBloc,
          prefsOGx: widget.prefsOGx,
          dataApiDog: widget.dataApiDog,
          cacheManager: widget.cacheManager,
          instruction: 0,
          fcmBloc: widget.fcmBloc,
          cloudStorageBloc: widget.cloudStorageBloc,
          geoUploader: widget.geoUploader,
        ),
        context);
  }

  void _navigateToMembers() {
    pp(' 🌀🌀🌀🌀 .................. _navigateToSettings to users ....');

    navigateWithScale(
        GioUserList(
            fcmBloc: widget.fcmBloc,
            organizationBloc: widget.organizationBloc,
            projectBloc: widget.projectBloc,
            prefsOGx: widget.prefsOGx,
            cacheManager: widget.cacheManager,
            geoUploader: widget.geoUploader,
            cloudStorageBloc: widget.cloudStorageBloc,
            dataApiDog: widget.dataApiDog),
        context);
  }

  void _onSearchTapped() {
    pp(' ✅✅✅ _onSearchTapped ...');
  }

  void _onDeviceUserTapped() {
    pp('✅✅✅ _onDeviceUserTapped ...');

    navigateWithScale(
        UserEditMain(
          user,
          fcmBloc: widget.fcmBloc,
          organizationBloc: widget.organizationBloc,
          projectBloc: widget.projectBloc,
          dataApiDog: widget.dataApiDog,
          prefsOGx: widget.prefsOGx,
          geoUploader: widget.geoUploader,
          cloudStorageBloc: widget.cloudStorageBloc,
          cacheManager: widget.cacheManager,
        ),
        context);
  }

  bool forceRefresh = false;

  void _onRefreshRequested() {
    pp(' ✅✅✅ .... _onRefreshRequested ... calling broadcastRefresh with true');
    // refreshBloc.broadcastRefresh();
    _getData();
  }

  void _onSettingsRequested() {
    pp(' ✅✅✅ _onSettingsRequested ...');
    _navigateToSettings();
  }

  void _onEventsSubtitleTapped() {
    pp('💚💚💚💚 events subtitle tapped');
    _navigateToActivities();
  }

  void _onProjectSubtitleTapped() {
    pp('💚💚💚💚 projects subtitle tapped');
    _navigateToProjects();
  }

  void _onUserSubtitleTapped() {
    pp('💚💚💚💚 users subtitle tapped');
    _navigateToMembers();
  }

  void _onEventTapped(ActivityModel act) async {
    pp('$mm 🌀🌀🌀🌀 _onEventTapped; activityModel: ${act.toJson()}\n');

    switch (act.activityType!) {
      case ActivityType.projectAdded:
        // TODO: Handle this case.
        break;
      case ActivityType.photoAdded:
        onPhotoTapped(act.photo!);
        break;
      case ActivityType.videoAdded:
        onVideoTapped(act.video!);
        break;
      case ActivityType.audioAdded:
        onAudioTapped(act.audio!);
        break;
      case ActivityType.messageAdded:
        onOrgMessage(act.orgMessage!);
        break;
      case ActivityType.userAddedOrModified:
        onUserTapped(act.user!);
        break;
      case ActivityType.positionAdded:
        onProjectPositionTapped(act.projectPosition!);
        break;
      case ActivityType.polygonAdded:
        onProjectPolygonTapped(act.projectPolygon!);
        break;
      case ActivityType.settingsChanged:
        onSettingsChanged(act.settingsModel!);
        break;
      case ActivityType.geofenceEventAdded:
        onGeofenceEventTapped(act.geofenceEvent!);
        break;
      case ActivityType.conditionAdded:
        // TODO: Handle this case.
        break;
      case ActivityType.locationRequest:
        onLocationRequest(act.locationRequest!);
        break;
      case ActivityType.locationResponse:
        onLocationResponse(act.locationResponse!);
        break;
      case ActivityType.kill:
        // TODO: Handle this case.
        break;
    }
  }

  onSettingsChanged(SettingsModel p1) {
    pp('🌀🌀🌀🌀 onSettingsChanged; ${p1.toJson()}');
    navigateWithScale(
        SettingsMain(
            dataHandler: widget.dataHandler,
            dataApiDog: widget.dataApiDog,
            prefsOGx: widget.prefsOGx,
            organizationBloc: widget.organizationBloc,
            cacheManager: widget.cacheManager,
            projectBloc: widget.projectBloc,
            geoUploader: widget.geoUploader,
            cloudStorageBloc: widget.cloudStorageBloc,
            fcmBloc: widget.fcmBloc),
        context);
  }

  onLocationRequest(LocationRequest p1) {
    pp('🌀🌀🌀🌀 onLocationRequest; ${p1.toJson()}');
    if (deviceType == 'phone') {}
  }

  onUserTapped(User p1) {
    pp('🌀🌀🌀🌀 onUserTapped; ${p1.toJson()}');

    navigateToUserEdit(p1);
  }

  void navigateToUserEdit(User? user) async {
    if (user != null) {
      if (user!.userType == UserType.fieldMonitor) {
        if (user.userId != user.userId!) {
          return;
        }
      }
    }
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 1),
            child: UserEditMain(
              user,
              fcmBloc: widget.fcmBloc,
              organizationBloc: widget.organizationBloc,
              projectBloc: widget.projectBloc,
              dataApiDog: widget.dataApiDog,
              geoUploader: widget.geoUploader,
              cloudStorageBloc: widget.cloudStorageBloc,
              prefsOGx: widget.prefsOGx,
              cacheManager: widget.cacheManager,
            )));
  }

  onLocationResponse(LocationResponse p1) {
    pp('🌀🌀🌀🌀 onLocationResponse; ${p1.toJson()}');
    if (deviceType == 'phone') {}
  }

  onPhotoTapped(Photo p1) {
    pp('🌀🌀🌀🌀 onPhotoTapped, deviceType: $deviceType ; ${p1.toJson()}');
    deviceType = getThisDeviceType();
    setState(() {
      photo = p1;
    });
    if (deviceType == 'phone') {
      if (mounted) {
        Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.scale,
                alignment: Alignment.topLeft,
                duration: const Duration(milliseconds: 1000),
                child: PhotoFrame(
                  photo: p1,
                  onMapRequested: (photo) {},
                  onRatingRequested: (photo) {},
                  elevation: 8.0,
                  cacheManager: widget.cacheManager,
                  dataApiDog: widget.dataApiDog,
                  geoUploader: widget.geoUploader,
                  cloudStorageBloc: widget.cloudStorageBloc,
                  onPhotoCardClose: () {},
                  translatedDate: '',
                  locale: settingsModel.locale!,
                  prefsOGx: widget.prefsOGx,
                  fcmBloc: widget.fcmBloc,
                  projectBloc: widget.projectBloc,
                  organizationBloc: widget.organizationBloc,
                )));
      }
    } else {
      setState(() {
        showPhoto = true;
        showAudio = false;
        playVideo = false;
      });
    }
  }

  onVideoTapped(Video p1) {
    pp('🌀🌀🌀🌀 onVideoTapped; ${p1.toJson()}');
    deviceType = getThisDeviceType();
    setState(() {
      video = p1;
    });
    if (deviceType == 'phone') {
      navigateWithSlide(
          PhoneVideoPlayer(
            video: p1,
            onCloseRequested: () {},
            dataApiDog: widget.dataApiDog,
            title: videoTitle!,
          ),
          context);
    } else {
      setState(() {
        playAudio = false;
        showPhoto = false;
        playVideo = true;
      });
    }
  }

  Audio? audio;
  Video? video;
  Photo? photo;

  onAudioTapped(Audio p1) {
    pp('🌀🌀🌀🌀 onAudioTapped; ${p1.toJson()}');
    setState(() {
      audio = p1;
    });
    deviceType = getThisDeviceType();
    if (deviceType == 'phone') {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (ctx) => GioAudioPlayer(
              cacheManager: widget.cacheManager,
              prefsOGx: widget.prefsOGx,
              audio: audio!,
              onCloseRequested: () {
                setState(() {
                  playAudio = false;
                });
              },
              dataApiDog: widget.dataApiDog)));
    } else {
      setState(() {
        showAudio = true;
        showPhoto = false;
        playVideo = false;
      });
    }
  }

  onProjectPositionTapped(ProjectPosition p1) async {
    pp('🌀🌀🌀🌀 onProjectPositionTapped; ${p1.toJson()}');
    final proj =
        await widget.cacheManager.getProjectById(projectId: p1.projectId!);

    if (mounted) {
      navigateWithScale(
          ProjectMapMobile(
            project: proj!,
          ),
          context);
    }
  }

  onProjectPolygonTapped(ProjectPolygon p1) async {
    pp('🌀🌀🌀🌀 onProjectPolygonTapped; ${p1.toJson()}');
    final proj =
        await widget.cacheManager.getProjectById(projectId: p1.projectId!);
    if (mounted) {
      navigateWithScale(
          ProjectPolygonMapMobile(
            project: proj!,
          ),
          context);
    }
  }

  onPolygonTapped(ProjectPolygon p1) async {
    pp('🌀🌀🌀🌀 onPolygonTapped; ${p1.toJson()}');
    final proj =
        await widget.cacheManager.getProjectById(projectId: p1.projectId!);
    if (mounted) {
      navigateWithScale(
          ProjectPolygonMapMobile(
            project: proj!,
          ),
          context);
    }
  }

  onGeofenceEventTapped(GeofenceEvent p1) {
    pp('🌀🌀🌀🌀 onGeofenceEventTapped; ${p1.toJson()}');

    navigateWithScale(
        GeofenceMap(
          geofenceEvent: p1,
        ),
        context);
  }

  onOrgMessage(OrgMessage p1) {
    pp('🌀🌀🌀🌀 onOrgMessage; ${p1.toJson()}');
    if (deviceType == 'phone') {}
  }

  void onProjectTapped(Project project) async {
    pp('🌀🌀🌀🌀 _onProjectTapped; navigate to timeLine: project: ${project.toJson()}');
    if (deviceType == 'phone') {}
    if (mounted) {
      navigateWithScale(
          ProjectMediaTimeline(
            projectBloc: widget.projectBloc,
            prefsOGx: widget.prefsOGx,
            project: project,
            fcmBloc: widget.fcmBloc,
            organizationBloc: widget.organizationBloc,
            cacheManager: widget.cacheManager,
            dataApiDog: widget.dataApiDog,
            geoUploader: widget.geoUploader,
            cloudStorageBloc: widget.cloudStorageBloc,
          ),
          context);
    }
  }

  void _onProjectsAcquired(int projects) async {
    pp('🌀🌀🌀🌀 _onProjectsAcquired; $projects');
    setState(() {
      totalProjects = projects;
    });
  }

  void _onEventsAcquired(int events) async {
    pp('🌀🌀🌀🌀 _onEventsAcquired; $events');
    setState(() {
      totalEvents = events;
    });
  }

  void _onUsersAcquired(int users) async {
    pp('🌀🌀🌀🌀 _onUsersAcquired; $users');
    setState(() {
      totalUsers = users;
    });
  }

  bool isPlaying = false;
  bool isPaused = false;
  bool isStopped = true;
  bool isBuffering = false;
  bool isLoading = false;

  bool playAudio = false;
  bool playVideo = false;
  bool showAudio = false;
  bool showPhoto = false;

  @override
  Widget build(BuildContext context) {
    var sigmaX = 12.0;
    var sigmaY = 12.0;

    var width = MediaQuery.of(context).size.width;
    final deviceType = getThisDeviceType();
    if (deviceType != 'phone') {}
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    var color = getTextColorForBackground(Theme.of(context).primaryColor);

    if (isDarkMode) {
      color = Theme.of(context).primaryColor;
    }
    return Scaffold(
        backgroundColor:
            isDarkMode ? Theme.of(context).canvasColor : Colors.brown[50],
        body: Stack(
          children: [
            ScreenTypeLayout.builder(
              mobile: (ctx) {
                return user == null
                    ? const SizedBox()
                    : RealDashboard(
                        projects: projects,
                        users: users,
                        locale: settings.locale!,
                        totalEvents: totalEvents,
                        totalProjects: totalProjects,
                        totalUsers: totalUsers,
                        sigmaX: sigmaX,
                        sigmaY: sigmaY,
                        user: user!,
                        width: width,
                        forceRefresh: forceRefresh,
                        membersText: membersText!,
                        projectsText: projectsText!,
                        eventsText: eventsText!,
                        dashboardText: dashboardText!,
                        recentEventsText: recentEventsText!,
                        cacheManager: widget.cacheManager,
                        prefsOGx: widget.prefsOGx,
                        dataApiDog: widget.dataApiDog,
                        geoUploader: widget.geoUploader,
                        cloudStorageBloc: widget.cloudStorageBloc,
                        projectBloc: widget.projectBloc,
                        onEventTapped: (event) {
                          _onEventTapped(event);
                        },
                        onProjectSubtitleTapped: () {
                          _onProjectSubtitleTapped();
                        },
                        onProjectsAcquired: (projects) {
                          _onProjectsAcquired(projects);
                        },
                        onProjectTapped: (project) {
                          onProjectTapped(project);
                        },
                        onUserSubtitleTapped: () {
                          _onUserSubtitleTapped();
                        },
                        onUsersAcquired: (users) {
                          _onUsersAcquired(users);
                        },
                        onUserTapped: (user) {
                          onUserTapped(user);
                        },
                        onEventsSubtitleTapped: () {
                          _onEventsSubtitleTapped();
                        },
                        onEventsAcquired: (events) {
                          _onEventsAcquired(events);
                        },
                        onRefreshRequested: () {
                          _onRefreshRequested();
                        },
                        onSearchTapped: () {
                          _onSearchTapped();
                        },
                        onSettingsRequested: () {
                          _onSettingsRequested();
                        },
                        onDeviceUserTapped: () {
                          _onDeviceUserTapped();
                        },
                        centerTopCards: true,
                        navigateToIntro: () {
                          navigateToIntro();
                        },
                        navigateToActivities: () {
                          _navigateToActivities();
                        },
                        organizationBloc: widget.organizationBloc,
                        fcmBloc: widget.fcmBloc,
                        onGioSubscriptionRequired: navigateToSubscription,
                      );
              },
              tablet: (ctx) {
                return Stack(
                  children: [
                    OrientationLayoutBuilder(
                      portrait: (context) {
                        return user == null
                            ? const SizedBox()
                            : RealDashboard(
                                topCardSpacing: 16.0,
                                centerTopCards: true,
                                projects: projects,
                                users: users,
                                fcmBloc: widget.fcmBloc,
                                navigateToActivities: () {
                                  _navigateToActivities();
                                },
                                cacheManager: widget.cacheManager,
                                prefsOGx: widget.prefsOGx,
                                dataApiDog: widget.dataApiDog,
                                organizationBloc: widget.organizationBloc,
                                geoUploader: widget.geoUploader,
                                cloudStorageBloc: widget.cloudStorageBloc,
                                projectBloc: widget.projectBloc,
                                locale: settings.locale!,
                                forceRefresh: forceRefresh,
                                totalEvents: totalEvents,
                                totalProjects: totalProjects,
                                totalUsers: totalUsers,
                                sigmaX: sigmaX,
                                sigmaY: sigmaY,
                                user: user!,
                                width: width,
                                membersText: membersText!,
                                projectsText: projectsText!,
                                eventsText: eventsText!,
                                dashboardText: dashboardText!,
                                recentEventsText: recentEventsText!,
                                onGioSubscriptionRequired:
                                    navigateToSubscription,
                                onEventTapped: (event) {
                                  _onEventTapped(event);
                                },
                                onProjectSubtitleTapped: () {
                                  _onProjectSubtitleTapped();
                                },
                                onProjectsAcquired: (projects) {
                                  _onProjectsAcquired(projects);
                                },
                                onProjectTapped: (project) {
                                  onProjectTapped(project);
                                },
                                onUserSubtitleTapped: () {
                                  _onUserSubtitleTapped();
                                },
                                onUsersAcquired: (users) {
                                  _onUsersAcquired(users);
                                },
                                onUserTapped: (user) {
                                  onUserTapped(user);
                                },
                                onEventsSubtitleTapped: () {
                                  _onEventsSubtitleTapped();
                                },
                                onEventsAcquired: (events) {
                                  _onEventsAcquired(events);
                                },
                                onRefreshRequested: () {
                                  _onRefreshRequested();
                                },
                                onSearchTapped: () {
                                  _onSearchTapped();
                                },
                                onSettingsRequested: () {
                                  _onSettingsRequested();
                                },
                                onDeviceUserTapped: () {
                                  _onDeviceUserTapped();
                                },
                                navigateToIntro: () {
                                  navigateToIntro();
                                },
                              );
                      },
                      landscape: (context) {
                        return user == null
                            ? const SizedBox()
                            : RealDashboard(
                                topCardSpacing: 16,
                                forceRefresh: forceRefresh,
                                projects: projects,
                                users: users,
                                fcmBloc: widget.fcmBloc,
                                navigateToActivities: () {
                                  _navigateToActivities();
                                },
                                cacheManager: widget.cacheManager,
                                prefsOGx: widget.prefsOGx,
                                dataApiDog: widget.dataApiDog,
                                organizationBloc: widget.organizationBloc,
                                geoUploader: widget.geoUploader,
                                cloudStorageBloc: widget.cloudStorageBloc,
                                projectBloc: widget.projectBloc,
                                totalEvents: totalEvents,
                                totalProjects: totalProjects,
                                totalUsers: totalUsers,
                                sigmaX: sigmaX,
                                sigmaY: sigmaY,
                                membersText: membersText!,
                                projectsText: projectsText!,
                                eventsText: eventsText!,
                                dashboardText: dashboardText!,
                                recentEventsText: recentEventsText!,
                                user: user!,
                                width: width,
                                navigateToIntro: () {
                                  navigateToIntro();
                                },
                                onEventTapped: (event) {
                                  _onEventTapped(event);
                                },
                                onProjectSubtitleTapped: () {
                                  _onProjectSubtitleTapped();
                                },
                                onProjectsAcquired: (projects) {
                                  _onProjectsAcquired(projects);
                                },
                                onProjectTapped: (project) {
                                  onProjectTapped(project);
                                },
                                onUserSubtitleTapped: () {
                                  _onUserSubtitleTapped();
                                },
                                onUsersAcquired: (users) {
                                  _onUsersAcquired(users);
                                },
                                onUserTapped: (user) {
                                  onUserTapped(user);
                                },
                                onEventsSubtitleTapped: () {
                                  _onEventsSubtitleTapped();
                                },
                                onEventsAcquired: (events) {
                                  _onEventsAcquired(events);
                                },
                                onRefreshRequested: () {
                                  _onRefreshRequested();
                                },
                                onSearchTapped: () {
                                  _onSearchTapped();
                                },
                                onSettingsRequested: () {
                                  _onSettingsRequested();
                                },
                                onDeviceUserTapped: () {
                                  _onDeviceUserTapped();
                                },
                                centerTopCards: true,
                                locale: settings.locale!,
                                onGioSubscriptionRequired:
                                    navigateToSubscription,
                              );
                      },
                    ),
                    playAudio
                        ? Positioned(
                            child: GioAudioPlayer(
                            cacheManager: widget.cacheManager,
                            prefsOGx: widget.prefsOGx,
                            audio: audio!,
                            onCloseRequested: () {},
                            dataApiDog: widget.dataApiDog,
                          ))
                        : const SizedBox()
                  ],
                );
              },
            ),
            busy
                ? Positioned(child: LoadingCard(loadingData: loadingDataText!))
                : const SizedBox(),
            showAudio
                ? Positioned(
                    left: 160,
                    right: 160,
                    top: 120,
                    child: SizedBox(
                      width: 440,
                      child: GioAudioPlayer(
                          cacheManager: widget.cacheManager,
                          prefsOGx: widget.prefsOGx,
                          audio: audio!,
                          onCloseRequested: () {
                            setState(() {
                              showAudio = false;
                            });
                          },
                          dataApiDog: dataApiDog),
                    ))
                : const SizedBox(),
            showPhoto
                ? Positioned(
                    left: 100,
                    right: 100,
                    top: 48,
                    child: SizedBox(
                      width: 600,
                      child: PhotoCard(
                        photo: photo!,
                        onMapRequested: (photo) {},
                        onRatingRequested: (photo) {},
                        elevation: 8.0,
                        onPhotoCardClose: () {
                          setState(() {
                            showPhoto = false;
                          });
                        },
                        translatedDate: '',
                      ),
                    ))
                : const SizedBox(),
            playVideo
                ? Positioned(
                    left: 100,
                    right: 100,
                    top: 48,
                    child: SizedBox(
                      width: 600,
                      child: GioVideoPlayer(
                        video: video!,
                        onCloseRequested: () {
                          setState(() {
                            playVideo = false;
                          });
                        },
                        width: 600,
                        dataApiDog: widget.dataApiDog,
                      ),
                    ))
                : const SizedBox(),
          ],
        ));
  }
}

class RealDashboard extends StatelessWidget {
  const RealDashboard({
    Key? key,
    required this.totalEvents,
    required this.totalProjects,
    required this.totalUsers,
    required this.sigmaX,
    required this.sigmaY,
    required this.user,
    required this.width,
    required this.onEventTapped,
    required this.onProjectSubtitleTapped,
    required this.onProjectsAcquired,
    required this.onProjectTapped,
    required this.onUserSubtitleTapped,
    required this.onUsersAcquired,
    required this.onUserTapped,
    required this.onEventsSubtitleTapped,
    required this.onEventsAcquired,
    required this.onRefreshRequested,
    required this.onSearchTapped,
    required this.onSettingsRequested,
    required this.onDeviceUserTapped,
    required this.dashboardText,
    required this.eventsText,
    required this.projectsText,
    required this.membersText,
    required this.forceRefresh,
    required this.projects,
    required this.users,
    this.topCardSpacing,
    required this.centerTopCards,
    required this.recentEventsText,
    required this.navigateToIntro,
    required this.locale,
    required this.navigateToActivities,
    required this.organizationBloc,
    required this.fcmBloc,
    required this.cacheManager,
    required this.dataApiDog,
    required this.prefsOGx,
    required this.geoUploader,
    required this.cloudStorageBloc,
    required this.projectBloc,
    required this.onGioSubscriptionRequired,
  }) : super(key: key);

  final Function onEventsSubtitleTapped;
  final Function(int) onEventsAcquired;
  final Function(ActivityModel) onEventTapped;
  final Function onProjectSubtitleTapped;
  final int totalEvents, totalProjects, totalUsers;
  final Function(int) onProjectsAcquired;
  final Function(Project) onProjectTapped;
  final Function onUserSubtitleTapped;
  final Function(int) onUsersAcquired;
  final Function(User) onUserTapped;
  final double sigmaX, sigmaY;
  final Function onRefreshRequested,
      onSearchTapped,
      onSettingsRequested,
      onDeviceUserTapped,
      onGioSubscriptionRequired;
  final User user;
  final double width;
  final String dashboardText,
      eventsText,
      projectsText,
      membersText,
      locale,
      recentEventsText;
  final bool forceRefresh;

  final List<Project> projects;
  final List<User> users;
  final double? topCardSpacing;
  final bool centerTopCards;
  final Function navigateToIntro, navigateToActivities;
  final OrganizationBloc organizationBloc;
  final FCMBloc fcmBloc;
  final CacheManager cacheManager;
  final DataApiDog dataApiDog;
  final PrefsOGx prefsOGx;
  final GeoUploader geoUploader;
  final CloudStorageBloc cloudStorageBloc;
  final ProjectBloc projectBloc;

  @override
  Widget build(BuildContext context) {
    final type = getThisDeviceType();
    final tabletActions = <Widget>[
      IconButton(
          onPressed: () {
            onRefreshRequested();
          },
          icon: Icon(
            Icons.refresh,
            color: Theme.of(context).primaryColor,
          )),
      IconButton(
          onPressed: () {
            onSettingsRequested();
          },
          icon: Icon(
            Icons.settings,
            color: Theme.of(context).primaryColor,
          )),
      const SizedBox(
        width: 8,
      ),
      GestureDetector(
        onTap: () {
          onDeviceUserTapped();
        },
        child: CircleAvatar(
          radius: 14,
          backgroundImage: NetworkImage(user.thumbnailUrl!),
        ),
      ),
      const SizedBox(
        width: 16,
      ),
    ];
    final phoneActions = <Widget>[
      PopupMenuButton(
        elevation: 8,
        itemBuilder: (context) {
          return [
            PopupMenuItem(
              value: 3,
              child: CircleAvatar(
                  radius: 24.0,
                  backgroundImage: NetworkImage(user.thumbnailUrl!)),
            ),
            PopupMenuItem(
                value: 1,
                child: Icon(
                  Icons.refresh,
                  color: Theme.of(context).primaryColor,
                )),
            PopupMenuItem(
                value: 2,
                child: Icon(
                  Icons.settings,
                  color: Theme.of(context).primaryColor,
                )),
            PopupMenuItem(
                value: 4,
                child: Icon(
                  Icons.subscriptions_sharp,
                  color: Theme.of(context).primaryColor,
                )),
          ];
        },
        onSelected: (index) {
          switch (index) {
            case 1:
              onRefreshRequested();
              break;
            case 2:
              onSettingsRequested();
              break;
            case 3:
              onDeviceUserTapped();
              break;
            case 4:
              onGioSubscriptionRequired();
              break;
          }
        },
      )
    ];
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    var backgroundColor = Theme.of(context).canvasColor;
    if ((!isDarkMode)) {
      backgroundColor = Colors.black;
    }

    return SizedBox(
      width: width,
      child: Stack(
        children: [
          Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 100),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            dashboardText,
                            style: myTextStyleLargePrimaryColor(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TopCardList(
                        organizationBloc: organizationBloc,
                        fcmBloc: fcmBloc,
                        dataApiDog: dataApiDog,
                        prefsOGx: prefsOGx,
                        cacheManager: cacheManager,
                        projectBloc: projectBloc,
                        geoUploader: geoUploader,
                        cloudStorageBloc: cloudStorageBloc,
                      ),
                      const SizedBox(height: 20),
                      SubTitleWidget(
                          title: eventsText,
                          onTapped: () {
                            onEventsSubtitleTapped();
                          },
                          number: totalEvents,
                          color: Colors.blue),
                      const SizedBox(height: 12),
                      RecentEventList(
                        organizationBloc: organizationBloc,
                        fcmBloc: fcmBloc,
                        prefsOGx: prefsOGx,
                        onEventTapped: (act) {
                          onEventTapped(act);
                        },
                        locale: locale,
                      ),
                      const SizedBox(
                        height: 36,
                      ),
                      SubTitleWidget(
                          title: projectsText,
                          onTapped: () {
                            pp('💚💚💚💚 project subtitle tapped');
                            onProjectSubtitleTapped();
                          },
                          number: totalProjects,
                          color: Colors.blue),
                      const SizedBox(
                        height: 12,
                      ),
                      ProjectListView(
                        projects: projects,
                        onProjectTapped: (project) {
                          onProjectTapped(project);
                        },
                      ),
                      const SizedBox(height: 36),
                      SubTitleWidget(
                          title: membersText,
                          onTapped: () {
                            onUserSubtitleTapped();
                          },
                          number: totalUsers,
                          color: Theme.of(context).indicatorColor),
                      const SizedBox(
                        height: 12,
                      ),
                      MemberList(
                        users: users,
                        onUserTapped: (user) {
                          onUserTapped(user);
                        },
                      ),
                      const SizedBox(height: 200),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            child: SizedBox(
              height: 80,
              child: AppBar(
                backgroundColor: backgroundColor,
                // flexibleSpace: ClipRect(
                //   child: BackdropFilter(
                //     filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
                //     child: Container(
                //       decoration:
                //           BoxDecoration(color: Colors.white.withOpacity(0.0)),
                //     ),
                //   ),
                // ),
                title: GioHeader(
                  navigateToIntro: () {
                    navigateToIntro();
                  },
                ),
                actions: type == 'phone' ? phoneActions : tabletActions,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SubTitleWidget extends StatelessWidget {
  const SubTitleWidget(
      {Key? key,
      required this.title,
      required this.onTapped,
      required this.number,
      required this.color})
      : super(key: key);

  final String title;
  final Function onTapped;
  final int number;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTapped();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            title,
            style: myTextStyleSubtitle(context),
          ),
          const SizedBox(
            width: 2,
          ),
          // MyBadge(number: number),
          SizedBox(
            width: 1,
            child: IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.arrow_forward_ios,
                  color: color,
                  size: 20,
                )),
          ),
          const SizedBox(
            width: 36,
          ),
          Text(
            '$number',
            style: myTextStyleMediumLargeWithOpacity(context, 0.25),
          )
        ],
      ),
    );
  }
}

class DashboardTopCard extends StatelessWidget {
  const DashboardTopCard(
      {Key? key,
      required this.number,
      required this.title,
      this.height,
      this.topPadding,
      this.textStyle,
      this.labelTitleStyle,
      required this.onTapped,
      this.width})
      : super(key: key);
  final int number;
  final String title;
  final double? height, topPadding, width;
  final TextStyle? textStyle, labelTitleStyle;
  final Function() onTapped;

  @override
  Widget build(BuildContext context) {
    // pp('primary color ${Theme.of(context).primaryColor} canvas color ${Theme.of(context).canvasColor}');

    Color color = Theme.of(context).primaryColor;
    if (Theme.of(context).canvasColor.value == const Color(0xff121212).value) {
      color = Theme.of(context).primaryColor;
    } else {
      color = Theme.of(context).canvasColor;
    }
    // var style = GoogleFonts.roboto(
    //     textStyle: Theme.of(context).textTheme.titleLarge,
    //     fontSize: 40,
    //     color: color,
    //     fontWeight: FontWeight.w900);

    var style2 = GoogleFonts.roboto(
        textStyle: Theme.of(context).textTheme.bodyMedium,
        fontSize: 12,
        color: color,
        fontWeight: FontWeight.normal);
    final fmt = NumberFormat.decimalPattern();
    final mNumber = fmt.format(number);

    return GestureDetector(
      onTap: () {
        onTapped();
      },
      child: Card(
        shape: getRoundedBorder(radius: 16),
        elevation: 4,
        child: SizedBox(
          height: height == null ? 104 : height!,
          width: width == null ? 128 : width!,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: topPadding == null ? 8 : topPadding!,
                ),
                Text(mNumber,
                    style: textStyle == null
                        ? myNumberStyleLargerPrimaryColor(context)
                        : textStyle!),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  title,
                  style: style2,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TopCardList extends StatefulWidget {
  const TopCardList(
      {Key? key,
      required this.organizationBloc,
      required this.fcmBloc,
      required this.prefsOGx,
      required this.projectBloc,
      required this.dataApiDog,
      required this.cacheManager,
      required this.geoUploader,
      required this.cloudStorageBloc})
      : super(key: key);

  final OrganizationBloc organizationBloc;
  final FCMBloc fcmBloc;
  final PrefsOGx prefsOGx;
  final ProjectBloc projectBloc;
  final DataApiDog dataApiDog;
  final CacheManager cacheManager;
  final GeoUploader geoUploader;
  final CloudStorageBloc cloudStorageBloc;

  @override
  State<TopCardList> createState() => TopCardListState();
}

class TopCardListState extends State<TopCardList> {
  final mm = '🛎🛎🛎🛎TopCardList: 🐸';
  late StreamSubscription<DataBag> bagSub;
  late StreamSubscription<SettingsModel> settingsSub;
  late StreamSubscription<ActivityModel> actSub;
  late StreamSubscription<bool> refreshSub;

  bool busy = false;

  // DataBag? dataBag;
  var eventsText = 'Events',
      projectsText = 'Projects',
      membersText = 'Members',
      photosText = 'Photos',
      videosText = 'Videos',
      audiosText = 'Audios',
      locationsText = 'Locations',
      areasText = 'Areas';
  var topCardSpacing = 24.0;

  var events = 0,
      projects = 0,
      members = 0,
      photos = 0,
      videos = 0,
      audios = 0,
      locations = 0,
      areas = 0;

  @override
  void initState() {
    super.initState();
    _setTexts();
    _getData(false);
    _listen();
  }

  int cnt = 0;

  void _getData(bool forceRefresh) async {
    pp('$mm _getData ... forceRefresh: $forceRefresh');
    try {
      setState(() {
        busy = true;
      });

      final sett = await widget.prefsOGx.getSettings();
      final m = await getStartEndDates(numberOfDays: sett.numberOfDays!);

      final bag = await widget.organizationBloc.getOrganizationData(
          organizationId: sett.organizationId!,
          forceRefresh: forceRefresh,
          startDate: m['startDate']!,
          endDate: m['endDate']!);

      _setTotals(bag);
    } catch (e) {
      pp(e);
    }

    if (mounted) {
      pp('$mm _getData ; setting state ..');
      setState(() {
        busy = false;
      });
    }
  }

  late SettingsModel settings;

  Future _setTexts() async {
    settings = await prefsOGx.getSettings();
    photosText = await translator.translate('photos', settings.locale!);
    videosText = await translator.translate('videos', settings.locale!);
    audiosText = await translator.translate('audioClips', settings.locale!);
    locationsText = await translator.translate('locations', settings.locale!);
    areasText = await translator.translate('areas', settings.locale!);
    projectsText = await translator.translate('projects', settings.locale!);
    membersText = await translator.translate('members', settings.locale!);
    eventsText = await translator.translate('events', settings.locale!);

    if (mounted) {
      setState(() {});
    }
  }

  void _listen() {
    refreshSub = refreshBloc.refreshStream.listen((event) {
      pp('$mm refreshStream delivered a command, call getData with forceRefresh = true ... ');
      _getData(true);
    });

    bagSub = widget.organizationBloc.dataBagStream.listen((bag) {
      pp('$mm Stream delivered a bag, set ui ... ');
      _setTotals(bag);
      if (mounted) {
        setState(() {});
      }
    });

    settingsSub = widget.fcmBloc.settingsStream.listen((event) async {
      await _setTexts();
      _getData(true);
    });

    actSub = widget.fcmBloc.activityStream.listen((act) {
      setState(() {
        events++;
      });
      switch (act.activityType) {
        case ActivityType.projectAdded:
          setState(() {
            projects++;
          });
          break;
        case ActivityType.photoAdded:
          setState(() {
            photos++;
          });
          break;
        case ActivityType.videoAdded:
          setState(() {
            videos++;
          });
          break;
        case ActivityType.audioAdded:
          setState(() {
            audios++;
          });
          break;
        case ActivityType.messageAdded:
          // TODO: Handle this case.
          break;
        case ActivityType.userAddedOrModified:
          // TODO: Handle this case.
          break;
        case ActivityType.positionAdded:
          setState(() {
            locations++;
          });
          break;
        case ActivityType.polygonAdded:
          setState(() {
            areas++;
          });
          break;
        case ActivityType.settingsChanged:
          //_getData(true);
          break;
        case ActivityType.geofenceEventAdded:
          // TODO: Handle this case.
          break;
        case ActivityType.conditionAdded:
          // TODO: Handle this case.
          break;
        case ActivityType.locationRequest:
          // TODO: Handle this case.
          break;
        case ActivityType.locationResponse:
          // TODO: Handle this case.
          break;
        case ActivityType.kill:
          // TODO: Handle this case.
          break;
        default:
          break;
      }
    });
  }

  void _setTotals(DataBag dataBag) {
    events = dataBag.activityModels!.length;
    projects = dataBag.projects!.length;
    members = dataBag.users!.length;
    photos = dataBag.photos!.length;
    videos = dataBag.videos!.length;
    audios = dataBag.audios!.length;
    locations = dataBag.projectPositions!.length;
    areas = dataBag.projectPolygons!.length;
    pp('$mm dataBag totals extracted .... ');
  }

  @override
  void dispose() {
    bagSub.cancel();
    settingsSub.cancel();
    super.dispose();
  }

  void _navigateToProjects() {
    pp(' 🌀🌀🌀🌀 .................. _navigateToProjects  ....');
    if (mounted) {
      navigateWithScale(
          GioProjects(
            projectBloc: widget.projectBloc,
            organizationBloc: widget.organizationBloc,
            prefsOGx: widget.prefsOGx,
            dataApiDog: widget.dataApiDog,
            cacheManager: widget.cacheManager,
            instruction: 0,
            fcmBloc: widget.fcmBloc,
            geoUploader: widget.geoUploader,
            cloudStorageBloc: widget.cloudStorageBloc,
          ),
          context);
    }
  }

  void _navigateToMembers() {
    pp(' 🌀🌀🌀🌀 .................. _navigateToMembers  ....');
    if (mounted) {
      navigateWithScale(
          GioUserList(
              fcmBloc: widget.fcmBloc,
              organizationBloc: widget.organizationBloc,
              projectBloc: widget.projectBloc,
              prefsOGx: widget.prefsOGx,
              cacheManager: widget.cacheManager,
              geoUploader: widget.geoUploader,
              cloudStorageBloc: widget.cloudStorageBloc,
              dataApiDog: widget.dataApiDog),
          context);
    }
  }

  void _navigateToMap() {
    pp(' 🌀🌀🌀🌀 .................. _navigateToMap ....');
    if (mounted) {
      navigateWithScale(
          OrganizationMap(
            organizationBloc: widget.organizationBloc,
            prefsOGx: widget.prefsOGx,
          ),
          context);
    }
  }

  void _navigateToTimeline() {
    pp(' 🌀🌀🌀🌀 .................. _navigateToTimeline  ....');
    if (mounted) {
      navigateWithScale(
          ProjectMediaTimeline(
              projectBloc: widget.projectBloc,
              prefsOGx: widget.prefsOGx,
              organizationBloc: widget.organizationBloc,
              cacheManager: widget.cacheManager,
              dataApiDog: widget.dataApiDog,
              geoUploader: widget.geoUploader,
              cloudStorageBloc: widget.cloudStorageBloc,
              fcmBloc: widget.fcmBloc),
          context);
    }
  }

  void _navigateToActivities() async {
    pp(' 🌀🌀🌀🌀 .................. _navigateToActivities  ....');
    final deviceScreenType = getThisDeviceType();
    if (mounted) {
      navigateWithScale(
          GioActivities(
            fcmBloc: widget.fcmBloc,
            organizationBloc: widget.organizationBloc,
            projectBloc: widget.projectBloc,
            dataApiDog: widget.dataApiDog,
            geoUploader: widget.geoUploader,
            cloudStorageBloc: widget.cloudStorageBloc,
            project: null,
            onPhotoTapped: (p) {
              pp('$mm navigateWithScale ... onPhotoTapped');
              if ((deviceScreenType == 'phone')) {
                navigateWithScale(
                    PhotoFrame(
                        photo: p,
                        onMapRequested: (p) {},
                        onRatingRequested: (p) {},
                        elevation: 0,
                        onPhotoCardClose: (p) {},
                        translatedDate: 'translatedDate',
                        locale: settings.locale!,
                        cacheManager: cacheManager,
                        dataApiDog: dataApiDog,
                        prefsOGx: prefsOGx,
                        fcmBloc: fcmBloc,
                        projectBloc: projectBloc,
                        organizationBloc: organizationBloc,
                        geoUploader: geoUploader,
                        cloudStorageBloc: cloudStorageBloc),
                    context);
              }
            },
            onVideoTapped: (p) {
              pp('$mm navigateWithScale ... onVideoTapped');
            },
            onAudioTapped: (p) {
              pp('$mm navigateWithScale ... onAudioTapped');
            },
            onUserTapped: (p) {},
            onProjectTapped: (p) {},
            onProjectPositionTapped: (p) {},
            onPolygonTapped: (p) {},
            onGeofenceEventTapped: (p) {},
            onOrgMessage: (p) {},
            onLocationResponse: (p) {},
            onLocationRequest: (p) {},
            prefsOGx: widget.prefsOGx,
            cacheManager: widget.cacheManager,
          ),
          context);
    }
  }

  bool showPhoto = false;
  bool showVideo = false;
  bool showAudio = false;

  @override
  Widget build(BuildContext context) {
    final type = getThisDeviceType();
    var padding1 = 16.0;
    var padding2 = 48.0;
    if (type == 'phone') {
      padding1 = 8;
      padding2 = 24;
    }
    // if (dataBag == null) {
    //   return const Center(
    //     child: SizedBox(
    //       width: 12,
    //       height: 12,
    //       child: CircularProgressIndicator(
    //         strokeWidth: 4,
    //         backgroundColor: Colors.pink,
    //       ),
    //     ),
    //   );
    // }
    return Stack(children: [
      SizedBox(
        height: 140,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: busy
              ? const Center(
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      backgroundColor: Colors.greenAccent,
                    ),
                  ),
                )
              : ListView(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  children: [
                    DashboardTopCard(
                        width: events > 999 ? 128 : 108,
                        number: events,
                        title: eventsText,
                        onTapped: () {
                          _onTapped(0);
                        }),
                    SizedBox(
                      width: padding1,
                    ),
                    DashboardTopCard(
                        width: projects > 999 ? 128 : 108,
                        number: projects,
                        title: projectsText,
                        onTapped: () {
                          _onTapped(1);
                        }),
                    SizedBox(
                      width: padding1,
                    ),
                    DashboardTopCard(
                        width: members > 999 ? 128 : 108,
                        number: members,
                        title: membersText,
                        onTapped: () {
                          _onTapped(2);
                        }),
                    SizedBox(
                      width: padding2,
                    ),
                    DashboardTopCard(
                        width: photos > 999 ? 128 : 108,
                        textStyle:
                            myNumberStyleLargerPrimaryColorLight(context),
                        number: photos,
                        title: photosText,
                        onTapped: () {
                          _onTapped(3);
                        }),
                    SizedBox(
                      width: padding1,
                    ),
                    DashboardTopCard(
                        textStyle:
                            myNumberStyleLargerPrimaryColorLight(context),
                        width: videos > 999 ? 128 : 108,
                        number: videos,
                        title: videosText,
                        onTapped: () {
                          _onTapped(4);
                        }),
                    SizedBox(
                      width: padding1,
                    ),
                    DashboardTopCard(
                        width: audios > 999 ? 128 : 108,
                        textStyle:
                            myNumberStyleLargerPrimaryColorLight(context),
                        number: audios,
                        title: audiosText,
                        onTapped: () {
                          _onTapped(5);
                        }),
                    SizedBox(
                      width: padding2,
                    ),
                    DashboardTopCard(
                        textStyle: myNumberStyleLargerPrimaryColorDark(context),
                        width: locations > 999 ? 128 : 108,
                        number: locations,
                        title: locationsText,
                        onTapped: () {
                          _onTapped(6);
                        }),
                    SizedBox(
                      width: padding1,
                    ),
                    DashboardTopCard(
                        textStyle: myNumberStyleLargerPrimaryColorDark(context),
                        width: areas > 999 ? 128 : 108,
                        number: areas,
                        title: areasText,
                        onTapped: () {
                          _onTapped(7);
                        }),
                  ],
                ),
        ),
      ),
      showAudio
          ? const Positioned(child: Text('show audio'))
          : const SizedBox(),
      showPhoto
          ? const Positioned(child: Text('show photo'))
          : const SizedBox(),
      showVideo
          ? const Positioned(child: Text('show video'))
          : const SizedBox(),
    ]);
  }

  void _onTapped(int id) {
    pp('$mm top card tapped: id: $id ............');
    switch (id) {
      case 0:
        _navigateToActivities();
        break;
      case 1:
        _navigateToProjects();
        break;
      case 2:
        _navigateToMembers();
        break;
      case 3:
        _navigateToTimeline();
        break;
      case 4:
        _navigateToTimeline();
        break;
      case 5:
        _navigateToTimeline();
        break;
      case 6:
        _navigateToMap();
        break;
      case 7:
        _navigateToMap();
        break;
    }
  }
}

class PhoneVideoPlayer extends StatelessWidget {
  const PhoneVideoPlayer(
      {Key? key,
      required this.video,
      required this.onCloseRequested,
      required this.dataApiDog,
      this.width,
      required this.title})
      : super(key: key);

  final Video video;
  final Function onCloseRequested;
  final DataApiDog dataApiDog;
  final double? width;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            title,
            style: myTextStyleMediumLarge(context),
          ),
        ),
        body: GioVideoPlayer(
          video: video,
          onCloseRequested: () {
            onCloseRequested();
          },
          width: width == null ? 600 : width!,
          dataApiDog: dataApiDog,
        ),
      ),
    );
  }
}
