import 'dart:async';
import 'dart:isolate';

import 'package:geo_monitor/library/api/prefs_og.dart';
import 'package:geo_monitor/library/bloc/data_refresher.dart';
import 'package:geo_monitor/library/bloc/project_bloc.dart';
import 'package:geo_monitor/library/bloc/user_bloc.dart';
import 'package:geo_monitor/library/bloc/zip_bloc.dart';
import 'package:geo_monitor/library/functions.dart';
import 'package:path_provider/path_provider.dart';

import '../auth/app_auth.dart';
import '../cache_manager.dart';
import '../data/data_bag.dart';
import 'fcm_bloc.dart';
import 'organization_bloc.dart';

late IsolateHandler isolateHandler;

class IsolateHandler {
  static const xx = ' 🎁 🎁 🎁 🎁 🎁 🎁 IsolateHandler:  🎁 ';

  final PrefsOGx prefsOGx;
  final AppAuth appAuth;
  final CacheManager cacheManager;
  final OrganizationBloc organizationBloc;
  final ProjectBloc projectBloc;
  final UserBloc userBloc;
  final FCMBloc fcmBloc;

  IsolateHandler(this.prefsOGx, this.appAuth, this.cacheManager, this.organizationBloc, this.projectBloc, this.userBloc, this.fcmBloc);

  ReceivePort myReceivePort = ReceivePort();
  Future handleOrganization() async {
    pp('$xx handleOrganization;  🦊collect parameters from SettingsModel ...');
    final sett = await prefsOGx.getSettings();
    final token = await appAuth.getAuthToken();
    final map = await getStartEndDates(numberOfDays: sett.numberOfDays!);
    final dir = await getApplicationDocumentsDirectory();

    var gioParams = GioParams(
        organizationId: sett.organizationId!,
        directoryPath: dir.path,
        sendPort: myReceivePort.sendPort,
        token: token!,
        startDate: map['startDate']!,
        endDate: map['endDate']!,
        url: getUrl(),
        projectId: null,
        userId: null);

    await startIsolate(gioParams);
  }

  Future startIsolate(GioParams gioParams) async {
    pp('$xx starting Isolate with gioParams ...');
    
    gioParams.sendPort = myReceivePort.sendPort;

    myReceivePort.listen((message) {
      if (message is DataBag) {
        pp('$xx The bag has been received!');
        printDataBag(message);
        _cacheTheData(message);
        if (gioParams.organizationId != null) {
          _sendOrganizationDataToStreams(message);
        }
        if (gioParams.projectId != null) {
          _sendProjectDataToStreams(message);
        }
        if (gioParams.userId != null) {
          _sendUserDataToStreams(message);
        }
      } else {
        pp('$xx startIsolate received msg: $message');
      }
    });
    await Isolate.spawn<GioParams>(heavyTaskInsideIsolate, gioParams).catchError((err) {
      pp('$xx catchError: $err');
      return Future<Isolate>.delayed(const Duration(milliseconds: 1));
    }).whenComplete(() {
      pp('$xx whenComplete: 💙💙 Isolate seems to be done!\n\n');
    });
  }
  void _sendOrganizationDataToStreams(DataBag bag) {
    organizationBloc.dataBagController.sink.add(bag);
    pp('$xx Organization Data sent to dataBagStream  ...');
  }

  void _sendProjectDataToStreams(DataBag bag) {
    projectBloc.dataBagController.sink.add(bag);
    pp('$xx Project Data sent to dataBagStream  ...');
  }

  void _sendUserDataToStreams(DataBag bag) {
    userBloc.dataBagController.sink.add(bag);
    pp('$xx User Data sent to dataBagStream  ...');
  }

  Future<void> _cacheTheData(DataBag? bag) async {
    pp('$xx zipped Data returned from server, adding to Hive cache ...');
    final start = DateTime.now();
    await cacheManager.addProjects(projects: bag!.projects!);
    await cacheManager.addProjectPolygons(polygons: bag.projectPolygons!);
    await cacheManager.addProjectPositions(positions: bag.projectPositions!);
    await cacheManager.addUsers(users: bag.users!);
    await cacheManager.addPhotos(photos: bag.photos!);
    await cacheManager.addVideos(videos: bag.videos!);
    await cacheManager.addAudios(audios: bag.audios!);
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
        fcmBloc.userController.sink.add(element);
      }
    }
    final end = DateTime.now();

    pp('$xx Org Data saved in Hive cache ... 🍎 '
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

  GioParams(
      {required this.organizationId,
      required this.directoryPath,
      required this.sendPort,
      required this.token,
      required this.startDate,
      required this.endDate,
      required this.url,
      required this.projectId,
      required this.userId});
}

///running inside isolate
void heavyTaskInsideIsolate(GioParams gioParams) async {
  gioParams.sendPort.send('Heavy Task starting ....');

  final bag = await refreshOrganizationDataInIsolate(
      token: gioParams.token,
      organizationId: gioParams.organizationId!,
      startDate: gioParams.startDate,
      endDate: gioParams.endDate,
      url: gioParams.url,
      directoryPath: gioParams.directoryPath);

  gioParams.sendPort.send(bag);
}
