import 'package:flutter/material.dart';
import 'package:geo_monitor/l10n/translation_handler.dart';
import 'package:geo_monitor/library/ui/project_edit/project_edit_card.dart';
import 'package:geo_monitor/library/ui/project_location/project_location_handler.dart';
import 'package:page_transition/page_transition.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../ui/activity/geo_activity.dart';
import '../../api/data_api_og.dart';
import '../../api/prefs_og.dart';
import '../../bloc/cloud_storage_bloc.dart';
import '../../bloc/fcm_bloc.dart';
import '../../bloc/geo_uploader.dart';
import '../../bloc/organization_bloc.dart';
import '../../bloc/project_bloc.dart';
import '../../cache_manager.dart';
import '../../data/location_response.dart';
import '../../data/project.dart';
import '../../data/user.dart';
import '../../functions.dart';
import '../maps/location_response_map.dart';

class ProjectEditorTablet extends StatefulWidget {
  final Project? project;
  final PrefsOGx prefsOGx;
  final CacheManager cacheManager;
  final ProjectBloc projectBloc;
  final OrganizationBloc organizationBloc;
  final DataApiDog dataApiDog;
  final FCMBloc fcmBloc;
  final GeoUploader geoUploader;
  final CloudStorageBloc cloudStorageBloc;
  const ProjectEditorTablet(
      {this.project,
      super.key,
      required this.prefsOGx,
      required this.cacheManager,
      required this.projectBloc,
      required this.organizationBloc,
      required this.dataApiDog,
      required this.fcmBloc,
      required this.geoUploader,
      required this.cloudStorageBloc});

  @override
  ProjectEditorTabletState createState() => ProjectEditorTabletState();
}

class ProjectEditorTabletState extends State<ProjectEditorTablet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  var nameController = TextEditingController();
  var descController = TextEditingController();
  var maxController = TextEditingController(text: '500.0');
  var isBusy = false;

  String? projectEditor,
      newProject,
      editProject,
      submitProject,
      projectName,
      descriptionOfProject,
      maximumMonitoringDistance;

  User? admin;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _setup();
    _getUser();
  }

  void _getUser() async {
    admin = await prefsOGx.getUser();
    var sett = await prefsOGx.getSettings();
    projectEditor = await translator.translate('projectEditor', sett.locale!);
    editProject = await translator.translate('editProject', sett.locale!);
    newProject = await translator.translate('newProject', sett.locale!);

    setState(() {});
    if (admin != null) {
      pp('🎽 🎽 🎽 We have an admin user? 🎽 🎽 🎽 ${admin!.name!}');
      setState(() {});
    }
  }

  void _setup() {
    if (widget.project != null) {
      nameController.text = widget.project!.name!;
      descController.text = widget.project!.description!;
      maxController.text = '${widget.project!.monitorMaxDistanceInMetres}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToProjectLocation(Project mProject) async {
    pp(' 😡 _navigateToProjectLocation  😡 😡 😡 ${mProject.name}');
    await Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.fade,
            alignment: Alignment.bottomRight,
            duration: const Duration(seconds: 1),
            child: ProjectLocationHandler(
                fcmBloc: widget.fcmBloc,
                organizationBloc: widget.organizationBloc,
                projectBloc: widget.projectBloc,
                dataApiDog: widget.dataApiDog,
                prefsOGx: widget.prefsOGx,
                geoUploader: widget.geoUploader,
                cloudStorageBloc: widget.cloudStorageBloc,
                cacheManager: widget.cacheManager,
                mProject)));
    if (mounted) {
      Navigator.pop(context);
    }
  }

  final _key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final ori = MediaQuery.of(context).orientation;
    var bottomHeight = 100.0;
    var bottomPadding = 12.0;
    if (ori.name == 'portrait') {
      bottomHeight = 160.0;
      bottomPadding = 48.0;
    }
    return SafeArea(
      child: Scaffold(
        key: _key,
        appBar: AppBar(
          title: Text(
            projectEditor == null ? 'Project Editor' : projectEditor!,
            style: myTextStyleLarge(context),
          ),
          actions: [
            widget.project == null
                ? Container()
                : IconButton(
                    icon: const Icon(Icons.location_on),
                    onPressed: () {
                      if (widget.project != null) {
                        _navigateToProjectLocation(widget.project!);
                      }
                    },
                  )
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(bottomHeight),
            child: Column(
              children: [
                const SizedBox(
                  height: 28,
                ),
                Text(
                  widget.project == null
                      ? newProject == null
                          ? 'New Project'
                          : newProject!
                      : editProject == null
                          ? 'Edit Project'
                          : editProject!,
                  style: myTextStyleMedium(context),
                ),
                const SizedBox(
                  height: 28,
                ),
                Text(
                  admin == null ? '' : admin!.organizationName!,
                  style: myTextStyleLargerPrimaryColor(context),
                ),
                SizedBox(
                  height: bottomPadding,
                )
              ],
            ),
          ),
        ),
        // backgroundColor: Colors.brown[100],
        body: OrientationLayoutBuilder(landscape: (ctx) {
          return Padding(
            padding: const EdgeInsets.all(48.0),
            child: Row(
              children: [
                SizedBox(
                  width: width / 2,
                  child: ProjectEditCard(
                    width: width / 2,
                    project: widget.project,
                    navigateToLocation: (project) {
                      _navigateToProjectLocation(project);
                    },
                  ),
                ),
                const SizedBox(
                  width: 64,
                ),
                GeoActivity(
                  width: (width / 2) - 200,
                  thinMode: true,
                  fcmBloc: widget.fcmBloc,
                  organizationBloc: widget.organizationBloc,
                  projectBloc: widget.projectBloc,
                  geoUploader: widget.geoUploader,
                  cloudStorageBloc: widget.cloudStorageBloc,
                  project: widget.project!,
                  showPhoto: (photo) {},
                  showVideo: (video) {},
                  showAudio: (audio) {},
                  showUser: (user) {},
                  showLocationRequest: (req) {},
                  showLocationResponse: (resp) {
                    _navigateToLocationResponseMap(resp);
                  },
                  showGeofenceEvent: (event) {},
                  showProjectPolygon: (polygon) {},
                  showProjectPosition: (position) {},
                  showOrgMessage: (message) {},
                  forceRefresh: false,
                  prefsOGx: widget.prefsOGx,
                  cacheManager: widget.cacheManager,
                  dataApiDog: widget.dataApiDog,
                ),
              ],
            ),
          );
        }, portrait: (ctx) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                SizedBox(
                  width: width / 2,
                  child: ProjectEditCard(
                    width: width / 2,
                    project: widget.project,
                    navigateToLocation: (project) {
                      _navigateToProjectLocation(project);
                    },
                  ),
                ),
                const SizedBox(
                  width: 24,
                ),
                GeoActivity(
                    width: (width / 2) - 80,
                    thinMode: true,
                    fcmBloc: widget.fcmBloc,
                    organizationBloc: widget.organizationBloc,
                    projectBloc: widget.projectBloc,
                    project: widget.project,
                    prefsOGx: widget.prefsOGx,
                    cacheManager: widget.cacheManager,
                    dataApiDog: widget.dataApiDog,
                    geoUploader: widget.geoUploader,
                    cloudStorageBloc: widget.cloudStorageBloc,
                    showPhoto: (photo) {},
                    showVideo: (video) {},
                    showAudio: (audio) {},
                    showUser: (user) {},
                    showLocationRequest: (req) {},
                    showLocationResponse: (resp) {
                      _navigateToLocationResponseMap(resp);
                    },
                    showGeofenceEvent: (event) {},
                    showProjectPolygon: (polygon) {},
                    showProjectPosition: (position) {},
                    showOrgMessage: (message) {},
                    forceRefresh: false),
              ],
            ),
          );
        }),
      ),
    );
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
}
