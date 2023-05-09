import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:geo_monitor/dashboard_khaya/project_list.dart';
import 'package:geo_monitor/dashboard_khaya/recent_event_list.dart';
import 'package:geo_monitor/dashboard_khaya/xd_header.dart';
import 'package:geo_monitor/library/api/prefs_og.dart';
import 'package:geo_monitor/library/bloc/organization_bloc.dart';
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
import 'package:geo_monitor/library/ui/media/time_line/project_media_timeline.dart';
import 'package:geo_monitor/library/ui/project_list/gio_projects.dart';
import 'package:geo_monitor/library/users/edit/user_edit_main.dart';
import 'package:geo_monitor/library/users/list/geo_user_list.dart';
import 'package:geo_monitor/ui/activity/gio_activities.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:universal_platform/universal_platform.dart';

import '../l10n/translation_handler.dart';
import '../library/api/data_api_og.dart';
import '../library/bloc/fcm_bloc.dart';
import '../library/bloc/isolate_handler.dart';
import '../library/bloc/project_bloc.dart';
import '../library/bloc/theme_bloc.dart';
import '../library/cache_manager.dart';
import '../library/data/data_bag.dart';
import '../library/data/project.dart';
import '../library/data/settings_model.dart';
import '../library/ui/loading_card.dart';
import '../library/ui/settings/settings_main.dart';
import 'member_list.dart';

class DashboardKhaya extends StatefulWidget {
  const DashboardKhaya(
      {Key? key,
      required this.isolateHandler,
      required this.dataApiDog,
      required this.fcmBloc,
      required this.organizationBloc,
      required this.projectBloc,
      required this.prefsOGx,
      required this.cacheManager})
      : super(key: key);

  final IsolateDataHandler isolateHandler;
  final DataApiDog dataApiDog;
  final FCMBloc fcmBloc;
  final OrganizationBloc organizationBloc;
  final ProjectBloc projectBloc;
  final PrefsOGx prefsOGx;
  final CacheManager cacheManager;

  @override
  State<DashboardKhaya> createState() => _DashboardKhayaState();
}

class _DashboardKhayaState extends State<DashboardKhaya> {
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

  late StreamSubscription<DataBag> dataBagSubscription;

  @override
  void initState() {
    super.initState();
    _listenForFCM();
    _setTexts();
    _getData(false);
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

  Future<void> _handleNewSettings(SettingsModel settings) async {
    Locale newLocale = Locale(settings.locale!);
    _setTexts();
    final m =
        LocaleAndTheme(themeIndex: settings.themeIndex!, locale: newLocale);
    themeBloc.themeStreamController.sink.add(m);
    _getData(false);
  }

  void _listenForFCM() async {
    var android = UniversalPlatform.isAndroid;
    var ios = UniversalPlatform.isIOS;
    if (android || ios) {
      pp('$mm 🍎 🍎 _listen to FCM message streams ... 🍎 🍎');
      geofenceSubscriptionFCM =
          widget.fcmBloc.geofenceStream.listen((GeofenceEvent event) async {
        pp('$mm: 🍎geofenceSubscriptionFCM: 🍎 GeofenceEvent: '
            'user ${event.user!.name} arrived: ${event.projectName} ');
        _handleGeofenceEvent(event);
      });
      projectSubscriptionFCM =
          widget.fcmBloc.projectStream.listen((Project project) async {
        _getData(false);
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
        _getData(false);
      });
      photoSubscriptionFCM = widget.fcmBloc.photoStream.listen((user) async {
        pp('$mm: 🍎 🍎 photoSubscriptionFCM photo arrived... 🍎 🍎');
        _getData(false);
      });

      videoSubscriptionFCM =
          widget.fcmBloc.videoStream.listen((Video message) async {
        pp('$mm: 🍎 🍎 videoSubscriptionFCM video arrived... 🍎 🍎');
        _getData(false);
      });
      audioSubscriptionFCM =
          widget.fcmBloc.audioStream.listen((Audio message) async {
        pp('$mm: 🍎 🍎 audioSubscriptionFCM audio arrived... 🍎 🍎');
        _getData(false);
      });
      projectPositionSubscriptionFCM = widget.fcmBloc.projectPositionStream
          .listen((ProjectPosition message) async {
        pp('$mm: 🍎 🍎 projectPositionSubscriptionFCM position arrived... 🍎 🍎');
        _getData(false);
      });
      projectPolygonSubscriptionFCM = widget.fcmBloc.projectPolygonStream
          .listen((ProjectPolygon message) async {
        pp('$mm: 🍎 🍎 projectPolygonSubscriptionFCM polygon arrived... 🍎 🍎');
        _getData(false);
        if (mounted) {}
      });
      dataBagSubscription =
          widget.organizationBloc.dataBagStream.listen((DataBag bag) async {
        pp('$mm: 🍎 🍎 dataBagStream bag arrived... 🍎 🍎');
        if (bag.projects != null) {
          projects = bag.projects!;
        }
        if (bag.projects != null) {
          users = bag.users!;
        }
        if (mounted) {
          setState(() {});
        }
      });
    } else {
      pp('App is running on the Web 👿👿👿firebase messaging is OFF 👿👿👿');
    }
  }

  var images = <Image>[];

  void _getData(bool forceRefresh) async {
    user = await prefsOGx.getUser();
    final sett = await prefsOGx.getSettings();
    try {
      setState(() {
        busy = true;
      });
      pp('$mm _getData .... forceRefresh: $forceRefresh  ');
      final m = await getStartEndDates(numberOfDays: sett.numberOfDays!);
      final bag = await organizationBloc.getOrganizationData(organizationId: user!.organizationId!,
          forceRefresh: forceRefresh, startDate: m['startDate']!, endDate: m['endDate']!);
      projects = bag.projects!;

      users = await organizationBloc.getUsers(
          organizationId: user!.organizationId!, forceRefresh: forceRefresh);
      setState(() {
        busy = true;
      });
      events = await organizationBloc.getOrganizationActivity(
          organizationId: user!.organizationId!,
          forceRefresh: forceRefresh,
          hours: sett.activityStreamHours!);
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

  String? serverProblem;
  void _setTexts() async {
    var sett = await prefsOGx.getSettings();
    loadingDataText =
        await translator.translate('loadingActivities', sett.locale!);
    dashboardText = await translator.translate('dashboard', sett.locale!);
    eventsText = await translator.translate('events', sett.locale!);
    projectsText = await translator.translate('projects', sett.locale!);
    membersText = await translator.translate('members', sett.locale!);
    recentEventsText = await translator.translate('recentEvents', sett.locale!);
    serverProblem = await translator.translate('serverProblem', sett.locale!);

    setState(() {});
  }

  bool refreshRequired = false;

  void _navigateToSettings() {
    pp(' 🌀🌀🌀🌀 .................. _navigateToSettings to Settings ....');
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

  void _navigateToActivities() {
    pp(' 🌀🌀🌀🌀 .................. _navigateToActivities  ....');

    if (mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return GioActivities(
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
            onLocationRequest: onLocationRequest);
      }));
    }
  }

  void _navigateToProjects() {
    pp(' 🌀🌀🌀🌀 .................. _navigateToSettings to Settings ....');
    if (mounted) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GioProjects(
              projectBloc: widget.projectBloc,
              organizationBloc: widget.organizationBloc,
              prefsOGx: widget.prefsOGx,
              dataApiDog: widget.dataApiDog,
              cacheManager: widget.cacheManager,
              instruction: 0,
              fcmBloc: widget.fcmBloc,
            ),
          ));
    }
  }

  void _navigateToMembers() {
    pp(' 🌀🌀🌀🌀 .................. _navigateToSettings to users ....');
    if (mounted) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  GioUserList(dataApiDog: widget.dataApiDog)));
    }
  }

  void _onSearchTapped() {
    pp(' ✅✅✅ _onSearchTapped ...');
  }

  void _onDeviceUserTapped() {
    pp('✅✅✅ _onDeviceUserTapped ...');
    if (mounted) {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.scale,
              alignment: Alignment.center,
              duration: const Duration(seconds: 1),
              child: UserEditMain(user)));
    }
  }

  bool forceRefresh = false;
  void _onRefreshRequested() {
    pp(' ✅✅✅ _onRefreshRequested ...');
    _getData(true);
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
    pp('🌀🌀🌀🌀 _onEventTapped; activityModel: ${act.toJson()}');
  }

  void onProjectTapped(Project project) async {
    pp('🌀🌀🌀🌀 _onProjectTapped; navigate to timeLine: project: ${project.toJson()}');
    if (mounted) {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.scale,
              alignment: Alignment.center,
              duration: const Duration(seconds: 1),
              child: ProjectMediaTimeline(
                projectBloc: widget.projectBloc,
                prefsOGx: widget.prefsOGx,
                project: project,
                organizationBloc: widget.organizationBloc,
                cacheManager: widget.cacheManager,
                dataApiDog: widget.dataApiDog,
              )));
    }
  }

  void _onUserTapped(User user) async {
    pp('🌀🌀🌀🌀 _onUserTapped; user: ${user.toJson()}');
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

  @override
  Widget build(BuildContext context) {
    var sigmaX = 12.0;
    var sigmaY = 12.0;
    // if (checkIfDarkMode()) {
    //   sigmaX = 200.0;
    //   sigmaY = 200.0;
    //   pp('💜💜 We are in darkMode now: sigmaX: $sigmaX sigmaY: $sigmaY');
    // } else {
    //   pp('💜💜 We are in lightMode now: sigmaX: $sigmaX sigmaY: $sigmaY');
    // }
    var width = MediaQuery.of(context).size.width;
    final deviceType = getThisDeviceType();
    if (deviceType != 'phone') {}
    return Scaffold(
      body: busy
          ? Center(
              child: LoadingCard(
                  loadingData: loadingDataText == null
                      ? 'Loading Data'
                      : loadingDataText!),
            )
          : ScreenTypeLayout(
              mobile: user == null
                  ? const SizedBox()
                  : RealDashboard(
                      projects: projects,
                      users: users,
                      events: events,
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
                        _onUserTapped(user);
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
                      centerTopCards: false,
                    ),
              tablet: OrientationLayoutBuilder(
                portrait: (context) {
                  return user == null
                      ? const SizedBox()
                      : RealDashboard(
                          topCardSpacing: 16.0,
                          centerTopCards: false,
                          projects: projects,
                          users: users,
                          events: events,
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
                            _onUserTapped(user);
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
                          });
                },
                landscape: (context) {
                  return user == null
                      ? const SizedBox()
                      : RealDashboard(
                          topCardSpacing: 16,
                          forceRefresh: forceRefresh,
                          projects: projects,
                          users: users,
                          events: events,
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
                            _onUserTapped(user);
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
                        );
                },
              ),
            ),
    );
  }

  onLocationRequest(LocationRequest p1) {}

  onUserTapped(User p1) {}

  onLocationResponse(LocationResponse p1) {}

  onPhotoTapped(Photo p1) {}

  onVideoTapped(Video p1) {}

  onAudioTapped(Audio p1) {}

  onProjectPositionTapped(ProjectPosition p1) {}

  onPolygonTapped(ProjectPolygon p1) {}

  onGeofenceEventTapped(GeofenceEvent p1) {}

  onOrgMessage(OrgMessage p1) {}
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
    required this.events,
    required this.users,
    this.topCardSpacing,
    required this.centerTopCards,
    required this.recentEventsText,
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
      onDeviceUserTapped;
  final User user;
  final double width;
  final String dashboardText,
      eventsText,
      projectsText,
      membersText,
      recentEventsText;
  final bool forceRefresh;

  final List<Project> projects;
  final List<ActivityModel> events;
  final List<User> users;
  final double? topCardSpacing;
  final bool centerTopCards;

  @override
  Widget build(BuildContext context) {
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
                      const SizedBox(height: 150),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            dashboardText,
                            style: TextStyle(
                                fontSize: 24,
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SubTitleWidget(
                          title: eventsText,
                          onTapped: () {
                            onEventsSubtitleTapped();
                          },
                          number: totalEvents,
                          color: Colors.blue),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: centerTopCards
                            ? MainAxisAlignment.center
                            : MainAxisAlignment.start,
                        children: [
                          DashboardTopCard(
                              number: events.length,
                              title: eventsText,
                              onTapped: () {}),
                          SizedBox(
                            width: topCardSpacing == null ? 2 : topCardSpacing!,
                          ),
                          DashboardTopCard(
                              number: projects.length,
                              title: projectsText,
                              onTapped: () {}),
                          SizedBox(
                            width: topCardSpacing == null ? 2 : topCardSpacing!,
                          ),
                          DashboardTopCard(
                              number: users.length,
                              title: membersText,
                              onTapped: () {}),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            recentEventsText,
                            style: myTextStyleSubtitleSmall(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      RecentEventList(
                        onEventTapped: (act) {
                          onEventTapped(act);
                        },
                        activities: events,
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
              height: 112,
              child: AppBar(
                // centerTitle: false,
                flexibleSpace: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
                    child: Container(
                      decoration:
                          BoxDecoration(color: Colors.white.withOpacity(0.0)),
                    ),
                  ),
                ),
                title: const XdHeader(),
                actions: [
                  IconButton(
                      onPressed: () {
                        onSearchTapped();
                      },
                      icon: Icon(
                        Icons.search,
                        color: Theme.of(context).primaryColor,
                      )),
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
                      radius: 16,
                      backgroundImage: NetworkImage(user.thumbnailUrl!),
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                ],
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
    var style = GoogleFonts.roboto(
        textStyle: Theme.of(context).textTheme.titleLarge,
        fontSize: 40,
        color: color,
        fontWeight: FontWeight.w900);

    var style2 = GoogleFonts.roboto(
        textStyle: Theme.of(context).textTheme.bodyMedium,
        fontSize: 12,
        color: color,
        fontWeight: FontWeight.normal);

    return GestureDetector(
      onTap: () {
        onTapped();
      },
      child: Card(
        shape: getRoundedBorder(radius: 16),
        child: SizedBox(
          height: height == null ? 104 : height!,
          width: width == null ? 104 : width!,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: topPadding == null ? 8 : topPadding!,
                ),
                Text('$number', style: textStyle == null ? style : textStyle!),
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
