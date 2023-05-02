import 'dart:async';

import 'package:animations/animations.dart';
import 'package:badges/badges.dart' as bd;
import 'package:flutter/material.dart';
import 'package:focused_menu/modals.dart';
import 'package:geo_monitor/l10n/translation_handler.dart';
import 'package:geo_monitor/library/data/audio.dart';
import 'package:geo_monitor/library/data/photo.dart';
import 'package:geo_monitor/library/data/video.dart';
import 'package:geo_monitor/library/generic_functions.dart';
import 'package:geo_monitor/library/ui/camera/video_player_tablet.dart';
import 'package:geo_monitor/library/ui/maps/project_map_mobile.dart';
import 'package:geo_monitor/library/ui/maps/project_map_tablet.dart';
import 'package:geo_monitor/library/ui/media/list/project_media_main.dart';
import 'package:geo_monitor/library/ui/project_list/project_list_card.dart';
import 'package:geo_monitor/library/ui/project_list/project_list_mobile.dart';
import 'package:geo_monitor/ui/activity/geo_activity.dart';
import 'package:geo_monitor/ui/audio/audio_player_og.dart';
import 'package:geo_monitor/ui/dashboard/photo_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:page_transition/page_transition.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../ui/audio/audio_recorder.dart';
import '../../../ui/dashboard/project_dashboard_main.dart';
import '../../api/prefs_og.dart';
import '../../bloc/fcm_bloc.dart';
import '../../bloc/geo_exception.dart';
import '../../bloc/organization_bloc.dart';
import '../../bloc/project_bloc.dart';
import '../../cache_manager.dart';
import '../../data/location_response.dart';
import '../../data/position.dart';
import '../../data/project.dart';
import '../../data/project_polygon.dart';
import '../../data/project_position.dart';
import '../../data/settings_model.dart';
import '../../data/user.dart' as mon;
import '../../data/user.dart';
import '../../errors/error_handler.dart';
import '../../functions.dart';
import '../maps/location_response_map.dart';
import '../maps/org_map_mobile.dart';
import '../maps/project_polygon_map_mobile.dart';
import '../project_edit/project_edit_main.dart';
import '../project_monitor/project_monitor_mobile.dart';
import '../schedule/project_schedules_mobile.dart';

class ProjectListTablet extends StatefulWidget {
  const ProjectListTablet({super.key, this.project, required this.instruction});
  final Project? project;
  final int instruction;
  @override
  ProjectListTabletState createState() => ProjectListTabletState();
}

class ProjectListTabletState extends State<ProjectListTablet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  var projects = <Project>[];
  mon.User? user;
  bool isBusy = false;
  bool isProjectsByLocation = false;
  var userTypeLabel = 'Unknown User Type';
  final mm = '🔵🔵🔵🔵 ProjectListTablet:  ';
  late StreamSubscription<String> killSubscription;
  var positions = <ProjectPosition>[];
  var polygons = <ProjectPolygon>[];
  final _key = GlobalKey<ScaffoldState>();
  bool _showPositionChooser = false;
  double sliderValue = 3.0;
  String? organizationProjects, projectsNotFound, refreshData;
  late StreamSubscription<SettingsModel> settingsSubscriptionFCM;

  @override
  void initState() {
    _animationController = AnimationController(
        value: 0.0,
        duration: const Duration(milliseconds: 3000),
        reverseDuration: const Duration(milliseconds: 2000),
        vsync: this);
    super.initState();
    _getData(false);
    _listen();
  }

  Future _setTexts() async {
    var sett = await prefsOGx.getSettings();
    organizationProjects =
        await translator.translate('organizationProjects', sett.locale!);
    projectsNotFound = await translator.translate('projectsNotFound', sett.locale!);
    refreshData = await translator.translate('refreshData', sett.locale!);
    setState(() {});
  }

  void _listen() {
    settingsSubscriptionFCM = fcmBloc.settingsStream.listen((event) async {
      if (mounted) {
        await _setTexts();
        _getData(false);
      }
    });
    fcmBloc.projectStream.listen((Project project) {
      _getData(false);
      if (mounted) {
        showToast(message: 'Project added: ${project.name}', context: context);
      }
    });
    projectBloc.projectStream.listen((List<Project> list) {
      projects = list;
      projects.sort((a, b) => a.name!.compareTo(b.name!));
      if (mounted) {
        setState(() {});
      }
    });
  }

  bool sortedByName = true;
  void _sort() {
    if (sortedByName) {
      _sortByDate();
    } else {
      _sortByName();
    }
  }

  void _sortByName() {
    projects.sort((a, b) => a.name!.compareTo(b.name!));
    sortedByName = true;
    if (mounted) {
      setState(() {});
    }
  }

  void _sortByDate() {
    projects.sort((a, b) => b.created!.compareTo(a.created!));
    sortedByName = false;
    if (mounted) {
      setState(() {});
    }
  }

  void _getData(bool forceRefresh) async {
    setState(() {
      isBusy = true;
    });
    try {
      user = await prefsOGx.getUser();
      if (user != null) {
        pp('$mm user found: ${user!.toJson()}');
        _setUserType();
        await refreshProjects(forceRefresh);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          busy = false;
        });
        if (e is GeoException) {
          var sett = await prefsOGx.getSettings();
          errorHandler.handleError(exception: e);
          final msg = await translator.translate(e.geTranslationKey(), sett.locale!);
          if (mounted) {
            showToast(
                backgroundColor: Theme
                    .of(context)
                    .primaryColor,
                textStyle: myTextStyleMedium(context),
                padding: 16,
                duration: const Duration(seconds: 10),
                message: msg,
                context: context);
          }
        }
      }
    }
    setState(() {
      isBusy = false;
    });
    switch (widget.instruction) {
      case goToMedia:
        _navigateToProjectMedia(widget.project!);
        break;
      case goToMap:
        _navigateToProjectMap(widget.project!);
        break;
      case goToSchedule:
        _navigateToProjectSchedules(widget.project!);
        break;
    }
  }

  void _setUserType() {
    setState(() {
      switch (user!.userType) {
        case UserType.fieldMonitor:
          userTypeLabel = 'Field Monitor';
          break;
        case UserType.orgAdministrator:
          userTypeLabel = 'Administrator';
          break;
        case UserType.orgExecutive:
          userTypeLabel = 'Executive';
          break;
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future refreshProjects(bool forceRefresh) async {
    pp('$mm 🥏 🥏 🥏 .................... refresh projects: forceRefresh: $forceRefresh');
    if (mounted) {
      setState(() {
        isBusy = true;
      });
    }
    try {
      if (isProjectsByLocation) {
        pp('$mm  🥏 🥏 🥏 getProjectsWithinRadius: $sliderValue km  🥏');
        projects = await projectBloc.getProjectsWithinRadius(
            radiusInKM: sliderValue, checkUserOrg: true);
      } else {
        pp('$mm  🥏 🥏 🥏 getOrganizationProjects, orgId: ${user!.organizationId} k 🥏');
        projects = await organizationBloc.getOrganizationProjects(
            organizationId: user!.organizationId!, forceRefresh: forceRefresh);
      }
      projects.sort((a, b) => a.name!.compareTo(b.name!));
      await _setTexts();
    } catch (e) {
      pp(e);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
    if (mounted) {
      setState(() {
        isBusy = false;
      });
      _animationController.forward();
    }
  }

  bool openProjectActions = false;

  void _navigateToDetail(Project? p) {
    // if (user!.userType == UserType.fieldMonitor) {
    //   Navigator.push(
    //       context,
    //       PageTransition(
    //           type: PageTransitionType.scale,
    //           alignment: Alignment.topLeft,
    //           duration: const Duration(milliseconds: 1500),
    //           child: ProjectEditMobile(p)));
    // }
    if (user!.userType! == UserType.orgAdministrator ||
        user!.userType == UserType.orgExecutive) {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.scale,
              alignment: Alignment.topLeft,
              duration: const Duration(milliseconds: 1500),
              child: ProjectEditMain(p)));
    }
  }

  void _navigateToProjectLocation(Project p) {
    pp('_navigateToProjectLocation .......................${p.name}');
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(milliseconds: 1500),
            child: ProjectMapMobile(project: p)));
  }

  void _navigateToMonitorStart(Project p) {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(milliseconds: 1500),
            child: ProjectMonitorMobile(project: p)));
  }

  void _navigateToProjectMedia(Project p) {
    if (user!.userType == UserType.fieldMonitor) {}
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(milliseconds: 1500),
            child: ProjectMediaMain(project: p)));
  }

  void _navigateToProjectSchedules(Project p) {
    if (user!.userType == UserType.fieldMonitor) {}
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(milliseconds: 1500),
            child: ProjectSchedulesMobile(project: p)));
  }

  void _navigateToProjectAudio(Project p) {
    if (user!.userType == UserType.fieldMonitor) {}
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.scale,
        alignment: Alignment.topLeft,
        duration: const Duration(milliseconds: 1500),
        child: AudioRecorder(
            onCloseRequested: () {
              pp('On stop requested');
              Navigator.of(context).pop();
            },
            project: p),
      ),
    );
  }

  Future<void> _navigateToOrgMap() async {
    pp('_navigateToOrgMap: ');

    if (mounted) {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.leftToRightWithFade,
              alignment: Alignment.topLeft,
              duration: const Duration(milliseconds: 1000),
              child: const OrganizationMapMobile()));
    }
  }

  void _navigateToProjectMap(Project p) async {
    pp('.................. _navigateToProjectMap: ');

    if (mounted) {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.scale,
              alignment: Alignment.topLeft,
              duration: const Duration(milliseconds: 1000),
              child: ProjectMapTablet(
                project: p,
              )));
    }
  }

  void _navigateToProjectPolygonMap(Project p) async {
    pp('.................. _navigateToProjectPolygonMap: ');

    if (mounted) {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.scale,
              alignment: Alignment.topLeft,
              duration: const Duration(milliseconds: 1000),
              child: ProjectPolygonMapMobile(
                project: p,
              )));
    }
  }

  void _navigateToProjectDashboard(Project p) async {
    pp('.................. _navigateToProjectPolygonMap: ');

    if (mounted) {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.scale,
              alignment: Alignment.topLeft,
              duration: const Duration(milliseconds: 1000),
              child: ProjectDashboardMain(
                project: p,
              )));
    }
  }

  void _navigateToDirections(
      {required double latitude, required double longitude}) async {
    pp('$mm 🍎 🍎 🍎 start Google Maps Directions .....');

    final availableMaps = await MapLauncher.installedMaps;
    pp('$mm 🍎 🍎 🍎 availableMaps: $availableMaps'); // [AvailableMap { mapName: Google Maps, mapType: google }, ...]

    var coordinates = Coords(latitude, longitude);
    await availableMaps.first.showDirections(destination: coordinates);
  }

  void _onPositionSelected(Position p1) {
    setState(() {
      _showPositionChooser = false;
    });
    _navigateToDirections(
        latitude: p1.coordinates[1], longitude: p1.coordinates[0]);
  }

  void _onClose() {
    setState(() {
      _showPositionChooser = false;
    });
  }

  void _startDirections(Project project) async {
    setState(() {
      isBusy = true;
    });
    try {
      var map = await getStartEndDates();
      final startDate = map['startDate'];
      final endDate = map['endDate'];
      positions = await projectBloc.getProjectPositions(
          projectId: project.projectId!,
          forceRefresh: false,
          startDate: startDate!,
          endDate: endDate!);
      polygons = await projectBloc.getProjectPolygons(
          projectId: project.projectId!, forceRefresh: false);
      if (positions.length == 1 && polygons.isEmpty) {
        _onPositionSelected(positions.first.position!);
        setState(() {
          isBusy = false;
          _showPositionChooser = false;
        });
        return;
      }
    } catch (e) {
      pp(e);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(duration: const Duration(seconds: 10), content: Text('$e')));
    }
    setState(() {
      isBusy = false;
      _showPositionChooser = true;
    });
    _animationController.forward();
  }

  List<FocusedMenuItem> getPopUpMenuItems(Project project) {
    List<FocusedMenuItem> menuItems = [];
    menuItems.add(
      FocusedMenuItem(
          backgroundColor: Theme.of(context).primaryColor,
          title:
              Text('Project Dashboard', style: myTextStyleSmallBlack(context)),
          trailingIcon: Icon(
            Icons.dashboard,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            _navigateToProjectDashboard(project);
          }),
    );
    menuItems.add(
      FocusedMenuItem(
          backgroundColor: Theme.of(context).primaryColor,
          title: Text(
            'Project Directions',
            style: myTextStyleSmallBlack(context),
          ),
          trailingIcon: Icon(
            Icons.directions,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            _startDirections(project);
          }),
    );
    menuItems.add(
      FocusedMenuItem(
          backgroundColor: Theme.of(context).primaryColor,
          title: Text(
            'Project Locations Map',
            style: myTextStyleSmallBlack(context),
          ),
          trailingIcon: Icon(
            Icons.map,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            _navigateToProjectMap(project);
          }),
    );

    menuItems.add(
      FocusedMenuItem(
          backgroundColor: Theme.of(context).primaryColor,
          title: Text('Photos & Video & Audio',
              style: myTextStyleSmallBlack(context)),
          trailingIcon: Icon(
            Icons.camera,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            pp('...... going to ProjectMedia ...');
            _navigateToProjectMedia(project);
          }),
    );
    menuItems.add(
      FocusedMenuItem(
          backgroundColor: Theme.of(context).primaryColor,
          title: Text('Create Audio', style: myTextStyleSmallBlack(context)),
          trailingIcon: Icon(
            Icons.camera,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            pp('...... going to ProjectAudio ...');
            _navigateToProjectAudio(project);
          }),
    );
    // menuItems.add(
    //   FocusedMenuItem(
    //       backgroundColor: Theme.of(context).primaryColor,
    //
    //       title: Text('Start Monitoring',
    //           style: myTextStyleSmallBlack(context)),
    //       trailingIcon: Icon(
    //         Icons.lock_clock,
    //         color: Theme.of(context).primaryColor,
    //       ),
    //       onPressed: () {
    //         _navigateToMonitorStart(project);
    //       }),
    // );
    if (user!.userType == UserType.orgAdministrator) {
      menuItems.add(FocusedMenuItem(
          backgroundColor: Theme.of(context).primaryColor,
          title: Text('Add Project Location',
              style: myTextStyleSmallBlack(context)),
          trailingIcon: Icon(
            Icons.location_pin,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            _navigateToProjectLocation(project);
          }));
      menuItems.add(
        FocusedMenuItem(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text(
              'Create Project Areas',
              style: myTextStyleSmallBlack(context),
            ),
            trailingIcon: Icon(
              Icons.map,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () {
              _navigateToProjectPolygonMap(project);
            }),
      );
      menuItems.add(FocusedMenuItem(
          backgroundColor: Theme.of(context).primaryColor,
          title: Text('Edit Project', style: myTextStyleSmallBlack(context)),
          trailingIcon: Icon(
            Icons.create,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            _navigateToDetail(project);
          }));
    }

    return menuItems;
  }

  List<IconButton> _getActions() {
    List<IconButton> list = [];
    list.add(IconButton(
      icon: Icon(
        Icons.refresh_rounded,
        size: 28,
        color: Theme.of(context).primaryColor,
      ),
      onPressed: () {
        refreshProjects(true);
      },
    ));
    list.add(IconButton(
      icon: isProjectsByLocation
          ? Icon(
              Icons.list,
              size: 28,
              color: Theme.of(context).primaryColor,
            )
          : Icon(
              Icons.location_pin,
              size: 28,
              color: Theme.of(context).primaryColor,
            ),
      onPressed: () {
        isProjectsByLocation = !isProjectsByLocation;
        refreshProjects(true);
      },
    ));
    if (projects.isNotEmpty) {
      list.add(
        IconButton(
          icon: Icon(
            Icons.map,
            size: 28,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            _navigateToOrgMap();
          },
        ),
      );
    }
    if (user != null) {
      if (user!.userType == UserType.orgAdministrator ||
          user!.userType == UserType.orgExecutive) {
        list.add(
          IconButton(
            icon: Icon(
              Icons.add,
              size: 28,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () {
              _navigateToDetail(null);
            },
          ),
        );
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    var amInPortrait = false;
    final ori = MediaQuery.of(context).orientation.name;
    if (ori == 'portrait') {
      amInPortrait = true;
    }
    return SafeArea(
        child: Scaffold(
            key: _key,
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                organizationProjects == null
                    ? 'Organization Projects'
                    : organizationProjects!,
                style: myTextStyleLarge(context),
              ),
              actions: _getActions(),
              bottom: PreferredSize(
                preferredSize:
                    Size.fromHeight(isProjectsByLocation ? 200 : 160),
                child: Column(
                  children: [
                    Text(
                        user == null ? 'Unknown User' : user!.organizationName!,
                        style: myTextStyleLargerPrimaryColor(context)),
                    const SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        isProjectsByLocation
                            ? Row(
                                children: [
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      activeTrackColor:
                                          Theme.of(context).primaryColor,
                                      inactiveTrackColor: Colors.pink[100],
                                      trackShape:
                                          const RoundedRectSliderTrackShape(),
                                      trackHeight: 2.0,
                                      thumbShape: const RoundSliderThumbShape(
                                          enabledThumbRadius: 12.0),
                                      thumbColor: Colors.pinkAccent,
                                      overlayColor: Colors.pink.withAlpha(32),
                                      overlayShape:
                                          const RoundSliderOverlayShape(
                                              overlayRadius: 28.0),
                                      tickMarkShape:
                                          const RoundSliderTickMarkShape(),
                                      activeTickMarkColor: Colors.indigo[700],
                                      inactiveTickMarkColor: Colors.pink[100],
                                      valueIndicatorShape:
                                          const PaddleSliderValueIndicatorShape(),
                                      valueIndicatorColor: Colors.pinkAccent,
                                      valueIndicatorTextStyle:
                                          myTextStyleSmall(context),
                                    ),
                                    child: Slider(
                                      value: sliderValue,
                                      min: 3,
                                      max: 50,
                                      divisions: 5,
                                      label: '$sliderValue',
                                      onChanged: _onSliderChanged,
                                    ),
                                  ),
                                  Text(
                                    '$sliderValue',
                                    style: myNumberStyleMedium(context),
                                  )
                                ],
                              )
                            : Container(),
                        const SizedBox(
                          width: 24,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 60,
                    ),
                  ],
                ),
              ),
            ),
            // backgroundColor: Colors.brown[100],
            body: isBusy
                ? Center(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 100,
                        ),
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 4,
                            backgroundColor: Colors.pink,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          isProjectsByLocation
                              ? 'Finding Projects within $sliderValue KM'
                              : 'Finding Organization Projects ...',
                          style: myTextStyleMedium(context),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: projects.isEmpty
                        ? Center(
                            child: Text(
                                projectsNotFound == null
                                    ? 'Projects Not Found'
                                    : projectsNotFound!,
                                style: GoogleFonts.lato(
                                    textStyle:
                                        Theme.of(context).textTheme.bodyLarge,
                                    fontWeight: FontWeight.w900)),
                          )
                        : Stack(
                            children: [
                              OrientationLayoutBuilder(landscape: (context) {
                                final width = MediaQuery.of(context).size.width;
                                final halfWidth = width / 2;
                                return Row(
                                  children: [
                                    GestureDetector(
                                      onTap: _sort,
                                      child: bd.Badge(
                                        badgeStyle: bd.BadgeStyle(
                                          badgeColor:
                                              Theme.of(context).primaryColor,
                                          elevation: 8,
                                          padding: const EdgeInsets.all(16),
                                        ),
                                        position: bd.BadgePosition.topEnd(
                                            top: -16, end: 8),
                                        badgeContent: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Text('${projects.length}',
                                              style:
                                                  myNumberStyleSmall(context)),
                                        ),
                                        child: AnimatedBuilder(
                                          animation: _animationController,
                                          builder: (BuildContext context,
                                              Widget? child) {
                                            return FadeScaleTransition(
                                              animation: _animationController,
                                              child: child,
                                            );
                                          },
                                          child: user == null
                                              ? const SizedBox()
                                              : SizedBox(
                                                  width: halfWidth - 120,
                                                  child: ProjectListCard(
                                                    projects: projects,
                                                    width: halfWidth - 120,
                                                    horizontalPadding: 12,
                                                    navigateToDetail: (p) {
                                                      _navigateToDetail(p);
                                                    },
                                                    navigateToProjectLocation:
                                                        (p) {
                                                      _navigateToProjectMap(p);
                                                    },
                                                    navigateToProjectMedia:
                                                        (p) {
                                                      _navigateToProjectMedia(
                                                          p);
                                                    },
                                                    navigateToProjectMap: (p) {
                                                      _navigateToProjectMap(p);
                                                    },
                                                    navigateToProjectPolygonMap:
                                                        (p) {
                                                      _navigateToProjectPolygonMap(
                                                          p);
                                                    },
                                                    navigateToProjectDashboard:
                                                        (p) {
                                                      _navigateToProjectDashboard(
                                                          p);
                                                    },
                                                    user: user!,
                                                    navigateToProjectDirections:
                                                        (project) {
                                                      _navigateToProjectDirections(
                                                          project);
                                                    },
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    GeoActivity(
                                      width: halfWidth + 60,
                                      thinMode: true,
                                      forceRefresh: true,
                                      showPhoto: showPhoto,
                                      showVideo: showVideo,
                                      showAudio: showAudio,
                                      showUser: (user) {},
                                      showLocationRequest: (req) {},
                                      showLocationResponse: (resp) {
                                        _navigateToLocationResponseMap(resp);
                                      },
                                      showGeofenceEvent: (event) {},
                                      showProjectPolygon: (polygon) {},
                                      showProjectPosition: (position) {},
                                      showOrgMessage: (message) {},
                                    ),
                                  ],
                                );
                              }, portrait: (context) {
                                final width = MediaQuery.of(context).size.width;
                                final firstWidth = (width / 2);
                                final secondWidth = (width / 2) - 76;
                                return Row(
                                  children: [
                                    GestureDetector(
                                      onTap: _sort,
                                      child: bd.Badge(
                                        badgeStyle: bd.BadgeStyle(
                                          badgeColor:
                                              Theme.of(context).primaryColor,
                                          elevation: 8,
                                          padding: const EdgeInsets.all(16),
                                        ),
                                        position: bd.BadgePosition.topEnd(
                                            top: -16, end: 8),
                                        badgeContent: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Text('${projects.length}',
                                              style:
                                                  myNumberStyleSmall(context)),
                                        ),
                                        child: AnimatedBuilder(
                                          animation: _animationController,
                                          builder: (BuildContext context,
                                              Widget? child) {
                                            return FadeScaleTransition(
                                              animation: _animationController,
                                              child: child,
                                            );
                                          },
                                          child: user == null
                                              ? const SizedBox()
                                              : SizedBox(
                                                  width: firstWidth,
                                                  child: ProjectListCard(
                                                    projects: projects,
                                                    width: firstWidth,
                                                    horizontalPadding: 12,
                                                    navigateToDetail: (p) {
                                                      _navigateToDetail(p);
                                                    },
                                                    navigateToProjectLocation:
                                                        (p) {
                                                      _navigateToProjectMap(p);
                                                    },
                                                    navigateToProjectMedia:
                                                        (p) {
                                                      _navigateToProjectMedia(
                                                          p);
                                                    },
                                                    navigateToProjectMap: (p) {
                                                      _navigateToProjectMap(p);
                                                    },
                                                    navigateToProjectPolygonMap:
                                                        (p) {
                                                      _navigateToProjectPolygonMap(
                                                          p);
                                                    },
                                                    navigateToProjectDashboard:
                                                        (p) {
                                                      _navigateToProjectDashboard(
                                                          p);
                                                    },
                                                    user: user!,
                                                    navigateToProjectDirections:
                                                        (project) {},
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 24,
                                    ),
                                    GeoActivity(
                                      width: secondWidth,
                                      thinMode: true,
                                      forceRefresh: true,
                                      showPhoto: showPhoto,
                                      showVideo: showVideo,
                                      showAudio: showAudio,
                                      showUser: (user) {},
                                      showLocationRequest: (req) {},
                                      showLocationResponse: (resp) {
                                        _navigateToLocationResponseMap(resp);
                                      },
                                      showGeofenceEvent: (event) {},
                                      showProjectPolygon: (polygon) {},
                                      showProjectPosition: (position) {},
                                      showOrgMessage: (message) {},
                                    ),
                                  ],
                                );
                              }),
                              _showPositionChooser
                                  ? Positioned(
                                      child: AnimatedBuilder(
                                        animation: _animationController,
                                        builder: (BuildContext context,
                                            Widget? child) {
                                          return FadeScaleTransition(
                                            animation: _animationController,
                                            child: child,
                                          );
                                        },
                                        child: ProjectLocationChooser(
                                          onSelected: _onPositionSelected,
                                          onClose: _onClose,
                                          projectPositions: positions,
                                          polygons: polygons,
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                              _showPhoto
                                  ? Positioned(
                                      left: amInPortrait ? 160 : 300,
                                      right: amInPortrait ? 160 : 300,
                                      child: PhotoCard(
                                          photo: selectedPhoto!,
                                          translatedDate: translatedDate!,
                                          onPhotoCardClose: () {
                                            setState(() {
                                              _showPhoto = false;
                                            });
                                          },
                                          elevation: 12.0,
                                          onMapRequested: onMapRequested,
                                          onRatingRequested: onRatingRequested),
                                    )
                                  : const SizedBox(),
                              _playAudio
                                  ? Positioned(
                                      left: amInPortrait ? 200 : 300,
                                      right: amInPortrait ? 200 : 300,
                                      child: AudioPlayerOG(
                                          audio: selectedAudio!,
                                          onCloseRequested: () {
                                            setState(() {
                                              _playAudio = false;
                                            });
                                          }),
                                    )
                                  : const SizedBox(),
                              _playVideo
                                  ? Positioned(
                                      child: VideoPlayerTablet(
                                          video: selectedVideo!,
                                          onCloseRequested: () {
                                            setState(() {
                                              _playVideo = false;
                                            });
                                          },
                                          width: 400))
                                  : const SizedBox(),
                            ],
                          ))));
  }

  void _navigateToProjectDirections(Project project) async {
    var poss = await cacheManager.getProjectPositions(project.projectId!);
    if (poss.isNotEmpty) {
      _navigateToDirections(
        latitude: poss.first.position!.coordinates[1],
        longitude: poss.first.position!.coordinates[0],
      );
    }
  }

  void _navigateToLocationResponseMap(LocationResponse locationResponse) async {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 1),
            child: LocationResponseMap(
              locationResponse: locationResponse!,
            )));
  }

  void _onSliderChanged(double value) {
    pp('ProjectListTabletPortrait  🥏 🥏 🥏 🥏 🥏 _onSliderChanged: $value');
    setState(() {
      sliderValue = value;
    });

    refreshProjects(true);
  }

  bool _showPhoto = false;
  bool _playAudio = false;
  bool _playVideo = false;
  Photo? selectedPhoto;
  Video? selectedVideo;
  Audio? selectedAudio;

  Audio? audio;
  String? translatedDate;
  showPhoto(Photo p1) async {
    selectedPhoto = p1;
    final settings = await prefsOGx.getSettings();
    translatedDate = getFmtDate(p1.created!, settings!.locale!);
    setState(() {
      _showPhoto = true;
      _playAudio = false;
      _playVideo = false;
    });

  }

  showVideo(Video p1) async {
    selectedVideo = p1;
    final settings = await prefsOGx.getSettings();
    translatedDate = getFmtDate(p1.created!, settings!.locale!);
    setState(() {
      _showPhoto = false;
      _playAudio = false;
      _playVideo = true;
    });
  }

  showAudio(Audio p1) async {
    selectedAudio = p1;
    final settings = await prefsOGx.getSettings();
    translatedDate = getFmtDate(p1.created!, settings!.locale!);
    setState(() {
      _showPhoto = false;
      _playAudio = true;
      _playVideo = false;
    });
  }

  onMapRequested(Photo p1) {}

  onRatingRequested(Photo p1) {}
}
