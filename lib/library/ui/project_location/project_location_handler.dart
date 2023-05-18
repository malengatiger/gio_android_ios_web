import 'package:flutter/material.dart';
import 'package:geo_monitor/ui/activity/geo_activity.dart';
import 'package:geocoding/geocoding.dart';
import 'package:page_transition/page_transition.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:uuid/uuid.dart';

import '../../../device_location/device_location_bloc.dart';
import '../../../l10n/translation_handler.dart';
import '../../api/data_api_og.dart';
import '../../api/prefs_og.dart';
import '../../bloc/cloud_storage_bloc.dart';
import '../../bloc/fcm_bloc.dart';
import '../../bloc/geo_uploader.dart';
import '../../bloc/organization_bloc.dart';
import '../../bloc/project_bloc.dart';
import '../../cache_manager.dart';
import '../../data/city.dart';
import '../../data/location_response.dart';
import '../../data/place_mark.dart';
import '../../data/position.dart' as mon;
import '../../data/project.dart';
import '../../data/project_polygon.dart';
import '../../data/project_position.dart';
import '../../data/user.dart';
import '../../functions.dart';
import '../maps/location_response_map.dart';
import '../maps/project_map_mobile.dart';
import '../maps/project_polygon_map_mobile.dart';

class ProjectLocationHandler extends StatefulWidget {
  final Project project;
  final PrefsOGx prefsOGx;
  final CacheManager cacheManager;
  final ProjectBloc projectBloc;
  final OrganizationBloc organizationBloc;
  final DataApiDog dataApiDog;
  final FCMBloc fcmBloc;
  final GeoUploader geoUploader;
  final CloudStorageBloc cloudStorageBloc;

  const ProjectLocationHandler(this.project,
      {super.key,
      required this.prefsOGx,
      required this.cacheManager,
      required this.projectBloc,
      required this.organizationBloc,
      required this.dataApiDog,
      required this.fcmBloc,
      required this.geoUploader,
      required this.cloudStorageBloc});

  @override
  ProjectLocationHandlerState createState() => ProjectLocationHandlerState();
}

class ProjectLocationHandlerState extends State<ProjectLocationHandler>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  var busy = false;
  List<ProjectPosition> _projectPositions = [];
  List<ProjectPolygon> _projectPolygons = [];
  final _key = GlobalKey<ScaffoldState>();
  static const mm = '💙💙💙ProjectLocationHandler: 💙 ';
  User? user;
  double? latitude, longitude;

  @override
  void initState() {
    _animationController = AnimationController(
        value: 0.0,
        duration: const Duration(milliseconds: 2000),
        reverseDuration: const Duration(milliseconds: 1000),
        vsync: this);
    super.initState();
    _getLocation();
    _getProjectPositions(false);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<bool> _isLocationWithinProjectMonitorDistance() async {
    pp('$mm calculating _isLocationWithinProjectMonitorDistance .... '
        '${widget.project.monitorMaxDistanceInMetres!} metres');

    var map = <double, ProjectPosition>{};
    for (var i = 0; i < _projectPositions.length; i++) {
      var projPos = _projectPositions.elementAt(i);
      var dist = await locationBloc.getDistanceFromCurrentPosition(
          latitude: projPos.position!.coordinates.elementAt(1),
          longitude: projPos.position!.coordinates.elementAt(0));

      map[dist] = projPos;
      pp('$mm Distance: 🌶 $dist metres 🌶 projectId: ${projPos.projectId} 🐊 projectPositionId: ${projPos.projectPositionId}');
    }

    if (map.isNotEmpty) {
      var list = map.keys.toList();
      list.sort();
      pp('$mm Distances in list, length: : ${list.length} $list');
      if (list.elementAt(0) <=
          widget.project.monitorMaxDistanceInMetres!.toInt()) {
        return true;
      }
    }
    var loc = await locationBloc.getLocation();
    if (loc != null) {
      var mOK = checkIfLocationIsWithinPolygons(
          polygons: _projectPolygons,
          latitude: loc.latitude!,
          longitude: loc.longitude!);
      return mOK;
    }
    return false;
  }

  bool isWithin = false;

  Future _getLocation() async {
    try {
      var position = await locationBloc.getLocation();

      if (position == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Current Location not available')));
        }
        return;
      }
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
      });
    } catch (e) {
      pp(e);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(duration: const Duration(seconds: 5), content: Text('$e')));
    }
  }

  void _getProjectPositions(bool forceRefresh) async {
    pp('$mm _getProjectPositions .... refresh project data ... ');
    setState(() {
      busy = true;
    });

    try {
      user = await prefsOGx.getUser();
      await _getLocation();
      var map = await getStartEndDates();
      final startDate = map['startDate'];
      final endDate = map['endDate'];
      _projectPositions = await projectBloc.getProjectPositions(
          projectId: widget.project.projectId!,
          forceRefresh: forceRefresh,
          startDate: startDate!,
          endDate: endDate!);
      _projectPolygons = await projectBloc.getProjectPolygons(
          projectId: widget.project.projectId!, forceRefresh: forceRefresh);

      pp('$mm _projectPositions found: ${_projectPositions.length}; checking location within project monitorDistance...');
    } catch (e) {
      pp(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: const Duration(seconds: 5),
            content: Text('Data refresh failed: $e')));
      }
    }
    if (mounted) {
      setState(() {
        busy = false;
      });
      _animationController.forward();
    }
  }

  void _submit() async {
    pp('$mm submit new project position .. check first .... ');
    var isOK = await _isLocationWithinProjectMonitorDistance();
    if (isOK) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: const Duration(seconds: 5),
            backgroundColor: Theme.of(context).colorScheme.error,
            content: Text(
              'There is a project location here already for ${widget.project.name}',
              style: myTextStyleMedium(context),
            )));
      }
      return;
    }
    setState(() {
      busy = true;
    });

    pp('$mm getting possible place marks  ..........');

    List<Placemark>? placeMarks;
    try {
      placeMarks = await placemarkFromCoordinates(latitude!, longitude!);
    } catch (e) {
      pp(e);
    }

    try {
      List<City> cities = await dataApiDog.findCitiesByLocation(
          latitude: latitude!, longitude: longitude!, radiusInKM: 10.0);
      pp('$mm Cities found for project position: ${cities.length}');
      pp('$mm submitting current position ..........');
      Placemark? pm;
      if (placeMarks != null) {
        if (placeMarks.isNotEmpty) {
          pm = placeMarks.first;
          pp('$mm Placemark for project location: ${pm.toString()}');
        }
      }
      var org = await prefsOGx.getUser();
      final sett = await cacheManager.getSettings();
      final projectLocationAdded =
          await translator.translate('projectLocationAdded', sett!.locale!);
      final messageFromGeo =
          await translator.translate('messageFromGeo', sett!.locale!);

      var projectPosition = ProjectPosition(
          userId: user!.userId,
          userName: user!.name,
          placemark: pm == null ? null : PlaceMark.getPlaceMark(placemark: pm),
          projectName: widget.project.name,
          caption: 'tbd',
          translatedMessage: projectLocationAdded,
          translatedTitle: messageFromGeo,
          organizationId: org!.organizationId,
          created: DateTime.now().toUtc().toIso8601String(),
          position:
              mon.Position(type: 'Point', coordinates: [longitude, latitude]),
          projectId: widget.project.projectId,
          nearestCities: cities,
          projectPositionId: const Uuid().v4());
      try {
        var m = await dataApiDog.addProjectPosition(position: projectPosition);
        pp('$mm  _submit: new projectPosition added .........  🍅 ${m.toJson()} 🍅');
        organizationBloc.addProjectPositionToStream(m);
        _getProjectPositions(false);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Project Location failed: $e')));
        }
      }

      if (mounted) {
        setState(() {
          busy = false;
        });
        Navigator.pop(context, projectPosition);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

  void onAddProjectLocationHere() {
    _submit();
  }

  void onAddProjectArea() {
    _navigateToProjectPolygonMap();
  }

  onAddProjectLocationElsewhere() {
    pp('$mm ... onAddProjectLocationElsewhere: about to navigate ');
    if (mounted) {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.fade,
              alignment: Alignment.center,
              duration: const Duration(milliseconds: 1000),
              child: ProjectMapMobile(
                project: widget.project,
              )));
    }
  }

  Future<void> _navigateToProjectPolygonMap() async {
    pp('$mm ... _navigateToProjectMap: about to navigate ');

    if (mounted) {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.leftToRightWithFade,
              alignment: Alignment.topLeft,
              duration: const Duration(milliseconds: 1000),
              child: ProjectPolygonMapMobile(
                project: widget.project,
              )));
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    var ori = MediaQuery.of(context).orientation;
    var topHeight = 260.0;
    if (ori.name == 'landscape') {
      topHeight = 180.0;
    }
    return SafeArea(
      child: Scaffold(
        key: _key,
        appBar: AppBar(
          // leading: const SizedBox(),
          centerTitle: true,
          title: Text(
            'Project Locations',
            style: myTextStyleLarge(context),
          ),
          actions: [
            // IconButton(
            //     onPressed: () async {
            //       pp('$mm ........ navigate to map when ready! ');
            //       _navigateToProjectPolygonMap();
            //     },
            //     icon: Icon(Icons.map,
            //         size: 20, color: Theme.of(context).primaryColor)),
            IconButton(
                onPressed: () async {
                  _animationController.reset();
                  _getProjectPositions(true);
                },
                icon: Icon(
                  Icons.refresh,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                )),
            const SizedBox(
              width: 20,
            )
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(topHeight),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${widget.project.name}',
                        style: myTextStyleLargerPrimaryColor(context),
                      ),
                      const SizedBox(
                        width: 48,
                      ),
                      busy
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 4,
                                backgroundColor: Colors.pink,
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 128.0),
                    child: Text(
                      'Add a Project Location at this location that you are at. '
                      'This location will be enabled for monitoring the project or event.',
                      style: myTextStyleSmall(context),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 128.0),
                    child: Text(
                      'If you want to create a new Project Area tap the map icon at top right '
                      'to go to a map that will help you do that',
                      style: myTextStyleSmall(context),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Row(
                    children: [
                      Text(
                        'Project Locations:',
                        style: myTextStyleSmall(context),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        '${_projectPositions.length}',
                        style: myNumberStyleMediumPrimaryColor(context),
                      ),
                      const SizedBox(
                        width: 28,
                      ),
                      Text(
                        'Project Areas:',
                        style: myTextStyleSmall(context),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        '${_projectPolygons.length}',
                        style: myNumberStyleMediumPrimaryColor(context),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                ],
              ),
            ),
          ),
        ),
        body: ScreenTypeLayout(
          mobile: latitude == null
              ? const SizedBox()
              : CurrentLocationCard(
                  latitude: latitude!,
                  longitude: longitude!,
                  width: width,
                  paddingTop: 48,
                  paddingBottom: 48,
                  onAddProjectArea: onAddProjectArea,
                  onAddProjectLocationHere: onAddProjectLocationHere,
                  onAddProjectLocationElsewhere: onAddProjectLocationElsewhere),
          tablet: latitude == null
              ? const SizedBox()
              : OrientationLayoutBuilder(landscape: (ctx) {
                  return Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: CurrentLocationCard(
                            latitude: latitude!,
                            longitude: longitude!,
                            width: (width / 2) - 80,
                            paddingTop: 32,
                            paddingBottom: 24,
                            onAddProjectLocationHere: onAddProjectLocationHere,
                            onAddProjectArea: onAddProjectArea,
                            onAddProjectLocationElsewhere:
                                onAddProjectLocationElsewhere),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28.0),
                        child: GeoActivity(
                            width: (width / 2) - 80,
                            prefsOGx: widget.prefsOGx,
                            cacheManager: widget.cacheManager,
                            thinMode: false,
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
                      )
                    ],
                  );
                }, portrait: (ctx) {
                  return Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: CurrentLocationCard(
                            latitude: latitude!,
                            longitude: longitude!,
                            width: (width / 2) + 2,
                            paddingTop: 60,
                            paddingBottom: 48,
                            onAddProjectArea: onAddProjectArea,
                            onAddProjectLocationHere: onAddProjectLocationHere,
                            onAddProjectLocationElsewhere:
                                onAddProjectLocationElsewhere),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      GeoActivity(
                          width: (width / 2) - 80,
                          thinMode: false,
                          fcmBloc: widget.fcmBloc,
                          organizationBloc: widget.organizationBloc,
                          projectBloc: widget.projectBloc,
                          project: widget.project,
                          dataApiDog: widget.dataApiDog,
                          geoUploader: widget.geoUploader,
                          cloudStorageBloc: widget.cloudStorageBloc,
                          prefsOGx: widget.prefsOGx,
                          cacheManager: widget.cacheManager,
                          showPhoto: (p) {},
                          showVideo: (p) {},
                          showAudio: (p) {},
                          showUser: (user) {},
                          showLocationRequest: (req) {},
                          showLocationResponse: (resp) {
                            _navigateToLocationResponseMap(resp);
                          },
                          showGeofenceEvent: (event) {},
                          showProjectPolygon: (polygon) {},
                          showProjectPosition: (position) {},
                          showOrgMessage: (message) {},
                          forceRefresh: false)
                    ],
                  );
                }),
        ),
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

class CurrentLocationCard extends StatelessWidget {
  const CurrentLocationCard(
      {Key? key,
      required this.latitude,
      required this.longitude,
      required this.paddingTop,
      required this.paddingBottom,
      required this.onAddProjectLocationHere,
      required this.onAddProjectLocationElsewhere,
      required this.width,
      required this.onAddProjectArea})
      : super(key: key);

  final double latitude, longitude, paddingTop, paddingBottom, width;
  final Function() onAddProjectLocationHere;
  final Function() onAddProjectLocationElsewhere;
  final Function() onAddProjectArea;

  @override
  Widget build(BuildContext context) {
    var spaceBetweenButtons = 0.0;
    var ori = MediaQuery.of(context).orientation;
    var delta = 8;
    if (ori.name == 'landscape') {
      spaceBetweenButtons = 24.0;
      delta = 10;
    } else {
      spaceBetweenButtons = 36.0;
      delta = 8;
    }
    return SizedBox(
      width: width,
      child: Card(
        elevation: 4,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
        child: Column(
          children: [
            SizedBox(
              height: paddingTop,
            ),
            Text(
              'You are at this Location',
              style: myTextStyleLarge(context),
            ),
            SizedBox(
              height: paddingTop,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      'Latitude',
                      style: myTextStyleSmall(context),
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Text(
                    latitude.toStringAsFixed(6),
                    style: myNumberStyleLarge(context),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      'Longitude',
                      style: myTextStyleSmall(context),
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Text(
                    longitude.toStringAsFixed(6),
                    style: myNumberStyleLarge(context),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: paddingTop,
            ),
            busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      backgroundColor: Colors.black,
                    ),
                  )
                : SizedBox(
                    height: spaceBetweenButtons * delta,
                    child: Column(
                      children: [
                        SizedBox(
                          height: spaceBetweenButtons,
                        ),
                        SizedBox(
                          width: 300.0,
                          child: ElevatedButton(
                            onPressed: onAddProjectLocationHere,
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  // side: const BorderSide(color: Colors.pink)
                                ),
                              ),
                              elevation: MaterialStateProperty.all<double>(8.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 20, right: 20, top: 12, bottom: 12),
                              child: Text(
                                'Add Project Location Here',
                                style: Styles.whiteSmall,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: spaceBetweenButtons,
                        ),
                        SizedBox(
                          width: 300,
                          child: ElevatedButton(
                            onPressed: onAddProjectLocationElsewhere,
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  // side: const BorderSide(color: Colors.pink)
                                ),
                              ),
                              elevation: MaterialStateProperty.all<double>(8.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 20, right: 20, top: 12, bottom: 12),
                              child: Text(
                                'Add Project Location Elsewhere',
                                style: myTextStyleMedium(context),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: spaceBetweenButtons,
                        ),
                        SizedBox(
                          width: 300,
                          child: ElevatedButton(
                            onPressed: onAddProjectArea,
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  // side: const BorderSide(color: Colors.pink)
                                ),
                              ),
                              elevation: MaterialStateProperty.all<double>(8.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 20, right: 20, top: 12, bottom: 12),
                              child: Text(
                                'Add Project Monitoring Area',
                                style: myTextStyleMedium(context),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            const SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
    );
  }
}
