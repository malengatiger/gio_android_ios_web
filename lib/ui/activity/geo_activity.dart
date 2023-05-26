import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geo_monitor/library/api/prefs_og.dart';
import 'package:geo_monitor/library/bloc/organization_bloc.dart';
import 'package:geo_monitor/library/data/activity_model.dart';
import 'package:geo_monitor/library/data/geofence_event.dart';
import 'package:geo_monitor/library/data/location_response.dart';
import 'package:geo_monitor/library/data/settings_model.dart';
import 'package:geo_monitor/ui/activity/gio_activities.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:universal_platform/universal_platform.dart';

import '../../l10n/translation_handler.dart';
import '../../library/api/data_api_og.dart';
import '../../library/bloc/cloud_storage_bloc.dart';
import '../../library/bloc/fcm_bloc.dart';
import '../../library/bloc/geo_uploader.dart';
import '../../library/bloc/project_bloc.dart';
import '../../library/cache_manager.dart';
import '../../library/data/audio.dart';
import '../../library/data/location_request.dart';
import '../../library/data/org_message.dart';
import '../../library/data/photo.dart';
import '../../library/data/project.dart';
import '../../library/data/project_polygon.dart';
import '../../library/data/project_position.dart';
import '../../library/data/user.dart';
import '../../library/data/video.dart';
import '../../library/functions.dart';
import '../../library/generic_functions.dart';

class GeoActivity extends StatefulWidget {
  const GeoActivity({
    Key? key,
    required this.width,
    required this.thinMode,
    required this.showPhoto,
    required this.showVideo,
    required this.showAudio,
    this.user,
    required this.project,
    required this.forceRefresh,
    required this.showLocationResponse,
    required this.showLocationRequest,
    required this.showUser,
    required this.showProjectPosition,
    required this.showOrgMessage,
    required this.showGeofenceEvent,
    required this.showProjectPolygon,
    required this.prefsOGx,
    required this.cacheManager,
    required this.projectBloc,
    required this.organizationBloc,
    required this.dataApiDog,
    required this.fcmBloc,
    required this.geoUploader,
    required this.cloudStorageBloc,
  }) : super(key: key);
  final double width;
  final bool thinMode;

  final Function(Photo) showPhoto;
  final Function(Video) showVideo;
  final Function(Audio) showAudio;
  final Function(LocationResponse) showLocationResponse;
  final Function(LocationRequest) showLocationRequest;
  final Function(User) showUser;
  final Function(ProjectPosition) showProjectPosition;
  final Function(OrgMessage) showOrgMessage;
  final Function(GeofenceEvent) showGeofenceEvent;
  final Function(ProjectPolygon) showProjectPolygon;

  final User? user;
  final bool forceRefresh;
  final PrefsOGx prefsOGx;
  final CacheManager cacheManager;
  final ProjectBloc projectBloc;
  final Project? project;
  final OrganizationBloc organizationBloc;
  final DataApiDog dataApiDog;
  final FCMBloc fcmBloc;
  final GeoUploader geoUploader;
  final CloudStorageBloc cloudStorageBloc;

  @override
  GeoActivityState createState() => GeoActivityState();
}

class GeoActivityState extends State<GeoActivity>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late StreamSubscription<Photo> photoSubscriptionFCM;
  late StreamSubscription<Video> videoSubscriptionFCM;
  late StreamSubscription<Audio> audioSubscriptionFCM;
  late StreamSubscription<ProjectPosition> projectPositionSubscriptionFCM;
  late StreamSubscription<ProjectPolygon> projectPolygonSubscriptionFCM;
  late StreamSubscription<Project> projectSubscriptionFCM;
  late StreamSubscription<User> userSubscriptionFCM;
  late StreamSubscription<GeofenceEvent> geofenceSubscriptionFCM;
  late StreamSubscription<ActivityModel> activitySubscriptionFCM;

  late StreamSubscription<SettingsModel> settingsSubscription;

  ScrollController listScrollController = ScrollController();

  final mm = '❇️❇️❇️❇️❇️ GeoActivityTablet: ';

  bool busy = false;
  SettingsModel? settings;
  String? arrivedAt;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getSettings();
    _listenForFCM();
  }

  void _getSettings() async {
    settings = await prefsOGx.getSettings();
    setState(() {});
  }

  int count = 0;

  void _listenForFCM() async {
    var android = UniversalPlatform.isAndroid;
    var ios = UniversalPlatform.isIOS;
    if (android || ios) {
      pp('$mm 🍎🍎 _listen to FCM message streams ... 🍎🍎 '
          'geofence stream via geofenceSubscriptionFCM...');

      settingsSubscription =
          organizationBloc.settingsStream.listen((SettingsModel event) {
        settings = event;
        if (mounted) {
          setState(() {});
        }
      });

      activitySubscriptionFCM =
          fcmBloc.activityStream.listen((ActivityModel event) {
        if (mounted) {
          pp('$mm activitySubscriptionFCM: DOING NOTHING!!!!!!!!!!!!!!');
          setState(() {});
        }
      });

      geofenceSubscriptionFCM =
          fcmBloc.geofenceStream.listen((GeofenceEvent event) async {
        pp('$mm: 🍎geofenceSubscriptionFCM: 🍎 GeofenceEvent: '
            'user ${event.user!.name} arrived: ${event.projectName} ');
        _handleGeofenceEvent(event);
      });
    } else {
      pp('App is running on the Web 👿👿👿firebase messaging is OFF 👿👿👿');
    }
  }

  Future<void> _handleGeofenceEvent(GeofenceEvent event) async {
    pp('$mm _handleGeofenceEvent ....');
    var settings = await prefsOGx.getSettings();
    final arr = await translator.translate('memberArrived', settings.locale!);
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return settings == null
        ? const SizedBox()
        : SizedBox(
            width: widget.width,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: widget.width,
                child: ScreenTypeLayout(
                  mobile: GioActivities(
                    project: widget.project,
                    user: widget.user,
                    prefsOGx: widget.prefsOGx,
                    cacheManager: widget.cacheManager,
                    fcmBloc: widget.fcmBloc,
                    organizationBloc: widget.organizationBloc,
                    projectBloc: widget.projectBloc,
                    dataApiDog: widget.dataApiDog,
                    geoUploader: widget.geoUploader,
                    cloudStorageBloc: widget.cloudStorageBloc,
                    onPhotoTapped: (photo) {
                      widget.showPhoto(photo);
                    },
                    onVideoTapped: (video) {
                      widget.showVideo(video);
                    },
                    onAudioTapped: (audio) {
                      widget.showAudio(audio);
                    },
                    onUserTapped: (user) {},
                    onProjectTapped: (project) {},
                    onProjectPositionTapped: (projectPosition) {
                      widget.showProjectPosition(projectPosition);
                    },
                    onPolygonTapped: (projectPolygon) {
                      widget.showProjectPolygon(projectPolygon);
                    },
                    onGeofenceEventTapped: (geofenceEvent) {
                      widget.showGeofenceEvent(geofenceEvent);
                    },
                    onOrgMessage: (orgMessage) {
                      widget.showOrgMessage(orgMessage);
                    },
                    onLocationRequest: (locRequest) {
                      widget.showLocationRequest(locRequest);
                    },
                    onLocationResponse: (locResp) {
                      widget.showLocationResponse(locResp);
                    }, onRefreshRequested: (){
                    pp('$mm SOMEBODY requested a refresh ....');
                  },
                  ),
                  tablet: OrientationLayoutBuilder(
                    portrait: (context) {
                      return settings == null
                          ? const SizedBox()
                          : GioActivities(
                              prefsOGx: widget.prefsOGx,
                              cacheManager: widget.cacheManager,
                              user: widget.user,
                              project: widget.project,
                              fcmBloc: widget.fcmBloc,
                              organizationBloc: widget.organizationBloc,
                              projectBloc: widget.projectBloc,
                              dataApiDog: widget.dataApiDog,
                              geoUploader: widget.geoUploader,
                              cloudStorageBloc: widget.cloudStorageBloc,
                              onPhotoTapped: (photo) {
                                widget.showPhoto(photo);
                              },
                              onVideoTapped: (video) {
                                widget.showVideo(video);
                              },
                              onAudioTapped: (audio) {
                                widget.showAudio(audio);
                              },
                              onLocationRequest: (locRequest) {
                                widget.showLocationRequest(locRequest);
                              },
                              onLocationResponse: (locResp) {
                                widget.showLocationResponse(locResp);
                              },
                              onUserTapped: (user) {},
                              onProjectTapped: (project) {},
                              onProjectPositionTapped: (projectPosition) {
                                widget.showProjectPosition(projectPosition);
                              },
                              onPolygonTapped: (projectPolygon) {
                                widget.showProjectPolygon(projectPolygon);
                              },
                              onGeofenceEventTapped: (geofenceEvent) {
                                widget.showGeofenceEvent(geofenceEvent);
                              },
                              onOrgMessage: (orgMessage) {
                                widget.showOrgMessage(orgMessage);
                              }, onRefreshRequested: (){
                        pp('$mm SOMEBODY requested a refresh ....');
                      },
                            );
                    },
                    landscape: (context) {
                      return settings == null
                          ? const SizedBox()
                          : GioActivities(
                              user: widget.user,
                              project: widget.project,
                              prefsOGx: widget.prefsOGx,
                              cacheManager: widget.cacheManager,
                              fcmBloc: widget.fcmBloc,
                              organizationBloc: widget.organizationBloc,
                              projectBloc: widget.projectBloc,
                              dataApiDog: widget.dataApiDog,
                              geoUploader: widget.geoUploader,
                              cloudStorageBloc: widget.cloudStorageBloc,
                              onPhotoTapped: (photo) {
                                widget.showPhoto(photo);
                              },
                              onVideoTapped: (video) {
                                widget.showVideo(video);
                              },
                              onAudioTapped: (audio) {
                                widget.showAudio(audio);
                              },
                              onUserTapped: (user) {
                                widget.showUser(user);
                              },
                              onProjectTapped: (project) {},
                              onProjectPositionTapped: (projectPosition) {
                                widget.showProjectPosition(projectPosition);
                              },
                              onPolygonTapped: (projectPolygon) {
                                widget.showProjectPolygon(projectPolygon);
                              },
                              onGeofenceEventTapped: (geofenceEvent) {
                                widget.showGeofenceEvent(geofenceEvent);
                              },
                              onOrgMessage: (orgMessage) {},
                              onLocationResponse: (locResp) {
                                widget.showLocationResponse(locResp);
                              },
                              onLocationRequest: (locReq) {
                                widget.showLocationRequest(locReq);
                              }, onRefreshRequested: (){
                                pp('$mm SOMEBODY requested a refresh ....');
                      },
                            );
                    },
                  ),
                ),
              ),
            ),
          );
  }
}
