import 'package:location/location.dart';
import 'package:maps_toolkit/maps_toolkit.dart';

import '../library/functions.dart';

late DeviceLocationBloc locationBloc;

class DeviceLocationBloc {
  final mm = '🍐🍐🍐🍐🍐🍐🍐 DeviceLocationBloc: ';

  PermissionStatus? _permissionGranted;
  final Location location;

  bool _serviceEnabled = false;

  DeviceLocationBloc(this.location);

  Future requestPermission() async {
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    return _permissionGranted;
  }

  Future<LocationData?> getLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    final loc = await location.getLocation();
    pp('$mm location has been acquired : $loc');
    return loc;
  }

  Future<double> getDistanceFromCurrentPosition(
      {required double latitude, required double longitude}) async {
    var pos = await getLocation();

    if (pos != null) {
      var latLngFrom = LatLng(pos.latitude!, pos.longitude!);
      var latLngTo = LatLng(latitude, longitude);

      var distanceBetweenPoints =
          SphericalUtil.computeDistanceBetween(latLngFrom, latLngTo);
      var m = distanceBetweenPoints.toDouble();
      pp('$mm getDistanceFromCurrentPosition calculated: $m metres');
      return m;
    }
    return 0.0;
  }

  double getDistance(
      {required double latitude,
      required double longitude,
      required double toLatitude,
      required double toLongitude}) {
    var latLngFrom = LatLng(latitude, longitude);
    var latLngTo = LatLng(toLatitude, toLongitude);

    var distanceBetweenPoints =
        SphericalUtil.computeDistanceBetween(latLngFrom, latLngTo);
    var m = distanceBetweenPoints.toDouble();
    pp('$mm getDistance between 2 points calculated: $m metres');

    return m;
  }
}
