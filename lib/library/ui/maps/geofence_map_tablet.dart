import 'dart:async';
import 'dart:math';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:geo_monitor/library/api/prefs_og.dart';
import 'package:geo_monitor/library/data/geofence_event.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../l10n/translation_handler.dart';
import '../../data/position.dart' as local;
import '../../data/project_polygon.dart';
import '../../data/project_position.dart';
import '../../data/user.dart';
import '../../functions.dart';

class GeofenceMap extends StatefulWidget {
  final GeofenceEvent geofenceEvent;

  const GeofenceMap({
    super.key,
    required this.geofenceEvent,
  });

  @override
  GeofenceMapState createState() => GeofenceMapState();
}

class GeofenceMapState extends State<GeofenceMap>
    with SingleTickerProviderStateMixin {
  final mm = '🔷🔷🔷GeofenceMapTablet: ';
  late AnimationController _animationController;
  final Completer<GoogleMapController> _mapController = Completer();

  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  var random = Random(DateTime.now().millisecondsSinceEpoch);
  final _key = GlobalKey<ScaffoldState>();
  bool busy = false;
  User? user;
  String? memberAtProject, translatedDate;
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-25.85656, 27.7857),
    zoom: 14.4746,
  );

  @override
  void initState() {
    _animationController = AnimationController(
        value: 0.0,
        duration: const Duration(milliseconds: 2000),
        reverseDuration: const Duration(milliseconds: 1500),
        vsync: this);
    super.initState();
    _setTexts();
    _getUser();
    _setMarkerIcon();
  }

  Future _setTexts() async {
    final sett = await prefsOGx.getSettings();
    memberAtProject = await translator.translate('memberAtProject', sett!.locale!);
    translatedDate = getFmtDate(widget.geofenceEvent.date!, sett!.locale!);
  }

  void _setMarkerIcon() async {
    BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(4.0, 4.0)),
      "assets/avatar.png",
    ).then(
      (icon) {
        setState(() {
          markerIcon = icon;
        });
      },
    );
  }

  User? geofenceUser;
  void _getUser() async {
    user = await prefsOGx.getUser();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  GoogleMapController? googleMapController;

  Future<void> _addMarker() async {
    pp('$mm _addMarker for geofence: ....... 🍎 ');
    markers.clear();
    var latLongs = <LatLng>[];
    var latLng = LatLng(widget.geofenceEvent.position!.coordinates[1],
        widget.geofenceEvent.position!.coordinates[0]);
    latLongs.add(latLng);

    final MarkerId markerId = MarkerId(
        '${widget.geofenceEvent.geofenceEventId}_${random.nextInt(9999988)}');
    final Marker marker = Marker(
      markerId: markerId,
      // icon: markerIcon,
      position: latLng,
      infoWindow: InfoWindow(
          title: widget.geofenceEvent.projectName,
          snippet:
              'Member was here at: ${getFormattedDateShortWithTime(widget.geofenceEvent.date!, context)}'),
      onTap: () {
        _onMarkerTapped();
      },
    );
    markers[markerId] = marker;

    googleMapController = await _mapController.future;
    _animateCamera(
        latitude: latLng.latitude, longitude: latLng.longitude, zoom: 14.0);
  }

  void _onMarkerTapped() {
    pp('$mm  GeofenceMapTablet: _onMarkerTapped ....... ');
  }

  bool isWithin = false;
  void _animateCamera(
      {required double latitude,
      required double longitude,
      required double zoom}) {
    final CameraPosition cameraPosition = CameraPosition(
      target: LatLng(latitude, longitude),
      zoom: zoom,
    );
    googleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  bool _showLargePhoto = false;

  @override
  Widget build(BuildContext context) {
    var showPicture = false;
    if (widget.geofenceEvent.user != null) {
      if (widget.geofenceEvent.user!.thumbnailUrl != null) {
        showPicture = true;
      }
    }
    var deviceType = getThisDeviceType();
    var color = getTextColorForBackground(Theme.of(context).primaryColor);
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;

    if (!isDarkMode) {
      color = Colors.white;
    } else {
      color = Theme.of(context).primaryColor;
    }
    return SafeArea(
      child: Scaffold(
        key: _key,
        appBar: AppBar(
          title: Text(
            memberAtProject == null
                ? 'Member Project Arrival'
                : memberAtProject!,
            style: myTextStyleMediumLargeWithColor(context, color),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Column(
              children: [
                Text(
                  widget.geofenceEvent.projectName!,
                  style: myTextStyleMediumWithColor(context, color),
                ),
                const SizedBox(
                  height: 16,
                )
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
              onMapCreated: (GoogleMapController controller) async {
                pp('\n\\$mm 🍎🍎🍎........... GoogleMap onMapCreated ... ready to rumble!\n\n');
                _mapController.complete(controller);
                googleMapController = controller;
                _addMarker();
                setState(() {});
                _animationController.forward();
              },
              // myLocationEnabled: true,
              markers: Set<Marker>.of(markers.values),
              compassEnabled: true,
              buildingsEnabled: true,
              zoomControlsEnabled: true,
            ),
            _showLargePhoto
                ? Positioned(
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (BuildContext context, Widget? child) {
                        return FadeScaleTransition(
                          animation: _animationController,
                          child: child,
                        );
                      },
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _showLargePhoto = !_showLargePhoto;
                          });
                          _animationController.reset();
                          _animationController.forward();
                        },
                        child: Card(
                          elevation: 8,
                          color: Colors.black38,
                          child: SizedBox(
                            height: deviceType == 'phone' ? 120 : 240,
                            width: deviceType == 'phone' ? 80 : 480,
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 8,
                                ),
                                showPicture
                                    ? Expanded(
                                        child: InteractiveViewer(
                                          child: Image.network(
                                            widget.geofenceEvent.user!
                                                .thumbnailUrl!!,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                    : const SizedBox(),
                                const SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  translatedDate == null
                                      ? widget.geofenceEvent.date!
                                      : translatedDate!,
                                  style: myTextStyleSmallBoldPrimaryColor(context),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  widget.geofenceEvent.user!.name!,
                                  style: myTextStyleSmall(context),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : Positioned(
                    left: 2,
                    top: 2,
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (BuildContext context, Widget? child) {
                        return FadeScaleTransition(
                          animation: _animationController,
                          child: child,
                        );
                      },
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _showLargePhoto = !_showLargePhoto;
                          });
                          _animationController.reset();
                          _animationController.forward();
                        },
                        child: Card(
                          elevation: 8,
                          color: Colors.black38,
                          shape: getRoundedBorder(radius: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: SizedBox(
                              // height: deviceType == 'phone'? 140: 420,
                              width: deviceType == 'phone' ? 144 : 160,
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  showPicture
                                      ? InteractiveViewer(
                                          child: Image.network(
                                            widget.geofenceEvent.user!
                                                .thumbnailUrl!,
                                            fit: BoxFit.fill,
                                          ),
                                        )
                                      : const SizedBox(),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    translatedDate == null
                                        ? widget.geofenceEvent.date!
                                        : translatedDate!,
                                    style: myTextStyleSmallWithColor(context, color),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    widget.geofenceEvent.user!.name!,
                                    style: myTextStyleSmallWithColor(context, color),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  _onSelected(local.Position p1) {
    _animateCamera(
        latitude: p1.coordinates[1], longitude: p1.coordinates[0], zoom: 14.6);
  }
}

class ProjectPositionChooser extends StatelessWidget {
  const ProjectPositionChooser(
      {Key? key,
      required this.projectPositions,
      required this.projectPolygons,
      required this.onSelected})
      : super(key: key);
  final List<ProjectPosition> projectPositions;
  final List<ProjectPolygon> projectPolygons;
  final Function(local.Position) onSelected;
  @override
  Widget build(BuildContext context) {
    var list = <local.Position>[];
    // projectPositions.sort((a,b) => a.created!.compareTo(b.created!));
    for (var value in projectPositions) {
      list.add(value.position!);
    }
    for (var value in projectPolygons) {
      list.add(value.positions.first);
      // for (var element in value.positions) {
      //
      // }
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
                'Location No. ',
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
        hint: Text(
          'Locations',
          style: myTextStyleSmall(context),
        ),
        items: menuItems,
        onChanged: (value) {
          onSelected(value);
        });
  }
}
