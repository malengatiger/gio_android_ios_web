import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geo_monitor/ui/dashboard/project_dashboard_mobile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:universal_platform/universal_platform.dart';

import '../../library/api/prefs_og.dart';
import '../../library/bloc/connection_check.dart';
import '../../library/bloc/fcm_bloc.dart';
import '../../library/bloc/organization_bloc.dart';
import '../../library/bloc/project_bloc.dart';
import '../../library/data/audio.dart';
import '../../library/data/field_monitor_schedule.dart';
import '../../library/data/photo.dart';
import '../../library/data/project.dart';
import '../../library/data/project_polygon.dart';
import '../../library/data/project_position.dart';
import '../../library/data/settings_model.dart';
import '../../library/data/user.dart';
import '../../library/data/video.dart';
import '../../library/functions.dart';
import '../../utilities/constants.dart';

class ProjectDashboardGrid extends StatefulWidget {
  const ProjectDashboardGrid(
      {Key? key,
      required this.onTypeTapped,
      this.totalHeight,
      this.topPadding,
      required this.project,
      required this.showProjectName,
      this.horizontalPadding,
      required this.crossAxisCount, required this.dashboardStrings})
      : super(key: key);
  final Function(int) onTypeTapped;
  final double? totalHeight;
  final double? topPadding;
  final double? horizontalPadding;
  final Project project;
  final bool showProjectName;
  final int crossAxisCount;
  final DashboardStrings dashboardStrings;

  @override
  State<ProjectDashboardGrid> createState() => _ProjectDashboardGridState();
}

class _ProjectDashboardGridState extends State<ProjectDashboardGrid>
    with TickerProviderStateMixin {

  late StreamSubscription<List<Project>> projectSubscription;
  late StreamSubscription<List<User>> userSubscription;
  late StreamSubscription<List<Photo>> photoSubscription;
  late StreamSubscription<List<Video>> videoSubscription;
  late StreamSubscription<List<Audio>> audioSubscription;
  late StreamSubscription<List<ProjectPosition>> projectPositionSubscription;
  late StreamSubscription<List<ProjectPolygon>> projectPolygonSubscription;
  late StreamSubscription<List<FieldMonitorSchedule>> schedulesSubscription;

  late StreamSubscription<Photo> photoSubscriptionFCM;
  late StreamSubscription<Video> videoSubscriptionFCM;
  late StreamSubscription<Audio> audioSubscriptionFCM;
  late StreamSubscription<ProjectPosition> projectPositionSubscriptionFCM;
  late StreamSubscription<ProjectPolygon> projectPolygonSubscriptionFCM;
  late StreamSubscription<Project> projectSubscriptionFCM;
  late StreamSubscription<User> userSubscriptionFCM;
  late StreamSubscription<SettingsModel> settingsSubscriptionFCM;

  var busy = false;
  var _projects = <Project>[];
  var _users = <User>[];
  var _photos = <Photo>[];
  var _videos = <Video>[];
  var _projectPositions = <ProjectPosition>[];
  var _projectPolygons = <ProjectPolygon>[];
  var _schedules = <FieldMonitorSchedule>[];
  var _audios = <Audio>[];
  final dur = 2000;
  User? user;
  final mm = '🔵🔵🔵🔵 ProjectDashboardGrid:  🍎 ';

  late StreamSubscription<String> killSubscriptionFCM;

  @override
  void initState() {
    //_setAnimationControllers();
    super.initState();
    _getData(false);
    _listenForFCM();
    _listenToProjectStreams();
  }

  void _getData(bool forceRefresh) async {
    user = await prefsOGx.getUser();
    pp('$mm ..... getting project data ...');
    if (mounted) {
      setState(() {
        busy = true;
      });
    }
    try {
      var map = await getStartEndDates();
      final startDate = map['startDate'];
      final endDate = map['endDate'];
      var dataBag = await projectBloc.getProjectData(
          projectId: widget.project.projectId!,
          forceRefresh: forceRefresh,
          startDate: startDate!,
          endDate: endDate!);
      _projects = dataBag.projects!;
      _users = dataBag.users!;
      _photos = dataBag.photos!;
      _videos = dataBag.videos!;
      _audios = dataBag.audios!;
      _projectPolygons = dataBag.projectPolygons!;
      _projectPositions = dataBag.projectPositions!;
      _schedules = dataBag.fieldMonitorSchedules!;

      if (mounted) {
        setState(() {});
      }
      // _projectAnimationController.reset();
      // _userAnimationController.reset();
      // _photoAnimationController.reset();
      // _videoAnimationController.reset();
      // _positionAnimationController.reset();
      // _polygonAnimationController.reset();
      // _audioAnimationController.reset();
      //
      // _projectAnimationController.forward().then((value) {
      //   _userAnimationController.forward().then((value) {
      //     _photoAnimationController.forward().then((value) {
      //       _videoAnimationController.forward().then((value) {
      //         _positionAnimationController.forward().then((value) {
      //           _polygonAnimationController.forward().then((value) {
      //             _audioAnimationController.forward();
      //           });
      //         });
      //       });
      //     });
      //   });
      // });
    } catch (e) {
      pp('$mm $e - will show snackbar ..');
      if (mounted) {
        showConnectionProblemSnackBar(
            context: context,
            message: 'Data refresh failed. Possible network problem - $e');
      }
    }
    if (mounted) {
      setState(() {
        busy = false;
      });
    }
  }

  void _listenToProjectStreams() async {
    projectSubscription = projectBloc.projectStream.listen((event) {
      _projects = event;
      pp('$mm attempting to set state after projects delivered by stream: ${_projects.length} ... mounted: $mounted');
      if (mounted) {
        setState(() {});
        // _projectAnimationController.forward();
      }
    });
    userSubscription = organizationBloc.usersStream.listen((event) {
      _users = event;
      pp('$mm attempting to set state after users delivered by stream: ${_users.length} ... mounted: $mounted');
      if (mounted) {
        setState(() {});
        // _userAnimationController.forward();
      }
    });
    photoSubscription = projectBloc.photoStream.listen((event) {
      _photos = event;
      pp('$mm attempting to set state after photos delivered by stream: ${_photos.length} ... mounted: $mounted');
      if (mounted) {
        setState(() {});
      }
      // _photoAnimationController.forward();
    });

    videoSubscription = projectBloc.videoStream.listen((event) {
      _videos = event;
      pp('$mm attempting to set state after videos delivered by stream: ${_videos.length} ... mounted: $mounted');
      if (mounted) {
        setState(() {});
        // _videoAnimationController.forward();
      }
    });
    audioSubscription = projectBloc.audioStream.listen((event) {
      _audios = event;
      pp('$mm attempting to set state after audios delivered by stream: ${_audios.length} ... mounted: $mounted');
      if (mounted) {
        setState(() {});
        // _audioAnimationController.forward();
      }
    });
    projectPositionSubscription =
        projectBloc.projectPositionsStream.listen((event) {
      _projectPositions = event;
      pp('$mm attempting to set state after projectPositions delivered by stream: ${_projectPositions.length} ... mounted: $mounted');
      if (mounted) {
        setState(() {});
        // _projectAnimationController.forward();
      }
    });
    projectPolygonSubscription =
        projectBloc.projectPolygonsStream.listen((event) {
      _projectPolygons = event;
      pp('$mm attempting to set state after projectPolygons delivered by stream: ${_projectPolygons.length} ... mounted: $mounted');
      if (mounted) {
        setState(() {});
        // _projectAnimationController.forward();
      }
    });

    schedulesSubscription =
        projectBloc.fieldMonitorScheduleStream.listen((event) {
      _schedules = event;
      pp('$mm attempting to set state after schedules delivered by stream: ${_schedules.length} ... mounted: $mounted');

      if (mounted) {
        setState(() {});
        // _projectAnimationController.forward();
      }
    });
  }

  void _listenForFCM() async {
    var android = UniversalPlatform.isAndroid;
    var ios = UniversalPlatform.isIOS;
    pp('$mm 🍎 🍎 🍎 🍎 FCM should be initialized!!  ... 🍎 🍎');
    if (android || ios) {
      pp('$mm 🍎 🍎 _listen to FCM message streams ... 🍎 🍎');

      // settingsSubscriptionFCM = fcmBloc.settingsStream.listen((settings) async {
      //   pp('$mm: 🍎🍎 settings arrived with themeIndex: ${settings.themeIndex}... 🍎🍎');
      //   themeBloc.themeStreamController.sink.add(settings.themeIndex!);
      //   if (mounted) {
      //     setState(() {});
      //   }
      // });
      // userSubscriptionFCM = fcmBloc.userStream.listen((user) async {
      //   pp('$mm: 🍎 🍎 user arrived... 🍎 🍎');
      //
      //   if (mounted) {
      //     _users = await organizationBloc.getUsers(
      //         organizationId: user.organizationId!, forceRefresh: false);
      //     setState(() {});
      //   }
      // });
      photoSubscriptionFCM = fcmBloc.photoStream.listen((user) async {
        pp('$mm: 🍎 🍎 photoSubscriptionFCM photo arrived... 🍎 🍎');
        if (mounted) {
          final map = await getStartEndDates();
          _photos = await projectBloc.getPhotos(
              projectId: widget.project.projectId!, forceRefresh: false,
          startDate: map['startDate']!, endDate: map['endDate']!);
          setState(() {});
        }
      });

      videoSubscriptionFCM = fcmBloc.videoStream.listen((Video message) async {
        pp('$mm: 🍎 🍎 videoSubscriptionFCM video arrived... 🍎 🍎');
        if (mounted) {
          pp('DashboardMobile: 🍎 🍎 showMessageSnackbar: ${message.projectName} ... 🍎 🍎');
          var map = await getStartEndDates();
          final startDate = map['startDate'];
          final endDate = map['endDate'];
          _videos = await projectBloc.getProjectVideos(
              projectId: widget.project.projectId!,
              forceRefresh: false,
              startDate: startDate!,
              endDate: endDate!);
          setState(() {});
        }
      });
      audioSubscriptionFCM = fcmBloc.audioStream.listen((Audio message) async {
        pp('$mm: 🍎 🍎 audioSubscriptionFCM audio arrived... 🍎 🍎');
        if (mounted) {
          var map = await getStartEndDates();
          final startDate = map['startDate'];
          final endDate = map['endDate'];
          _audios = await projectBloc.getProjectAudios(
              projectId: widget.project.projectId!,
              forceRefresh: false,
              startDate: startDate!,
              endDate: endDate!);
        }
      });
      projectPositionSubscriptionFCM =
          fcmBloc.projectPositionStream.listen((ProjectPosition message) async {
        pp('$mm: 🍎 🍎 projectPositionSubscriptionFCM position arrived... 🍎 🍎');
        if (mounted) {
          var map = await getStartEndDates();
          final startDate = map['startDate'];
          final endDate = map['endDate'];
          _projectPositions = await projectBloc.getProjectPositions(
              projectId: widget.project.projectId!,
              forceRefresh: false,
              startDate: startDate!,
              endDate: endDate!);
        }
      });
      projectPolygonSubscriptionFCM =
          fcmBloc.projectPolygonStream.listen((ProjectPolygon message) async {
        pp('$mm: 🍎 🍎 projectPolygonSubscriptionFCM polygon arrived... 🍎 🍎');
        if (mounted) {
          _projectPolygons = await projectBloc.getProjectPolygons(
              projectId: widget.project.projectId!, forceRefresh: false);
        }
      });
    } else {
      pp('App is running on the Web 👿👿👿firebase messaging is OFF 👿👿👿');
    }
  }

  @override
  void dispose() {
    // _projectAnimationController.dispose();
    // _photoAnimationController.dispose();
    // _videoAnimationController.dispose();
    // _audioAnimationController.dispose();
    // _positionAnimationController.dispose();
    // _polygonAnimationController.dispose();

    projectPolygonSubscription.cancel();
    projectPositionSubscription.cancel();
    projectSubscription.cancel();
    photoSubscription.cancel();
    videoSubscription.cancel();
    userSubscription.cancel();
    audioSubscription.cancel();
    projectPolygonSubscriptionFCM.cancel();
    projectPositionSubscriptionFCM.cancel();
    projectSubscriptionFCM.cancel();
    photoSubscriptionFCM.cancel();
    videoSubscriptionFCM.cancel();
    userSubscriptionFCM.cancel();
    audioSubscriptionFCM.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 8,
            ),
            InkWell(
              onTap: () {
                _getData(true);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 28,
                    ),
                    Text(widget.dashboardStrings.refreshProjectDashboardData,
                      style: myTextStyleSmall(context),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    const Icon(
                      Icons.refresh,
                      size: 12,
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    busy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 4,
                              backgroundColor: Colors.pink,
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: widget.topPadding == null ? 48 : widget.topPadding!,
            ),
            widget.showProjectName
                ? Text(
                    '${widget.project.name}',
                    style: myTextStyleLargePrimaryColor(context),
                  )
                : const SizedBox(),
            SizedBox(
              height: widget.totalHeight == null ? 900 : widget.totalHeight!,
              child: Padding(
                padding: EdgeInsets.all(widget.horizontalPadding ?? 28),
                child: GridView.count(
                  crossAxisCount: widget.crossAxisCount,
                  children: [
                    GestureDetector(
                      onTap: () {
                        pp('$mm widget on tapped: typePhotos $typePhotos ...');

                        widget.onTypeTapped(typePhotos);
                      },
                      child: DashboardElement(
                        title: widget.dashboardStrings.photos,
                        number: _photos.length,
                        topPadding: widget.topPadding,
                        textStyle: GoogleFonts.secularOne(
                            textStyle: Theme.of(context).textTheme.titleLarge,
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context).primaryColor),
                        onTapped: () {
                          widget.onTypeTapped(typePhotos);
                        },
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        pp('$mm widget on tapped: typeVideos $typeVideos ...');

                        widget.onTypeTapped(typeVideos);
                      },
                      child: DashboardElement(
                        title: widget.dashboardStrings.videos,
                        topPadding: widget.topPadding,
                        number: _videos.length,
                        onTapped: () {
                          widget.onTypeTapped(typeVideos);
                        },
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        widget.onTypeTapped(typeAudios);
                      },
                      child: DashboardElement(
                        title: widget.dashboardStrings.audioClips,
                        topPadding: widget.topPadding,
                        number: _audios.length,
                        textStyle: GoogleFonts.secularOne(
                            textStyle: Theme.of(context).textTheme.titleLarge,
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context).primaryColor),
                        onTapped: () {
                          widget.onTypeTapped(typeAudios);
                        },
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        widget.onTypeTapped(typePositions);
                      },
                      child: DashboardElement(
                        title: widget.dashboardStrings.locations,
                        topPadding: widget.topPadding,
                        number: _projectPositions.length,
                        onTapped: () {
                          widget.onTypeTapped(typePositions);
                        },
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        widget.onTypeTapped(typePolygons);
                      },
                      child: DashboardElement(
                        title: widget.dashboardStrings.areas,
                        topPadding: widget.topPadding,
                        number: _projectPolygons.length,
                        textStyle: GoogleFonts.secularOne(
                            textStyle: Theme.of(context).textTheme.titleLarge,
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context).primaryColor),
                        onTapped: () {
                          widget.onTypeTapped(typePolygons);
                        },
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        widget.onTypeTapped(typeSchedules);
                      },
                      child: DashboardElement(
                        title: widget.dashboardStrings.schedules,
                        topPadding: widget.topPadding,
                        number: _schedules.length,
                        onTapped: () {
                          widget.onTypeTapped(typeSchedules);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

////
////
class DashboardElement extends StatelessWidget {
  const DashboardElement(
      {Key? key,
      required this.number,
      required this.title,
      this.height,
      this.topPadding,
      this.textStyle,
      this.labelTitleStyle,
      required this.onTapped})
      : super(key: key);
  final int number;
  final String title;
  final double? height, topPadding;
  final TextStyle? textStyle, labelTitleStyle;
  final Function() onTapped;

  @override
  Widget build(BuildContext context) {
    var style = GoogleFonts.secularOne(
        textStyle: Theme.of(context).textTheme.titleLarge,
        fontWeight: FontWeight.w900);

    return GestureDetector(
      onTap: () {
        onTapped();
      },
      child: Card(
        shape: getRoundedBorder(radius: 16),
        child: SizedBox(
          height: height == null ? 240 : height!,
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  height: topPadding == null ? 72 : topPadding!,
                ),
                Text('$number', style: textStyle == null ? style : textStyle!),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  title,
                  style: myTextStyleMediumGrey(context),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
