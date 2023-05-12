import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geo_monitor/library/cache_manager.dart';
import 'package:geo_monitor/library/data/location_request.dart';
import 'package:geo_monitor/library/data/location_response.dart';
import 'package:geo_monitor/ui/activity/activity_header.dart';
import 'package:geo_monitor/ui/activity/activity_stream_card.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../l10n/translation_handler.dart';
import '../../library/api/prefs_og.dart';
import '../../library/data/activity_model.dart';
import '../../library/data/audio.dart';
import '../../library/data/geofence_event.dart';
import '../../library/data/org_message.dart';
import '../../library/data/photo.dart';
import '../../library/data/project.dart';
import '../../library/data/project_polygon.dart';
import '../../library/data/project_position.dart';
import '../../library/data/settings_model.dart';
import '../../library/data/user.dart';
import '../../library/data/video.dart';
import '../../library/functions.dart';
import '../../library/ui/loading_card.dart';
import 'activity_list_card.dart';

class ActivityList extends StatefulWidget {
  const ActivityList({
    Key? key,
    required this.onPhotoTapped,
    required this.onVideoTapped,
    required this.onAudioTapped,
    required this.onUserTapped,
    required this.onProjectTapped,
    required this.onProjectPositionTapped,
    required this.onPolygonTapped,
    required this.onGeofenceEventTapped,
    required this.onOrgMessage,
    required this.user,
    required this.project,
    required this.onLocationResponse,
    required this.onLocationRequest, required this.prefsOGx, required this.cacheManager,
  }) : super(key: key);

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

  final User? user;
  final Project? project;
  final PrefsOGx prefsOGx;
  final CacheManager cacheManager;

  @override
  State<ActivityList> createState() => ActivityListState();
}

class ActivityListState extends State<ActivityList>
    with SingleTickerProviderStateMixin {
  final ScrollController listScrollController = ScrollController();
  SettingsModel? settings;

  // late StreamSubscription<ActivityModel> subscription;
  // late StreamSubscription<SettingsModel> settingsSubscriptionFCM;
  // var models = <ActivityModel>[];
  static const userActive = 0, projectActive = 1, orgActive = 2;
  late int activeType;
  User? user;
  bool busy = true;
  String? prefix,
      suffix,
      name,
      noActivities,
      title,
      loadingActivities,
      tapToRefresh;
  final mm = '😎😎😎😎😎😎 ActivityList: 😎';
  String? locale;
  ActivityStrings? activityStrings;
  bool sortedByDateAscending = false;
  bool sortedAscending = false;

  @override
  void initState() {
    super.initState();
    _setTexts();
    // _getData(true);
    // _listenToFCM();
  }

  @override
  void dispose() {
    // settingsSubscriptionFCM.cancel();
    // subscription.cancel();
    super.dispose();
  }

  Future _setTexts() async {
    user = await prefsOGx.getUser();
    settings = await prefsOGx.getSettings();
    locale = settings!.locale;
    if (widget.project != null) {
      title = await translator.translate('projectActivity', settings!.locale!);
      name = widget.project!.name!;
    } else if (widget.user != null) {
      title = await translator.translate('memberActivity', settings!.locale!);
      name = widget.user!.name;
    } else {
      title =
          await translator.translate('organizationActivity', settings!.locale!);
      name = user!.organizationName;
    }
    activityStrings = await ActivityStrings.getTranslated(settings!.locale!);
    loadingActivities =
        await translator.translate('loadingActivities', settings!.locale!);

    var sub = await translator.translate('activityTitle', settings!.locale!);
    int index = sub.indexOf('\$');
    prefix = sub.substring(0, index);
    suffix = sub.substring(index + 6);
    setState(() {});
  }

  Future<void> _handleTappedActivity(ActivityModel act) async {
    if (act.photo != null) {
      widget.onPhotoTapped(act.photo!);
    }
    if (act.video != null) {
      widget.onVideoTapped(act.video!);
    }

    if (act.audio != null) {
      widget.onAudioTapped(act.audio!);
    }

    if (act.user != null) {}
    if (act.projectPosition != null) {
      widget.onProjectPositionTapped(act.projectPosition!);
    }
    if (act.locationRequest != null) {
      widget.onLocationRequest(act.locationRequest!);
    }
    if (act.locationResponse != null) {
      widget.onLocationResponse(act.locationResponse!);
    }
    if (act.geofenceEvent != null) {
      widget.onGeofenceEventTapped(act.geofenceEvent!);
    }
    if (act.orgMessage != null) {
      widget.onOrgMessage(act.orgMessage!);
    }
  }

  int numberOfActivities = 0;
  bool forceRefresh = false;
  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      tablet: OrientationLayoutBuilder(
        landscape: (context) {
          return Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: prefix == null
                        ? const SizedBox()
                        : ActivityHeader(
                            prefix: prefix!,
                            suffix: suffix!,
                            onRefreshRequested: () {
                              pp('$mm onRefreshRequested J');
                              setState(() {
                                forceRefresh = true;
                              });
                            },
                            hours: settings == null
                                ? 12
                                : settings!.activityStreamHours!,
                            number: 0,
                            onSortRequested: () {
                              pp('$mm onSortRequested');
                            },
                          ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Expanded(
                    child: activityStrings == null
                        ? const SizedBox()
                        : Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: ActivityListCard(
                              topPadding: 0.0,
                              prefsOGx: widget.prefsOGx, cacheManager: widget.cacheManager,
                              onTapped: (act) {
                                _handleTappedActivity(act);
                              },
                            ),
                          ),
                  ),
                ],
              ),
              Positioned(
                left: 12,
                right: 12,
                child: SizedBox(
                  height: 100,
                  child: Card(
                    shape: getRoundedBorder(radius: 12),
                    elevation: 10,
                    child: Center(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                                vertical: 12,
                              ),
                              child: prefix == null
                                  ? const SizedBox()
                                  : ActivityHeader(
                                      prefix: prefix!,
                                      suffix: suffix!,
                                      onRefreshRequested: () {
                                        pp('$mm onRefreshRequested E');
                                        setState(() {
                                          forceRefresh = true;
                                        });
                                      },
                                      hours: settings!.activityStreamHours!,
                                      number: numberOfActivities,
                                      onSortRequested: () {
                                        pp('$mm onSortRequested');
                                      },
                                    ),
                            ),
                          ]),
                    ),
                  ),
                ),
              ),
              busy
                  ? Positioned(
                      bottom: 124,
                      left: 24,
                      child: loadingActivities == null
                          ? const SizedBox()
                          : LoadingCard(loadingData: loadingActivities!))
                  : const SizedBox()
            ],
          );
        },
        portrait: (context) {
          return Stack(
            children: [
              Column(
                children: [
                  InkWell(
                    onTap: () {
                      //_getData(true);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: prefix == null
                          ? const SizedBox()
                          : ActivityHeader(
                              prefix: prefix!,
                              suffix: suffix!,
                              onRefreshRequested: () {
                                pp('$mm onRefreshRequested G');

                                setState(() {
                                  forceRefresh = true;
                                });
                              },
                              hours: settings == null
                                  ? 12
                                  : settings!.activityStreamHours!,
                              number: numberOfActivities,
                              onSortRequested: () {
                                pp('$mm onSortRequested');
                              },
                            ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Expanded(
                    child: activityStrings == null
                        ? const SizedBox()
                        : Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: ActivityListCard(
                              topPadding: 0.0,
                              onTapped: (act) {
                                _handleTappedActivity(act);
                              }, prefsOGx: widget.prefsOGx, cacheManager: widget.cacheManager,
                            ),
                          ),
                  ),
                ],
              ),
              Positioned(
                left: 12,
                right: 12,
                child: SizedBox(
                  height: 100,
                  child: Card(
                    shape: getRoundedBorder(radius: 12),
                    elevation: 8,
                    child: Center(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                                vertical: 12,
                              ),
                              child: prefix == null
                                  ? const SizedBox()
                                  : ActivityHeader(
                                      prefix: prefix!,
                                      suffix: suffix!,
                                      onRefreshRequested: () {
                                        // _getData(true);
                                        pp('$mm onRefreshRequested B');
                                        setState(() {
                                          forceRefresh = true;
                                        });
                                      },
                                      hours: settings!.activityStreamHours!,
                                      number: numberOfActivities,
                                      onSortRequested: () {
                                        pp('$mm onSortRequested');
                                      },
                                    ),
                            ),
                          ]),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      mobile: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              title == null ? 'Activity' : title!,
              style: myTextStyleMediumBold(context),
            ),
            actions: [
              IconButton(
                  onPressed: () {
                    //_getData(true);
                    pp('$mm onRefreshRequested C');
                    setState(() {
                      forceRefresh = true;
                    });
                  },
                  icon: Icon(
                    Icons.refresh,
                    color: Theme.of(context).primaryColor,
                  )),
            ],
            bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          name == null ? 'Name' : name!,
                          style: myTextStyleLargePrimaryColor(context),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 24,
                    )
                  ],
                )),
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  InkWell(
                    onTap: () {
                      //_getData(true);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: prefix == null
                          ? const SizedBox()
                          : ActivityHeader(
                              prefix: prefix!,
                              suffix: suffix!,
                              onRefreshRequested: () {
                                pp('$mm onRefreshRequested D');
                                setState(() {
                                  forceRefresh = true;
                                });
                              },
                              hours: settings == null
                                  ? 12
                                  : settings!.activityStreamHours!,
                              number: numberOfActivities,
                              onSortRequested: () {
                                pp('$mm onSortRequested');
                              },
                            ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Expanded(
                    child: activityStrings == null
                        ? const SizedBox()
                        : Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: ActivityListCard(
                              topPadding: 0.0,
                              prefsOGx: widget.prefsOGx, cacheManager: widget.cacheManager,
                              onTapped: (act) {
                                _handleTappedActivity(act);
                              },
                            ),
                          ),
                  ),
                ],
              ),
              busy
                  ? Positioned(
                      bottom: 124,
                      left: 24,
                      child: loadingActivities == null
                          ? const SizedBox()
                          : LoadingCard(loadingData: loadingActivities!))
                  : const SizedBox()
            ],
          ),
        ),
      ),
    );
  }
}

/// holds and manages activity list
