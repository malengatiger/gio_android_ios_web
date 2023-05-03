import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:geo_monitor/l10n/translation_handler.dart';
import 'package:geo_monitor/library/bloc/geo_exception.dart';
import 'package:geo_monitor/library/generic_functions.dart';
import 'package:geo_monitor/library/ui/settings/settings_main.dart';
import 'package:geo_monitor/library/users/full_user_photo.dart';
import 'package:geo_monitor/ui/activity/geo_activity_mobile.dart';
import 'package:geo_monitor/ui/activity/user_profile_card.dart';
import 'package:geo_monitor/ui/dashboard/dashboard_grid.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:universal_platform/universal_platform.dart';

import '../../library/api/data_api_og.dart';
import '../../library/api/prefs_og.dart';
import '../../library/bloc/connection_check.dart';
import '../../library/bloc/fcm_bloc.dart';
import '../../library/bloc/isolate_handler.dart';
import '../../library/bloc/organization_bloc.dart';
import '../../library/bloc/project_bloc.dart';
import '../../library/bloc/theme_bloc.dart';
import '../../library/bloc/user_bloc.dart';
import '../../library/cache_manager.dart';
import '../../library/data/audio.dart';
import '../../library/data/data_bag.dart';
import '../../library/data/geofence_event.dart';
import '../../library/data/photo.dart';
import '../../library/data/project.dart';
import '../../library/data/project_polygon.dart';
import '../../library/data/project_position.dart';
import '../../library/data/settings_model.dart';
import '../../library/data/user.dart';
import '../../library/data/video.dart';
import '../../library/emojis.dart';
import '../../library/errors/error_handler.dart';
import '../../library/functions.dart';
import '../../library/ui/maps/project_map_mobile.dart';
import '../../library/ui/media/list/project_media_list_mobile.dart';
import '../../library/ui/media/user_media_list/user_media_list_mobile.dart';
import '../../library/ui/project_list/project_list_mobile.dart';
import '../../library/ui/weather/daily_forecast_page.dart';
import '../../library/users/list/user_list_main.dart';
import '../../utilities/constants.dart';
import '../intro/intro_page_viewer_portrait.dart';

class DashboardMobile extends StatefulWidget {
  const DashboardMobile({
    Key? key,
    this.user,
    this.project, required this.prefsOGx, required this.dataApiDog, required this.cacheManager, required this.isolateHandler, required this.fcmBloc, required this.organizationBloc,
  }) : super(key: key);
  final User? user;
  final Project? project;
  final PrefsOGx prefsOGx;
  final DataApiDog dataApiDog;
  final CacheManager cacheManager;
  final IsolateDataHandler isolateHandler;
  final FCMBloc fcmBloc;
  final OrganizationBloc organizationBloc;


  @override
  DashboardMobileState createState() => DashboardMobileState();
}

class DashboardMobileState extends State<DashboardMobile>
    with SingleTickerProviderStateMixin {
  static const mm = '🎽🎽🎽🎽🎽🎽 DashboardMobile: 🎽';

  late AnimationController _gridViewAnimationController;
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

  late StreamSubscription<DataBag> dataBagSubscription;
  //

  var busy = false;
  User? deviceUser;
  final fb.FirebaseAuth firebaseAuth = fb.FirebaseAuth.instance;
  bool authed = false;
  bool networkAvailable = false;
  final dur = 3000;
  String type = 'Unknown Rider';
  DataBag? dataBag;
  final _key = GlobalKey<ScaffoldState>();
  int instruction = stayOnList;
  var items = <BottomNavigationBarItem>[];
  SettingsModel? settings;
  String? title, prefix, suffix;

  int numberOfDays = 7;
  @override
  void initState() {
    _gridViewAnimationController = AnimationController(
        duration: Duration(milliseconds: dur),
        reverseDuration: Duration(milliseconds: dur),
        vsync: this);
    super.initState();
    _setTexts();
    _getData(false);
    _setItems();
    _listenForData();
    _listenForFCM();
    _getAuthenticationStatus();
    _subscribeToConnectivity();
  }

  void _listenForData() async {
    settingsSubscription =
        organizationBloc.settingsStream.listen((SettingsModel settings) async {
      pp('$mm organizationBloc.settingsStream delivered settings ... ${settings.locale!}');
      await _handleNewSettings(settings);
      if (mounted) {
        setState(() {});
      }
    });

    dataBagSubscription = organizationBloc.dataBagStream.listen((DataBag bag) {
      dataBag = bag;
      pp('$mm dataBagStream delivered a dataBag!! 🍐Yebo! 🍐');
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _handleNewSettings(SettingsModel settings) async {
    Locale newLocale = Locale(settings.locale!);
    await _setTexts();
    final m =
        LocaleAndTheme(themeIndex: settings!.themeIndex!, locale: newLocale);
    themeBloc.themeStreamController.sink.add(m);
    this.settings = settings;
    _getData(false);
  }

  void _getAuthenticationStatus() async {
    var cUser = firebaseAuth.currentUser;
    if (cUser == null) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _navigateToIntro();
      });
      //
    }
  }

  Future<void> _subscribeToConnectivity() async {
    connectionSubscription =
        connectionCheck.connectivityStream.listen((bool connected) {
      if (connected) {
        pp('$mm We have a connection! - $connected');
      } else {
        pp('$mm We DO NOT have a connection! - show snackbar ...  🍎 mounted? $mounted');
        if (mounted) {
          //showConnectionProblemSnackBar(context: context);
        }
      }
    });
    var isConnected = await connectionCheck.internetAvailable();
    pp('$mm Are we connected? answer: $isConnected');
  }

  @override
  void dispose() {
    _gridViewAnimationController.dispose();

    connectionSubscription.cancel();
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

  void _setItems() {
    items.add(const BottomNavigationBarItem(
        icon: Icon(
          Icons.person,
          color: Colors.pink,
        ),
        label: 'My Work'));

    items.add(const BottomNavigationBarItem(
        icon: Icon(
          Icons.send,
          color: Colors.blue,
        ),
        label: 'Send Message'));

    items.add(const BottomNavigationBarItem(
        icon: Icon(
          Icons.radar,
          color: Colors.teal,
        ),
        label: 'Weather'));
  }

  var subTitle = '';

  Future _setTexts() async {
    settings = await prefsOGx.getSettings();
    numberOfDays = settings!.numberOfDays!;

    title = await translator.translate('dashboard', settings!.locale!);
    var sub1 = await translator.translate('dashboardSubTitle', settings!.locale!);
    subTitle = sub1.replaceAll('\$count', '$numberOfDays');
    var sub =
    await translator.translate('dashboardSubTitle', settings!.locale!);
    pp('deciphering this string: 🍎 $sub');
    int index = sub.indexOf('\$');
    prefix = sub.substring(0, index);
    String? stuff;
    try {
      stuff = sub.substring(index + 6);
      suffix = stuff;
      pp('$mm prefix: $prefix suffix: $suffix');
    } catch (e) {
      pp('🔴🔴🔴🔴🔴🔴 $e');
    }
    setState(() {});
  }

  Future _getData(bool forceRefresh) async {
    pp('$mm ............................................ Refreshing dashboard data ....');
    deviceUser = await prefsOGx.getUser();

    if (deviceUser != null) {
      if (deviceUser!.userType == UserType.orgAdministrator) {
        type = await translator.translate('administrator', settings!.locale!);
      }
      if (deviceUser!.userType == UserType.orgExecutive) {
        type = await translator.translate('executive', settings!.locale!);
      }
      if (deviceUser!.userType == UserType.fieldMonitor) {
        type = await translator.translate('fieldMonitor', settings!.locale!);
      }
    } else {
      throw Exception('No user cached on device');
    }

    if (mounted) {
      setState(() {
        busy = true;
      });
    }
    try {
      await _doTheWork(forceRefresh);
      _gridViewAnimationController.forward();
    } catch (e) {
        if (mounted) {
          setState(() {
            busy = false;
          });
        }
        if (e is GeoException) {
          var sett = await prefsOGx.getSettings();
          errorHandler.handleError(exception: e);
          final msg = await translator.translate(e.geTranslationKey(), sett.locale!);
          if (mounted) {
            showToast(
                backgroundColor: Theme
                    .of(context)
                    .primaryColor,
                textStyle: myTextStyleMedium(context),
                padding: 16,
                duration: const Duration(seconds: 10),
                message: msg,
                context: context);
          }
        }
    }
  }

  Future<void> _doTheWork(bool forceRefresh) async {
    if (deviceUser == null) {
      throw Exception(
          "The data refresh man is fucked! Device User is not found");
    }
    if (widget.project != null) {
      await _getProjectData(widget.project!.projectId!, forceRefresh);
    } else if (widget.user != null) {
      await _getUserData(widget.user!.userId!, forceRefresh);
    } else {
      await _getOrganizationData(deviceUser!.organizationId!, forceRefresh);
    }

    _gridViewAnimationController.forward();
    setState(() {
      busy = false;
    });
  }

  Future _getOrganizationData(String organizationId, bool forceRefresh) async {
    var map = await getStartEndDates();
    final startDate = map['startDate'];
    final endDate = map['endDate'];
    pp('$mm _getOrganizationData: startDate : $startDate endDate: $endDate');
    final start = DateTime.now();
    dataBag = await organizationBloc.getOrganizationData(
        organizationId: organizationId,
        forceRefresh: forceRefresh,
        startDate: startDate!,
        endDate: endDate!);
    final end = DateTime.now();
    pp('$mm _getOrganizationData: data bag returned ... '
        '${end.difference(start).inSeconds} seconds elapsed');

    await _setTexts();
  }

  Future _getProjectData(String projectId, bool forceRefresh) async {
    var map = await getStartEndDates();
    final startDate = map['startDate'];
    final endDate = map['endDate'];
    pp('$mm _getOrganizationData: startDate : $startDate endDate: $endDate');
    dataBag = await projectBloc.getProjectData(
        projectId: projectId,
        forceRefresh: forceRefresh,
        startDate: startDate!,
        endDate: endDate!);
    pp('$mm _getProjectData: data bag returned ...');
  }

  Future _getUserData(String userId, bool forceRefresh) async {
    var map = await getStartEndDates();
    final startDate = map['startDate'];
    final endDate = map['endDate'];
    pp('$mm _getOrganizationData: startDate : $startDate endDate: $endDate');
    dataBag = await userBloc.getUserData(
        userId: userId,
        forceRefresh: forceRefresh,
        startDate: startDate!,
        endDate: endDate!);
    pp('$mm _getUserData: data bag returned ...');
  }

  Future<void> _handleGeofenceEvent(GeofenceEvent event) async {
    pp('$mm _handleGeofenceEvent ... ');
    var settings = await prefsOGx.getSettings();
    var arr = await translator.translate('memberArrived', settings!.locale!);
    if (event.projectName != null) {
      var arrivedAt = arr.replaceAll('\$project', event.projectName!);
      if (mounted) {
        showToast(
            duration: const Duration(seconds: 5),
            backgroundColor: Theme.of(context).primaryColor,
            padding: 20,
            textStyle: myTextStyleMedium(context),
            message: arrivedAt,
            context: context);
      }
    }
  }

  void _listenForFCM() async {
    var android = UniversalPlatform.isAndroid;
    var ios = UniversalPlatform.isIOS;
    if (android || ios) {
      pp('$mm 🍎 🍎 _listen to FCM message streams ... 🍎 🍎');
      geofenceSubscriptionFCM =
          fcmBloc.geofenceStream.listen((GeofenceEvent event) async {
        pp('$mm: 🍎geofenceSubscriptionFCM: 🍎 GeofenceEvent: '
            'user ${event.user!.name} arrived: ${event.projectName} ');
        _handleGeofenceEvent(event);
      });
      projectSubscriptionFCM =
          fcmBloc.projectStream.listen((Project project) async {
        await _getData(false);
        if (mounted) {
          pp('$mm: 🍎 🍎 project arrived: ${project.name} ... 🍎 🍎');
          setState(() {});
        }
      });

      settingsSubscriptionFCM = fcmBloc.settingsStream.listen((settings) async {
        pp('$mm: 🍎🍎 settingsSubscriptionFCM: settings arrived with themeIndex: ${settings.themeIndex}... 🍎🍎');
        _handleNewSettings(settings);
      });

      userSubscriptionFCM = fcmBloc.userStream.listen((user) async {
        pp('$mm: 🍎 🍎 user arrived... 🍎 🍎');
        if (user.userId == deviceUser!.userId!) {
          deviceUser = user;
        }
        _getData(false);
      });
      photoSubscriptionFCM = fcmBloc.photoStream.listen((user) async {
        pp('$mm: 🍎 🍎 photoSubscriptionFCM photo arrived... 🍎 🍎');
        _getData(false);
      });

      videoSubscriptionFCM = fcmBloc.videoStream.listen((Video message) async {
        pp('$mm: 🍎 🍎 videoSubscriptionFCM video arrived... 🍎 🍎');
        await _getData(false);
        if (mounted) {
          pp('DashboardMobile: 🍎 🍎 showMessageSnackbar: ${message.projectName} ... 🍎 🍎');
          setState(() {});
        }
      });
      audioSubscriptionFCM = fcmBloc.audioStream.listen((Audio message) async {
        pp('$mm: 🍎 🍎 audioSubscriptionFCM audio arrived... 🍎 🍎');
        await _getData(false);
        if (mounted) {}
      });
      projectPositionSubscriptionFCM =
          fcmBloc.projectPositionStream.listen((ProjectPosition message) async {
        pp('$mm: 🍎 🍎 projectPositionSubscriptionFCM position arrived... 🍎 🍎');
        await _getData(false);
        if (mounted) {}
      });
      projectPolygonSubscriptionFCM =
          fcmBloc.projectPolygonStream.listen((ProjectPolygon message) async {
        pp('$mm: 🍎 🍎 projectPolygonSubscriptionFCM polygon arrived... 🍎 🍎');
        await _getData(false);
        if (mounted) {}
      });
    } else {
      pp('App is running on the Web 👿👿👿firebase messaging is OFF 👿👿👿');
    }
  }

  void _navigateToProjectList() {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 1),
            child: ProjectListMobile(
              instruction: instruction,
            )));
  }

  void _navigateToUserMediaList() async {
    if (mounted) {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.scale,
              alignment: Alignment.topLeft,
              duration: const Duration(seconds: 1),
              child: UserMediaListMobile(user: deviceUser!)));
    }
  }

  void _navigateToIntro() {
    pp('$mm .................. _navigateToIntro to Intro ....');
    if (mounted) {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.scale,
              alignment: Alignment.topLeft,
              duration: const Duration(seconds: 1),
              child:  IntroPageViewerPortrait(
                prefsOGx: widget.prefsOGx,
                dataApiDog: widget.dataApiDog,
                cacheManager: widget.cacheManager,
                isolateHandler: widget.isolateHandler,
                fcmBloc: widget.fcmBloc,
                organizationBloc: widget.organizationBloc,
              )));
    }
  }

  Future<void> _navigateToFullUserPhoto() async {
    pp('$mm .................. _navigateToFullUserPhoto  ....');
    deviceUser = await prefsOGx.getUser();
    if (deviceUser != null) {
      if (mounted) {
        Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.scale,
                alignment: Alignment.topLeft,
                duration: const Duration(seconds: 1),
                child: FullUserPhoto(user: deviceUser!)));
        setState(() {});
      }
    }
  }

  Future<void> _navigateToSettings() async {
    pp('$mm .................. _navigateToIntro to Settings ....');
    if (mounted) {
     await Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.fade,
              alignment: Alignment.center,
              duration: const Duration(seconds: 1),
              child:  SettingsMain(
                isolateHandler: widget.isolateHandler, dataApiDog: widget.dataApiDog,
              )));
     pp('$mm  back from Settings ....');
     settings = await prefsOGx.getSettings();
     await _handleNewSettings(settings!);

    }
  }

  void showPhoto(Photo p) async {}

  void showVideo(Video p) async {}

  void showAudio(Audio p) async {}

  void _navigateToActivity() {
    pp('$mm .................. _navigateToActivity ....');
    if (mounted) {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.fade,
              alignment: Alignment.center,
              duration: const Duration(seconds: 1),
              child: GeoActivityMobile(
                user: widget.user,
                project: widget.project,
              )));
    }
  }

  void _navigateToUserList() {
    if (dataBag == null) return;
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.fade,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 1),
            child: UserListMain(
              user: deviceUser!,
              users: dataBag!.users!,
            )));
  }

  void _navigateToProjectMedia(Project project) {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 1),
            child: ProjectMediaListMobile(project: project)));
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

  void _navigateToDailyForecast() {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 1),
            child: const DailyForecastPage()));
  }

  static const typeVideo = 0,
      typeAudio = 1,
      typePhoto = 2,
      typePositions = 3,
      typePolygons = 4,
      typeSchedules = 5;

  @override
  Widget build(BuildContext context) {
    bool showAdminIcons = false;
    if (deviceUser != null) {
      switch (deviceUser!.userType) {
        case UserType.orgAdministrator:
          showAdminIcons = true;
          break;
        case UserType.orgExecutive:
          showAdminIcons = true;
          break;
        case UserType.fieldMonitor:
          showAdminIcons = true;
          break;
      }
    }
    return SafeArea(
      child: Scaffold(
        key: _key,
        appBar: AppBar(
          // title:  Text(title == null? 'Dashboard': title!),
          actions: [
            IconButton(
                icon: Icon(
                  Icons.info_outline,
                  size: 18,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: _navigateToIntro),
            showAdminIcons
                ? IconButton(
                    icon: Icon(
                      Icons.access_alarm,
                      size: 18,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: _navigateToActivity,
                  )
                : const SizedBox(),
            showAdminIcons
                ? IconButton(
                    icon: Icon(
                      Icons.settings,
                      size: 18,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: _navigateToSettings,
                  )
                : const SizedBox(),
            IconButton(
              icon: Icon(
                Icons.refresh,
                size: 18,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () {
                _getData(true);
              },
            )
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(180),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    title == null ? 'Dashboard' : title!,
                    style: myTextStyleSmall(context),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  deviceUser == null
                      ? const SizedBox()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                deviceUser!.organizationName!,
                                style: myTextStyleMediumBold(context),
                              ),
                            ),
                          ],
                        ),
                  const SizedBox(
                    height: 16,
                  ),
                  deviceUser == null
                      ? const SizedBox()
                      : UserProfileCard(
                          userName: deviceUser!.name!,
                          userThumbUrl: deviceUser!.thumbnailUrl,
                          namePictureHorizontal: true,
                          avatarRadius: 20,
                          elevation: 1,
                          padding: 2,
                          textStyle: myTextStyleMediumPrimaryColor(context)),
                  const SizedBox(
                    height: 0,
                  ),
                  deviceUser == null
                      ? const Text('')
                      : Text(
                          type,
                          style: GoogleFonts.lato(
                            textStyle: Theme.of(context).textTheme.bodySmall,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        prefix == null ? '' : prefix!,
                        style: myTextStyleSmall(context),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        '$numberOfDays',
                        style: myTextStyleLargePrimaryColor(context),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        suffix == null ? '' : suffix!,
                        style: myTextStyleSmall(context),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                ],
              ),
            ),
          ),
        ),
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
            : Stack(children: [
                dataBag == null
                    ? const SizedBox()
                    : DashboardGrid(
                        gridPadding: 16,
                        topPadding: 12,
                        elementPadding: 48,
                        leftPadding: 12,
                        crossAxisCount: 2,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                        dataBag: dataBag!,
                        onTypeTapped: (type) {
                          switch (type) {
                            case typeProjects:
                              _navigateToProjectList();
                              break;
                            case typeUsers:
                              _navigateToUserList();
                              break;
                            case typePhotos:
                              _navigateToProjectList();
                              break;
                            case typeVideos:
                              _navigateToProjectList();
                              break;
                            case typeAudios:
                              _navigateToProjectList();
                              break;
                            case typePositions:
                              _navigateToProjectList();
                              break;
                            case typePolygons:
                              _navigateToProjectList();
                              break;
                          }
                        },
                      ),
              ]),
      ),
    );
  }
}

final mm = '${E.heartRed}${E.heartRed}${E.heartRed}${E.heartRed} Dashboard: ';
