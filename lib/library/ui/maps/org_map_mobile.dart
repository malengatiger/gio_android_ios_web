import 'dart:async';
import 'dart:math';

import 'package:badges/badges.dart' as bd;
import 'package:flutter/material.dart';
import 'package:geo_monitor/library/data/settings_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../l10n/translation_handler.dart';
import '../../api/prefs_og.dart';
import '../../bloc/organization_bloc.dart';
import '../../data/organization.dart';
import '../../data/project.dart';
import '../../data/project_position.dart';
import '../../data/user.dart';
import '../../functions.dart';

class OrganizationMap extends StatefulWidget {
  const OrganizationMap({
    super.key, required this.organizationBloc, required this.prefsOGx,
  });

  final OrganizationBloc organizationBloc;
  final PrefsOGx prefsOGx;

  @override
  OrganizationMapState createState() => OrganizationMapState();
}

class OrganizationMapState extends State<OrganizationMap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Completer<GoogleMapController> _mapController = Completer();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  var random = Random(DateTime.now().millisecondsSinceEpoch);
  final _key = GlobalKey<ScaffoldState>();
  static const defaultZoom = 10.0;
  String? organizationProjects, locations;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-25.42796133580664, 26.085749655962),
    zoom: defaultZoom,
  );
  List<ProjectPosition> _projectPositions = [];
  List<Project> _projects = [];

  Organization? organization;
  bool loading = false;
  User? user;
  String? projectLocatedHere;
  late SettingsModel settings;

  @override
  void initState() {
    pp('$mm initState ...................');
    _controller = AnimationController(vsync: this);
    super.initState();
    _setTexts();
  }
  Future _setTexts() async {
    user = await widget.prefsOGx.getUser();
    settings = await widget.prefsOGx.getSettings();
    organizationProjects =
    await translator.translate('organizationProjects', settings.locale!);
    projectLocatedHere =
    await translator.translate('projectLocatedHere', settings.locale!);
    setState(() {

    });
  }
  void _getOrganizationLocations() async {
    setState(() {
      loading = true;
    });
    user = await widget.prefsOGx.getUser();
    organization = await organizationBloc.getOrganizationById(
        organizationId: user!.organizationId!);

    _refreshProjectPositions(forceRefresh: false);

  }

  void _refreshProjectPositions({required bool forceRefresh}) async {
    pp('$mm _refreshProjectPositions .....  forceRefresh: $forceRefresh');
    var map = await getStartEndDates();
    final startDate = map['startDate'];
    final endDate = map['endDate'];

    _projectPositions = await widget.organizationBloc.getProjectPositions(
        organizationId: organization!.organizationId!,
        forceRefresh: forceRefresh,
        startDate: startDate!,
        endDate: endDate!);
    _projects = await widget.organizationBloc.getOrganizationProjects(
        organizationId: organization!.organizationId!,
        forceRefresh: forceRefresh);

    _projectPositions.sort((a, b) => a.created!.compareTo(b.created!));
    var list = <ProjectPosition>[];
    for (var pos in _projectPositions) {
      if (pos.created == null) {
        pp('$mm found the offending null-in-create bastard! 🔴🔴 ${pos.toJson()} 🔴🔴');
      } else {
        list.add(pos);
      }
    }
    _projectPositions = list;
    _createMarkers();
    setState(() {
      loading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final mm = '💜 💜 💜 💜 💜 💜 OrganizationMapMobile ';
  GoogleMapController? googleMapController;
  var latLngs = <LatLng>[];
  LatLngBounds? bounds;

  Future<void> _createMarkers() async {
    markers.clear();
    latLngs.clear();
    for (var projectPosition in _projectPositions) {
      final latLng = LatLng(
        projectPosition.position!.coordinates.elementAt(1),
        projectPosition.position!.coordinates.elementAt(0),
      );
      latLngs.add(latLng);
      final MarkerId markerId =
          MarkerId('${projectPosition.projectId}_${random.nextInt(9999988)}');
      final Marker marker = Marker(
        markerId: markerId,
        // icon: markerIcon,
        position: latLng,
        infoWindow: InfoWindow(
            title: projectPosition.projectName,
            snippet: projectLocatedHere == null
                ? 'Project Located Here'
                : projectLocatedHere!),
        onTap: () {
          _onMarkerTapped(projectPosition);
        },
      );
      markers[markerId] = marker;
    }
    bounds = boundsFromLatLngList(latLngs);
    pp(' bounds: ${bounds!.toJson()}  🍎');

    final CameraPosition first = CameraPosition(
      target: LatLng(
          _projectPositions.elementAt(0).position!.coordinates.elementAt(1),
          _projectPositions.elementAt(0).position!.coordinates.elementAt(0)),
      zoom: 12.0,
    );
    googleMapController!.animateCamera(CameraUpdate.newCameraPosition(first));
  }

  Future<void> _animateMap() async {
    if (bounds != null) {
      googleMapController = await _mapController.future;
      await googleMapController!
          .animateCamera(CameraUpdate.newLatLngBounds(bounds!, 12));
      setState(() {});
    } else {
      pp('$mm bounds still null .....');
    }
  }

  void _onMarkerTapped(ProjectPosition projectPosition) {
    pp('$mm OrganizationMapMobile: _onMarkerTapped ....... ${projectPosition.projectName}');
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    var  color = getTextColorForBackground(Theme.of(context).primaryColor);

    if (isDarkMode) {
      color = Theme.of(context).primaryColor;
    }
    return SafeArea(
      child: Scaffold(
        key: _key,
        appBar: AppBar(
          title: Text(
            organizationProjects == null
                ? 'Organization Projects'
                : organizationProjects!,
            style: myTextStyleMediumBoldWithColor(context, color),
          ),
          bottom:  PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Column(
              children: [
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 28.0),
                //   child: InkWell(
                //     onTap: () {
                //       _refreshProjectPositions(forceRefresh: true);
                //     },
                //     child: bd.Badge(
                //       // badgeColor: Theme.of(context).primaryColor,
                //       position: bd.BadgePosition.topEnd(top: -20, end: 12),
                //       badgeContent: Text(
                //         '${_projects.length}',
                //         style: myTextStyleMediumBoldWithColor(context, color),
                //       ),
                //       // padding: const EdgeInsets.all(8.0),
                //       child: Row(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: [
                //           organization == null
                //               ? const SizedBox()
                //               : Expanded(
                //                   child: Text(
                //                     organization!.name!,
                //                     style: myTextStyleMediumWithColor(context, color),
                //                   ),
                //                 ),
                //           const SizedBox(
                //             width: 28,
                //           ),
                //           loading
                //               ? SizedBox(
                //                   width: 16,
                //                   height: 16,
                //                   child: CircularProgressIndicator(
                //                     strokeWidth: 4,
                //                     backgroundColor:
                //                         Theme.of(context).primaryColor,
                //                   ),
                //                 )
                //               : const SizedBox(),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                user == null? const SizedBox(): Text(user!.organizationName!,
                  style: myTextStyleMediumWithColor(context, color),),
                const SizedBox(
                  height: 16,
                ),
              ],
            ),
          ),
        ),
        body: Stack(
          children: [
            GoogleMap(
              mapType: MapType.hybrid,
              mapToolbarEnabled: true,
              initialCameraPosition: _kGooglePlex,
              zoomControlsEnabled: true,
              // myLocationButtonEnabled: true,
              compassEnabled: true,
              buildingsEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                pp('$mm onMapCreated ... ready to rumble? ...');
                _mapController.complete(controller);
                googleMapController = controller;
                _getOrganizationLocations();
              },
              markers: Set<Marker>.of(markers.values),
            ),
          ],
        ),
      ),
    );
  }
}
