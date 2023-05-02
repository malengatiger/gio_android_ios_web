import 'dart:async';

import 'package:geo_monitor/library/api/data_api_og.dart';
import 'package:geo_monitor/library/bloc/geo_exception.dart';
import 'package:geo_monitor/library/data/position.dart';
import 'package:geo_monitor/library/errors/error_handler.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:geofence_service/models/geofence.dart' as geo;
import 'package:uuid/uuid.dart';

import '../../device_location/device_location_bloc.dart';
import '../../l10n/translation_handler.dart';
import '../api/data_api.dart';
import '../api/prefs_og.dart';
import '../bloc/organization_bloc.dart';
import '../cache_manager.dart';
import '../data/geofence_event.dart';
import '../data/project_position.dart';
import '../data/user.dart';
import '../functions.dart';

final geofenceService = GeofenceService.instance.setup(
    interval: 5000,
    accuracy: 100,
    loiteringDelayMs: 60000,
    statusChangeDelayMs: 10000,
    useActivityRecognition: false,
    allowMockLocations: false,
    printDevLog: false,
    geofenceRadiusSortType: GeofenceRadiusSortType.DESC);

late TheGreatGeofencer theGreatGeofencer;

class TheGreatGeofencer {
  final xx = '😡😡😡😡😡😡😡 TheGreatGeofencer:  🔱 🔱 ';

  final DataApiDog dataApiDog;
  final PrefsOGx prefsOGx;

  final StreamController<GeofenceEvent> _streamController =
      StreamController.broadcast();

  TheGreatGeofencer(this.dataApiDog, this.prefsOGx);
  Stream<GeofenceEvent> get geofenceEventStream => _streamController.stream;

  final _geofenceList = <geo.Geofence>[];
  User? _user;

  Future<List<ProjectPosition>> _findProjectPositionsByLocation(
      {required String organizationId,
      required double latitude,
      required double longitude,
      required double radiusInKM}) async {

    var mList = await dataApiDog.findProjectPositionsByLocation(
        organizationId: organizationId,
        latitude: latitude,
        longitude: longitude,
        radiusInKM: radiusInKM);
    pp('$xx _getProjectPositionsByLocation: found ${mList.length}\n');
    return mList;
  }

  Future buildGeofences({double? radiusInKM}) async {
    pp('$xx buildGeofences .... build geofences for the organization started ... 🌀 ');
    _user ??= await prefsOGx.getUser();
    if (_user == null) {
      return;
    }

    pp('$xx buildGeofences .... build geofences for the organization 🌀 ${_user!.organizationName}  🌀');

    await locationBloc.requestPermission();
    var startDate = DateTime.now()
        .subtract(const Duration(days: (365 * 2)))
        .toUtc()
        .toIso8601String();
    var endDate = DateTime.now().toUtc().toIso8601String();

    var mList = await organizationBloc.getProjectPositions(
        organizationId: _user!.organizationId!,
        forceRefresh: false,
        startDate: startDate,
        endDate: endDate);
    try {
      if (mList.isEmpty || mList.length > 98) {
        var loc = await locationBloc.getLocation();
        mList = await _findProjectPositionsByLocation(
            organizationId: _user!.organizationId!,
            latitude: loc!.latitude!,
            longitude: loc.longitude!,
            radiusInKM: radiusInKM ?? 50);
        pp('$xx buildGeofences .... project positions found by location: ${mList.length} ');
      }
    } catch (e) {
      pp(e);
    }

    int cnt = 0;
    for (var pos in mList) {
      await addGeofence(projectPosition: pos);
      cnt++;
      if (cnt > 98) {
        break;
      }
    }

    pp('$xx ${_geofenceList.length} geofences added to list');
    geofenceService.addGeofenceList(_geofenceList);

    geofenceService.addGeofenceStatusChangeListener(
        (geofence, geofenceRadius, geofenceStatus, location) async {
      pp('$xx Geofence Listener 💠 FIRED!! '
          '🔵🔵🔵 geofenceStatus: ${geofenceStatus.name}  at 🔶 ${geofence.data['projectName']}');
      await _processGeofenceEvent(
          geofence: geofence,
          geofenceRadius: geofenceRadius,
          geofenceStatus: geofenceStatus,
          location: location);
    });

    try {
      pp('$xx  🔶🔶🔶🔶🔶🔶 Starting GeofenceService ...... 🔶🔶🔶🔶🔶🔶 ');
      await geofenceService.start().onError((error, stackTrace) => {
            // pp('\n\n\n$mm $reds GeofenceService failed to start, onError: 🔴 $error 🔴 \n\n\n')
            errorHandler.handleError(
                exception: GeoException(
                    message: 'No location available, geofenceEvent failed',
                    translationKey: 'serverProblem',
                    errorType: GeoException.formatException,
                    url: '/geo/v1/addGeofenceEvent'))
          });

      pp('$xx ✅✅✅✅✅✅ geofences 🍐🍐🍐 STARTED OK 🍐🍐🍐 '
          '🔆🔆🔆 will wait for geofence status changes ... 🔵🔵🔵🔵🔵 ');
    } catch (e) {
      pp('\n\n$xx GeofenceService failed to start: 🔴 $e 🔴 }');
      errorHandler.handleError(exception: GeoException(message: 'GeofenceService failed to start',
          translationKey: 'serverProblem', errorType: GeoException.formatException,
          url: 'n/a'));
    }
  }

  final reds = '🔴 🔴 🔴 🔴 🔴 🔴 TheGreatGeofencer: ';
  void onError() {}

  Future _processGeofenceEvent(
      {required Geofence geofence,
      required GeofenceRadius geofenceRadius,
      required GeofenceStatus geofenceStatus,
      required Location location}) async {
    pp('$xx _processing new GeofenceEvent; 🔵 ${geofence.data['projectName']} '
        '🔵geofenceStatus: ${geofenceStatus.toString()}');

    var loc = await locationBloc.getLocation();
    //use org settings rather than possibly changed settings from prefs
    final sett = await cacheManager.getSettings();

    String message = 'A member has arrived at ${geofence.data['projectName']}';
    String title = 'Message from Geo';
    final arr = await translator.translate('arrivedAt', sett.locale!);
    message = arr.replaceAll('\$project', geofence.data['projectName']);
    final tit = await translator.translate('messageFromGeo', sett.locale!);
    title = tit.replaceAll('\$geo', 'Geo');

    if (loc != null) {
      var event = GeofenceEvent(
          status: geofenceStatus.toString(),
          organizationId: geofence.data['organizationId'],
          translatedMessage: message,
          user: _user,
          position: Position(
              coordinates: [loc.longitude, loc.latitude], type: 'Point'),
          geofenceEventId: const Uuid().v4(),
          projectPositionId: geofence.id,
          projectId: geofence.data['projectId'],
          projectName: geofence.data['projectName'],
          date: DateTime.now().toUtc().toIso8601String(),
          translatedTitle: title);

      String status = geofenceStatus.toString();
      switch (status) {
        case 'GeofenceStatus.ENTER':
          event.status = 'ENTER';
          pp('$xx IGNORING geofence ENTER event for ${event.projectName}');
          break;
        case 'GeofenceStatus.DWELL':
          event.status = 'DWELL';
          addObject(event);
          break;
        case 'GeofenceStatus.EXIT':
          event.status = 'EXIT';
          addObject(event);
          break;
      }
    } else {
      pp('$xx $reds UNABLE TO PROCESS GEOFENCE - location not available');
      errorHandler.handleError(
          exception: GeoException(
              message: 'No location available, add geofenceEvent failed',
              translationKey: 'serverProblem',
              errorType: GeoException.formatException,
              url: '/geo/v1/addGeofenceEvent'));
    }
  }

  Future addObject(GeofenceEvent event) async {
    pp('$xx about to send geofence event to backend ... ');
    try {
      var gfe = await dataApiDog.addGeofenceEvent(event);
      pp('$xx geofence event added to database for ${event.projectName}');
      _streamController.sink.add(gfe);
    } catch (e) {
      pp('$xx failed to add geofence event');
      if (e is GeoException) {
        errorHandler.handleError(exception: e);
      } else {
        errorHandler.handleError(
            exception: GeoException(
                message: 'Failed to add geofenceEvent',
                translationKey: 'serverProblem',
                errorType: GeoException.httpException,
                url: '/geo/v1/addGeofenceEvent'));
      }
    }
  }

  Future addGeofence({required ProjectPosition projectPosition}) async {
    projectPosition.nearestCities = [];
    if (projectPosition.position != null) {
      var fence = Geofence(
        id: '${projectPosition.projectId!}_${DateTime.now().microsecondsSinceEpoch}',
        data: projectPosition.toJson(),
        latitude: projectPosition.position!.coordinates[1],
        longitude: projectPosition.position!.coordinates[0],
        radius: [
          GeofenceRadius(id: 'radius_100m', length: 100),
          GeofenceRadius(id: 'radius_200m', length: 200),
        ],
      );

      _geofenceList.add(fence);
      pp('$xx added Geofence : 👽👽👽 ${projectPosition.projectName} 👽👽👽👽 '
          '_geofenceList now has ${_geofenceList.length} fences 🍎 ');
    } else {
      pp('🔴🔴🔴🔴🔴🔴 project position is null, WTF??? ${projectPosition.projectName}');
    }
  }

  var defaultRadiusInKM = 100.0;
  var defaultRadiusInMetres = 150.0;
  var defaultDwellInMilliSeconds = 30;

  close() {
    _streamController.close();
  }
}
