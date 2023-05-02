import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geo_monitor/library/cache_manager.dart';
import 'package:geo_monitor/ui/activity/activity_header.dart';

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
import '../../library/ui/media/list/project_videos_page.dart';
import 'activity_stream_card.dart';

class ActivityListCard extends StatefulWidget {
  const ActivityListCard(
      {Key? key,
      required this.onTapped,
      this.topPadding,
      this.user,
      this.project})
      : super(key: key);

  final Function(ActivityModel) onTapped;
  final double? topPadding;
  final User? user;
  final Project? project;
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
  String? locale, prefix, suffix;

  var models = <ActivityModel>[];
  static const userActive = 0, projectActive = 1, orgActive = 2;
  late int activeType;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _setTexts();
    _listenToFCM();
    _getData(true);
  }

  Future _setTexts() async {
    settings = await prefsOGx.getSettings();
    activityStrings = await ActivityStrings.getTranslated();
    var sub = await translator.translate('activityTitle', settings!.locale!);
    int index = sub.indexOf('\$');
    prefix = sub.substring(0, index);
    suffix = sub.substring(index + 6);
  }

  Future _getData(bool forceRefresh) async {
    if (mounted) {
      setState(() {
        loading = true;
      });
    }
    pp('$mm ... getting activity data ... 🔵forceRefresh: $forceRefresh');
    try {
      settings = await prefsOGx.getSettings();
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
          pp('🍎 translated userType:, translatedUserType: $translatedUserType');
        } else {
          pp('🍎 activityUser not found in cache; activity: ${activity.toJson()}');
          activity.translatedUserType = '';
        }
      } else if (activity.user != null){
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
    await Future.delayed(const Duration(milliseconds: 200));
    models = await organizationBloc.getOrganizationActivity(
        organizationId: settings!.organizationId!,
        hours: hours,
        forceRefresh: true);

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
      if (models.isEmpty || models.length == 1) {
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
    pp('$mm build: ......... 🍎🍎 activities: ${models.length}');
    return Stack(
      children: [
        Column(
          children: [
            SizedBox(
              height: widget.topPadding == null ? 100 : widget.topPadding!,
            ),
            Expanded(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: models.length,
                  itemBuilder: (_, index) {
                    var act = models.elementAt(index);
                    var type = '';
                    if (act.translatedUserType != null) {
                      type = act.translatedUserType!;
                    }
                    return GestureDetector(
                      onTap: () {
                        widget.onTapped(act);
                      },
                      child: ActivityStreamCard(
                        translatedUserType: type,
                        locale: settings!.locale!,
                        activityStrings: activityStrings!,
                        activityModel: act,
                        frontPadding: 24,
                        thinMode: true,
                        width: 300, avatarRadius: 16, namePictureHorizontal: true,
                      ),
                    );
                  }),
            ),
          ],
        ),
        Positioned(
            child: Card(
          elevation: 8,
          shape: getRoundedBorder(radius: 16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36.0, vertical: 20),
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
                        loadingActivities: activityStrings!.loadingActivities!))
            : const SizedBox()
      ],
    );
  }

  static const mm = '🌎🌎🌎🌎🌎 ActivityListCard 🌎';
}
