import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

import '../../library/api/prefs_og.dart';
import '../../library/bloc/user_bloc.dart';
import '../../library/cache_manager.dart';
import '../../library/data/field_monitor_schedule.dart';
import '../../library/data/user.dart';
import '../../library/functions.dart';
import '../../library/generic_functions.dart';
import '../../library/ui/maps/project_map_mobile.dart';
import '../../library/ui/media/user_media_list/user_media_list_mobile.dart';

class SchedulesListMobile extends StatefulWidget {
  const SchedulesListMobile({super.key});

  @override
  SchedulesListMobileState createState() => SchedulesListMobileState();
}

class SchedulesListMobileState extends State<SchedulesListMobile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  User? _user;
  List<FieldMonitorSchedule> _schedules = [];
  bool busy = false;
  final _key = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getData(false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToProjectMapMobile(FieldMonitorSchedule sched) async {
    var pos = await cacheManager.getProjectPositions(sched.projectId!);
    var pol =
        await cacheManager.getProjectPolygons(projectId: sched.projectId!);
    var proj = await cacheManager.getProjectById(projectId: sched.projectId!);
    if (mounted) {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.scale,
              alignment: Alignment.topLeft,
              duration: const Duration(seconds: 1),
              child: ProjectMapMobile(
                project: proj!,
              )));
    }
  }

  void _navigateToUserMediaListMobile() {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 1),
            child: UserMediaListMobile(user: _user!)));
  }

  void _getData(bool refresh) async {
    setState(() {
      busy = true;
    });
    try {
      _user = await prefsOGx.getUser();
      _schedules = await userBloc.getFieldMonitorSchedules(
          userId: _user!.userId!, forceRefresh: refresh);
    } catch (e) {
      showToast(message: 'Data refresh failed: $e', context: context);
    }

    setState(() {
      busy = false;
    });
  }

  static const mm = '🍏 🍏 🍏 ScheduleList 🍏 : ';
  List<FocusedMenuItem> getPopUpMenuItems(FieldMonitorSchedule schedule) {
    List<FocusedMenuItem> menuItems = [];
    menuItems.add(
      FocusedMenuItem(
          title: const Text('Project Map'),
          trailingIcon: Icon(
            Icons.map,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            pp('$mm should navigate to map');
            _navigateToProjectMapMobile(schedule);
          }),
    );
    menuItems.add(
      FocusedMenuItem(
          title: const Text('Photos & Videos'),
          trailingIcon: Icon(
            Icons.camera,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            //_navigateToMedia(p);
            pp('$mm should navigate to media');
            _navigateToUserMediaListMobile();
          }),
    );
    if (_user!.userType == UserType.orgAdministrator) {
      menuItems.add(FocusedMenuItem(
          title: const Text('Add Project Location'),
          trailingIcon: Icon(
            Icons.location_pin,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            //_navigateToProjectLocation(p);
          }));
    }
    if (_user!.userType == UserType.orgAdministrator) {
      menuItems.add(FocusedMenuItem(
          title: const Text('Edit Project'),
          trailingIcon: Icon(
            Icons.create,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            //_navigateToDetail(p);
          }));
    }
    return menuItems;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: busy
          ? Scaffold(
              key: _key,
              appBar: AppBar(
                title: Text(
                  'Loading FieldMonitor schedules ...',
                  style: Styles.whiteSmall,
                ),
              ),
              body: const Center(
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    backgroundColor: Colors.amber,
                  ),
                ),
              ),
            )
          : Scaffold(
              key: _key,
              appBar: AppBar(
                title: Text(
                  'FieldMonitor Schedules',
                  style: Styles.whiteSmall,
                ),
                actions: [
                  IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        _getData(true);
                      })
                ],
                bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(100),
                    child: Column(
                      children: [
                        Text(
                          '${_user == null ? '' : _user!.name}',
                          style: Styles.whiteBoldMedium,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          'Field Monitor',
                          style: Styles.whiteTiny,
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                      ],
                    )),
              ),
              // backgroundColor: Colors.brown[100],
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                    itemCount: _schedules.length,
                    itemBuilder: (context, index) {
                      var schedule = _schedules.elementAt(index);
                      var subTitle = _getSubTitle(schedule);
                      return FocusedMenuHolder(
                        menuOffset: 20,
                        duration: const Duration(milliseconds: 300),
                        menuItems: getPopUpMenuItems(schedule),
                        animateMenuItems: true,
                        openWithTap: true,
                        onPressed: () {
                          pp('💛️ 💛️ 💛️ not sure what I pressed on schedules context menu ...');
                        },
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0)),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 12,
                                ),
                                Row(
                                  children: [
                                    Opacity(
                                      opacity: 0.5,
                                      child: Icon(
                                        Icons.water_damage,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Flexible(
                                      child: Text(
                                        schedule.projectName!,
                                        style: GoogleFonts.lato(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 32,
                                    ),
                                    Text('Frequency :',
                                        style: GoogleFonts.lato(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                            fontWeight: FontWeight.normal)),
                                    const SizedBox(
                                      width: 12,
                                    ),
                                    Text(
                                      subTitle,
                                      style: GoogleFonts.secularOne(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                          fontWeight: FontWeight.w900),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                      // return Card(
                      //   elevation: 2,
                      //   child: Column(
                      //     children: [
                      //       SizedBox(
                      //         height: 8,
                      //       ),
                      //       ListTile(
                      //         leading: Icon(
                      //           Icons.alarm,
                      //           color: Theme.of(context).primaryColor,
                      //         ),
                      //         title: Text(
                      //           '${schedule.projectName}',
                      //           style: Styles.blackBoldSmall,
                      //         ),
                      //         subtitle: Text('$subTitle'),
                      //       ),
                      //       // SizedBox(
                      //       //   height: 0,
                      //       // ),
                      //       // Text(getFormattedDateLongWithTime(
                      //       //     schedule.date!, context), style: Styles.greyLabelSmall,),
                      //       SizedBox(
                      //         height: 8,
                      //       ),
                      //     ],
                      //   ),
                      // );
                    }),
              ),
            ),
    );
  }

  String _getSubTitle(FieldMonitorSchedule sc) {
    var string = 'per Day';
    if (sc.perDay! > 0) {
      return '${sc.perDay} $string';
    }
    if (sc.perWeek! > 0) {
      return '${sc.perWeek} per Week';
    }
    if (sc.perMonth! > 0) {
      return '${sc.perMonth} per Month';
    }
    return '';
  }
}
