import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geo_monitor/library/api/data_api_og.dart';
import 'package:geo_monitor/library/api/prefs_og.dart';
import 'package:geo_monitor/library/bloc/fcm_bloc.dart';
import 'package:geo_monitor/library/bloc/organization_bloc.dart';
import 'package:geo_monitor/library/bloc/project_bloc.dart';
import 'package:geo_monitor/library/data/activity_model.dart';
import 'package:geo_monitor/library/data/settings_model.dart';
import 'package:geo_monitor/ui/activity/activity_list_card.dart';
import 'package:geo_monitor/ui/activity/activity_stream_card.dart';
import 'package:page_transition/page_transition.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../l10n/translation_handler.dart';
import '../../library/bloc/cloud_storage_bloc.dart';
import '../../library/bloc/geo_uploader.dart';
import '../../library/cache_manager.dart';
import '../../library/data/audio.dart';
import '../../library/data/geofence_event.dart';
import '../../library/data/location_request.dart';
import '../../library/data/location_response.dart';
import '../../library/data/org_message.dart';
import '../../library/data/photo.dart';
import '../../library/data/project.dart';
import '../../library/data/project_polygon.dart';
import '../../library/data/project_position.dart';
import '../../library/data/user.dart';
import '../../library/data/video.dart';
import '../../library/emojis.dart';
import '../../library/functions.dart';
import '../../library/ui/media/time_line/project_media_timeline.dart';

class GioActivities extends StatefulWidget {
  const GioActivities(
      {Key? key,
      required this.onPhotoTapped,
      required this.onVideoTapped,
      required this.onAudioTapped,
      required this.onUserTapped,
      required this.onProjectTapped,
      required this.onProjectPositionTapped,
      required this.onPolygonTapped,
      required this.onGeofenceEventTapped,
      required this.onOrgMessage,
      required this.onLocationResponse,
      required this.onLocationRequest,
      required this.project,
      this.user,
      required this.prefsOGx,
      required this.cacheManager,
      required this.projectBloc,
      required this.organizationBloc,
      required this.dataApiDog,
      required this.fcmBloc,
      required this.geoUploader,
      required this.cloudStorageBloc, required this.onRefreshRequested})
      : super(key: key);

  final Function(Photo) onPhotoTapped;
  final Function(Video) onVideoTapped;
  final Function(Audio) onAudioTapped;
  final Function(User) onUserTapped;
  final Function(Project) onProjectTapped;
  final Function(ProjectPosition) onProjectPositionTapped;
  final Function(ProjectPolygon) onPolygonTapped;
  final Function(GeofenceEvent) onGeofenceEventTapped;
  final Function(OrgMessage) onOrgMessage;
  final Function(LocationResponse) onLocationResponse;
  final Function(LocationRequest) onLocationRequest;
  final Project? project;
  final User? user;
  final PrefsOGx prefsOGx;
  final CacheManager cacheManager;
  final ProjectBloc projectBloc;
  final OrganizationBloc organizationBloc;
  final DataApiDog dataApiDog;
  final FCMBloc fcmBloc;
  final GeoUploader geoUploader;
  final CloudStorageBloc cloudStorageBloc;
  final Function onRefreshRequested;


  @override
  GioActivitiesState createState() => GioActivitiesState();
}

class GioActivitiesState extends State<GioActivities>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late StreamSubscription<ActivityModel> subscription;
  late StreamSubscription<SettingsModel> settingsSubscriptionFCM;
  late SettingsModel settings;
  var activities = <ActivityModel>[];
  ActivityStrings? activityStrings;

  @override
  void initState() {
    _animationController = AnimationController(vsync: this);
    super.initState();
    _setTexts();
  }

  Future _setTexts() async {
    settings = await widget.prefsOGx.getSettings();
    activityStrings = (await ActivityStrings.getTranslated(settings.locale!))!;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapped(ActivityModel activity) async {
    pp('${E.redDot} GioActivitiesState: onTapped - ActivityModel: ${activity.toJson()}');
    if (activity.photo != null) {
      widget.onPhotoTapped(activity.photo!);
    }
    if (activity.audio != null) {
      widget.onAudioTapped(activity.audio!);
    }
    if (activity.video != null) {
      widget.onVideoTapped(activity.video!);
    }
    if (activity.user != null) {
      widget.onUserTapped(activity.user!);
    }
    if (activity.geofenceEvent != null) {
      widget.onGeofenceEventTapped(activity.geofenceEvent!);
    }
    if (activity.project != null) {
      widget.onProjectTapped(activity.project!);
    }
    if (activity.projectPosition != null) {
      widget.onProjectPositionTapped(activity.projectPosition!);
    }
    if (activity.projectPolygon != null) {
      widget.onPolygonTapped(activity.projectPolygon!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final  color = getTextColorForBackground(Theme.of(context).primaryColor);
    return ScreenTypeLayout.builder(
      mobile: (context) {
        return MobileList(
          prefsOGx: widget.prefsOGx,
          cacheManager: widget.cacheManager,
          fcmBloc: widget.fcmBloc,
          organizationBloc: widget.organizationBloc,
          geoUploader: widget.geoUploader,
          cloudStorageBloc: widget.cloudStorageBloc,
          projectBloc: widget.projectBloc,
          project: widget.project,
          onTapped: _onTapped,
          onRefreshRequested: (){
            widget.onRefreshRequested();
          },
          dataApiDog: widget.dataApiDog,
        );
      },
      tablet: (ctx) {
        return TabletList(
          fcmBloc: widget.fcmBloc,
          organizationBloc: widget.organizationBloc,
          projectBloc: widget.projectBloc,
          project: widget.project,
          dataApiDog: widget.dataApiDog,
          prefsOGx: widget.prefsOGx,
          cacheManager: widget.cacheManager,
          onTapped: _onTapped,
          onRefreshRequested: (){
            widget.onRefreshRequested();
          },
        );
      },
    );
  }
}

class TabletList extends StatefulWidget {
  const TabletList(
      {Key? key,
      required this.onTapped,
      required this.prefsOGx,
      required this.cacheManager,
      required this.projectBloc,
      required this.project,
      required this.organizationBloc,
      required this.dataApiDog,
      required this.fcmBloc, required this.onRefreshRequested})
      : super(key: key);
  final Function(ActivityModel) onTapped;
  final PrefsOGx prefsOGx;
  final CacheManager cacheManager;
  final ProjectBloc projectBloc;
  final Project? project;
  final OrganizationBloc organizationBloc;
  final DataApiDog dataApiDog;
  final FCMBloc fcmBloc;
  final Function onRefreshRequested;


  @override
  State<TabletList> createState() => TabletListState();
}

class TabletListState extends State<TabletList> {
  ActivityStrings? activityStrings;
  late SettingsModel settings;
  @override
  void initState() {
    super.initState();
    _setTexts();
  }

  void _setTexts() async {
    settings = await prefsOGx.getSettings();
    activityStrings = await ActivityStrings.getTranslated(settings.locale!);
    setState(() {});
  }

  onTapped(ActivityModel act) {
    pp(' 🍎 onTapped ... ${act.toJson()}');
    widget.onTapped(act);
  }

  @override
  Widget build(BuildContext context) {
    return OrientationLayoutBuilder(landscape: (context) {
      return ActivityListCard(
          prefsOGx: widget.prefsOGx,
          cacheManager: widget.cacheManager,
          onTapped: onTapped);
    }, portrait: (context) {
      return ActivityListCard(
          prefsOGx: widget.prefsOGx,
          cacheManager: widget.cacheManager,
          onTapped: onTapped);
    });
  }
}

//////////////////////////////////////
class MobileList extends StatefulWidget {
  const MobileList(
      {Key? key,
      required this.onTapped,
      required this.prefsOGx,
      required this.cacheManager,
      required this.projectBloc,
      required this.project,
      required this.organizationBloc,
      required this.dataApiDog,
      required this.fcmBloc,
      required this.geoUploader,
      required this.cloudStorageBloc, required this.onRefreshRequested})
      : super(key: key);
  final Function(ActivityModel) onTapped;
  final PrefsOGx prefsOGx;
  final CacheManager cacheManager;
  final ProjectBloc projectBloc;
  final Project? project;
  final OrganizationBloc organizationBloc;
  final DataApiDog dataApiDog;
  final FCMBloc fcmBloc;
  final GeoUploader geoUploader;
  final CloudStorageBloc cloudStorageBloc;
  final Function onRefreshRequested;

  @override
  State<MobileList> createState() => MobileListState();
}

class MobileListState extends State<MobileList> {
  String? locale, title;
  ActivityStrings? activityStrings;
  SettingsModel? settings;

  @override
  void initState() {
    super.initState();
    _setTexts();
  }

  void _setTexts() async {
    settings = await prefsOGx.getSettings();
    activityStrings = await ActivityStrings.getTranslated(settings!.locale!);
    title = await translator.translate('events', settings!.locale!);
    setState(() {});
  }

  void _navigateToTimeline() {
    // pp('........ _navigateToProjectMedia with project: 🔆🔆🔆${widget.project?.toJson()}🔆🔆🔆');
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(milliseconds: 1000),
            child: ProjectMediaTimeline(
              project: widget.project,
              projectBloc: widget.projectBloc,
              organizationBloc: widget.organizationBloc,
              prefsOGx: widget.prefsOGx,
              cacheManager: widget.cacheManager,
              dataApiDog: widget.dataApiDog,
              fcmBloc: widget.fcmBloc,
              geoUploader: widget.geoUploader,
              cloudStorageBloc: widget.cloudStorageBloc,
            )));
  }

  _onTapped(ActivityModel activity) async {
    widget.onTapped(activity);
  }

  @override
  Widget build(BuildContext context) {
    var color = getTextColorForBackground(Theme.of(context).primaryColor);
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;

    if (isDarkMode) {
      color = Theme.of(context).primaryColor;
    }
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title == null ? 'Events' : title!,
            style: myTitleTextStyle(context, color),
          ),
        ),
        actions: [
          IconButton(onPressed: (){
            widget.onRefreshRequested();
          }, icon: const Icon(Icons.refresh)),
        ],
      ),
          backgroundColor: isDarkMode?Theme.of(context).canvasColor: Colors.brown[50],
          body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ActivityListCard(
          prefsOGx: widget.prefsOGx,
          cacheManager: widget.cacheManager,
          onTapped: (act) {
            _onTapped(act);
          },
        ),
      ),
    ));
  }
}
