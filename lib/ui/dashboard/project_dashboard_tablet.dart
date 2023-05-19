import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geo_monitor/library/data/activity_model.dart';
import 'package:geo_monitor/library/ui/maps/project_map_mobile.dart';
import 'package:geo_monitor/library/ui/maps/project_polygon_map_mobile.dart';
import 'package:geo_monitor/library/ui/media/time_line/project_media_timeline.dart';
import 'package:geo_monitor/ui/audio/gio_audio_player.dart';
import 'package:geo_monitor/ui/dashboard/photo_frame.dart';
import 'package:geo_monitor/ui/dashboard/project_dashboard_grid.dart';
import 'package:geo_monitor/ui/dashboard/project_dashboard_mobile.dart';
import 'package:page_transition/page_transition.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:universal_platform/universal_platform.dart';

import '../../library/api/data_api_og.dart';
import '../../library/api/prefs_og.dart';
import '../../library/bloc/cloud_storage_bloc.dart';
import '../../library/bloc/connection_check.dart';
import '../../library/bloc/fcm_bloc.dart';
import '../../library/bloc/geo_uploader.dart';
import '../../library/bloc/organization_bloc.dart';
import '../../library/bloc/project_bloc.dart';
import '../../library/bloc/theme_bloc.dart';
import '../../library/cache_manager.dart';
import '../../library/data/audio.dart';
import '../../library/data/data_bag.dart';
import '../../library/data/field_monitor_schedule.dart';
import '../../library/data/geofence_event.dart';
import '../../library/data/location_response.dart';
import '../../library/data/photo.dart';
import '../../library/data/project.dart';
import '../../library/data/project_polygon.dart';
import '../../library/data/project_position.dart';
import '../../library/data/settings_model.dart';
import '../../library/data/user.dart';
import '../../library/data/video.dart';
import '../../library/functions.dart';
import '../../library/ui/camera/gio_video_player.dart';
import '../../library/ui/maps/geofence_map_tablet.dart';
import '../../library/ui/maps/location_response_map.dart';
import '../../library/ui/maps/photo_map.dart';
import '../../library/ui/maps/project_map_main.dart';
import '../../utilities/constants.dart';
import '../activity/geo_activity.dart';

class ProjectDashboardTablet extends StatefulWidget {
  const ProjectDashboardTablet(
      {Key? key,
      required this.project,
      required this.projectBloc,
      required this.prefsOGx,
      required this.organizationBloc,
      required this.dataApiDog,
      required this.cacheManager,
      required this.fcmBloc, required this.geoUploader, required this.cloudStorageBloc})
      : super(key: key);

  final Project project;
  final ProjectBloc projectBloc;
  final PrefsOGx prefsOGx;
  final OrganizationBloc organizationBloc;
  final DataApiDog dataApiDog;
  final CacheManager cacheManager;
  final FCMBloc fcmBloc;
  final GeoUploader geoUploader;
  final CloudStorageBloc cloudStorageBloc;


  @override
  ProjectDashboardTabletState createState() => ProjectDashboardTabletState();
}

class ProjectDashboardTabletState extends State<ProjectDashboardTablet>
    with SingleTickerProviderStateMixin {
  late AnimationController _gridViewAnimationController;
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
  late StreamSubscription<ActivityModel> activitySubscriptionFCM;
  late StreamSubscription<String> killSubscriptionFCM;

  User? deviceUser;
  DataBag? dataBag;
  DashboardStrings? dashboardStrings;
  @override
  void initState() {
    _gridViewAnimationController = AnimationController(vsync: this);
    super.initState();
    _setTexts();
    _listenForFCM();
    _getData(false);
  }

  void _setTexts() async {
    var sett = await prefsOGx.getSettings();
    dashboardStrings = await DashboardStrings.getTranslated();
  }

  var type = '';
  void _getData(bool forceRefresh) async {
    pp('$mm ............................................Refreshing data ....');
    deviceUser = await prefsOGx.getUser();
    if (deviceUser != null) {
      if (deviceUser!.userType == UserType.orgAdministrator) {
        type = 'Administrator';
      }
      if (deviceUser!.userType == UserType.orgExecutive) {
        type = 'Executive';
      }
      if (deviceUser!.userType == UserType.fieldMonitor) {
        type = 'Field Monitor';
      }
    } else {
      throw Exception('No user cached on device');
    }

    _gridViewAnimationController.reverse().then((value) async {
      if (mounted) {
        setState(() {
          busy = true;
        });
        await _doTheWork(forceRefresh);
        _gridViewAnimationController.forward();
      }
    });
  }

  Future<void> _doTheWork(bool forceRefresh) async {
    try {
      if (deviceUser == null) {
        throw Exception("Tax man is fucked! User is not found");
      }
      await _getProjectData(widget.project.projectId!, forceRefresh);
      setState(() {});
      _gridViewAnimationController.forward();
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

  Future _getProjectData(String projectId, bool forceRefresh) async {
    var map = await getStartEndDates();
    final startDate = map['startDate'];
    final endDate = map['endDate'];
    dataBag = await projectBloc.getProjectData(
        projectId: projectId,
        forceRefresh: forceRefresh,
        startDate: startDate!,
        endDate: endDate!);
  }

  void _listenForFCM() async {
    var android = UniversalPlatform.isAndroid;
    var ios = UniversalPlatform.isIOS;
    if (android || ios) {
      pp('$mm 🍎 🍎 _listen to FCM message streams ... 🍎 🍎');
      pp('$mm ... _listenToFCM activityStream ...');

      activitySubscriptionFCM =
          fcmBloc.activityStream.listen((ActivityModel model) {
        pp('$mm activityStream delivered activity data ... ${model.date!}');
        // if (isActivityValid(model)) {
        //   models.insert(0, model);
        // }
        if (mounted) {
          setState(() {});
        }
      });
      projectSubscriptionFCM =
          fcmBloc.projectStream.listen((Project project) async {
        _getData(false);
        if (mounted) {
          pp('$mm: 🍎 🍎 project arrived: ${project.name} ... 🍎 🍎');
          setState(() {});
        }
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
      userSubscriptionFCM = fcmBloc.userStream.listen((user) async {
        pp('$mm: 🍎 🍎 user arrived... 🍎 🍎');
        _getData(false);
        if (mounted) {
          setState(() {});
        }
      });
      photoSubscriptionFCM = fcmBloc.photoStream.listen((user) async {
        pp('$mm: 🍎 🍎 photoSubscriptionFCM photo arrived... 🍎 🍎');
        _getData(false);
        if (mounted) {
          setState(() {});
        }
      });

      videoSubscriptionFCM = fcmBloc.videoStream.listen((Video message) async {
        pp('$mm: 🍎 🍎 videoSubscriptionFCM video arrived... 🍎 🍎');
        _getData(false);
        if (mounted) {
          pp('DashboardMobile: 🍎 🍎 showMessageSnackbar: ${message.projectName} ... 🍎 🍎');
          setState(() {});
        }
      });
      audioSubscriptionFCM = fcmBloc.audioStream.listen((Audio message) async {
        pp('$mm: 🍎 🍎 audioSubscriptionFCM audio arrived... 🍎 🍎');
        _getData(false);
        if (mounted) {}
      });
      projectPositionSubscriptionFCM =
          fcmBloc.projectPositionStream.listen((ProjectPosition message) async {
        pp('$mm: 🍎 🍎 projectPositionSubscriptionFCM position arrived... 🍎 🍎');
        _getData(false);
        if (mounted) {}
      });
      projectPolygonSubscriptionFCM =
          fcmBloc.projectPolygonStream.listen((ProjectPolygon message) async {
        pp('$mm: 🍎 🍎 projectPolygonSubscriptionFCM polygon arrived... 🍎 🍎');
        _getData(false);
        if (mounted) {}
      });
    } else {
      pp('App is running on the Web 👿👿👿firebase messaging is OFF 👿👿👿');
    }
  }

  @override
  void dispose() {
    _gridViewAnimationController.dispose();
    super.dispose();
  }

  _navigateToMedia() async {
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
              dataApiDog: widget.dataApiDog,
              geoUploader: widget.geoUploader,
              cloudStorageBloc: widget.cloudStorageBloc,
              fcmBloc: widget.fcmBloc,
            )));
  }

  bool _showPhoto = false;
  bool _showVideo = false;
  bool _showAudio = false;
  final mm = ' 🍔 🍔 🍔 🍔 🍔 🍔ProjectDashboardTabletLandscape: ';

  void _displayPhoto(Photo photo) async {
    pp('$mm _displayPhoto ...');
    this.photo = photo;
    final settings = await prefsOGx.getSettings();
    translatedDate = getFmtDate(photo.created!, settings!.locale!);
    setState(() {
      _showPhoto = true;
      _showVideo = false;
      _showAudio = false;
    });
  }

  void _displayVideo(Video video) async {
    pp('$mm _displayVideo ...');
    this.video = video;
    setState(() {
      _showPhoto = false;
      _showVideo = true;
      _showAudio = false;
    });
  }

  void _displayAudio(Audio audio) async {
    pp('$mm _displayAudio ...');
    this.audio = audio;
    setState(() {
      _showPhoto = false;
      _showVideo = false;
      _showAudio = true;
    });
  }

  Photo? photo;
  Video? video;
  Audio? audio;
  String? translatedDate;

  void _navigateToPositionsMap() async {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 1),
            child: ProjectMapMobile(
              project: widget.project,
            )));
  }

  void _navigateToPolygonsMap() async {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 1),
            child: ProjectPolygonMapMobile(
              project: widget.project,
            )));
  }

  void _navigateToGeofenceMap(GeofenceEvent event) async {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 1),
            child: GeofenceMap(
              geofenceEvent: event!,
            )));
  }

  void _navigateToPhotoMap() {
    pp('$mm _navigateToPhotoMap ...');

    if (mounted) {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.scale,
              alignment: Alignment.topLeft,
              duration: const Duration(milliseconds: 1000),
              child: PhotoMap(
                photo: photo!,
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text(
          'Project Dashboard',
          style: myTextStyleLarge(context),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(64),
          child: SizedBox(),
        ),
      ),
      body: Stack(
        children: [
          OrientationLayoutBuilder(landscape: (context) {
            return Row(
              children: [
                SizedBox(
                  width: (width / 2),
                  // height: 500,
                  child: Center(
                    child: dashboardStrings == null
                        ? const SizedBox()
                        : ProjectDashboardGrid(
                            dashboardStrings: dashboardStrings!,
                            crossAxisCount: 3,
                            topPadding: 32,
                            showProjectName: true,
                            onTypeTapped: onTypeTapped,
                            project: widget.project),
                  ),
                ),
                GeoActivity(
                  width: (width / 2) - 120,
                  forceRefresh: true,
                  project: widget.project,
                  prefsOGx: widget.prefsOGx, cacheManager: widget.cacheManager,
                  thinMode: false,
                  fcmBloc: widget.fcmBloc,
                  organizationBloc: widget.organizationBloc,
                  projectBloc: widget.projectBloc,
                  dataApiDog: widget.dataApiDog,
                  geoUploader: widget.geoUploader,
                  cloudStorageBloc: widget.cloudStorageBloc,
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
                  showOrgMessage: (message) {},
                ),
              ],
            );
          }, portrait: (context) {
            return Row(
              children: [
                SizedBox(
                  width: (width / 2) + 80,
                  child: Center(
                    child: dashboardStrings == null
                        ? const SizedBox()
                        : ProjectDashboardGrid(
                            dashboardStrings: dashboardStrings!,
                            crossAxisCount: 2,
                            topPadding: 80,
                            showProjectName: true,
                            onTypeTapped: onTypeTapped,
                            project: widget.project),
                  ),
                ),
                GeoActivity(
                  width: (width / 2) - 80,
                  forceRefresh: true,
                  project: widget.project,
                  prefsOGx: widget.prefsOGx, cacheManager: widget.cacheManager,
                  fcmBloc: widget.fcmBloc,
                  organizationBloc: widget.organizationBloc,
                  projectBloc: widget.projectBloc,
                  dataApiDog: widget.dataApiDog,
                  geoUploader: widget.geoUploader,
                  cloudStorageBloc: widget.cloudStorageBloc,
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
                  showOrgMessage: (message) {},
                ),
              ],
            );
          }),
          _showPhoto
              ? Positioned(
                  left: 100,
                  right: 100,
                  top: 12,
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
                          onMapRequested: (photo) {
                            _navigateToPhotoMap();
                          },
                          onRatingRequested: (photo) {
                            pp('show rating ui');
                          },
                          onPhotoCardClose: () {
                            setState(() {
                              _showPhoto = false;
                            });
                          },
                        ),
                      ),
                    ),
                  ))
              : const SizedBox(),
          _showVideo
              ? Positioned(
                  left: 100,
                  right: 100,
                  top: 12,
                  child: GioVideoPlayer(
                    width: 400,
                    video: video!,
                    onCloseRequested: () {
                      if (mounted) {
                        setState(() {
                          _showVideo = false;
                        });
                      }
                    },
                    dataApiDog: widget.dataApiDog,
                  ),
                )
              : const SizedBox(),
          _showAudio
              ? Positioned(
                  left: 100,
                  right: 100,
                  top: 160,
                  child: GioAudioPlayer(
                    cacheManager: widget.cacheManager,
                    prefsOGx: widget.prefsOGx,
                    audio: audio!,
                    onCloseRequested: () {
                      if (mounted) {
                        setState(() {
                          _showAudio = false;
                        });
                      }
                    },
                    dataApiDog: widget.dataApiDog,
                  ))
              : const SizedBox(),
        ],
      ),
    ));
  }

  void _navigateToLocationResponseMap(LocationResponse locationResponse) async {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 1),
            child: LocationResponseMap(
              locationResponse: locationResponse!,
            )));
  }

  onTypeTapped(int p1) {
    switch (p1) {
      case typePhotos:
        _navigateToMedia();
        break;
      case typeVideos:
        _navigateToMedia();
        break;
      case typeAudios:
        _navigateToMedia();
        break;
      case typePositions:
        _navigateToPositionsMap();
        break;
      case typePolygons:
        _navigateToPolygonsMap();
        break;
    }
  }
}
