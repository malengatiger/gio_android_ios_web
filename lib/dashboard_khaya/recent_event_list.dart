import 'package:flutter/material.dart';
import 'package:geo_monitor/library/data/activity_model.dart';
import 'package:geo_monitor/library/data/activity_type_enum.dart';

import '../library/functions.dart';

class RecentEventList extends StatelessWidget {
  final Function(ActivityModel) onEventTapped;
  final List<ActivityModel> activities;

  const RecentEventList(
      {super.key, required this.onEventTapped, required this.activities});

  @override
  Widget build(BuildContext context) {
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
            height: 60,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: activities.length,
                itemBuilder: (_, index) {
                  final act = activities.elementAt(index);
                  return GestureDetector(
                      onTap: () {
                        onEventTapped(act);
                      },
                      child: EventView(activity: act, height: 60, width: 248));
                }),
          );
  }
}

class EventView extends StatelessWidget {
  const EventView(
      {Key? key,
      required this.activity,
      required this.height,
      required this.width})
      : super(key: key);
  final ActivityModel activity;
  final double height, width;
  @override
  Widget build(BuildContext context) {
    // pp(' ${activity.toJson()}');
    String? typeName;
    Icon icon = const Icon(Icons.access_time);
    if (activity.photo != null) {
      icon = const Icon(
        Icons.camera_alt_outlined,
        color: Colors.teal,
      );
    }
    if (activity.video != null) {
      icon = const Icon(Icons.video_camera_back_outlined);
    }
    if (activity.geofenceEvent != null) {
      icon = const Icon(
        Icons.person,
        color: Colors.blue,
      );
    }
    if (activity.projectPosition != null) {
      icon = const Icon(Icons.location_on_sharp);
    }
    if (activity.activityType == ActivityType.settingsChanged) {
      icon = const Icon(
        Icons.settings,
        color: Colors.pink,
      );
      typeName = 'Settings changed';
    }

      final date = getFmtDateShortWithSlash(activity.date!, 'en');

    return SizedBox(
      height: height,
      width: width,
      child: Card(
        shape: getRoundedBorder(radius: 10),
        // color: const Color(0xFFe1e4eb),
        elevation: 2,
        child: Column(mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  icon,
                  const SizedBox(
                    width: 8,
                  ),
                  SizedBox(
                    height: 32,
                    child: Column(
                      children: [
                        activity.projectName == null
                            ? typeName == null
                                ? const Text('')
                                : Row(mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                    typeName,
                                    style: myTextStyleTiny(context),
                                      ),
                                  ],
                                )
                            : Row(mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  '${activity.projectName}',
                                  overflow: TextOverflow.clip,
                                  style: myTextStyleSmallBlackBold(context),
                                ),
                              ],
                            ),
                        Text(date, style: myTextStyleTiny(context)),
                      ],
                    ),
                  )
                ],
              ),

            ),

          ],
        ),
      ),
    );
  }
}
