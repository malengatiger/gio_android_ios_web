import 'package:badges/badges.dart' as bd;
import 'package:flutter/material.dart';
import 'package:geo_monitor/library/ui/maps_field_monitor/field_monitor_map_tablet.dart';
import 'package:intl/intl.dart';

import '../../library/functions.dart';

class ActivityHeader extends StatelessWidget {
  const ActivityHeader(
      {Key? key,
      required this.onRefreshRequested,
      required this.hours,
      required this.number,
      required this.prefix,
      required this.suffix,
      required this.onSortRequested})
      : super(key: key);

  final Function() onRefreshRequested;
  final Function() onSortRequested;
  final int hours;
  final int number;
  final String prefix, suffix;
  @override
  Widget build(BuildContext context) {
    final ori = MediaQuery.of(context).orientation;
    if (ori.name == 'landscape') {
    }
    final  fmt = NumberFormat.decimalPattern();
    final  mNumber = fmt.format(number);
    var padding = 4.0;
    if ((number > 999)) {
      padding = 8.0;
    }
    final  color = getTextColorForBackground(Theme.of(context).primaryColor);

    return SizedBox(
      child: bd.Badge(
        badgeContent: Padding(
          padding: EdgeInsets.all(padding),
          child: Text(mNumber, style: myTextStyleSmallWithColor(context, color),),
        ),
        badgeAnimation: const bd.BadgeAnimation.scale(),
        position: bd.BadgePosition.topEnd(),

        onTap: (){},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () {
                onRefreshRequested();
              },
              child: Row(
                children: [
                  Text(
                    prefix,
                    style: myTextStyleSmall(context),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    '$hours',
                    style: myTextStyleMediumBoldPrimaryColor(context),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    suffix,
                    style: myTextStyleSmall(context),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 2,
            ),
          ],
        ),
      ),
    );
  }
}
