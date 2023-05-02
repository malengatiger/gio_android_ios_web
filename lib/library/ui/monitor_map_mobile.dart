import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../api/prefs_og.dart';
import '../bloc/organization_bloc.dart';
import '../bloc/project_bloc.dart';
import '../data/project.dart';
import '../data/project_position.dart';
import '../data/user.dart';
import '../functions.dart';


class MonitorMapMobile extends StatefulWidget {
  const MonitorMapMobile({super.key});

  @override
  MonitorMapMobileState createState() => MonitorMapMobileState();
}

class MonitorMapMobileState extends State<MonitorMapMobile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<ProjectPosition> projectPositions = [];
  List<Project> projects = [];
  User? user;
  bool isBusy = false;
  GoogleMapController? googleMapController;

  BitmapDescriptor? markerIcon;

  bool isPortrait = true;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getUser();
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void _getUser() async {
    markerIcon = await BitmapDescriptor.fromAssetImage(
        createLocalImageConfiguration(context),
        'assets/mapicons/construction.png');
    setState(() {
      isBusy = true;
    });
    user = await prefsOGx.getUser();
    pp('🍎 🍎 🍎 user found: 🍎 ${user!.name!}');
    setState(() {
      isBusy = false;
    });
    _getData(false);
  }

  void _getData(bool forceRefresh) async {
    setState(() {
      isBusy = true;
    });
    try {
      user = await prefsOGx.getUser();
      projects = await organizationBloc.getOrganizationProjects(
          organizationId: user!.organizationId!, forceRefresh: forceRefresh);

      var map = await getStartEndDates();
      final startDate = map['startDate'];
      final endDate = map['endDate'];
      for (var i = 0; i < projects.length; i++) {
        var pos = await projectBloc.getProjectPositions(
            projectId: projects.elementAt(i).projectId!,
            forceRefresh: forceRefresh, startDate: startDate!, endDate: endDate!);
        projectPositions.addAll(pos);
      }

      pp('💜 💜 💜 Project positions found: 🍎 ${projectPositions.length}');
      _addMarkers();
    } catch (e) {
      pp(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data refresh failed: $e')));

    }
    setState(() {
      isBusy = false;
    });
  }

  final Completer<GoogleMapController> _mapController = Completer();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  var random = Random(DateTime.now().millisecondsSinceEpoch);

  Future<void> _addMarkers() async {
    pp('💜 💜 💜 _addMarkers ....... 🍎 ${projectPositions.length}');
    markers.clear();
    for (var projectPosition in projectPositions) {
      final MarkerId markerId =
          MarkerId('${projectPosition.projectId}_${random.nextInt(9999988)}');
      final Marker marker = Marker(
        markerId: markerId,
        // icon: markerIcon,
        position: LatLng(
          projectPosition.position!.coordinates.elementAt(1),
          projectPosition.position!.coordinates.elementAt(0),
        ),
        infoWindow: InfoWindow(
            title: projectPosition.projectName,
            snippet: 'Project Located Here'),
        onTap: () {
          _onMarkerTapped(projectPosition);
        },
        onDragEnd: (LatLng position) {
          _onMarkerDragEnd(projectPosition, position);
        },
      );
      markers[markerId] = marker;
    }
    final CameraPosition first = CameraPosition(
      target: LatLng(
          projectPositions.elementAt(0).position!.coordinates.elementAt(1),
          projectPositions.elementAt(0).position!.coordinates.elementAt(0)),
      zoom: 14.4746,
    );
    googleMapController = await _mapController.future;
    googleMapController!.animateCamera(CameraUpdate.newCameraPosition(first));
  }

  final _key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    if (isPortrait) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
    }
    return Scaffold(
      body: Stack(
        children: [
          isBusy
              ? Scaffold(
                  key: _key,
                  appBar: AppBar(
                    title: const Text('Project Map'),
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(200),
                      child: Column(
                        children: [
                          Text(
                            user == null ? '' : user!.name!,
                            style: Styles.whiteBoldSmall,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(user == null ? '' : user!.organizationName!,
                              style: Styles.blackBoldSmall),
                          const SizedBox(
                            height: 40,
                          ),
                        ],
                      ),
                    ),
                  ),
                  body: Center(
                    child: Column(
                      children: const [
                        SizedBox(
                          height: 100,
                        ),
                        CircularProgressIndicator(
                          strokeWidth: 8,
                          backgroundColor: Colors.black,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text('Loading Project Data ...'),
                      ],
                    ),
                  ),
                )
              : GoogleMap(
                  mapType: MapType.hybrid,
                  mapToolbarEnabled: true,
                  initialCameraPosition: _kGooglePlex,
                  onMapCreated: (GoogleMapController controller) {
                    _mapController.complete(controller);
                    googleMapController = controller;
                  },
                  myLocationEnabled: true,
                  onLongPress: _onLongPress,
                  markers: Set<Marker>.of(markers.values),
                ),
          isBusy
              ? Container()
              : Positioned(
                  left: 8,
                  top: 40,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isPortrait = !isPortrait;
                      });
                    },
                    child: Card(
                      elevation: 16,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 16, right: 8, top: 8, bottom: 8),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  user == null ? '' : user!.organizationName!,
                                  style: Styles.blackBoldSmall,
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text('Projects', style: Styles.greyLabelSmall),
                                const SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  '${projects.length}',
                                  style: Styles.pinkBoldSmall,
                                )
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
                )
        ],
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _getData,
      //   label: Text('To the lake!'),
      //   icon: Icon(Icons.directions_boat),
      // ),
    );
  }

  void _onLongPress(LatLng argument) {
    pp('🔆🔆🔆 _onLongPress ,,,,,,,, $argument');
  }

  void _onMarkerTapped(ProjectPosition projectPosition) {
    pp('💜 💜 💜 _onMarkerTapped ....... ${projectPosition.projectName}');
  }

  void _onMarkerDragEnd(ProjectPosition projectPosition, LatLng position) {
    pp('💜 💜 💜 _onMarkerDragEnd ....... ${projectPosition.projectName} LatLng: $position');
  }


}
