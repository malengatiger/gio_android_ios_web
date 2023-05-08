import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geo_monitor/library/api/prefs_og.dart';
import 'package:geo_monitor/library/data/activity_model.dart';
import 'package:geo_monitor/library/data/settings_model.dart';
import 'package:geo_monitor/ui/activity/activity_list_card.dart';
import 'package:geo_monitor/ui/activity/activity_stream_card.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../l10n/translation_handler.dart';
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
import '../../library/functions.dart';

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
      this.project,
      this.user})
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

  @override
  GioActivitiesState createState() => GioActivitiesState();
}

class GioActivitiesState extends State<GioActivities>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late StreamSubscription<ActivityModel> subscription;
  late StreamSubscription<SettingsModel> settingsSubscriptionFCM;
  SettingsModel? settings;
  var activities = <ActivityModel>[];
  ActivityStrings? activityStrings;

  @override
  void initState() {
    _animationController = AnimationController(vsync: this);
    super.initState();
    _setTexts();
  }

  Future _setTexts() async {
    activityStrings = (await ActivityStrings.getTranslated())!;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapped(ActivityModel activity) async {
    pp('onTapped - ${activity.toJson()}');
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
    return ScreenTypeLayout.builder(
      mobile: (context) {
        return MobileList(
          onTapped: _onTapped,
        );
      },
      tablet: (ctx) {
        return TabletList(
          onTapped: _onTapped,
        );
      },
    );
  }
}

class TabletList extends StatefulWidget {
  const TabletList({Key? key, required this.onTapped}) : super(key: key);
  final Function(ActivityModel) onTapped;

  @override
  State<TabletList> createState() => TabletListState();
}

class TabletListState extends State<TabletList> {
  ActivityStrings? activityStrings;
  SettingsModel? settings;
  @override
  void initState() {
    super.initState();
    _setTexts();
  }

  void _setTexts() async {
    settings = await prefsOGx.getSettings();
    activityStrings = await ActivityStrings.getTranslated();
    setState(() {});
  }

  onTapped(ActivityModel act) {
    pp(' 🍎 onTapped ... ${act.toJson()}');
    widget.onTapped(act);
  }

  @override
  Widget build(BuildContext context) {
    return OrientationLayoutBuilder(landscape: (context) {
      return ActivityListCard(onTapped: onTapped);
    }, portrait: (context) {
      return ActivityListCard(onTapped: onTapped);
    });
  }
}

//////////////////////////////////////
class MobileList extends StatefulWidget {
  const MobileList({Key? key, required this.onTapped}) : super(key: key);
  final Function(ActivityModel) onTapped;

  @override
  State<MobileList> createState() => _MobileListState();
}

class _MobileListState extends State<MobileList> {
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
    activityStrings = await ActivityStrings.getTranslated();
    title = await translator.translate('projectActivities', settings!.locale!);
  }

  _onTapped(ActivityModel activity) async {
    widget.onTapped(activity);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text(
          title == null ? 'Activities' : title!,
          style: myTextStyleSmall(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ActivityListCard(
          onTapped: (act) {
            _onTapped(act);
          },
        ),
      ),
    ));
  }
}
