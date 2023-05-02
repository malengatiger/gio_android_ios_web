import 'dart:async';
import 'dart:isolate';

import 'package:geo_monitor/library/api/prefs_og.dart';
import 'package:geo_monitor/library/bloc/data_refresher.dart';
import 'package:geo_monitor/library/bloc/zip_bloc.dart';
import 'package:geo_monitor/library/functions.dart';
import 'package:path_provider/path_provider.dart';

import '../auth/app_auth.dart';
import '../data/data_bag.dart';

late IsolateHandler isolateHandler;

class IsolateHandler {
  static const xx = ' 🎁 🎁 🎁 🎁 🎁 🎁 IsolateHandler:  🎁 ';

  final PrefsOGx prefsOGx;
  final AppAuth appAuth;

  IsolateHandler(this.prefsOGx, this.appAuth);

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
      } else {
        pp('$xx received msg: $message');
      }
    });
    await Isolate.spawn<GioParams>(heavyTaskInsideIsolate, gioParams).catchError((err) {
      pp('$xx catchError: $err');
      return Future<Isolate>.delayed(const Duration(milliseconds: 1));
    }).whenComplete(() {
      pp('$xx whenComplete: 💙💙 Isolate seems to be done!\n\n');
    });
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
