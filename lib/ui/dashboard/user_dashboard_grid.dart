import 'package:flutter/material.dart';
import 'package:geo_monitor/ui/dashboard/project_dashboard_mobile.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../library/data/data_bag.dart';
import '../../library/data/user.dart';
import '../../library/functions.dart';
import '../../utilities/constants.dart';
import 'dashboard_element.dart';

class UserDashboardGrid extends StatelessWidget {
  const UserDashboardGrid(
      {super.key,
      required this.onTypeTapped,
      this.totalHeight,
      this.topPadding,
      required this.user,
      required this.dataBag,
      this.elementPadding,
      this.leftPadding,
      required this.gridPadding,
      required this.crossAxisCount, required this.width, required this.dashboardStrings});

  final Function(int) onTypeTapped;
  final double? totalHeight;
  final User user;
  final DataBag dataBag;

  final double? topPadding, elementPadding;
  final double? leftPadding;
  final double gridPadding;
  final double width;
  final int crossAxisCount;
  final DashboardStrings dashboardStrings;

  final mm = '🔵🔵🔵🔵 UserDashboardGrid:  🍎 ';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: topPadding == null ? 60 : topPadding!,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            user.thumbnailUrl == null
                ? const CircleAvatar()
                : CircleAvatar(
                    radius: 36,
                    backgroundImage: NetworkImage(
                      user.thumbnailUrl!,
                    ),
                  ),
            const SizedBox(
              width: 20,
            ),
            Text(
              '${user.name}',
              style: myTextStyleLargePrimaryColor(context),
            ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            child: SizedBox(height: totalHeight == null ? 900 : totalHeight!,
              width: width,
              child: Padding(
                padding: EdgeInsets.all(gridPadding),
                child: GridView.count(
                  crossAxisCount: crossAxisCount,
                  children: [
                    GestureDetector(
                      onTap: () {
                        onTypeTapped(typeProjects);
                      },
                      child: DashboardElement(
                        title: dashboardStrings.projects,
                        topPadding: elementPadding,
                        number: dataBag.projects!.length,
                        onTapped: () {
                          onTypeTapped(typeProjects);
                        },
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        onTypeTapped(typePhotos);
                      },
                      child: DashboardElement(
                        title: dashboardStrings.photos,
                        number: dataBag.photos!.length,
                        topPadding: elementPadding,
                        textStyle: GoogleFonts.secularOne(
                            textStyle: Theme.of(context).textTheme.titleLarge,
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context).primaryColor),
                        onTapped: () {
                          onTypeTapped(typePhotos);
                        },
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        onTypeTapped(typeVideos);
                      },
                      child: DashboardElement(
                        title: dashboardStrings.videos,
                        topPadding: elementPadding,
                        number: dataBag.videos!.length,
                        textStyle: GoogleFonts.secularOne(
                            textStyle: Theme.of(context).textTheme.titleLarge,
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context).primaryColor),
                        onTapped: () {
                          onTypeTapped(typeVideos);
                        },
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        onTypeTapped(typeAudios);
                      },
                      child: DashboardElement(
                        title: dashboardStrings.audioClips,
                        topPadding: elementPadding,
                        number: dataBag.audios!.length,
                        textStyle: GoogleFonts.secularOne(
                            textStyle: Theme.of(context).textTheme.titleLarge,
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context).primaryColor),
                        onTapped: () {
                          onTypeTapped(typeAudios);
                        },
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        onTypeTapped(typeSchedules);
                      },
                      child: DashboardElement(
                        title: dashboardStrings.schedules,
                        topPadding: elementPadding,
                        number: dataBag.fieldMonitorSchedules!.length,
                        onTapped: () {
                          onTypeTapped(typeSchedules);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}

////
////
class UserDashboardElement extends StatelessWidget {
  const UserDashboardElement(
      {Key? key,
      required this.number,
      required this.title,
      this.height,
      this.topPadding,
      this.textStyle,
      this.labelTitleStyle,
      required this.onTapped})
      : super(key: key);
  final int number;
  final String title;
  final double? height, topPadding;
  final TextStyle? textStyle, labelTitleStyle;
  final Function() onTapped;

  @override
  Widget build(BuildContext context) {
    var style = GoogleFonts.secularOne(
        textStyle: Theme.of(context).textTheme.titleLarge,
        fontWeight: FontWeight.w900);
    var labelStyle = GoogleFonts.secularOne(
        textStyle: Theme.of(context).textTheme.titleSmall,
        fontWeight: FontWeight.w900,
        color: Colors.grey);

    return GestureDetector(
      onTap: () {
        onTapped();
      },
      child: Card(
        shape: getRoundedBorder(radius: 16),
        child: SizedBox(
          height: height == null ? 280 : height!,
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  height: topPadding == null ? 32 : topPadding!,
                ),
                Text('$number', style: textStyle == null ? style : textStyle!),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  title,
                  style: labelStyle,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
