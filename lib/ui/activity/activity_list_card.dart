import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geo_monitor/library/cache_manager.dart';
import 'package:geo_monitor/ui/activity/activity_header.dart';

import '../../dashboard_khaya/recent_event_list.dart';
import '../../l10n/translation_handler.dart';
import '../../library/api/prefs_og.dart';
import '../../library/bloc/fcm_bloc.dart';
import '../../library/bloc/organization_bloc.dart';
import '../../library/bloc/project_bloc.dart';
import '../../library/bloc/user_bloc.dart';
import '../../library/data/activity_model.dart';
import '../../library/data/project.dart';
import '../../library/data/settings_model.dart';
import '../../library/data/user.dart';
import '../../library/functions.dart';
import '../../library/generic_functions.dart';
import '../../library/ui/loading_card.dart';
import 'activity_stream_card.dart';

class ActivityListCard extends StatefulWidget {
  const ActivityListCard(
      {Key? key,
      required this.onTapped,
      this.topPadding,
      this.user,
      this.project,
      required this.prefsOGx,
      required this.cacheManager})
      : super(key: key);

  final Function(ActivityModel) onTapped;
  final double? topPadding;
  final User? user;
  final Project? project;
  final PrefsOGx prefsOGx;
  final CacheManager cacheManager;

  // final bool refresh;
  // final Function(List<ActivityModel>) onRefreshed;

  @override
  State<ActivityListCard> createState() => _ActivityListCardState();
}

class _ActivityListCardState extends State<ActivityListCard> {
  late StreamSubscription<ActivityModel> subscription;
  late StreamSubscription<SettingsModel> settingsSubscriptionFCM;
  SettingsModel? settings;
  ActivityStrings? activityStrings;
  String? locale, prefix, suffix, loadingActivities;

  var models = <ActivityModel>[];
  static const userActive = 0, projectActive = 1, orgActive = 2;
  late int activeType;
  bool loading = false;
  var users = <User>[];
  bool busy = false, loadingSettings = false;

  @override
  void initState() {
    super.initState();
    _setTexts();
    _listenToFCM();
    _getData(false);
  }

  Future _setTexts() async {
    setState(() {
      loadingSettings = true;
    });
    settings = await prefsOGx.getSettings();
    activityStrings = await ActivityStrings.getTranslated(settings!.locale!);
    var sub = await translator.translate('activityTitle', settings!.locale!);

    int index = sub.indexOf('\$');
    prefix = sub.substring(0, index);
    suffix = sub.substring(index + 6);
    setState(() {
      loadingSettings = false;
    });
  }

  Future _getData(bool forceRefresh) async {
    if (mounted) {
      setState(() {
        loading = true;
      });
    }
    pp('$mm ... getting activity data ... 🔵forceRefresh: $forceRefresh');
    try {
      users = await widget.cacheManager.getUsers();
      settings = await widget.prefsOGx.getSettings();
      var hours = settings!.activityStreamHours!;
      pp('$mm ... get Activity (n hours) ... : $hours');
      if (widget.project != null) {
        activeType = projectActive;
        await _getProjectData(forceRefresh, hours);
      } else if (widget.user != null) {
        activeType = userActive;
        await _getUserData(forceRefresh, hours);
      } else {
        activeType = orgActive;
        await _getOrganizationData(forceRefresh, hours);
      }
      sortActivitiesDescending(models);
    } catch (e) {
      pp(e);
      if (mounted) {
        setState(() {
          loading = false;
        });
        showToast(
            backgroundColor: Theme.of(context).primaryColor,
            textStyle: myTextStyleMedium(context),
            padding: 16,
            duration: const Duration(seconds: 10),
            message: '$e',
            context: context);
      }
    }
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _translateUserTypes() async {
    for (var activity in models) {
      if (activity.userId != null) {
        final activityUser = await cacheManager.getUserById(activity.userId!);
        if (activityUser != null) {
          final translatedUserType =
              await getTranslatedUserType(activityUser.userType!);
          activity.translatedUserType = translatedUserType;
          // pp('🍎 translated userType:, translatedUserType: $translatedUserType');
        } else {
          pp('🍎 activityUser not found in cache; activity: ${activity.toJson()}');
          activity.translatedUserType = '';
        }
      } else if (activity.user != null) {
        final translatedUserType =
            await getTranslatedUserType(activity.user!.userType!);
        activity.translatedUserType = translatedUserType;
      } else {
        activity.translatedUserType = 'User type unknown';
      }
    }
  }

  Future _getOrganizationData(bool forceRefresh, int hours) async {
    models = await organizationBloc.getCachedOrganizationActivity(
        organizationId: settings!.organizationId!, hours: hours);

    if (models.isNotEmpty) {
      await _translateUserTypes();
      setState(() {
        loading = false;
      });
    }
    pp('$mm _getOrganizationData 1: ............ activities: ${models.length}');
    await Future.delayed(const Duration(seconds: 10));
    models = await organizationBloc.getOrganizationActivity(
        organizationId: settings!.organizationId!,
        hours: hours,
        forceRefresh: forceRefresh);

    pp('$mm _getOrganizationData 2 :............ activities: ${models.length}');
    if (models.isNotEmpty) {
      await _translateUserTypes();
      setState(() {
        loading = false;
      });
    }
  }

  Future _getProjectData(bool forceRefresh, int hours) async {
    models = await projectBloc.getProjectActivity(
        projectId: widget.project!.projectId!,
        hours: hours,
        forceRefresh: forceRefresh);
    if (models.isNotEmpty) {
      await _translateUserTypes();
      setState(() {});
    }
  }

  Future _getUserData(bool forceRefresh, int hours) async {
    models = await userBloc.getUserActivity(
        userId: widget.user!.userId!, hours: hours, forceRefresh: forceRefresh);
    if (models.isNotEmpty) {
      await _translateUserTypes();
      setState(() {});
    }
  }

  void _listenToFCM() async {
    pp('$mm ... _listenToFCM activityStream ...');

    settingsSubscriptionFCM =
        fcmBloc.settingsStream.listen((SettingsModel event) async {
      if (mounted) {
        _getData(true);
      }
    });

    subscription = fcmBloc.activityStream.listen((ActivityModel model) async {
      pp('$mm activityStream delivered activity data ... ${model.date!}, current models: ${models.length}');
      if (models.length < 2) {
        await _getData(true);
      } else {
        await _getData(false);
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loadingSettings) {
      return const SizedBox();
    }
    return busy
        ? Center(
            child:
                LoadingCard(loadingData: activityStrings!.loadingActivities!))
        : Stack(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: widget.topPadding == null ? 72 : widget.topPadding!,
                  ),
                  Expanded(
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: models.length,
                        itemBuilder: (_, index) {
                          var act = models.elementAt(index);
                          if (act.translatedUserType != null) {}
                          return GestureDetector(
                            onTap: () {
                              pp('$mm event has been tapped - calling widget.onTapped(act); $widget');
                              widget.onTapped(act);
                            },
                            child: EventView(
                              activity: act,
                              height: 84,
                              width: 300,
                              locale: settings!.locale!,
                            ),
                          );
                        }),
                  ),
                ],
              ),
              Positioned(
                  child: Card(
                elevation: 12,
                shape: getRoundedBorder(radius: 16),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0.0, vertical: 16),
                  child: settings == null
                      ? const SizedBox()
                      : ActivityHeader(
                          hours: settings!.activityStreamHours!,
                          number: models.length,
                          prefix: prefix!,
                          suffix: suffix!,
                          onRefreshRequested: () {
                            _getData(true);
                          },
                          onSortRequested: () {},
                        ),
                ),
              )),
              loading
                  ? Positioned(
                      bottom: 124,
                      left: 24,
                      right: 24,
                      child: activityStrings == null
                          ? const SizedBox()
                          : LoadingCard(
                              loadingData: activityStrings!.loadingActivities!))
                  : const SizedBox()
            ],
          );
  }

  static const mm = '🌎🌎🌎🌎🌎 ActivityListCard 🌎';
}
