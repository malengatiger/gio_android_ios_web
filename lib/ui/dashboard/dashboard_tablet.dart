import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geo_monitor/library/bloc/fcm_bloc.dart';
import 'package:geo_monitor/library/bloc/organization_bloc.dart';
import 'package:geo_monitor/library/cache_manager.dart';
import 'package:geo_monitor/library/data/activity_model.dart';
import 'package:geo_monitor/library/data/geofence_event.dart';
import 'package:geo_monitor/library/data/location_request.dart';
import 'package:geo_monitor/library/data/location_response.dart';
import 'package:geo_monitor/library/data/org_message.dart';
import 'package:geo_monitor/library/ui/camera/video_player_tablet.dart';
import 'package:geo_monitor/library/ui/maps/geofence_map_tablet.dart';
import 'package:geo_monitor/library/ui/media/list/project_media_main.dart';
import 'package:geo_monitor/library/ui/ratings/rating_adder.dart';
import 'package:geo_monitor/library/ui/settings/settings_main.dart';
import 'package:geo_monitor/ui/activity/geo_activity.dart';
import 'package:geo_monitor/ui/audio/audio_player_og.dart';
import 'package:geo_monitor/ui/charts/summary_chart.dart';
import 'package:geo_monitor/ui/dashboard/dashboard_grid.dart';
import 'package:geo_monitor/ui/dashboard/photo_card.dart';
import 'package:geo_monitor/ui/intro/intro_main.dart';
import 'package:page_transition/page_transition.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:universal_platform/universal_platform.dart';

import '../../l10n/translation_handler.dart';
import '../../library/api/data_api_og.dart';
import '../../library/api/prefs_og.dart';
import '../../library/bloc/geo_exception.dart';
import '../../library/bloc/isolate_handler.dart';
import '../../library/bloc/theme_bloc.dart';
import '../../library/data/audio.dart';
import '../../library/data/data_bag.dart';
import '../../library/data/photo.dart';
import '../../library/data/project.dart';
import '../../library/data/project_polygon.dart';
import '../../library/data/project_position.dart';
import '../../library/data/settings_model.dart';
import '../../library/data/user.dart';
import '../../library/data/video.dart';
import '../../library/errors/error_handler.dart';
import '../../library/functions.dart';
import '../../library/generic_functions.dart';
import '../../library/ui/maps/location_response_map.dart';
import '../../library/ui/maps/photo_map_tablet.dart';
import '../../library/ui/maps/project_map_main.dart';
import '../../library/ui/project_list/project_list_main.dart';
import '../../library/users/full_user_photo.dart';
import '../../library/users/list/user_list_main.dart';
import '../../utilities/constants.dart';
import '../activity/user_profile_card.dart';

class DashboardTablet extends StatefulWidget {
  const DashboardTablet(
      {Key? key,
      required this.user,
      required this.prefsOGx,
      required this.dataApiDog,
      required this.cacheManager,
      required this.isolateHandler,
      required this.fcmBloc,
      required this.organizationBloc})
      : super(key: key);

  final User user;
  final PrefsOGx prefsOGx;
  final DataApiDog dataApiDog;
  final CacheManager cacheManager;
  final IsolateDataHandler isolateHandler;
  final FCMBloc fcmBloc;
  final OrganizationBloc organizationBloc;

  @override
  State<DashboardTablet> createState() => DashboardTabletState();
}

class DashboardTabletState extends State<DashboardTablet>
    with WidgetsBindingObserver {
  final mm = '🍎🍎🍎🍎 DashboardTablet: 🔵 ';

  late StreamSubscription<Photo> photoSubscriptionFCM;
  late StreamSubscription<Video> videoSubscriptionFCM;
  late StreamSubscription<Audio> audioSubscriptionFCM;
  late StreamSubscription<ProjectPosition> projectPositionSubscriptionFCM;
  late StreamSubscription<ProjectPolygon> projectPolygonSubscriptionFCM;
  late StreamSubscription<Project> projectSubscriptionFCM;
  late StreamSubscription<User> userSubscriptionFCM;
  late StreamSubscription<SettingsModel> settingsSubscriptionFCM;
  late StreamSubscription<ActivityModel> activitySubscriptionFCM;

  late StreamSubscription<DataBag> dataBagSubscription;

  late StreamSubscription<SettingsModel> settingsSubscription;

  late StreamSubscription<String> killSubscriptionFCM;
  var users = <User>[];
  User? user;
  DataBag? dataBag;
  bool busy = false;
  int numberOfDays = 7;
  SettingsModel? settingsModel;

  String? title;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    _setTexts();
    _listenForDataBag();
    _listenForFCM();
    _getData(false);
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    super.didChangeLocales(locales);
    pp('$mm didChangeLocales: This is run when system locales are changed, '
        'locales; ${locales?.length}');
    locales?.forEach((loc) {
      pp('$mm didChangeLocales: System Locale: $loc');
    });
    // Update state with the new values and redraw controls
    setState(() {});
  }

  @override
  void dispose() {
    activitySubscriptionFCM.cancel();
    projectPolygonSubscriptionFCM.cancel();
    projectPositionSubscriptionFCM.cancel();
    photoSubscriptionFCM.cancel();
    videoSubscriptionFCM.cancel();
    audioSubscriptionFCM.cancel();
    settingsSubscriptionFCM.cancel();
    dataBagSubscription.cancel();
    // killSubscriptionFCM.cancel();
    userSubscriptionFCM.cancel();
    settingsSubscriptionFCM.cancel();

    super.dispose();
  }

  void _listenForDataBag() async {
    dataBagSubscription = organizationBloc.dataBagStream.listen((DataBag bag) {
      dataBag = bag;
      pp('$mm dataBagStream delivered a dataBag!! 🍐Yebo! 🍐');
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _listenForFCM() async {
    var android = UniversalPlatform.isAndroid;
    var ios = UniversalPlatform.isIOS;
    if (android || ios) {
      pp('$mm 🍎 🍎 _listen to FCM message streams ... 🍎 🍎');
      pp('$mm ... _listenToFCM activityStream ...');

      settingsSubscription = widget.organizationBloc.settingsStream
          .listen((SettingsModel settings) async {
        pp('$mm settingsStream delivered settings ... ${settings.locale!}');
        await _handleNewSettings(settings);
        if (mounted) {
          setState(() {});
        }
      });
      activitySubscriptionFCM =
          widget.fcmBloc.activityStream.listen((ActivityModel model) {
        pp('$mm activityStream delivered activity data ... ${model.date!}');
        _getData(false);
        if (mounted) {
          setState(() {});
        }
      });
      projectSubscriptionFCM =
          widget.fcmBloc.projectStream.listen((Project project) async {
        _getData(false);
      });

      settingsSubscriptionFCM = widget.fcmBloc.settingsStream.listen((settings) async {
        pp('$mm: 🍎🍎 settings arrived with themeIndex: ${settings.themeIndex}... locale: ${settings.locale} 🍎🍎');
        await _handleNewSettings(settings);
      });

      userSubscriptionFCM = widget.fcmBloc.userStream.listen((user) async {
        pp('$mm: 🍎 🍎 user arrived... 🍎 🍎');
        _getData(false);
      });
      photoSubscriptionFCM = widget.fcmBloc.photoStream.listen((user) async {
        pp('$mm: 🍎 🍎 photoSubscriptionFCM photo arrived... 🍎 🍎');
        _getData(false);
      });

      videoSubscriptionFCM = widget.fcmBloc.videoStream.listen((Video message) async {
        pp('$mm: 🍎 🍎 videoSubscriptionFCM video arrived... 🍎 🍎');
        _getData(false);
      });
      audioSubscriptionFCM = widget.fcmBloc.audioStream.listen((Audio message) async {
        pp('$mm: 🍎 🍎 audioSubscriptionFCM audio arrived... 🍎 🍎');
        _getData(false);
      });
      projectPositionSubscriptionFCM =
          widget.fcmBloc.projectPositionStream.listen((ProjectPosition message) async {
        pp('$mm: 🍎 🍎 projectPositionSubscriptionFCM position arrived... 🍎 🍎');
        _getData(false);
      });
      projectPolygonSubscriptionFCM =
          widget.fcmBloc.projectPolygonStream.listen((ProjectPolygon message) async {
        pp('$mm: 🍎 🍎 projectPolygonSubscriptionFCM polygon arrived... 🍎 🍎');
        _getData(false);
      });
    } else {
      pp('App is running on the Web 👿👿👿firebase messaging is OFF 👿👿👿');
    }
  }

  Future<void> _handleNewSettings(SettingsModel settings) async {
    Locale newLocale = Locale(settings.locale!);
    final m =
        LocaleAndTheme(themeIndex: settings!.themeIndex!, locale: newLocale);
    themeBloc.themeStreamController.sink.add(m);
    settingsModel = settings;
    await _getData(true);
    if (mounted) {
      await _setTexts();
    }
  }

  String? dashboardSubTitle, prefix, suffix, translatedUserType;
  Row? subtitleRow;

  Future _setTexts() async {
    settingsModel = await prefsOGx.getSettings();
    numberOfDays = settingsModel!.numberOfDays!;
    title = await translator.translate('dashboard', settingsModel!.locale!);
    var sub =
        await translator.translate('dashboardSubTitle', settingsModel!.locale!);
    pp('deciphering this string: 🍎 $sub');
    int index = sub.indexOf('\$');
    prefix = sub.substring(0, index);
    String? suff;
    try {
      suff = sub.substring(index + 6);
      suffix = suff;
      pp('$mm prefix: $prefix suffix: $suffix');
    } catch (e) {
      pp('🔴🔴🔴🔴🔴🔴 $e');
    }
    dashboardSubTitle = sub.replaceAll('\$count', '$numberOfDays');

    setState(() {});
  }

  Future _getData(bool forceRefresh) async {
    setState(() {
      busy = true;
    });
    try {
      user = await prefsOGx.getUser();
      translatedUserType = await getTranslatedUserType(user!.userType!);
      pp('$mm translatedUserType: $translatedUserType');
      var map = await getStartEndDates();
      final startDate = map['startDate'];
      final endDate = map['endDate'];

      dataBag = await organizationBloc.getOrganizationData(
          organizationId: user!.organizationId!,
          forceRefresh: forceRefresh,
          startDate: startDate!,
          endDate: endDate!);
    } catch (e) {
      pp(e);
      if (e is GeoException) {
        var sett = await prefsOGx.getSettings();
        errorHandler.handleError(exception: e);
        final msg =
            await translator.translate(e.geTranslationKey(), sett.locale!);
        if (mounted) {
          showToast(
              backgroundColor: Theme.of(context).primaryColor,
              textStyle: myTextStyleMedium(context),
              padding: 16,
              duration: const Duration(seconds: 10),
              message: msg,
              context: context);
        }
      }
    }

    if (mounted) {
      setState(() {
        busy = false;
      });
    }
  }

  void _navigateToProjectList() {
    if (selectedProject != null) {
      pp('$mm _navigateToProjectList ...');

      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.scale,
              alignment: Alignment.topLeft,
              duration: const Duration(seconds: 1),
              child: const ProjectListMain()));
      selectedProject = null;
    } else {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.scale,
              alignment: Alignment.topLeft,
              duration: const Duration(seconds: 1),
              child: const ProjectListMain()));
    }
  }

  void _navigateToMessageSender() {
    // Navigator.push(
    //     context,
    //     PageTransition(
    //         type: PageTransitionType.scale,
    //         alignment: Alignment.topLeft,
    //         duration: const Duration(seconds: 1),
    //         child: const ChatPage()));
    showToast(
        textStyle: myTextStyleMediumBold(context),
        toastGravity: ToastGravity.TOP,
        message: 'Messaging under construction, see you later!',
        context: context);
  }

  void _navigateToIntro() {
    pp('$mm .................. _navigateToIntro  ....');
    if (mounted) {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.scale,
              alignment: Alignment.topLeft,
              duration: const Duration(seconds: 1),
              child: IntroMain(
                prefsOGx: widget.prefsOGx,
                dataApiDog: widget.dataApiDog,
                cacheManager: widget.cacheManager,
                isolateHandler: widget.isolateHandler,
                fcmBloc: widget.fcmBloc,
                organizationBloc: widget.organizationBloc,
              )));
    }
  }

  void _navigateToCharts() {
    pp('$mm .................. _navigateToCharts  ....');
    if (mounted) {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.scale,
              alignment: Alignment.topLeft,
              duration: const Duration(seconds: 1),
              child: const ProjectSummaryChart()));
    }
  }

  Future<void> _navigateToFullUserPhoto() async {
    pp('$mm .................. _navigateToFullUserPhoto  ....');
    user = await prefsOGx.getUser();
    if (user != null) {
      if (mounted) {
        Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.scale,
                alignment: Alignment.topLeft,
                duration: const Duration(seconds: 1),
                child: FullUserPhoto(user: user!)));
        setState(() {});
      }
    }
  }

  void _navigateToSettings() {
    pp('$mm .................. _navigateToSettings to Settings ....');
    if (mounted) {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.scale,
              alignment: Alignment.center,
              duration: const Duration(seconds: 1),
              child: SettingsMain(
                isolateHandler: widget.isolateHandler,
                dataApiDog: widget.dataApiDog,
              )));
    }
  }

  void _navigateToUserList() {
    pp('$mm _navigateToUserList ...');
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 1),
            child: UserListMain(
              user: user!,
              users: users,
            )));
  }

  void _navigateToProjectMedia(Project project) {
    pp('$mm _navigateToProjectMedia ...');

    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 1),
            child: ProjectMediaMain(project: project)));
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

  void _navigateToDailyForecast() {
    // Navigator.push(
    //     context,
    //     PageTransition(
    //         type: PageTransitionType.scale,
    //         alignment: Alignment.topLeft,
    //         duration: const Duration(seconds: 1),
    //         child: const DailyForecastPage()));
  }

  onMapRequested(Photo p1) {
    pp('$mm onMapRequested ... ');
    if (mounted) {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.scale,
              alignment: Alignment.topLeft,
              duration: const Duration(milliseconds: 1000),
              child: PhotoMap(
                photo: p1,
              )));
    }
  }

  bool _showRatingAdder = false;

  onRatingRequested(Photo p1) {
    pp('$mm onRatingRequested ...');
    if (mounted) {
      setState(() {
        photo = p1;
        _showRatingAdder = true;
        _showAudio = false;
        _showVideo = false;
      });
    }
  }

  Project? selectedProject;
  bool _showPhoto = false;
  bool _showVideo = false;
  bool _showAudio = false;

  // bool _showLocationResponse = false;
  // bool _showProjectPosition = false;
  // bool _showALocationRequest = false;
  // bool _showProjectPolygon = false;
  // bool _showMessage = false;
  // bool _showUser = false;

  Photo? photo;
  Video? video;
  Audio? audio;
  LocationRequest? request;
  LocationResponse? response;
  ProjectPolygon? projectPolygon;
  ProjectPosition? projectPosition;
  OrgMessage? orgMessage;
  User? someUser;
  String? translatedDate;

  void _resetFlags() {
    _showPhoto = false;
    _showVideo = false;
    _showAudio = false;
    // _showLocationResponse = false;
    // _showALocationRequest = false;
    // _showProjectPosition = false;
    // _showProjectPolygon = false;
    // _showMessage = false;
    // _showUser = false;
  }

  void _displayPhoto(Photo photo) async {
    pp('$mm _displayPhoto ...');
    this.photo = photo;
    final settings = await prefsOGx.getSettings();
    translatedDate = getFmtDate(photo.created!, settings!.locale!);
    _resetFlags();
    setState(() {
      _showPhoto = true;
    });
  }

  void _displayVideo(Video video) async {
    pp('$mm _displayVideo ...');
    this.video = video;
    _resetFlags();
    setState(() {
      _showVideo = true;
    });
  }

  void _displayAudio(Audio audio) async {
    pp('$mm _displayAudio ...');
    this.audio = audio;
    _resetFlags();
    setState(() {
      _showAudio = true;
    });
  }

  void _navigateToLocationResponseMap(LocationResponse resp) async {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 1),
            child: LocationResponseMap(
              locationResponse: resp!,
            )));
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

  @override
  Widget build(BuildContext context) {
    final Locale appLocale = Localizations.localeOf(context);
    pp('$mm build: app Localizations.localeOf 🌎🌎🌎 locale: $appLocale, not the same as the app');
    var size = MediaQuery.of(context).size;
    var ori = MediaQuery.of(context).orientation;
    var bottomHeight = 200.0;
    var padding = 360.0;
    var extPadding = 300.0;
    var top = -12.0;
    var avatarRadius = 32.0;
    var userPadding = 16.0;
    var spaceFromBottom = 8.0;
    var width = 360.0;
    if (ori.name == 'portrait') {
      padding = 200;
      top = 0;
      bottomHeight = 200;
      extPadding = 140;
      avatarRadius = 20;
      userPadding = 0.0;
      spaceFromBottom = 8;
      width = 300.0;
    }

    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(title == null ? 'Dashboard' : title!),
        actions: [
          IconButton(
              icon: Icon(
                Icons.info_outline,
                size: 24,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: _navigateToIntro),
          IconButton(
              icon: Icon(
                Icons.bar_chart,
                size: 24,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: _navigateToCharts),
          IconButton(
            icon: Icon(
              Icons.settings,
              size: 24,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: _navigateToSettings,
          ),
          IconButton(
            icon: Icon(
              Icons.refresh,
              size: 24,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () {
              _getData(true);
            },
          )
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(bottomHeight),
          child: Column(
            children: [
              user == null
                  ? const SizedBox()
                  : Text(
                      user!.organizationName!,
                      style: myTextStyleLargePrimaryColor(context),
                    ),
              user == null
                  ? const SizedBox()
                  : const SizedBox(
                      height: 12,
                    ),
              user == null
                  ? const SizedBox()
                  : UserProfileCard(
                      userName: user!.name!,
                      userThumbUrl: user!.thumbnailUrl!,
                      namePictureHorizontal: false,
                      avatarRadius: 20,
                      elevation: 2,
                      width: width,
                      userType: translatedUserType,
                      padding: userPadding,
                      textStyle: myTextStyleMediumPrimaryColor(context)),
              const SizedBox(
                height: 4,
              ),
              SizedBox(
                height: spaceFromBottom,
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 28.0),
                  child: Row(
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
                  )),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          OrientationLayoutBuilder(
            portrait: (context) {
              return Row(
                children: [
                  SizedBox(
                    width: (size.width / 2) + 20,
                    child: dataBag == null
                        ? const SizedBox()
                        : DashboardGrid(
                            dataBag: dataBag!,
                            crossAxisCount: 2,
                            topPadding: 48,
                            elementPadding: 48,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            leftPadding: 12,
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
                                case typeSchedules:
                                  _navigateToProjectList();
                                  break;
                              }
                            },
                            gridPadding: 48,
                          ),
                  ),
                  GeoActivity(
                    width: (size.width / 2) - 20,
                    forceRefresh: true,
                    thinMode: true,
                    showPhoto: (photo) {
                      _displayPhoto(photo);
                    },
                    showVideo: (video) {
                      _displayVideo(video);
                    },
                    showAudio: (audio) {
                      _displayAudio(audio);
                    },
                    showUser: (user) {},
                    showLocationRequest: (req) {},
                    showLocationResponse: (resp) {
                      _navigateToLocationResponseMap(resp);
                    },
                    showGeofenceEvent: (event) {
                      _navigateToGeofenceMap(event);
                    },
                    showProjectPolygon: (polygon) async {
                      var proj = await cacheManager.getProjectById(
                          projectId: polygon.projectId!);
                      if (proj != null) {
                        _navigateToProjectMap(proj);
                      }
                    },
                    showProjectPosition: (position) async {
                      var proj = await cacheManager.getProjectById(
                          projectId: position.projectId!);
                      if (proj != null) {
                        _navigateToProjectMap(proj);
                      }
                    },
                    showOrgMessage: (message) {
                      _navigateToMessageSender();
                    },
                  ),
                ],
              );
            },
            landscape: (context) {
              return Row(
                children: [
                  SizedBox(
                    width: (size.width / 2) + 60,
                    child: dataBag == null
                        ? const SizedBox()
                        : DashboardGrid(
                            dataBag: dataBag!,
                            crossAxisCount: 3,
                            topPadding: 12,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            elementPadding: 48,
                            leftPadding: 12,
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
                                case typeSchedules:
                                  _navigateToProjectList();
                                  break;
                              }
                            },
                            gridPadding: 32,
                          ),
                  ),
                  GeoActivity(
                    width: (size.width / 2) - 140,
                    forceRefresh: true,
                    thinMode: false,
                    showPhoto: (photo) {
                      _displayPhoto(photo);
                    },
                    showVideo: (video) {
                      _displayVideo(video);
                    },
                    showAudio: (audio) {
                      _displayAudio(audio);
                    },
                    showUser: (user) {},
                    showLocationRequest: (req) {},
                    showLocationResponse: (resp) {
                      _navigateToLocationResponseMap(resp);
                    },
                    showGeofenceEvent: (event) {
                      _navigateToGeofenceMap(event);
                    },
                    showProjectPolygon: (polygon) async {
                      var proj = await cacheManager.getProjectById(
                          projectId: polygon.projectId!);
                      if (proj != null) {
                        _navigateToProjectMap(proj);
                      }
                    },
                    showProjectPosition: (position) async {
                      var proj = await cacheManager.getProjectById(
                          projectId: position.projectId!);
                      if (proj != null) {
                        _navigateToProjectMap(proj);
                      }
                    },
                    showOrgMessage: (message) {
                      _navigateToMessageSender();
                    },
                  ),
                ],
              );
            },
          ),
          busy
              ? const Positioned(
                  left: 80,
                  top: 140,
                  child: Card(
                    child: Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 4,
                          backgroundColor: Colors.pink,
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox(),
          _showPhoto
              ? Positioned(
                  left: extPadding,
                  right: extPadding,
                  top: -10,
                  child: SizedBox(
                    width: 600,
                    height: 800,
                    // color: Theme.of(context).primaryColor,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _showPhoto = false;
                          });
                        },
                        child: PhotoCard(
                            photo: photo!,
                            translatedDate: translatedDate!,
                            elevation: 8.0,
                            onPhotoCardClose: () {
                              setState(() {
                                _showPhoto = false;
                              });
                            },
                            onMapRequested: onMapRequested,
                            onRatingRequested: onRatingRequested),
                      ),
                    ),
                  ))
              : const SizedBox(),
          _showVideo
              ? Positioned(
                  left: padding,
                  right: padding,
                  top: top,
                  child: VideoPlayerTablet(
                    video: video!,
                    width: 400,
                    onCloseRequested: () {
                      setState(() {
                        _showVideo = false;
                      });
                    },
                  ))
              : const SizedBox(),
          _showAudio
              ? Positioned(
                  left: padding,
                  right: padding,
                  top: 12,
                  child: AudioPlayerOG(
                    audio: audio!,
                    onCloseRequested: () {
                      if (mounted) {
                        setState(() {
                          _showAudio = false;
                        });
                      }
                    },
                  ))
              : const SizedBox(),
          _showRatingAdder
              ? Positioned(
                  left: 200,
                  right: 200,
                  top: 60,
                  child: RatingAdder(
                    photo: photo,
                    audio: audio,
                    video: video,
                    width: 400.0,
                    onDone: () {
                      setState(() {
                        _showRatingAdder = false;
                      });
                    },
                    elevation: 8.0,
                  ))
              : const SizedBox(),
        ],
      ),
    ));
  }
}
