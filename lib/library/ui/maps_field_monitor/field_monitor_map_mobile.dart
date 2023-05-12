import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../device_location/device_location_bloc.dart';
import '../../api/data_api_og.dart';
import '../../data/position.dart';
import '../../data/user.dart';
import '../../functions.dart';

class FieldMonitorMapMobile extends StatefulWidget {
  final User user;

  const FieldMonitorMapMobile(this.user, {super.key});

  @override
  FieldMonitorMapMobileState createState() => FieldMonitorMapMobileState();
}

class FieldMonitorMapMobileState extends State<FieldMonitorMapMobile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Completer<GoogleMapController> _mapController = Completer();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  var random = Random(DateTime.now().millisecondsSinceEpoch);
  final _key = GlobalKey<ScaffoldState>();
  bool busy = false;
// -25.7605441 longitude: 27.8525941
  CameraPosition _cameraPosition = const CameraPosition(
    target: LatLng(-25.7705441, 27.8525941),
    zoom: 14.4746,
  );

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getLocation();
  }

  void _getLocation() async {
    pp('💜 💜 💜 💜 💜 💜 FieldMonitorMapMobile: ..... current user, check position: ${widget.user.toJson()}');
    var pos = await locationBloc.getLocation();
    if (pos != null) {
      setState(() {
        _cameraPosition = CameraPosition(
          target: LatLng(pos.latitude!, pos.longitude!),
          zoom: 14.4746,
        );
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  GoogleMapController? googleMapController;
  Future<void> _addMarker(double latitude, double longitude) async {
    pp('💜 💜 💜 💜 💜 💜 FieldMonitorMapMobile: _addMarker: ....... 🍎 $latitude $longitude');
    markers.clear();
    final MarkerId markerId =
        MarkerId('${DateTime.now().millisecondsSinceEpoch}');
    final Marker marker = Marker(
      markerId: markerId,
      // icon: markerIcon,
      position: LatLng(
        latitude,
        longitude,
      ),
      infoWindow: InfoWindow(
          title: widget.user.name,
          snippet: 'Field Monitor Located Around Here'),
      onTap: () {
        _onMarkerTapped();
      },
    );
    markers[markerId] = marker;

    final CameraPosition first = CameraPosition(
      target: LatLng(
        latitude,
        longitude,
      ),
      zoom: 14.4746,
    );
    googleMapController = await _mapController.future;
    googleMapController!.animateCamera(CameraUpdate.newCameraPosition(first));
  }

  void _onMarkerTapped() {
    pp('💜 💜 💜 💜 💜 💜 FieldMonitorMapMobile: _onMarkerTapped ....... ');
  }

  void _onLongPress(LatLng argument) {
    pp('_onLongPress: 🍎 🍎 🍎 $argument');
    _addMarker(argument.latitude, argument.longitude);
    _updateUser(argument.latitude, argument.longitude);
  }

  void _updateUser(double lat, double lng) async {
    pp('💜 💜 💜 💜 💜 💜 FieldMonitorMapMobile: _updateUser ....... ');
    setState(() {
      busy = true;
    });
    try {
      widget.user.position = Position(coordinates: [lng, lat], type: 'Point');
      var result = await dataApiDog.updateUser(widget.user);
      pp('💜 💜 💜 💜 💜 💜 Response : ${result.toJson()}');
    } catch (e) {
      pp(e);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('User Update failed: $e')));
    }

    setState(() {
      busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _key,
        appBar: AppBar(
          title: Text(
            widget.user.name!,
            style: Styles.whiteSmall,
          ),
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(124),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Text(
                      'Locate the FieldMonitor at their Home base. This enables you to match projects with monitors during the onboarding process ',
                      style: myTextStyleSmall(context),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Text(
                      'Press and Hold to locate FieldMonitor',
                      style: myTextStyleSmall(context),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                  ],
                ),
              )),
        ),
        body: Stack(
          children: [
            GoogleMap(
              mapType: MapType.hybrid,
              mapToolbarEnabled: true,
              myLocationButtonEnabled: true,
              initialCameraPosition: _cameraPosition,
              onMapCreated: (GoogleMapController controller) {
                pp('🔵 🔵 GoogleMap:onMapCreated ....');
                _mapController.complete(controller);
                googleMapController = controller;

                if (widget.user.position != null) {
                  pp('🔵 🔵 GoogleMap:onMapCreated ....widget.user.position != null 🔆 🔆 ... add marker');
                  _addMarker(widget.user.position!.coordinates.elementAt(1),
                      widget.user.position!.coordinates.elementAt(0));
                } else {
                  pp('🔵 🔵 GoogleMap:onMapCreated ....widget.user.position == null 🔆 🔆 ... WTF?');
                }
              },
              myLocationEnabled: true,
              markers: Set<Marker>.of(markers.values),
              onLongPress: _onLongPress,
            ),
            busy
                ? const Positioned(
                    left: 60,
                    top: 60,
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 8,
                        backgroundColor: Colors.amber,
                      ),
                    ))
                : Container(),
          ],
        ),
      ),
    );
  }
}
