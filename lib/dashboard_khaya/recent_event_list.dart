import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geo_monitor/library/api/prefs_og.dart';
import 'package:geo_monitor/library/bloc/fcm_bloc.dart';
import 'package:geo_monitor/library/bloc/organization_bloc.dart';
import 'package:geo_monitor/library/bloc/refresh_bloc.dart';
import 'package:geo_monitor/library/data/activity_model.dart';
import 'package:geo_monitor/library/data/activity_type_enum.dart';
import 'package:geo_monitor/library/data/settings_model.dart';

import '../library/data/data_bag.dart';
import '../library/functions.dart';

class RecentEventList extends StatefulWidget {
  final Function(ActivityModel) onEventTapped;
  final String locale;
  final OrganizationBloc organizationBloc;
  final PrefsOGx prefsOGx;
  final FCMBloc fcmBloc;

  const RecentEventList(
      {super.key,
      required this.onEventTapped,
      required this.locale,
      required this.organizationBloc,
      required this.prefsOGx,
      required this.fcmBloc});

  @override
  State<RecentEventList> createState() => _RecentEventListState();
}

class _RecentEventListState extends State<RecentEventList> {
  late StreamSubscription<ActivityModel> actSub;
  late StreamSubscription<DataBag> bagSub;
  late StreamSubscription<bool> refreshSub;
  late StreamSubscription<SettingsModel> settingsSub;

  var activities = <ActivityModel>[];
  bool busy = false;
  final mm = '🔵🔵🔵 RecentEventList 🔵🔵🔵🔵🔵🔵 : ';

  @override
  void initState() {
    super.initState();
    pp('$mm initState ..............');
    _listen();
    _getData(false);
  }

  void _listen() {
    settingsSub = widget.fcmBloc.settingsStream.listen((event) {
      pp('$mm settingsStream delivered a setting ');
      _getData(true);
    });
    actSub = widget.fcmBloc.activityStream.listen((event) {
      pp('$mm activityStream delivered an activity, insert received activity in list: 🔆${activities.length}');
      activities.insert(0, event);
      _sort();
      if (mounted) {
        pp('$mm activityStream delivered an activity: setting state with: 🔆 ${activities.length} activities');
        setState(() {

        });
      }
    });

    // bagSub = widget.organizationBloc.dataBagStream.listen((bag) {
    //   pp('$mm dataBagStream delivered a bag, set ui .');
    //   activities = bag.activityModels!;
    //   _sort();
    //   if (mounted) {
    //     setState(() {
    //
    //     });
    //   }
    // });
    
    refreshSub = refreshBloc.refreshStream.listen((event) { 
      pp('$mm refreshStream delivered a refresh command: $event, ');
      _getData(true);
    });
  }

  Future _getData(bool forceRefresh) async {
    setState(() {
      busy = true;
    });
    try {
      pp('$mm ........ getting activity data .....');
      final sett = await widget.prefsOGx.getSettings();
      activities = await widget.organizationBloc.getOrganizationActivity(
          organizationId: sett.organizationId!,
          hours: sett.activityStreamHours!,
          forceRefresh: forceRefresh);

      _sort();
    } catch (e) {
      showSnackBar(message: '$e', context: context);
    }
    if (mounted) {
      setState(() {
        busy = false;
      });
    }
  }

  void _sort() {
    pp('$mm ........ sort activities by date  .....');
    for (var act in activities) {
      final date = DateTime.parse(act.date!);
      act.intDate = date.toUtc().millisecondsSinceEpoch;
    }

    activities.sort((a,b) => b.intDate.compareTo(a.intDate));
  }

  @override
  void dispose() {
    actSub.cancel();
    bagSub.cancel();
    refreshSub.cancel();
    settingsSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = 340.0;
    final deviceType = getThisDeviceType();
    if (deviceType == 'phone') {
      width = 332.0;
    }
    return busy
        ? const Center(
            child: SizedBox(width: 14, height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                backgroundColor: Colors.pink,
              ),
            ),
          )
        : SizedBox(
            height: 64,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: activities.length,
                itemBuilder: (_, index) {
                  final act = activities.elementAt(index);
                  return GestureDetector(
                      onTap: () {
                        widget.onEventTapped(act);
                      },
                      child: EventView(
                        activity: act,
                        height: 84,
                        width: width,
                        locale: widget.locale,
                      ));
                }),
          );
  }
}

class EventView extends StatelessWidget {
  const EventView(
      {Key? key,
      required this.activity,
      required this.height,
      required this.width,
      required this.locale})
      : super(key: key);
  final ActivityModel activity;
  final double height, width;
  final String locale;

  @override
  Widget build(BuildContext context) {
    // pp(' ${activity.toJson()}');
    String? typeName, userUrl;
    Icon icon = const Icon(Icons.access_time);
    if (activity.photo != null) {
      icon = const Icon(
        Icons.camera_alt_outlined,
        color: Colors.teal,
      );
      userUrl = activity.photo!.userUrl!;
    }
    if (activity.audio != null) {
      icon = const Icon(
        Icons.mic,
        color: Colors.deepOrange,
      );
      userUrl = activity.audio!.userUrl!;
    }
    if (activity.video != null) {
      icon = const Icon(Icons.video_camera_back_outlined);
      userUrl = activity.video!.userUrl!;
    }
    if (activity.geofenceEvent != null) {
      icon = const Icon(
        Icons.person,
        color: Colors.blue,
      );
      userUrl = activity.geofenceEvent!.user!.thumbnailUrl;
    }
    if (activity.project != null) {
      icon = const Icon(
        Icons.home,
        color: Colors.deepPurple,
      );
      userUrl = activity.userThumbnailUrl;
    }
    if (activity.projectPosition != null) {
      icon = const Icon(
        Icons.location_on_sharp,
        color: Colors.green,
      );
      userUrl = activity.userThumbnailUrl;
    }
    if (activity.projectPolygon != null) {
      icon = const Icon(
        Icons.location_on_rounded,
        color: Colors.yellow,
      );
      userUrl = activity.userThumbnailUrl;
    }
    if (activity.activityType == ActivityType.settingsChanged) {
      icon = const Icon(
        Icons.settings,
        color: Colors.pink,
      );
      userUrl = activity.userThumbnailUrl;
    }

    final date = getFmtDate(activity.date!, locale);

    return SizedBox(
        width: width,
        height: 100,
        child: Card(
          shape: getRoundedBorder(radius: 12),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon,
                  const SizedBox(
                    width: 8,
                  ),
                  SizedBox(
                    height: 48,
                    child: Column(
                      children: [
                        activity.projectName == null
                            ? const SizedBox()
                            : Flexible(
                                child: Text(
                                  activity.projectName!,
                                  style: myTextStyleSmallPrimaryColor(context),
                                ),
                              ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          date,
                          style: myTextStyleTiny(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  userUrl == null
                      ? const SizedBox()
                      : CircleAvatar(
                          backgroundImage: NetworkImage(userUrl),
                          radius: 14,
                        )
                ],
              ),
            ),
          ),
        ));
  }
}
