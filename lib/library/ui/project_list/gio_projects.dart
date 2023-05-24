import 'dart:async';

import 'package:badges/badges.dart' as bd;
import 'package:flutter/material.dart';
import 'package:focused_menu/modals.dart';
import 'package:geo_monitor/library/cache_manager.dart';
import 'package:geo_monitor/library/ui/maps/project_map_mobile.dart';
import 'package:geo_monitor/library/ui/media/time_line/project_media_timeline.dart';
import 'package:geo_monitor/library/ui/project_list/project_list_card.dart';
import 'package:geo_monitor/ui/activity/geo_activity.dart';
import 'package:geo_monitor/ui/dashboard/project_dashboard_mobile.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:page_transition/page_transition.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../l10n/translation_handler.dart';
import '../../../ui/audio/audio_recorder.dart';
import '../../api/data_api_og.dart';
import '../../api/prefs_og.dart';
import '../../bloc/cloud_storage_bloc.dart';
import '../../bloc/fcm_bloc.dart';
import '../../bloc/geo_exception.dart';
import '../../bloc/geo_uploader.dart';
import '../../bloc/organization_bloc.dart';
import '../../bloc/project_bloc.dart';
import '../../data/position.dart';
import '../../data/project.dart';
import '../../data/project_polygon.dart';
import '../../data/project_position.dart';
import '../../data/settings_model.dart';
import '../../data/user.dart';
import '../../data/user.dart' as mon;
import '../../errors/error_handler.dart';
import '../../functions.dart';
import '../../generic_functions.dart';
import '../maps/org_map_mobile.dart';
import '../maps/project_map_main.dart';
import '../maps/project_polygon_map_mobile.dart';
import '../project_edit/project_edit_main.dart';
import '../schedule/project_schedules_mobile.dart';

const goToMedia = 1;
const goToMap = 2;
const stayOnList = 3;
const goToSchedule = 4;

class GioProjects extends StatefulWidget {
  const GioProjects(
      {Key? key,
      this.project,
      required this.instruction,
      required this.projectBloc,
      required this.prefsOGx,
      required this.organizationBloc,
      required this.cacheManager,
      required this.dataApiDog,
      required this.fcmBloc,
      required this.geoUploader,
      required this.cloudStorageBloc})
      : super(key: key);
  final Project? project;
  final int instruction;
  final ProjectBloc projectBloc;
  final PrefsOGx prefsOGx;
  final OrganizationBloc organizationBloc;
  final CacheManager cacheManager;
  final DataApiDog dataApiDog;
  final FCMBloc fcmBloc;
  final GeoUploader geoUploader;
  final CloudStorageBloc cloudStorageBloc;

  @override
  State<GioProjects> createState() => GioProjectsState();
}

class GioProjectsState extends State<GioProjects>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  var projects = <Project>[];
  mon.User? user;
  bool isBusy = false;
  bool isProjectsByLocation = false;
  var userTypeLabel = 'Unknown User Type';
  final mm = '🔵🔵🔵🔵 GioProjects:  ';
  late StreamSubscription<String> killSubscription;
  late StreamSubscription<SettingsModel> settingsSubscriptionFCM;

  int numberOfDays = 30;
  bool sortedByName = true;
  bool openProjectActions = false;
  String? organizationProjects,
      projectsNotFound,
      searchProjects,
      refreshData,
      search,
      projectsText;

  @override
  void initState() {
    _animationController = AnimationController(
        value: 0.0,
        duration: const Duration(milliseconds: 3000),
        reverseDuration: const Duration(milliseconds: 2000),
        vsync: this);
    super.initState();
    _setTexts();
    _getUser();
    _listen();
  }

  Future _setTexts() async {
    var sett = await widget.prefsOGx.getSettings();
    organizationProjects =
        await translator.translate('organizationProjects', sett.locale!);
    projectsNotFound =
        await translator.translate('projectsNotFound', sett.locale!);
    refreshData = await translator.translate('refreshData', sett.locale!);
    search = await translator.translate('search', sett.locale!);
    projectsText = await translator.translate('projects', sett.locale!);
    searchProjects = await translator.translate('searchProjects', sett.locale!);
  }

  void _listen() {
    settingsSubscriptionFCM =
        widget.fcmBloc.settingsStream.listen((event) async {
      if (mounted) {
        await _setTexts();
        _getData(false);
      }
    });
    widget.fcmBloc.projectStream.listen((Project project) {
      if (mounted) {
        _getData(false);
      }
    });
    widget.projectBloc.projectStream.listen((List<Project> list) {
      projects = list;
      projects.sort((a, b) => a.name!.compareTo(b.name!));

      if (mounted) {
        setState(() {});
      }
    });
  }

  void _sort() {
    pp('......... sort projects, sortedByName: $sortedByName');
    if (sortedByName) {
      _sortByDate();
    } else {
      _sortByName();
    }
    projectsToDisplay = projects;
    if (mounted) {
      setState(() {});
    }
  }

  void _sortByName() {
    projects.sort((a, b) => a.name!.compareTo(b.name!));
    sortedByName = true;

  }

  void _sortByDate() {
    projects.sort((a, b) => b.created!.compareTo(a.created!));
    sortedByName = false;

  }

  void _getUser() async {
    setState(() {
      isBusy = true;
    });
    user = await widget.prefsOGx.getUser();
    var settings = await widget.prefsOGx.getSettings();
    numberOfDays = settings.numberOfDays!;
    if (user != null) {
      pp('$mm user found: ${user!.name!}');
      _setUserType();
      await _getData(false);
    } else {
      pp('$mm user NOT found!!! 🥏 🥏 🥏');

      throw Exception('$mm Fucked! we are! user is null???');
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

  var projectsToDisplay = <Project>[];

  void _runFilter(String text) {
    pp('$mm .... _runFilter: text: $text ......');
    if (text.isEmpty) {
      pp('$mm .... text is empty ......');
      projectsToDisplay.clear();
      for (var project in projects) {
        projectsToDisplay.add(project);
      }
      setState(() {});
      return;
    }
    projectsToDisplay.clear();

    pp('$mm ...  filtering projects that contain: $text from ${projectNames.length} projects');
    for (var name in projectNames) {
      if (name.toLowerCase().contains(text.toLowerCase())) {
        var proj = _findProject(name);
        if (proj != null) {
          projectsToDisplay.add(proj);
        }
      }
    }
    pp('$mm .... set state with projectsToDisplay: ${projectsToDisplay.length} ......');
    setState(() {});
  }

  Project? _findProject(String name) {
    pp('$mm ... find project by name $name from ${projects.length}');
    for (var project in projects) {
      if (project.name!.toLowerCase() == name.toLowerCase()) {
        return project;
      }
    }
    return null;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future _getData(bool forceRefresh) async {
    pp('$mm 🥏 🥏 🥏 .................... refresh projects: forceRefresh: $forceRefresh');
    if (mounted) {
      setState(() {
        isBusy = true;
      });
    }
    try {
      pp('$mm  🥏 🥏 🥏 getOrganizationProjects, orgId: ${user!.organizationId} k 🥏');
      projects = await widget.organizationBloc.getOrganizationProjects(
          organizationId: user!.organizationId!, forceRefresh: forceRefresh);

      projects.sort((a, b) => a.name!.compareTo(b.name!));
      for (var p in projects) {
        projectNames.add(p.name!);
      }
      projectsToDisplay.clear();
      for (var project in projects) {
        projectsToDisplay.add(project);
      }
    } catch (e) {
      pp(e);
      if (mounted) {
        setState(() {
          busy = false;
        });
        if (e is GeoException) {
          var sett = await widget.prefsOGx.getSettings();
          errorHandler.handleError(exception: e);
          final msg =
              await translator.translate(e.geTranslationKey(), sett.locale!);
          if (mounted) {
            showToast(
                backgroundColor: Theme.of(context).primaryColor,
                textStyle: myTextStyleMedium(context),
                padding: 16,
                duration: const Duration(seconds: 10),
                message: msg,
                context: context);
          }
        }
      }
    }
    if (mounted) {
      setState(() {
        isBusy = false;
      });
      _animationController.forward();
    }
  }

  void _navigateToDetail(Project? p) {
    if (user!.userType == UserType.fieldMonitor) {
      pp('$mm Field Monitors not allowed to edit or create a project');
    }
    if (user!.userType! == UserType.orgAdministrator ||
        user!.userType == UserType.orgExecutive) {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.scale,
              alignment: Alignment.topLeft,
              duration: const Duration(milliseconds: 1500),
              child: ProjectEditMain(
                p,
                prefsOGx: widget.prefsOGx,
                cacheManager: widget.cacheManager,
                fcmBloc: widget.fcmBloc,
                organizationBloc: widget.organizationBloc,
                projectBloc: widget.projectBloc,
                geoUploader: widget.geoUploader,
                cloudStorageBloc: widget.cloudStorageBloc,
                dataApiDog: widget.dataApiDog,
              )));
    }
  }

  void _navigateToProjectLocation(Project p) {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(milliseconds: 1500),
            child: ProjectMapMobile(
              project: p,
            )));
  }

  void _navigateToProjectMedia(Project p) {
    // pp('$mm _navigateToProjectMedia with project: 🔆🔆🔆${p.toJson()}🔆🔆🔆');
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(milliseconds: 1000),
            child: ProjectMediaTimeline(
              project: p,
              projectBloc: widget.projectBloc,
              organizationBloc: widget.organizationBloc,
              prefsOGx: widget.prefsOGx,
              cacheManager: widget.cacheManager,
              dataApiDog: widget.dataApiDog,
              fcmBloc: widget.fcmBloc,
              geoUploader: widget.geoUploader,
              cloudStorageBloc: widget.cloudStorageBloc,
            )));
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
            cloudStorageBloc: widget.cloudStorageBloc,
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
              child: OrganizationMap(
                organizationBloc: widget.organizationBloc,
                prefsOGx: widget.prefsOGx,
              )));
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
              child: ProjectMapMain(
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
    pp('.................. _navigateToProjectDashboard: ');

    if (mounted) {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.scale,
              alignment: Alignment.topLeft,
              duration: const Duration(milliseconds: 1000),
              child: ProjectDashboardMobile(
                project: p,
                projectBloc: widget.projectBloc,
                organizationBloc: widget.organizationBloc,
                prefsOGx: widget.prefsOGx,
                fcmBloc: fcmBloc,
                dataApiDog: widget.dataApiDog,
                geoUploader: widget.geoUploader,
                cloudStorageBloc: widget.cloudStorageBloc,
                cacheManager: widget.cacheManager,
              )));
    }
  }

  bool _showPositionChooser = false;

  void _navigateToDirections(
      {required double latitude, required double longitude}) async {
    pp('$mm 🍎 🍎 🍎 start Google Maps Directions .....');

    final availableMaps = await MapLauncher.installedMaps;
    pp('$mm 🍎 🍎 🍎 availableMaps: $availableMaps'); // [AvailableMap { mapName: Google Maps, mapType: google }, ...]

    var coordinates = Coords(latitude, longitude);
    await availableMaps.first.showDirections(destination: coordinates);
  }

  _onPositionSelected(Position p1) {
    setState(() {
      _showPositionChooser = false;
    });
    _navigateToDirections(
        latitude: p1.coordinates[1], longitude: p1.coordinates[0]);
  }

  _onClose() {
    setState(() {
      _showPositionChooser = false;
    });
  }

  var positions = <ProjectPosition>[];
  var polygons = <ProjectPolygon>[];

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
          title:
              Text('Create Audio Clip', style: myTextStyleSmallBlack(context)),
          trailingIcon: Icon(
            Icons.camera,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            pp('...... going to ProjectAudio ...');
            _navigateToProjectAudio(project);
          }),
    );

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

  final _key = GlobalKey<ScaffoldState>();

  List<IconButton> _getActions() {
    List<IconButton> list = [];
    list.add(IconButton(
      icon: Icon(
        Icons.refresh_rounded,
        size: 20,
        color: Theme.of(context).primaryColor,
      ),
      onPressed: () {
        _getData(true);
      },
    ));
    // list.add(IconButton(
    //   icon: isProjectsByLocation
    //       ? Icon(
    //           Icons.list,
    //           size: 24,
    //           color: Theme.of(context).primaryColor,
    //         )
    //       : Icon(
    //           Icons.location_pin,
    //           size: 20,
    //           color: Theme.of(context).primaryColor,
    //         ),
    //   onPressed: () {
    //     isProjectsByLocation = !isProjectsByLocation;
    //     refreshProjects(true);
    //   },
    // ));
    if (projects.isNotEmpty) {
      list.add(
        IconButton(
          icon: Icon(
            Icons.map,
            size: 20,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            _navigateToOrgMap();
          },
        ),
      );
    }
    if (user != null) {
      if (user!.userType == UserType.orgAdministrator) {
        list.add(
          IconButton(
            icon: Icon(
              Icons.add,
              size: 20,
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

  final projectNames = <String>[];
  int _getIndex(String value) {
    int index = 0;
    for (var element in projectNames) {
      if (value == element) {
        break;
      }
      index++;
    }
    return index;
  }

  static String _displayStringForOption(Project project) => project.name!;
  final TextEditingController _textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final type = getThisDeviceType();
    var searchWidth = 400.0;
    if (type == 'phone') {
      searchWidth = 300.0;
    }
    var color = getTextColorForBackground(Theme.of(context).primaryColor);
    var color2 = getTextColorForBackground(Theme.of(context).primaryColor);

    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;

    if (isDarkMode) {
      color = Theme.of(context).primaryColor;
      color2 = Colors.white;
    }
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text(
                projectsText == null ? 'Projects' : projectsText!,
                style: myTextStyleLargeWithColor(context, color),
              ),
              bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(100),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: searchWidth,
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20.0, horizontal: 12.0),
                                child: TextField(
                                  controller: _textEditingController,
                                  onChanged: (text) {
                                    pp(' ........... changing to: $text');
                                    _runFilter(text);
                                  },
                                  decoration: InputDecoration(
                                      label: Text(
                                        search == null ? 'Search' : search!,
                                        style: myTextStyleSmallWithColor(
                                            context, color),
                                      ),
                                      icon: Icon(
                                        Icons.search,
                                        color: color,
                                      ),
                                      border: const OutlineInputBorder(),
                                      hintText: searchProjects == null
                                          ? 'Search Projects'
                                          : searchProjects!,
                                      hintStyle: myTextStyleSmallWithColor(
                                          context, color)),
                                )),
                          ),
                          const SizedBox(
                            height: 24,
                          )
                        ],
                      )
                    ],
                  )),
              actions: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.refresh)),
              ],
            ),
            backgroundColor: isDarkMode?Theme.of(context).canvasColor: Colors.brown[50],
            body: ScreenTypeLayout.builder(
              mobile: (ctx) {
                return GestureDetector(
                    onTap: _sort,
                    child: bd.Badge(
                      badgeStyle: bd.BadgeStyle(
                        badgeColor: Theme.of(context).primaryColor,
                        elevation: 8,
                        padding: const EdgeInsets.all(8),
                      ),
                      position: bd.BadgePosition.topEnd(top: 2, end: 8),
                      badgeContent: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text('${projectsToDisplay.length}',
                            style: myTextStyleSmallWithColor(context, color2)),
                      ),
                      child: user == null
                          ? const SizedBox()
                          : ProjectListCard(
                              projects: projectsToDisplay,
                              width: width,
                              horizontalPadding: 12,
                              navigateToDetail: _navigateToDetail,
                              navigateToProjectLocation:
                                  _navigateToProjectLocation,
                              navigateToProjectMedia: _navigateToProjectMedia,
                              navigateToProjectMap: _navigateToProjectMap,
                              navigateToProjectPolygonMap:
                                  _navigateToProjectPolygonMap,
                              navigateToProjectDashboard:
                                  _navigateToProjectDashboard,
                              user: user!,
                              navigateToProjectDirections: (project) async {
                                var poss = await cacheManager
                                    .getProjectPositions(project.projectId!);
                                if (poss.isNotEmpty) {
                                  _navigateToDirections(
                                    latitude:
                                        poss.first.position!.coordinates[1],
                                    longitude:
                                        poss.first.position!.coordinates[0],
                                  );
                                }
                              },
                              prefsOGx: widget.prefsOGx,
                            ),
                    ));
              },
              tablet: (ctx) {
                return OrientationLayoutBuilder(
                  portrait: (ctx) {
                    return Row(
                      children: [
                        GestureDetector(
                            onTap: _sort,
                            child: bd.Badge(
                              badgeStyle: bd.BadgeStyle(
                                badgeColor: Theme.of(context).primaryColor,
                                elevation: 8,
                                padding: const EdgeInsets.all(8),
                              ),
                              position:
                                  bd.BadgePosition.topEnd(top: -2, end: -4),
                              badgeContent: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text('${projectsToDisplay.length}',
                                    style: myTextStyleSmallWithColor(
                                        context, color)),
                              ),
                              child: user == null
                                  ? const SizedBox()
                                  : ProjectListCard(
                                      projects: projectsToDisplay,
                                      width: (width / 2) - 20,
                                      horizontalPadding: 12,
                                      navigateToDetail: _navigateToDetail,
                                      navigateToProjectLocation:
                                          _navigateToProjectLocation,
                                      navigateToProjectMedia:
                                          _navigateToProjectMedia,
                                      navigateToProjectMap:
                                          _navigateToProjectMap,
                                      navigateToProjectPolygonMap:
                                          _navigateToProjectPolygonMap,
                                      navigateToProjectDashboard:
                                          _navigateToProjectDashboard,
                                      user: user!,
                                      prefsOGx: widget.prefsOGx,
                                      navigateToProjectDirections:
                                          (project) async {
                                        var poss = await cacheManager
                                            .getProjectPositions(
                                                project.projectId!);
                                        if (poss.isNotEmpty) {
                                          _navigateToDirections(
                                            latitude: poss
                                                .first.position!.coordinates[1],
                                            longitude: poss
                                                .first.position!.coordinates[0],
                                          );
                                        }
                                      },
                                    ),
                            )),
                        GeoActivity(
                            width: (width / 2),
                            thinMode: true,
                            prefsOGx: widget.prefsOGx,
                            cacheManager: widget.cacheManager,
                            dataApiDog: widget.dataApiDog,
                            organizationBloc: widget.organizationBloc,
                            projectBloc: widget.projectBloc,
                            fcmBloc: widget.fcmBloc,
                            geoUploader: widget.geoUploader,
                            cloudStorageBloc: widget.cloudStorageBloc,
                            project: null,
                            showPhoto: (p) {},
                            showVideo: (p) {},
                            showAudio: (p) {},
                            forceRefresh: true,
                            showLocationResponse: (p) {},
                            showLocationRequest: (p) {},
                            showUser: (p) {},
                            showProjectPosition: (p) {},
                            showOrgMessage: (p) {},
                            showGeofenceEvent: (p) {},
                            showProjectPolygon: (p) {}),
                      ],
                    );
                  },
                  landscape: (ctx) {
                    return Row(
                      children: [
                        GestureDetector(
                            onTap: _sort,
                            child: bd.Badge(
                              badgeStyle: bd.BadgeStyle(
                                badgeColor: Theme.of(context).primaryColor,
                                elevation: 8,
                                padding: const EdgeInsets.all(8),
                              ),
                              position:
                                  bd.BadgePosition.topEnd(top: -2, end: 2),
                              badgeContent: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text('${projectsToDisplay.length}',
                                    style: myTextStyleSmallWithColor(
                                        context, color)),
                              ),
                              child: ProjectListCard(
                                projects: projectsToDisplay,
                                width: width / 2,
                                horizontalPadding: 12,
                                prefsOGx: widget.prefsOGx,
                                navigateToDetail: _navigateToDetail,
                                navigateToProjectLocation:
                                    _navigateToProjectLocation,
                                navigateToProjectMedia: _navigateToProjectMedia,
                                navigateToProjectMap: _navigateToProjectMap,
                                navigateToProjectPolygonMap:
                                    _navigateToProjectPolygonMap,
                                navigateToProjectDashboard:
                                    _navigateToProjectDashboard,
                                user: user!,
                                navigateToProjectDirections: (project) async {
                                  var poss = await cacheManager
                                      .getProjectPositions(project.projectId!);
                                  if (poss.isNotEmpty) {
                                    _navigateToDirections(
                                      latitude:
                                          poss.first.position!.coordinates[1],
                                      longitude:
                                          poss.first.position!.coordinates[0],
                                    );
                                  }
                                },
                              ),
                            )),
                        GeoActivity(
                            width: (width / 2) - 48,
                            thinMode: true,
                            prefsOGx: widget.prefsOGx,
                            cacheManager: widget.cacheManager,
                            fcmBloc: widget.fcmBloc,
                            organizationBloc: widget.organizationBloc,
                            projectBloc: widget.projectBloc,
                            project: widget.project,
                            dataApiDog: widget.dataApiDog,
                            geoUploader: widget.geoUploader,
                            cloudStorageBloc: widget.cloudStorageBloc,
                            showPhoto: (p) {},
                            showVideo: (p) {},
                            showAudio: (p) {},
                            forceRefresh: true,
                            showLocationResponse: (p) {},
                            showLocationRequest: (p) {},
                            showUser: (p) {},
                            showProjectPosition: (p) {},
                            showOrgMessage: (p) {},
                            showGeofenceEvent: (p) {},
                            showProjectPolygon: (p) {}),
                      ],
                    );
                  },
                );
              },
            )));
  }

  Widget _fieldBuilder(
      BuildContext context,
      TextEditingController textEditingController,
      FocusNode focusNode,
      VoidCallback onFieldSubmitted) {
    return TextField(
      controller: textEditingController,
      focusNode: focusNode,
      decoration: InputDecoration(
          hintText: 'Enter project search',
          label: Text(
            search == null ? 'Project Search' : search!,
            style: myTextStyleSmall(context),
          ),
          icon: Icon(
            Icons.search,
            color: Theme.of(context).primaryColor,
          )),
    );
  }
}
