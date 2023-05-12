import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geo_monitor/library/bloc/fcm_bloc.dart';
import 'package:geo_monitor/library/bloc/organization_bloc.dart';
import 'package:geo_monitor/library/data/location_request.dart';

import '../../l10n/translation_handler.dart';
import '../../library/api/prefs_og.dart';
import '../../library/bloc/project_bloc.dart';
import '../../library/bloc/user_bloc.dart';
import '../../library/cache_manager.dart';
import '../../library/data/activity_model.dart';
import '../../library/data/audio.dart';
import '../../library/data/geofence_event.dart';
import '../../library/data/location_response.dart';
import '../../library/data/org_message.dart';
import '../../library/data/photo.dart';
import '../../library/data/project.dart';
import '../../library/data/project_polygon.dart';
import '../../library/data/project_position.dart';
import '../../library/data/settings_model.dart';
import '../../library/data/user.dart';
import '../../library/data/video.dart';
import '../../library/functions.dart';
import '../../library/generic_functions.dart';
import 'activity_header.dart';
import 'activity_list_card.dart';
import 'activity_stream_card.dart';

class ActivityListTablet extends StatefulWidget {
  const ActivityListTablet({
    Key? key,
    required this.width,
    required this.onPhotoTapped,
    required this.onVideoTapped,
    required this.onAudioTapped,
    required this.onUserTapped,
    required this.onProjectTapped,
    required this.onProjectPositionTapped,
    required this.onPolygonTapped,
    required this.onGeofenceEventTapped,
    required this.onOrgMessage,
    required this.thinMode,
    this.user,
    this.project,
    required this.onLocationResponse,
    required this.onLocationRequest, required this.prefsOGx, required this.cacheManager,
  }) : super(key: key);
  final double width;
  final bool thinMode;
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
  State<ActivityListTablet> createState() => _ActivityListTabletState();
}

class _ActivityListTabletState extends State<ActivityListTablet>
    with SingleTickerProviderStateMixin {
  final ScrollController listScrollController = ScrollController();

  var models = <ActivityModel>[];

  late StreamSubscription<ActivityModel> subscription;
  late StreamSubscription<SettingsModel> settingsSubscriptionFCM;
  late StreamSubscription<SettingsModel> settingsSubscription;

  ActivityStrings? activityStrings;
  User? me;
  bool busy = true;
  final mm = '😎😎😎😎😎😎 ActivityListTablet: 😎 ';

  @override
  void initState() {
    pp('$mm ... initState');

    super.initState();
    _setTexts();
    _getData(true);
    _listenToStreams();
  }

  SettingsModel? sett;
  Future _setTexts() async {
    sett = await widget.prefsOGx.getSettings();

    activityStrings = await ActivityStrings.getTranslated(sett!.locale!);
    setState(() {});
  }

  @override
  void dispose() {
    listScrollController.dispose();
    subscription.cancel();
    settingsSubscription.cancel();
    settingsSubscriptionFCM.cancel();
    super.dispose();
  }

  String? title;
  String? prefix, suffix;

  void _getData(bool forceRefresh) async {
    setState(() {
      busy = true;
    });

    pp('$mm ... getting activity data ... forceRefresh: $forceRefresh');
    try {
      me = await prefsOGx.getUser();
      var hours = 12;
      hours = sett!.activityStreamHours!;
      var sub = await translator.translate('activityTitle', sett!.locale!);
      int index = sub.indexOf('\$');
      prefix = sub.substring(0, index);
      suffix = sub.substring(index + 6);

      if (widget.project != null) {
        await _getProjectData(forceRefresh, hours);
      } else if (widget.user != null) {
        await _getUserData(forceRefresh, hours);
      } else {
        await _getOrganizationActivity(forceRefresh, hours);
      }
      sortActivitiesDescending(models);
    } catch (e) {
      pp(e);
      if (mounted) {
        showToast(
            backgroundColor: Theme.of(context).primaryColor,
            textStyle: myTextStyleSmallBold(context),
            padding: 24,
            duration: const Duration(seconds: 6),
            message: '$e',
            context: context);
      }
    }
    if (mounted) {
      setState(() {
        busy = false;
      });
    }
  }

  Future _getOrganizationActivity(bool forceRefresh, int hours) async {
    models = await organizationBloc.getOrganizationActivity(
        organizationId: me!.organizationId!,
        hours: hours,
        forceRefresh: forceRefresh);
    pp('$mm org activity models found: ${models.length}');
  }

  Future _getProjectData(bool forceRefresh, int hours) async {
    models = await projectBloc.getProjectActivity(
        projectId: widget.project!.projectId!,
        hours: hours,
        forceRefresh: forceRefresh);
  }

  Future _getUserData(bool forceRefresh, int hours) async {
    models = await userBloc.getUserActivity(
        userId: widget.user!.userId!, hours: hours, forceRefresh: forceRefresh);
  }

  void _listenToStreams() async {
    pp('$mm ... _listenToStreams  ...');
    settingsSubscriptionFCM =
        fcmBloc.settingsStream.listen((SettingsModel event) async {
      await _setTexts();
      _getData(true);
    });
    settingsSubscription =
        organizationBloc.settingsStream.listen((SettingsModel event) async {
      pp('$mm settingsSubscription: delivered settings, locale: ${event.locale}');
      await translator.translate('settings', event.locale!);
      await _setTexts();
      _getData(false);
    });

    subscription =
        fcmBloc.activityStream.listen((ActivityModel activity) async {
      pp('$mm activityStream delivered activity data ... '
          'current models: ${models.length}\n\n');

      // if (model.geofenceEvent != null) {
      //   _getData(false);
      //   return;
      // }

      if (isActivityValid(activity)) {
        models.insert(0, activity);
        sortActivitiesDescending(models);
      }

      if (mounted) {
        setState(() {});
      }
    });
  }

  bool isActivityValid(ActivityModel activity) {
    pp('$mm check validity of incoming activity');
    if (widget.project == null && widget.user == null) {
      return true;
    }
    if (widget.project != null) {
      if (activity.projectId == widget.project!.projectId) {
        return true;
      }
    }
    if (widget.user != null) {
      if (activity.userId == widget.user!.userId) {
        return true;
      }
    }
    return false;
  }

  bool forceRefresh = false;
  int numberOfActivities = 0;
  @override
  Widget build(BuildContext context) {
    pp('$mm ... build method starting .........................');
    if (busy) {
      return Center(
        child: Card(
          shape: getRoundedBorder(radius: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 120,
              width: 300,
              child: Column(
                children: [
                  const SizedBox(
                    height: 36,
                  ),
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      backgroundColor: Colors.pink,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    activityStrings == null
                        ? 'Loading activities'
                        : activityStrings!.loadingActivities!,
                    style: myTextStyleSmall(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    if (models.isEmpty) {
      return Center(
        child: GestureDetector(
          onTap: () {
            _getData(true);
          },
          child: SizedBox(
            height: 200,
            child: Card(
              shape: getRoundedBorder(radius: 12),
              elevation: 8,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 32,
                      ),
                      Text(
                        activityStrings == null
                            ? 'No activities happening yet'
                            : activityStrings!.noActivities!,
                        style: myTextStyleSmall(context),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Text(
                        activityStrings == null
                            ? 'Tap to refresh'
                            : activityStrings!.tapToRefresh!,
                        style: myTextStyleSmallBold(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
        body: Stack(
      children: [
        SizedBox(
          width: widget.width,
          // height: height - 100,
          child: ActivityListCard(
            onTapped: _handleTappedActivity,
            prefsOGx: widget.prefsOGx, cacheManager: widget.cacheManager,
          ),
        ),
        Positioned(
          child: SizedBox(
            height: 100,
            child: Card(
              shape: getRoundedBorder(radius: 12),
              elevation: 10,
              child: Center(
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
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
                             setState(() {
                               forceRefresh = true;
                             });
                            },
                            hours: sett!.activityStreamHours!,
                            number: numberOfActivities,
                            onSortRequested: _sort,
                          ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ],
    ));
  }

  bool sortedAscending = false;
  void _sort() {
    if (sortedAscending) {
      sortActivitiesDescending(models);
      sortedAscending = false;
    } else {
      sortActivitiesAscending(models);
      sortedAscending = true;
    }
    //scroll to top after sort
    if (mounted) {
      setState(() {
        listScrollController.animateTo(
          listScrollController.position.minScrollExtent,
          curve: Curves.fastOutSlowIn,
          duration: const Duration(milliseconds: 2000),
        );
      });
    }
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

    if (act.user != null) {
      widget.onUserTapped(act.user!);
    }
    if (act.projectPosition != null) {
      widget.onProjectPositionTapped(act.projectPosition!);
    }
    if (act.locationRequest != null) {}
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
}
