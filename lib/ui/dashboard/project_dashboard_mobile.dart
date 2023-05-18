import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geo_monitor/library/api/data_api_og.dart';
import 'package:geo_monitor/library/cache_manager.dart';
import 'package:geo_monitor/library/data/geofence_event.dart';
import 'package:geo_monitor/library/data/settings_model.dart';
import 'package:geo_monitor/library/ui/maps/project_map_mobile.dart';
import 'package:geo_monitor/library/ui/media/time_line/project_media_timeline.dart';
import 'package:geo_monitor/ui/dashboard/project_dashboard_grid.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:universal_platform/universal_platform.dart';

import '../../l10n/translation_handler.dart';
import '../../library/api/prefs_og.dart';
import '../../library/bloc/cloud_storage_bloc.dart';
import '../../library/bloc/connection_check.dart';
import '../../library/bloc/fcm_bloc.dart';
import '../../library/bloc/geo_uploader.dart';
import '../../library/bloc/organization_bloc.dart';
import '../../library/bloc/project_bloc.dart';
import '../../library/bloc/theme_bloc.dart';
import '../../library/data/audio.dart';
import '../../library/data/photo.dart';
import '../../library/data/project.dart';
import '../../library/data/project_polygon.dart';
import '../../library/data/project_position.dart';
import '../../library/data/user.dart';
import '../../library/data/video.dart';
import '../../library/emojis.dart';
import '../../library/functions.dart';
import '../activity/geo_activity.dart';

class ProjectDashboardMobile extends StatefulWidget {
  const ProjectDashboardMobile({
    Key? key,
    this.user,
    required this.project,
    required this.projectBloc,
    required this.prefsOGx,
    required this.organizationBloc,
    required this.dataApiDog,
    required this.cacheManager, required this.fcmBloc, required this.geoUploader, required this.cloudStorageBloc,
  }) : super(key: key);
  final Project project;
  final User? user;
  final ProjectBloc projectBloc;
  final PrefsOGx prefsOGx;
  final OrganizationBloc organizationBloc;
  final DataApiDog dataApiDog;
  final CacheManager cacheManager;
  final FCMBloc fcmBloc;
  final GeoUploader geoUploader;
  final CloudStorageBloc cloudStorageBloc;

  @override
  ProjectDashboardMobileState createState() => ProjectDashboardMobileState();
}

class ProjectDashboardMobileState extends State<ProjectDashboardMobile>
    with TickerProviderStateMixin {
  late AnimationController _gridViewAnimationController;

  late StreamSubscription<GeofenceEvent> geofenceSubscription;
  late StreamSubscription<Photo> photoSubscriptionFCM;
  late StreamSubscription<Video> videoSubscriptionFCM;
  late StreamSubscription<Audio> audioSubscriptionFCM;
  late StreamSubscription<ProjectPosition> projectPositionSubscriptionFCM;
  late StreamSubscription<ProjectPolygon> projectPolygonSubscriptionFCM;
  late StreamSubscription<Project> projectSubscriptionFCM;
  late StreamSubscription<User> userSubscriptionFCM;
  late StreamSubscription<SettingsModel> settingsSubscriptionFCM;

  late StreamSubscription<String> killSubscriptionFCM;

  var busy = false;

  User? user;
  DashboardStrings? dashboardStrings;

  static const mm = '🔆🔆🔆🔆🔆🔆🔆🔆 ProjectDashboardMobile: 🔆🔆';
  bool networkAvailable = false;
  final dur = 600;
  String? title;

  @override
  void initState() {
    _gridViewAnimationController = AnimationController(
        duration: const Duration(milliseconds: 3000),
        reverseDuration: const Duration(milliseconds: 3000),
        vsync: this);

    super.initState();
    _setTexts();
    _listenForFCM();

    if (widget.user != null) {
      _getData(true);
    } else {
      _getData(false);
    }
  }

  void _setTexts() async {
    var sett = await prefsOGx.getSettings();
    dashboardStrings = await DashboardStrings.getTranslated();
    title = await translator.translate('projectDashboard', sett!.locale!);
  }

  @override
  void dispose() {
    _gridViewAnimationController.dispose();
    projectPolygonSubscriptionFCM.cancel();
    projectPositionSubscriptionFCM.cancel();
    projectSubscriptionFCM.cancel();
    photoSubscriptionFCM.cancel();
    videoSubscriptionFCM.cancel();
    userSubscriptionFCM.cancel();
    audioSubscriptionFCM.cancel();
    geofenceSubscription.cancel();
    super.dispose();
  }

  String type = 'Unknown Rider';

  Future _getData(bool forceRefresh) async {
    pp('$mm ............................................Refreshing data ....');
    user = await prefsOGx.getUser();
    if (user != null) {
      if (user!.userType == UserType.orgAdministrator) {
        type = 'Administrator';
      }
      if (user!.userType == UserType.orgExecutive) {
        type = 'Executive';
      }
      if (user!.userType == UserType.fieldMonitor) {
        type = 'Field Monitor';
      }
    } else {
      throw Exception('No user cached on device');
    }

    if (mounted) {
      setState(() {
        busy = true;
      });
    }
    await _doTheWork(forceRefresh);
  }

  Future<void> _doTheWork(bool forceRefresh) async {
    try {
      var map = await getStartEndDates();
      final startDate = map['startDate'];
      final endDate = map['endDate'];
      var bag = await projectBloc.getProjectData(
          projectId: widget.project.projectId!,
          forceRefresh: forceRefresh,
          startDate: startDate!,
          endDate: endDate!);
      // await _extractData(bag);
      setState(() {});
    } catch (e) {
      pp('$mm $e - will show snackbar ..');
      showConnectionProblemSnackBar(
          context: context,
          message: 'Data refresh failed. Possible network problem - $e');
    }
    setState(() {
      busy = false;
    });
  }

  void _listenForFCM() async {
    var android = UniversalPlatform.isAndroid;
    var ios = UniversalPlatform.isIOS;

    if (android || ios) {
      pp('$mm 🍎 🍎 _listen to FCM message streams ... 🍎 🍎');
      projectSubscriptionFCM =
          fcmBloc.projectStream.listen((Project project) async {
        pp('$mm: 🍎 🍎 project arrived: ${project.name} ... 🍎 🍎');

        await _getData(false);
      });
      projectPolygonSubscriptionFCM =
          fcmBloc.projectPolygonStream.listen((ProjectPolygon polygon) async {
        pp('$mm: 🍎 🍎 polygon arrived: ${polygon.name} ... 🍎 🍎');

        await _getData(false);
      });
      projectPositionSubscriptionFCM =
          fcmBloc.projectPositionStream.listen((ProjectPosition pos) async {
        pp('$mm: 🍎 🍎 position arrived: ${pos.name} ... 🍎 🍎');

        await _getData(false);
      });

      settingsSubscriptionFCM = fcmBloc.settingsStream.listen((settings) async {
        pp('$mm: 🍎🍎 settings arrived with themeIndex: ${settings.themeIndex}... 🍎🍎');
        Locale newLocale = Locale(settings!.locale!);
        final m = LocaleAndTheme(
            themeIndex: settings!.themeIndex!, locale: newLocale);
        themeBloc.themeStreamController.sink.add(m);
        if (mounted) {
          setState(() {});
        }
      });

      photoSubscriptionFCM = fcmBloc.photoStream.listen((user) async {
        pp('$mm: 🍎 🍎 photoSubscriptionFCM photo arrived... 🍎 🍎');
        await _getData(false);
      });

      videoSubscriptionFCM = fcmBloc.videoStream.listen((Video message) async {
        pp('$mm: 🍎 🍎 videoSubscriptionFCM video arrived... 🍎 🍎');
        await _getData(false);
      });
      audioSubscriptionFCM = fcmBloc.audioStream.listen((Audio message) async {
        pp('$mm: 🍎 🍎 audioSubscriptionFCM audio arrived... 🍎 🍎');
        await _getData(false);
      });
    } else {
      pp('App is running on the Web 👿👿👿firebase messaging is OFF 👿👿👿');
    }
  }

  void _navigateToProjectMedia(Project project) {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 1),
            child: ProjectMediaTimeline(
              project: widget.project,
              projectBloc: widget.projectBloc,
              organizationBloc: widget.organizationBloc,
              prefsOGx: widget.prefsOGx,
              cacheManager: widget.cacheManager,
              geoUploader: widget.geoUploader,
              cloudStorageBloc: widget.cloudStorageBloc,
              dataApiDog: widget.dataApiDog, fcmBloc: widget.fcmBloc,
            )));
  }

  void _navigateToActivity() {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        alignment: Alignment.topLeft,
        duration: const Duration(seconds: 1),
        child: GeoActivity(
            prefsOGx: widget.prefsOGx, cacheManager: widget.cacheManager,
            fcmBloc: widget.fcmBloc,
            organizationBloc: widget.organizationBloc,
            projectBloc: widget.projectBloc,
            project: widget.project,
            dataApiDog: widget.dataApiDog,
            geoUploader: widget.geoUploader,
            cloudStorageBloc: widget.cloudStorageBloc,
            width: 400, thinMode: false, showPhoto: (p){},
            showVideo: (v){}, showAudio: (a){}, forceRefresh: true,
            showLocationResponse: (r){}, showLocationRequest: (r){},
            showUser: (r){}, showProjectPosition: (r){}, showOrgMessage: (r){},
            showGeofenceEvent: (r){}, showProjectPolygon: (r){})
      ),
    );
  }

  void _navigateToProjectMap(Project project) {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 1),
            child: ProjectMapMobile(project: project)));
  }

  static const typeVideo = 0,
      typeAudio = 1,
      typePhoto = 2,
      typePositions = 3,
      typePolygons = 4,
      typeSchedules = 5;

  Project? selectedProject;

  @override
  Widget build(BuildContext context) {
    var style = GoogleFonts.secularOne(
        textStyle: Theme.of(context).textTheme.titleLarge,
        fontWeight: FontWeight.w900,
        color: Theme.of(context).primaryColor);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            title == null ? 'Project Dashboard' : title!,
            style: myTextStyleMedium(context),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.access_alarm,
                size: 18,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () {
                _navigateToActivity();
              },
            ),
            IconButton(
              icon: Icon(
                Icons.refresh,
                size: 18,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () {
                _getData(true);
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(72),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const SizedBox(
                    height: 12,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          widget.project.name!,
                          style: GoogleFonts.lato(
                              textStyle: Theme.of(context).textTheme.titleLarge,
                              fontWeight: FontWeight.w900,
                              color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                ],
              ),
            ),
          ),
        ),
        // backgroundColor: Colors.brown[100],
        body: busy
            ? const Center(
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 6,
                    backgroundColor: Colors.amber,
                  ),
                ),
              )
            : Stack(
                children: [
                  dashboardStrings == null
                      ? const SizedBox()
                      : ProjectDashboardGrid(
                          onTypeTapped: onTypeTapped,
                          dashboardStrings: dashboardStrings!,
                          project: widget.project,
                          showProjectName: false,
                          crossAxisCount: 2)
                ],
              ),
      ),
    );
  }

  onTypeTapped(int p1) {
    //todo - implement types tapped
  }
}

//////
void showKillDialog({required String message, required BuildContext context}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: Text(
        "Critical App Message",
        style: myTextStyleLarge(ctx),
      ),
      content: Text(
        message,
        style: myTextStyleMedium(ctx),
      ),
      shape: getRoundedBorder(radius: 16),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            pp('$mm Navigator popping for the last time, Sucker! 🔵🔵🔵');
            var android = UniversalPlatform.isAndroid;
            var ios = UniversalPlatform.isIOS;
            if (android) {
              SystemNavigator.pop();
            }
            if (ios) {
              Navigator.of(ctx).pop();
              Navigator.of(ctx).pop();
            }
          },
          child: const Text("Exit the App"),
        ),
      ],
    ),
  );
}

final mm = '${E.heartRed}${E.heartRed}${E.heartRed}${E.heartRed} Dashboard: ';

class DashboardStrings {
  late String projects,
      members,
      photos,
      videos,
      areas,
      locations,
      schedules,
      refreshProjectDashboardData,
      audioClips;

  DashboardStrings(
      {required this.projects,
      required this.members,
      required this.photos,
      required this.videos,
      required this.areas,
      required this.refreshProjectDashboardData,
      required this.locations,
      required this.schedules,
      required this.audioClips});

  static Future<DashboardStrings> getTranslated() async {
    var sett = await prefsOGx.getSettings();
    var projects = await translator.translate('projects', sett!.locale!);
    var members = await translator.translate('members', sett.locale!);
    var photos = await translator.translate('photos', sett.locale!);
    var audioClips = await translator.translate('audioClips', sett.locale!);
    var locations = await translator.translate('locations', sett.locale!);
    var areas = await translator.translate('areas', sett.locale!);
    var schedules = await translator.translate('schedules', sett.locale!);
    var videos = await translator.translate('videos', sett.locale!);
    var refreshProjectDashboardData =
        await translator.translate('refreshProjectDashboardData', sett.locale!);

    var m = DashboardStrings(
        projects: projects,
        members: members,
        photos: photos,
        videos: videos,
        areas: areas,
        refreshProjectDashboardData: refreshProjectDashboardData,
        locations: locations,
        schedules: schedules,
        audioClips: audioClips);

    return m;
  }
}
