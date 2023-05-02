// import 'package:carp_background_location/carp_background_location.dart' as bg;
// import 'package:location/location.dart';

// import '../data/position.dart';

// final LocationBloc locationBloc = LocationBloc();
// final LocationBlocOG locationBlocOG = LocationBlocOG();

// class LocationBloc {
//   Future<bg.LocationDto> getLocation() async {
//     // configure the location manager
//     bool ok = await askForLocationAlwaysPermission();
//     bg.LocationManager().interval = 1;
//     bg.LocationManager().distanceFilter = 0;
//     bg.LocationManager().notificationTitle = 'Geo Message';
//     bg.LocationManager().notificationMsg =
//         'Geo is tracking your location for work purposes';
//     // get the current location
//     var dto = await bg.LocationManager().getCurrentLocation();
//
//     // var result = await requestPermission();
//     // pp(result);
//     // var pos = await Geolocator.getCurrentPosition(
//     //     desiredAccuracy: LocationAccuracy.best);
//     // pp('🔆🔆🔆 Location has been found:  💜 latitude: ${pos.latitude} longitude: ${pos.longitude}');
//     return dto;
//   }
//
//   Future<bool> askForLocationAlwaysPermission() async {
//     bool granted = await Permission.locationAlways.isGranted;
//     if (!granted) {
//       granted =
//           await Permission.locationAlways.request() == PermissionStatus.granted;
//     }
//
//     return granted;
//   }
//   // Future<LocationPermission> checkPermission() async {
//   //   var perm = await Geolocator.checkPermission();
//   //   return perm;
//   // }
//   //
//   // Future<LocationPermission> requestPermission() async {
//   //   var perm = await Geolocator.requestPermission();
//   //   return perm;
//   // }
//
//   Future<double> getDistanceFromCurrentPosition(
//       {required double latitude, required double longitude}) async {
//     var pos = await getLocation();
//
//     var dist = SphericalUtils.computeDistanceBetween(
//         Point(pos.latitude, pos.longitude), Point(latitude, longitude));
//
//     // return Geolocator.distanceBetween(
//     //     latitude, longitude, pos.latitude, pos.longitude);
//     return dist;
//   }
//
//   Future<double> getDistance(
//       {required double latitude,
//       required double longitude,
//       required double toLatitude,
//       required double toLongitude}) async {
//     var dist = SphericalUtils.computeDistanceBetween(
//         Point(latitude, longitude), Point(toLatitude, toLongitude));
//
//     return dist;
//     // return Geolocator.distanceBetween(
//     //     latitude, longitude, toLatitude, toLongitude);
//   }
// }
const mc = '';

// class LocationBlocOG {
//   //Location location = Location();
//   final mm = '🍐🍐🍐🍐🍐🍐 LocationBlocOG: ';
//   bool _serviceEnabled = false;
//   // PermissionStatus? _permissionGranted;
//   // Location location = Location();
//
//   Future requestPermission() async {
//     // _permissionGranted = await location.hasPermission();
//     // if (_permissionGranted == PermissionStatus.denied) {
//     //   _permissionGranted = await location.requestPermission();
//     //   if (_permissionGranted != PermissionStatus.granted) {
//     //     return;
//     //   }
//     // }
//
//     // return _permissionGranted;
//     return true;
//   }
//
//   Future<dynamic?> getLocation() async {
//     // _serviceEnabled = await location.serviceEnabled();
//     // if (!_serviceEnabled) {
//     //   _serviceEnabled = await location.requestService();
//     //   if (!_serviceEnabled) {
//     //     return null;
//     //   }
//     // }
//     //
//     // _permissionGranted = await location.hasPermission();
//     // if (_permissionGranted == PermissionStatus.denied) {
//     //   _permissionGranted = await location.requestPermission();
//     //   if (_permissionGranted != PermissionStatus.granted) {
//     //     return null;
//     //   }
//     // }
//     //
//     // final loc = await location.getLocation();
//     // pp('$mm location has been acquired : $loc');
//     return null;
//   }
//
//   Future<double> getDistanceFromCurrentPosition(
//       {required double latitude, required double longitude}) async {
//     var pos = await getLocation();
//
//     if (pos != null) {
//       var latLngFrom = LatLng(pos.latitude!, pos.longitude!);
//       var latLngTo = LatLng(latitude, longitude);
//
//       var distanceBetweenPoints =
//           SphericalUtil.computeDistanceBetween(latLngFrom, latLngTo);
//       var m = distanceBetweenPoints.toDouble();
//       pp('$mm getDistanceFromCurrentPosition calculated: $m metres');
//       return m;
//     }
//     return 0.0;
//   }
//
//   double getDistance(
//       {required double latitude,
//       required double longitude,
//       required double toLatitude,
//       required double toLongitude}) {
//     var latLngFrom = LatLng(latitude, longitude);
//     var latLngTo = LatLng(toLatitude, toLongitude);
//
//     var distanceBetweenPoints =
//         SphericalUtil.computeDistanceBetween(latLngFrom, latLngTo);
//     var m = distanceBetweenPoints.toDouble();
//     pp('$mm getDistance between 2 points calculated: $m metres');
//
//     return m;
//   }
// }
