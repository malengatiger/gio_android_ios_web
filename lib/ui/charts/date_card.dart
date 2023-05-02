import 'package:flutter/material.dart';

import '../../library/functions.dart';

class DateCard extends StatelessWidget {
  const DateCard(
      {Key? key, required this.dateTimeRange, required this.onRefreshRequested})
      : super(key: key);

  final DateTimeRange dateTimeRange;
  final Function() onRefreshRequested;

  @override
  Widget build(BuildContext context) {
    final start = getFormattedDateLongWithTime(
        dateTimeRange.start.toIso8601String(), context);
    final end = getFormattedDateLongWithTime(
        dateTimeRange.end.toIso8601String(), context);
    final days = dateTimeRange.duration.inDays;
    return SizedBox(
      child: GestureDetector(
        onTap: onRefreshRequested,
        child: Card(
          shape: getRoundedBorder(radius: 24),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48),
            child: Column(
              children: [
                const SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Text('Start Date', style: myTextStyleSmall(context),),
                    const SizedBox(
                      width: 20,
                    ),
                    Text(
                      start,
                      style: myNumberStyleMediumPrimaryColor(context),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Text('End Date', style: myTextStyleSmall(context),),
                    const SizedBox(
                      width: 24,
                    ),
                    Text(
                      end,
                      style: myNumberStyleMediumPrimaryColor(context),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Text('Number of Days', style: myTextStyleSmall(context),),
                    const SizedBox(
                      width: 24,
                    ),
                    Text(
                      '$days',
                      style: myNumberStyleMediumPrimaryColor(context),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
