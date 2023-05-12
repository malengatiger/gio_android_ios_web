import 'dart:async';

import 'package:geo_monitor/library/api/data_api_og.dart';
import 'package:geo_monitor/library/api/prefs_og.dart';
import 'package:geo_monitor/library/data/location_request.dart';
import 'package:uuid/uuid.dart';

import '../../l10n/translation_handler.dart';
import '../cache_manager.dart';
import '../data/location_response.dart';
import '../data/position.dart';
import '../data/user.dart';
import '../functions.dart';

late LocationRequestHandler locationRequestHandler;

class LocationRequestHandler {
  final mm = '️🌀🌀🌀🌀LocationRequestHandler: 🍎 ';
  bool isStarted = false;
  final DataApiDog dataApiDog;


  LocationRequestHandler(this.dataApiDog);

  Future sendLocationRequest(
      {required String requesterId,
      required String requesterName,
      required String userId,
      required String userName}) async {
    pp('$mm sendLocationRequest ... getting user');
    var user = await prefsOGx.getUser();
    if (user == null) {
      pp('$mm ..... user is null, cannot send location request ....');
      return;
    }
    pp('$mm ..... sending user location request ....');
    final sett = await cacheManager.getSettings();
    final locationRequestArrived = await translator.translate('locationRequestArrived', sett!.locale!);
    final messageFromGeo = await translator.translate('messageFromGeo', sett!.locale!);

    var req = LocationRequest(
      organizationId: user.organizationId,
      requesterId: requesterId,
      requesterName: requesterName,
      userName: userName,
      userId: userId,
      translatedTitle: messageFromGeo,
      translatedMessage: locationRequestArrived,
      organizationName: user.organizationName,
      created: DateTime.now().toUtc().toIso8601String(),
    );

    var result = await dataApiDog.sendLocationRequest(req);
    pp('$mm  LocationRequest sent to cloud backend, result: ${result.toJson()}');
  }

  /// user response to a locationRequest
  Future sendLocationResponse(
      {required String requesterId,
      required String requesterName,
      required double latitude,
      required double longitude,
      required User user}) async {
    pp('$mm sendLocationResponse ... getting user');

    pp('$mm ..... sending user location response ....');

    final messageTitle = await getFCMMessageTitle();
    final locationResponseArrived = await getFCMMessage('locationResponseArrived');

    var locResp = LocationResponse(
        position: Position(coordinates: [longitude, latitude], type: 'Point'),
        date: DateTime.now().toUtc().toIso8601String(),
        userId: user.userId,
        userName: user.name,
        translatedMessage: locationResponseArrived,
        translatedTitle: messageTitle,
        requesterName: requesterName,
        requesterId: requesterId,
        locationResponseId: const Uuid().v4(),
        organizationId: user.organizationId,
        organizationName: user.organizationName);

    var result = await dataApiDog.addLocationResponse(locResp);
    pp('$mm  LocationResponse sent to database, result: ${result.toJson()}');
  }
}
