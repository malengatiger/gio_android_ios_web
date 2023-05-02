import 'package:badges/badges.dart' as bd;
import 'package:flutter/material.dart';

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
    var width = 128.0;
    if (ori.name == 'landscape') {
      width = 200;
    }
    return Row(
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
                style: myTextStyleSmallBoldPrimaryColor(context),
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
          width: 4,
        ),
        GestureDetector(
          onTap: () {
            onSortRequested();
          },
          child: bd.Badge(
            badgeContent: Text(
              '$number',
              style: myTextStyleTiny(context),
            ),
            badgeAnimation: const bd.BadgeAnimation.slide(
                colorChangeAnimationDuration: Duration(milliseconds: 500)),
            badgeStyle: bd.BadgeStyle(
                elevation: 8,
                borderRadius: BorderRadius.circular(2),
                badgeColor: getRandomColor(),
                padding: const EdgeInsets.all(12.0)),
          ),
        ),
      ],
    );
  }
}
