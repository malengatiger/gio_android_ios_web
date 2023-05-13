import 'package:flutter/material.dart';
import 'package:geo_monitor/library/data/activity_model.dart';
import 'package:geo_monitor/library/data/activity_type_enum.dart';

import '../library/functions.dart';

class RecentEventList extends StatelessWidget {
  final Function(ActivityModel) onEventTapped;
  final List<ActivityModel> activities;
  final String locale;

  const RecentEventList(
      {super.key, required this.onEventTapped, required this.activities, required this.locale});

  @override
  Widget build(BuildContext context) {
    var width = 340.0;
    final deviceType = getThisDeviceType();
    if (deviceType == 'phone') {
      width = 332.0;
    }
    return busy
        ? const Center(
            child: SizedBox(
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
                        onEventTapped(act);
                      },
                      child: EventView(
                        activity: act,
                        height: 84,
                        width: width,
                        locale: locale,
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
      icon = const Icon(Icons.location_on_sharp, color: Colors.green,);
      userUrl = activity.userThumbnailUrl;
    }
    if (activity.projectPolygon != null) {
      icon = const Icon(Icons.location_on_rounded,
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
        width: width, height: 100,
        child: Card(
          shape: getRoundedBorder(radius: 12),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Row(mainAxisAlignment: MainAxisAlignment.center,
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
                  userUrl == null? const SizedBox(): CircleAvatar(
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

