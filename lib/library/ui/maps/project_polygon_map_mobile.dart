import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:badges/badges.dart' as bd;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geo_monitor/library/bloc/organization_bloc.dart';
import 'package:geo_monitor/library/data/project_position.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../device_location/device_location_bloc.dart';
import '../../../l10n/translation_handler.dart';
import '../../api/data_api_og.dart';
import '../../api/prefs_og.dart';
import '../../bloc/project_bloc.dart';
import '../../cache_manager.dart';
import '../../data/city.dart';
import '../../data/position.dart';
import '../../data/position.dart' as local;
import '../../data/project.dart';
import '../../data/project_polygon.dart';
import '../../data/user.dart';
import '../../emojis.dart';
import '../../functions.dart';
import '../../generic_functions.dart';

class ProjectPolygonMapMobile extends StatefulWidget {
  final Project project;

  const ProjectPolygonMapMobile({
    super.key,
    required this.project,
  });

  @override
  ProjectPolygonMapMobileState createState() => ProjectPolygonMapMobileState();
}

class ProjectPolygonMapMobileState extends State<ProjectPolygonMapMobile>
    with SingleTickerProviderStateMixin {
  final mm = '🍎🍎🍎 ProjectPolygonMapMobile: ';
  late AnimationController _animationController;
  final Completer<GoogleMapController> _mapController = Completer();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  var random = Random(DateTime.now().millisecondsSinceEpoch);
  bool busy = false;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 6,
  );
  final Set<Polygon> _polygons = HashSet<Polygon>();
  final Set<Marker> _positionMarkers = HashSet<Marker>();
  var projectPolygons = <ProjectPolygon>[];
  var projectPositions = <ProjectPosition>[];

  String? title, area, areas;

  User? user;
  @override
  void initState() {
    _animationController = AnimationController(
        value: 0.0,
        duration: const Duration(milliseconds: 2000),
        reverseDuration: const Duration(milliseconds: 1500),
        vsync: this);
    super.initState();
    _setTexts();
    _getData(false);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _setTexts() async {
    var sett = await prefsOGx.getSettings();
    title = await translator.translate('projectMonitoringAreas', sett.locale!);
    areas = await translator.translate('areas', sett.locale!);
    var x = await translator.translate('area', sett.locale!);
    area = x.replaceAll('$count', '');
  }

  void _getData(bool forceRefresh) async {
    setState(() {
      busy = true;
    });
    try {
      user = await prefsOGx.getUser();
      var map = await getStartEndDates();
      final startDate = map['startDate'];
      final endDate = map['endDate'];
      projectPolygons = await projectBloc.getProjectPolygons(
          projectId: widget.project.projectId!, forceRefresh: forceRefresh);
      projectPositions = await projectBloc.getProjectPositions(
          projectId: widget.project.projectId!,
          forceRefresh: forceRefresh,
          startDate: startDate!,
          endDate: endDate!);
      var loc = await locationBloc.getLocation();
      if (loc != null) {
        _latitude = loc.latitude!;
        _longitude = loc.longitude!;
        _addMarkers();
        _buildProjectPolygons(animateToLast: false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
    setState(() {
      busy = false;
    });
  }

  void _addMarkers() {
    markers.clear();
    for (var pos in projectPositions) {
      var marker = Marker(
          position: LatLng(pos.position!.coordinates.elementAt(1),
              pos.position!.coordinates.elementAt(0)),
          markerId: MarkerId(DateTime.now().toIso8601String()), infoWindow: InfoWindow(
        title: widget.project.name, snippet: widget.project.description,
        onTap: _onMarkerTapped,
      ));
      _positionMarkers.add(marker);
    }
    pp('$mm _addMarkers: 🍏project markers added.: '
        '🔵 ${_positionMarkers.length} markers ...');
    _animateCamera(zoom: 12.6, position: projectPositions.first.position!);
    setState(() {});
  }

  void _buildProjectPolygons({required bool animateToLast}) {
    pp('$mm _buildProjectPolygons happening ... projectPolygons: ${projectPolygons.length}');
    _polygons.clear();
    for (var polygon in projectPolygons) {
      var points = <LatLng>[];
      for (var position in polygon.positions) {
        points.add(LatLng(position.coordinates[1], position.coordinates[0]));
      }
      _polygons.add(Polygon(
        polygonId: PolygonId(polygon.projectPolygonId!),
        points: points,
        fillColor: Colors.black26,
        strokeColor: Colors.pink,
        geodesic: true,
        strokeWidth: 4,
      ));
    }

    pp('$mm _buildProjectPolygons: 🍏project polygons created.: '
        '🔵 ${_polygons.length} points in polygon ...');
    _animateCamera(zoom: 12.6, position: projectPolygons.first.positions.first);
    setState(() {});
  }

  GoogleMapController? googleMapController;
  double _latitude = 0.0, _longitude = 0.0;

  final _myPoints = <LatLng>[];

  void _drawPolygon() {
    pp('$mm about to draw my Polygon with 💜 ${_myPoints.length} points');
    _polygons.add(Polygon(
      polygonId: PolygonId(DateTime.now().toIso8601String()),
      points: _myPoints,
      fillColor: Colors.black26,
      strokeColor: Colors.pink,
      geodesic: true,
      strokeWidth: 4,
    ));
    setState(() {});
  }

  void _clearPolygon() {
    pp('$mm about to CLEAR my Polygon with ${_myPoints.length} points');
    _myPoints.clear();
    _polygons.clear();
    _buildProjectPolygons(animateToLast: false);
    setState(() {});
  }

  void _onLongPress(LatLng latLng) {
    pp('$mm long pressed location: 🍎 $latLng');
    var isOK = checkIfLocationIsWithinPolygons(
        latitude: latLng.latitude,
        longitude: latLng.longitude,
        polygons: projectPolygons);
    pp('$mm long pressed location found in any of the project\'s 🍎 '
        'polygons; isWithin the polygons: $isOK - ${isOK ? E.leaf : E.redDot}');

    if (user!.userType == UserType.fieldMonitor) {
      pp('$mm FieldMonitor not allowed to create polygon, 🔶 quitting!');
      return;
    }
    _myPoints.add(latLng);
    pp('$mm Polygon has collected ${_myPoints.length} ');
    showToast(
        toastGravity: ToastGravity.CENTER_LEFT,
        textStyle: myTextStyleSmall(context),
        backgroundColor: Theme.of(context).primaryColor,
        message: 'Area point no. ${_myPoints.length}',
        context: context);

    if (_myPoints.length > 1) {
      _drawPolygon();
    }
  }

  Future<void> _submitNewPolygon() async {
    pp('\n\n$mm _submitNewPolygon started. 🍏🍏adding polygon to project ...'
        '${E.blueDot} polygon points: ${_myPoints.length}');

    setState(() {
      busy = true;
    });
    try {
      _latitude = _myPoints.first.latitude;
      _longitude = _myPoints.first.longitude;

      pp('Go and find nearest cities to this location : lat: $_latitude lng: $_longitude ...');
      List<City> cities = await dataApiDog.findCitiesByLocation(
          latitude: _latitude, longitude: _longitude, radiusInKM: 5.0);

      pp('$mm Cities around this project polygon: ${cities.length}');

      var positions = <local.Position>[];
      for (var point in _myPoints) {
        positions.add(local.Position(
            type: 'Point', coordinates: [point.longitude, point.latitude]));
      }
      pp('$mm Positions in this project polygon: ${positions.length}; 🔷 polygon about to be created');
      final sett = await cacheManager.getSettings();
      final projectAreaAdded = await translator.translate('projectAreaAdded', sett!.locale!);
      final messageFromGeo = await getFCMMessageTitle();

      var pos = ProjectPolygon(
          projectName: widget.project.name,
          userId: user!.userId,
          userName: user!.name,
          projectPolygonId: const Uuid().v4(),
          created: DateTime.now().toUtc().toIso8601String(),
          positions: positions,
          nearestCities: cities,
          translatedTitle: messageFromGeo,
          translatedMessage: projectAreaAdded,
          organizationId: widget.project.organizationId,
          projectId: widget.project.projectId);

      var resultPolygon = await dataApiDog.addProjectPolygon(polygon: pos);
      pp('$mm polygon saved in DB. we are good to go! '
          '🍏🍏${resultPolygon.toJson()}🍏🍏 ');
      organizationBloc.addProjectPolygonToStream(resultPolygon);
      projectPolygons.add(resultPolygon);
      _buildProjectPolygons(animateToLast: true);
      _myPoints.clear();
    } catch (e) {
      pp(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: const Duration(seconds: 10), content: Text('$e')));
      }
    }
    setState(() {
      busy = false;
    });
  }

  void _animateCamera(
      {required double zoom, required local.Position position}) {
    CameraPosition? first = CameraPosition(
      target: LatLng(
          position.coordinates.elementAt(1), position.coordinates.elementAt(0)),
      zoom: zoom,
    );

    googleMapController!.animateCamera(CameraUpdate.newCameraPosition(first));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            title == null ? 'Project Monitoring Areas' : title!,
            style: myTextStyleMediumLarge(context),
          ),
          elevation: 0.0,
          titleSpacing: 10.0,
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(80),
            child: Column(
              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(left:16.0),
                          child: Text(
                      '${widget.project.name}',
                      style: myTextStyleMediumPrimaryColor(context),
                    ),
                        )),
                    const SizedBox(
                      width: 16,
                    ),
                    ProjectPolygonChooser(
                      area: area == null? 'Area': area!,
                        areas: areas == null? 'Areas': areas!,
                        projectPolygons: projectPolygons,
                        onSelected: onSelected),
                    const SizedBox(
                      width: 8,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 24,
                )
              ],
            ),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  _getData(true);
                },
                icon: Icon(
                  Icons.refresh,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                )),
            _myPoints.length > 2
                ? IconButton(
                    onPressed: () {
                      _submitNewPolygon();
                    },
                    icon: Icon(
                      Icons.check,
                      size: 32,
                      color: Theme.of(context).primaryColor,
                    ))
                : const SizedBox(),
            _myPoints.isEmpty
                ? const SizedBox()
                : IconButton(
                    tooltip: 'Clear area you are working on',
                    onPressed: () {
                      _clearPolygon();
                    },
                    icon: Icon(
                      Icons.layers_clear,
                      size: 16,
                      color: Theme.of(context).primaryColor,
                    )),
            // IconButton(
            //     onPressed: () {},
            //     icon: Icon(
            //       Icons.close,
            //       size: 20,
            //       color: Theme.of(context).primaryColor,
            //     )),
          ],
        ),
        body: Stack(
          children: [
            GestureDetector(
              onTap: () {
                if (projectPositions.isNotEmpty) {
                  _animateCamera(
                      zoom: 10.0, position: projectPositions.first.position!);
                }
              },
              child: bd.Badge(
                badgeStyle: bd.BadgeStyle(
                  badgeColor: Theme.of(context).primaryColor,
                  elevation: 8,
                  padding: const EdgeInsets.all(8),
                ),
                badgeContent: Text(
                  '${projectPolygons.length}',
                  style: myNumberStyleSmall(context),
                ),
                position: bd.BadgePosition.topEnd(top: 8, end: 8),
                // elevation: 16,
                child: GoogleMap(
                  mapType: MapType.hybrid,
                  mapToolbarEnabled: true,
                  initialCameraPosition: _kGooglePlex,
                  onMapCreated: (GoogleMapController controller) {
                    pp('🍎🍎🍎........... GoogleMap onMapCreated ... ready to rumble!');
                    _mapController.complete(controller);
                    googleMapController = controller;
                    setState(() {});
                  },
                  // myLocationEnabled: true,
                  markers: _positionMarkers,
                  polygons: _polygons,
                  compassEnabled: true,
                  buildingsEnabled: true,
                  zoomControlsEnabled: true,
                  onLongPress: _onLongPress,
                  rotateGesturesEnabled: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  onSelected(Position p1) {
    _animateCamera(zoom: 14.6, position: p1);
  }

  void _onMarkerTapped() {
    pp('$mm marker tapped');
  }
}

class ProjectPolygonChooser extends StatelessWidget {
  const ProjectPolygonChooser(
      {Key? key,
      required this.projectPolygons,
      required this.onSelected,
      required this.area,
      required this.areas})
      : super(key: key);
  final List<ProjectPolygon> projectPolygons;
  final Function(local.Position) onSelected;
  final String area, areas;

  @override
  Widget build(BuildContext context) {
    var list = <local.Position>[];
    projectPolygons.sort((a, b) => a.created!.compareTo(b.created!));

    for (var value in projectPolygons) {
      list.add(value.positions.first);
    }
    var cnt = 0;
    var menuItems = <DropdownMenuItem>[];
    for (var pos in list) {
      cnt++;
      menuItems.add(
        DropdownMenuItem<local.Position>(
          value: pos,
          child: Row(
            children: [
              Text(
                area,
                style: myTextStyleSmall(context),
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                '$cnt',
                style: myNumberStyleSmall(context),
              ),
            ],
          ),
        ),
      );
    }
    return DropdownButton(
        hint: Text(areas,
          style: myTextStyleSmall(context),
        ),
        items: menuItems,
        onChanged: (value) {
          onSelected(value);
        });
  }
}
