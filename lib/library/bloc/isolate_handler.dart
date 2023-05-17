import 'dart:async';
import 'dart:isolate';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geo_monitor/library/api/prefs_og.dart';
import 'package:geo_monitor/library/bloc/data_refresher.dart';
import 'package:geo_monitor/library/bloc/geo_exception.dart';
import 'package:geo_monitor/library/bloc/location_request_handler.dart';
import 'package:geo_monitor/library/bloc/project_bloc.dart';
import 'package:geo_monitor/library/bloc/user_bloc.dart';
import 'package:geo_monitor/library/bloc/zip_bloc.dart';
import 'package:geo_monitor/library/errors/error_handler.dart';
import 'package:geo_monitor/library/functions.dart';
import 'package:path_provider/path_provider.dart';

import '../api/data_api_og.dart';
import '../auth/app_auth.dart';
import '../cache_manager.dart';
import '../data/data_bag.dart';
import 'fcm_bloc.dart';
import 'organization_bloc.dart';

late IsolateDataHandler dataHandler;

class IsolateDataHandler {
  static const xx = ' 🎁 🎁 🎁 🎁 🎁 🎁 IsolateDataHandler:  🎁 ';
  IsolateDataHandler(this.prefsOGx, this.appAuth, this.cacheManager) {}

  final PrefsOGx prefsOGx;
  final AppAuth appAuth;
  final CacheManager cacheManager;

  late ReceivePort myReceivePort;

  Future<DataBag?> getOrganizationData() async {
    pp('$xx handleOrganization;  🦊collect parameters from SettingsModel ...');
    final sett = await prefsOGx.getSettings();
    pp('$xx getOrganizationData, settings.activityStreamHours: ${sett.activityStreamHours}');
    final token = await appAuth.getAuthToken();
    final map = await getStartEndDates(numberOfDays: sett.numberOfDays!);
    final dir = await getApplicationDocumentsDirectory();

    myReceivePort = ReceivePort();

    var gioParams = GioParams(
        organizationId: sett.organizationId!,
        directoryPath: dir.path,
        sendPort: myReceivePort.sendPort,
        token: token!,
        startDate: map['startDate']!,
        endDate: map['endDate']!,
        url: getUrl(),
        projectId: null,
        activityStreamHours: sett.activityStreamHours!,
        userId: null);

    final bag = await _spawnIsolate(gioParams);
    if (bag != null) {
      await _cacheTheData(bag);
      _sendOrganizationDataToStreams(bag);
    }

    return bag;
  }

  Future<DataBag?> getProjectData(String projectId) async {
    pp('$xx getProjectData;  🦊...');
    myReceivePort = ReceivePort();

    final sett = await prefsOGx.getSettings();
    final token = await appAuth.getAuthToken();
    final map = await getStartEndDates(numberOfDays: sett.numberOfDays!);
    final dir = await getApplicationDocumentsDirectory();

    var gioParams = GioParams(
        organizationId: null,
        directoryPath: dir.path,
        sendPort: myReceivePort.sendPort,
        token: token!,
        startDate: map['startDate']!,
        endDate: map['endDate']!,
        url: getUrl(),
        activityStreamHours: sett.activityStreamHours!,
        projectId: projectId,
        userId: null);

    final bag = await _spawnIsolate(gioParams);
    if (bag != null) {
      await _cacheTheData(bag);
      _sendProjectDataToStreams(bag);
    }
    return bag;
  }

  Future<DataBag?> getUserData(String userId) async {
    pp('$xx handleOrganization;  🦊collect parameters from SettingsModel ...');
    myReceivePort = ReceivePort();
    userBloc = UserBloc(dataApiDog, cacheManager, this);

    final sett = await prefsOGx.getSettings();
    final token = await appAuth.getAuthToken();
    final map = await getStartEndDates(numberOfDays: sett.numberOfDays!);
    final dir = await getApplicationDocumentsDirectory();

    var gioParams = GioParams(
        organizationId: null,
        directoryPath: dir.path,
        sendPort: myReceivePort.sendPort,
        token: token!,
        startDate: map['startDate']!,
        endDate: map['endDate']!,
        url: getUrl(),
        activityStreamHours: sett.activityStreamHours!,
        projectId: null,
        userId: userId);

    final bag = await _spawnIsolate(gioParams);
    if (bag != null) {
      await _cacheTheData(bag);
      _sendUserDataToStreams(bag);
    }
    return bag;
  }

  Future<DataBag?> _spawnIsolate(GioParams gioParams) async {
    pp('$xx starting Isolate with gioParams ... .................');
    pp('$xx starting Isolate with gioParams ... activityStreamHours: ${gioParams.activityStreamHours}');

    final bag = await Isolate.run(() => _heavyTaskInsideIsolate(gioParams));
    return bag;
  }

  void _sendOrganizationDataToStreams(DataBag bag) async {
    organizationBloc.dataBagController.sink.add(bag);
    pp('$xx Organization Data sent to dataBagStream  ...');
  }

  void _sendProjectDataToStreams(DataBag bag) {
    projectBloc.dataBagController.sink.add(bag);
    pp('$xx Project Data sent to dataBagStream  ...');
  }

  void _sendUserDataToStreams(DataBag bag) {
    userBloc?.dataBagController.sink.add(bag);
    pp('$xx User Data sent to dataBagStream  ...');
  }

  Future<void> _cacheTheData(DataBag? bag) async {
    pp('$xx zipped Data returned from server, adding to Hive cache ...');
    if (bag == null) {
      return;
    }
    final start = DateTime.now();
    await cacheManager.addProjects(projects: bag!.projects!);
    await cacheManager.addProjectPolygons(polygons: bag.projectPolygons!);
    await cacheManager.addProjectPositions(positions: bag.projectPositions!);
    await cacheManager.addUsers(users: bag.users!);
    await cacheManager.addPhotos(photos: bag.photos!);
    await cacheManager.addVideos(videos: bag.videos!);
    await cacheManager.addAudios(audios: bag.audios!);
    await cacheManager.addActivityModels(activities: bag.activityModels!);
    bag.settings!.sort((a, b) => DateTime.parse(b.created!)
        .millisecondsSinceEpoch
        .compareTo(DateTime.parse(a.created!).millisecondsSinceEpoch));
    if (bag.settings!.isNotEmpty) {
      await cacheManager.addSettings(settings: bag.settings!.first);
    }
    await cacheManager.addFieldMonitorSchedules(
        schedules: bag.fieldMonitorSchedules!);

    final user = await prefsOGx.getUser();
    for (var element in bag.users!) {
      if (element.userId == user!.userId) {
        await prefsOGx.saveUser(element);
      }
    }
    final end = DateTime.now();

    pp('$xx Organization Data saved in Hive cache ... 🍎 '
        '${end.difference(start).inSeconds} seconds elapsed');
  }
}

class GioParams {
  String? organizationId;
  String? projectId;
  String? userId;

  late String directoryPath;
  late SendPort sendPort;
  late String token;
  late String startDate;
  late String endDate;
  late String url;
  late int activityStreamHours;

  GioParams(
      {required this.organizationId,
      required this.directoryPath,
      required this.sendPort,
      required this.token,
      required this.startDate,
      required this.endDate,
      required this.url,
      required this.projectId,
      required this.userId,
      required this.activityStreamHours});
}

///running inside isolate
Future<DataBag?> _heavyTaskInsideIsolate(GioParams gioParams) async {
  final xx = '🐤🐤🐤🐤 _heavyTaskInsideIsolate: 🐤🐤🐤🐤 '
      'activityStreamHours: ${gioParams.activityStreamHours}';

  pp('$xx starting ................');
  // gioParams.sendPort.send(
  //     'Heavy Task starting .... call method for org or project or user ...');

  DataBag? bag;
  if (gioParams.organizationId != null) {
    bag = await refreshOrganizationDataInIsolate(
        token: gioParams.token,
        organizationId: gioParams.organizationId!,
        startDate: gioParams.startDate,
        endDate: gioParams.endDate,
        url: gioParams.url,
        activityStreamHours: gioParams.activityStreamHours,
        directoryPath: gioParams.directoryPath);
  }
  if (gioParams.projectId != null) {
    bag = await refreshProjectDataInIsolate(
        token: gioParams.token,
        projectId: gioParams.projectId!,
        startDate: gioParams.startDate,
        endDate: gioParams.endDate,
        url: gioParams.url,
        activityStreamHours: gioParams.activityStreamHours,
        directoryPath: gioParams.directoryPath);
  }
  if (gioParams.userId != null) {
    bag = await refreshUserDataInIsolate(
        token: gioParams.token,
        userId: gioParams.userId!,
        startDate: gioParams.startDate,
        endDate: gioParams.endDate,
        url: gioParams.url,
        activityStreamHours: gioParams.activityStreamHours,
        directoryPath: gioParams.directoryPath);
  }

  pp('🔷🔷🔷🔷 heavyTaskInsideIsolate completed, 🔷bag to be returned to the other side via sendPort');
  //gioParams.sendPort.send(bag);
  return bag;
}
