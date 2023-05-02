import 'dart:async';
import 'dart:math';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geo_monitor/library/cache_manager.dart';
import 'package:geo_monitor/library/data/location_response.dart';
import 'package:geo_monitor/library/generic_functions.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_launcher/map_launcher.dart' as ml;

import '../../data/user.dart';
import '../../functions.dart';

class LocationResponseMap extends StatefulWidget {
  final LocationResponse locationResponse;

  const LocationResponseMap({
    super.key,
    required this.locationResponse,
  });

  @override
  LocationResponseMapState createState() => LocationResponseMapState();
}

class LocationResponseMapState extends State<LocationResponseMap>
    with SingleTickerProviderStateMixin {
  final mm = '🔷🔷🔷🔷🔷🔷LocationResponseMap: ';
  late AnimationController _animationController;
  final Completer<GoogleMapController> _mapController = Completer();

  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  var random = Random(DateTime.now().millisecondsSinceEpoch);
  final _key = GlobalKey<ScaffoldState>();
  bool busy = false;
  bool _showUser = false;
  User? user;
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

  Future _getUser() async {
    user = await cacheManager.getUserById(widget.locationResponse.userId!);
    if (user != null) {
      pp('$mm user found in Hive cache ${user!.name!}');
      _showUser = true;
    } else {
      pp('$mm user NOT found in Hive cache');
    }
    setState(() {});
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  GoogleMapController? googleMapController;

  Future<void> _addMarker() async {
    pp('$mm _add user Marker: ....... 🍎 ');

    markers.clear();
    final MarkerId markerId = MarkerId('${random.nextInt(9999988)}');
    final Marker marker = Marker(
      markerId: markerId,
      // icon: markerIcon,
      position: LatLng(
        widget.locationResponse.position!.coordinates.elementAt(1),
        widget.locationResponse.position!.coordinates.elementAt(0),
      ),
      infoWindow: InfoWindow(
          title: widget.locationResponse.userName,
          snippet:
              'Member Location at ${getFormattedDateLongWithTime(widget.locationResponse.date!, context)}'),
      onTap: () {
        _onMarkerTapped();
      },
    );
    markers[markerId] = marker;
    googleMapController = await _mapController.future;
    var lat = widget.locationResponse.position!.coordinates[1];
    var lng = widget.locationResponse.position!.coordinates[0];
    _animateCamera(latitude: lat, longitude: lng, zoom: 15.0);
  }

  void _onMarkerTapped() {
    pp('$mm _onMarkerTapped ....... ');
  }

  void _navigateToDirections(
      {required double latitude, required double longitude}) async {
    pp('$mm 🍎 🍎 🍎 start Google Maps Directions .....');

    final availableMaps = await ml.MapLauncher.installedMaps;
    pp('$mm 🍎 🍎 🍎 availableMaps: $availableMaps'); // [AvailableMap { mapName: Google Maps, mapType: google }, ...]

    var coordinates = ml.Coords(latitude, longitude);
    await availableMaps.first.showDirections(destination: coordinates);
  }

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

  @override
  Widget build(BuildContext context) {
    var date = DateTime.parse(widget.locationResponse.date!)
        .toLocal()
        .toIso8601String();
    var deviceType = getThisDeviceType();
    return SafeArea(
      child: Scaffold(
        key: _key,
        appBar: AppBar(
          title: Text(
            'Member Location',
            style: myTextStyleLarge(context),
          ),
          bottom: PreferredSize(
            preferredSize:  Size.fromHeight(deviceType == 'phone'? 100: 80),
            child: Column(
              children: [

                Text(
                  widget.locationResponse.userName!,
                  style: myTextStyleLargerPrimaryColor(context),
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(
                      width: 12,
                    ),

                    const SizedBox(
                      width: 28,
                    ),
                    Text(
                      getFormattedDateHourMinuteSecond(
                          date: DateTime.parse(date), context: context),
                      style: myNumberStyleLarge(context),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const SizedBox(
                          width: 0,
                        ),
                        IconButton(
                          onPressed: () {
                            _navigateToDirections(
                              latitude: widget
                                  .locationResponse.position!.coordinates[1],
                              longitude: widget
                                  .locationResponse.position!.coordinates[0],
                            );
                          },
                          icon: const Icon(Icons.directions_car),
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(
                          width: 28,
                        ),
                        IconButton(
                          onPressed: () {
                            //todo - navigate to chat messaging
                            showToast(
                                backgroundColor: Theme.of(context).primaryColor,
                                toastGravity: ToastGravity.TOP,
                                message:
                                    'Messaging Under Construction! \n\nPlease come back soon.\n',
                                textStyle: myTextStyleMediumBold(context),
                                context: context);
                          },
                          icon: Icon(Icons.send, color: Theme.of(context).primaryColor,),
                          color: Colors.blue,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
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
              onMapCreated: (GoogleMapController controller) async {
                pp('\n\\$mm 🍎🍎🍎........... GoogleMap onMapCreated ... ready to rumble!\n\n');
                _mapController.complete(controller);
                googleMapController = controller;
                _addMarker();
                await _getUser();
                setState(() {});
              },
              // myLocationEnabled: true,
              markers: Set<Marker>.of(markers.values),
              compassEnabled: true,
              buildingsEnabled: true,
              zoomControlsEnabled: true,
            ),
            _showUser
                ? Positioned(
                    left: 12,
                    top: 12,
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (BuildContext context, Widget? child) {
                        return FadeScaleTransition(
                          animation: _animationController,
                          child: child,
                        );
                      },
                      child: Card(
                        elevation: 8,
                        color: Colors.black26,
                        child: SizedBox(
                          height: deviceType =='phone'? 200: 360,
                          width: deviceType =='phone'? 100: 200,
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 12,
                              ),
                              Image.network(
                                user!.thumbnailUrl!,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Text(
                                getFormattedDateShortestWithTime(
                                    widget.locationResponse.date!, context),
                                style: myNumberStyleMedium(context),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(
                    child: Text('User is null, wtf?'),
                  )
          ],
        ),
      ),
    );
  }


}
