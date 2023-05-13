import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geo_monitor/library/bloc/fcm_bloc.dart';
import 'package:geo_monitor/library/bloc/organization_bloc.dart';
import 'package:geo_monitor/ui/dashboard/project_dashboard_mobile.dart';

import '../../library/data/data_bag.dart';
import '../../library/data/project.dart';
import '../../library/data/settings_model.dart';
import '../../library/data/user.dart';
import '../../library/functions.dart';
import '../../utilities/constants.dart';
import 'dashboard_element.dart';

class DashboardGrid extends StatefulWidget {
  final Function(int) onTypeTapped;
  final double? totalHeight;
  final double? topPadding, elementPadding;
  final double? leftPadding;
  final DataBag dataBag;
  final double gridPadding;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;

  const DashboardGrid(
      {super.key,
      required this.onTypeTapped,
      this.totalHeight,
      this.topPadding,
      this.elementPadding,
      this.leftPadding,
      required this.dataBag,
      required this.gridPadding,
      required this.crossAxisCount,
      required this.crossAxisSpacing,
      required this.mainAxisSpacing});

  @override
  State<DashboardGrid> createState() => _DashboardGridState();
}

class _DashboardGridState extends State<DashboardGrid> {
  final mm = '🔵🔵🔵🔵DashboardGrid:  🍎 ';

  late StreamSubscription<SettingsModel> settingsSubscription;
  late StreamSubscription<SettingsModel> settingsSubscriptionFCM;

  SettingsModel? settingsModel;
  DashboardStrings? dashboardStrings;

  var projects = <Project>[];
  var users = <User>[];
  User? user;

  @override
  void initState() {
    super.initState();
    _listen();
    _setTexts();
  }

  Future _listen() async {
    settingsSubscriptionFCM = fcmBloc.settingsStream.listen((SettingsModel settings) {
      pp('$mm fcmBloc.settingsStream delivered settings ... ${settings.toJson()}');

      _setTexts();
    });
    settingsSubscription = organizationBloc.settingsStream.listen((SettingsModel settings) {
      pp('$mm organizationBloc.settingsStream delivered settings ... ${settings.toJson()}');
      _setTexts();
    });
  }

  @override
  void dispose() {
    settingsSubscription.cancel();
    super.dispose();
  }

  Future _setTexts() async {
    dashboardStrings = await DashboardStrings.getTranslated();
    pp('$mm setting translated texts ...');
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Padding(
        padding: EdgeInsets.all(widget.gridPadding),
        child: dashboardStrings == null
            ? const SizedBox()
            : GridView.count(
                crossAxisCount: widget.crossAxisCount,
                crossAxisSpacing: widget.crossAxisSpacing,
                mainAxisSpacing: widget.mainAxisSpacing,
                children: [
                  GestureDetector(
                    onTap: () {
                      widget.onTypeTapped(typeProjects);
                    },
                    child: DashboardElement(
                      title: dashboardStrings!.projects,
                      topPadding: widget.elementPadding,
                      number: widget.dataBag.projects!.length,
                      onTapped: () {
                        widget.onTypeTapped(typeProjects);
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      widget.onTypeTapped(typeUsers);
                    },
                    child: DashboardElement(
                      title: dashboardStrings!.members,
                      number: widget.dataBag.users!.length,
                      topPadding: widget.elementPadding,
                      onTapped: () {
                        widget.onTypeTapped(typeUsers);
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      widget.onTypeTapped(typePhotos);
                    },
                    child: DashboardElement(
                      title: dashboardStrings!.photos,
                      number: widget.dataBag.photos!.length,
                      topPadding: widget.elementPadding,
                      textStyle: myNumberStyleLargerPrimaryColor(context),
                      onTapped: () {
                        widget.onTypeTapped(typePhotos);
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      widget.onTypeTapped(typeVideos);
                    },
                    child: DashboardElement(
                      title: dashboardStrings!.videos,
                      topPadding: widget.elementPadding,
                      number: widget.dataBag.videos!.length,
                      textStyle: myNumberStyleLargerPrimaryColor(context),
                      onTapped: () {
                        widget.onTypeTapped(typeVideos);
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      widget.onTypeTapped(typeAudios);
                    },
                    child: DashboardElement(
                      title: dashboardStrings!.audioClips,
                      topPadding: widget.elementPadding,
                      number: widget.dataBag.audios!.length,
                      textStyle: myNumberStyleLargerPrimaryColor(context),
                      onTapped: () {
                        widget.onTypeTapped(typeAudios);
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      widget.onTypeTapped(typePositions);
                    },
                    child: DashboardElement(
                      title: dashboardStrings!.locations,
                      topPadding: widget.elementPadding,
                      number: widget.dataBag.projectPositions!.length,
                      onTapped: () {
                        widget.onTypeTapped(typePositions);
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      widget.onTypeTapped(typePolygons);
                    },
                    child: DashboardElement(
                      title: dashboardStrings!.areas,
                      topPadding: widget.elementPadding,
                      number: widget.dataBag.projectPolygons!.length,
                      onTapped: () {
                        widget.onTypeTapped(typePolygons);
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      widget.onTypeTapped(typeSchedules);
                    },
                    child: DashboardElement(
                      title: dashboardStrings!.schedules,
                      topPadding: widget.elementPadding,
                      number: widget.dataBag.fieldMonitorSchedules!.length,
                      onTapped: () {
                        widget.onTypeTapped(typeSchedules);
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
