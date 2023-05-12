import 'dart:async';
import 'dart:math';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:geo_monitor/library/api/prefs_og.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../l10n/translation_handler.dart';
import '../../data/photo.dart';
import '../../data/position.dart' as local;
import '../../data/project_polygon.dart';
import '../../data/project_position.dart';
import '../../data/user.dart';
import '../../functions.dart';

class PhotoMap extends StatefulWidget {
  final Photo photo;

  const PhotoMap({
    super.key,
    required this.photo,
  });

  @override
  PhotoMapState createState() => PhotoMapState();
}

class PhotoMapState extends State<PhotoMap>
    with SingleTickerProviderStateMixin {
  final mm = '🔷🔷🔷PhotoMap: ';
  late AnimationController _animationController;
  final Completer<GoogleMapController> _mapController = Completer();

  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  var random = Random(DateTime.now().millisecondsSinceEpoch);
  final _key = GlobalKey<ScaffoldState>();
  bool busy = false;
  User? user;
  String? photoLocationText, myDate;
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

  Future _setTexts() async {
    final sett = await prefsOGx.getSettings();
    photoLocationText =
        await translator.translate('photoLocation', sett!.locale!);
    myDate = getFmtDate(widget.photo.created!, sett!.locale!);
    setState(() {});
  }

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
    pp('$mm _addMarker for photo: ....... 🍎 ');
    markers.clear();
    var latLongs = <LatLng>[];
    var latLng = LatLng(widget.photo.projectPosition!.coordinates[1],
        widget.photo.projectPosition!.coordinates[0]);
    latLongs.add(latLng);

    final MarkerId markerId =
        MarkerId('${widget.photo.photoId}_${random.nextInt(9999988)}');
    final Marker marker = Marker(
      markerId: markerId,
      // icon: markerIcon,
      position: latLng,
      infoWindow: InfoWindow(
          title: widget.photo.projectName, snippet: 'Photo was taken here'),
      onTap: () {
        _onMarkerTapped();
      },
    );
    markers[markerId] = marker;

    googleMapController = await _mapController.future;
    _animateCamera(
        latitude: latLng.latitude, longitude: latLng.longitude, zoom: 18.0);
  }

  void _onMarkerTapped() {
    pp('💜 💜 💜 💜 💜 💜 PhotoMapTablet: _onMarkerTapped ....... ');
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
    var photoHeight = 0.0;
    var photoWidth = 0.0;
    final deviceType = getThisDeviceType();
    if (deviceType == 'phone') {
      if (widget.photo.landscape == 0) {
        photoHeight = 200;
        photoWidth = 160;
      } else {
        photoHeight = 160;
        photoWidth = 200;
      }
    } else {
      if (widget.photo.landscape == 0) {
        photoHeight = 300;
        photoWidth = 400;
      } else {
        photoHeight = 400;
        photoWidth = 300;
      }
    }

    return SafeArea(
      child: Scaffold(
        key: _key,
        appBar: AppBar(
          title: Text(
            photoLocationText == null ? 'Photo Location' : photoLocationText!,
            style: myTextStyleMediumLarge(context),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(84),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 12,
                    ),
                    Flexible(
                      child: Text(
                        widget.photo.projectName!,
                        style: myTextStyleMediumLargePrimaryColor(context),
                      ),
                    ),
                    const SizedBox(
                      width: 28,
                    ),
                    busy
                        ? const SizedBox(
                            width: 48,
                          )
                        : const SizedBox(),
                    busy
                        ? const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              backgroundColor: Colors.pink,
                            ),
                          )
                        : const SizedBox(),

                  ],
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
            Positioned(
              left: 0,
              top: 0,
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
                    shape: getRoundedBorder(radius: 12),
                    color: Colors.black38,
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: SizedBox(
                        // width: deviceType == 'phone' ? 100 : 220,
                        // height: deviceType == 'phone' ? 120 : 340,
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 12,
                            ),
                            InteractiveViewer(
                              child: Image.network(
                                widget.photo.thumbnailUrl!,
                                width: photoWidth,
                                height: photoHeight,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              myDate == null ? widget.photo.created! : myDate!,
                              style: myTextStyleSmall(context),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              '${widget.photo.userName}',
                              style: myTextStyleSmallBoldPrimaryColor(context),
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
