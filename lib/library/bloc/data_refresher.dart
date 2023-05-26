import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:archive/archive_io.dart';

import 'package:geo_monitor/library/api/prefs_og.dart';
import 'package:geo_monitor/library/bloc/fcm_bloc.dart';
import 'package:geo_monitor/library/bloc/organization_bloc.dart';
import 'package:geo_monitor/library/errors/error_handler.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../l10n/translation_handler.dart';
import '../api/data_api_og.dart';
import '../auth/app_auth.dart';
import '../cache_manager.dart';
import '../data/country.dart';
import '../data/data_bag.dart';
import '../data/project.dart';
import '../data/user.dart';
import '../emojis.dart';
import '../functions.dart';
import 'geo_exception.dart';
import 'project_bloc.dart';
import 'user_bloc.dart';

late DataRefresher dataRefresher;

Random rand = Random(DateTime.now().millisecondsSinceEpoch);
late Directory directory;

/// Manages the uploading of media files to Cloud Storage using isolates
class DataRefresher {
  static const xx = '🌼🌼🌼🌼🌼🌼🌼🌼 DataRefresher: 🌼🌼 ';

  var numberOfDays = 60;
  late String url = '';
  var token = '';
  late String startDate;
  late String endDate;
  User? user;

  final AppAuth appAuth;
  final ErrorHandler errorHandler;
  final DataApiDog dataApiDog;
  final http.Client client;
  final CacheManager cacheManager;

  DataRefresher(this.appAuth, this.errorHandler, this.dataApiDog, this.client,
      this.cacheManager);

  Future<DataBag?> manageRefresh(
      {required int? numberOfDays,
      required String? organizationId,
      required String? projectId,
      required String? userId}) async {
    pp('\n\n\n$xx manageRefresh: will run inside Isolates: starting ... 🔵🔵🔵😡😡\n\n');
    var start = DateTime.now();
    final sett = await prefsOGx.getSettings();

    if (numberOfDays == null) {
      this.numberOfDays = sett.numberOfDays!;
    } else {
      this.numberOfDays = numberOfDays;
    }
    directory = await getApplicationDocumentsDirectory();
    pp('$xz manageRefresh: 🔆🔆🔆 directory: ${directory.path}');
    await _setUp();
    DataBag? bag;
    try {
      bag = await _performWork(
          organizationId: organizationId,
          bag: bag,
          projectId: projectId,
          userId: userId,
          activityStreamHours: sett.activityStreamHours!);
      _finish(bag, start);
    } catch (e) {
      pp('$xx Something went horribly wrong, will RETRY ...: $e');
      if (e is GeoException) {
        errorHandler.handleError(exception: e);
      }
      bag = await retry(
          numberOfDays: numberOfDays,
          organizationId: organizationId,
          projectId: projectId,
          userId: userId,
          activityStreamHours: sett.activityStreamHours!);
      _finish(bag, start);
    }

    pp('$xx Done with organization data, refreshing projects and users if needed ...');

    pp('$xx users empty; will start refresh ...... ');
    var users = await _startUsersRefresh(organizationId: organizationId!);
    if (bag != null) {
      bag.users = users;
      var projects =
          await _startProjectsRefresh(organizationId: organizationId!);
      bag.projects = projects;

      pp('$xx users in bag: ${bag!.users!.length}; putting bag in stream ...... ');
      organizationBloc.dataBagController.sink.add(bag);
    }

    var end = DateTime.now();
    pp('$xx Data refresh took ${end.difference(start).inSeconds} seconds');
    return bag;
  }

  DataBag? _finish(DataBag? bag, DateTime start) {
    var end = DateTime.now();
    if (bag != null) {
      pp('$xx manageRefresh: 🥬🥬🥬🥬🥬🥬 '
          'completed and data cached and sent to stream. 🥬🥬🥬 '
          '${end.difference(start).inSeconds} seconds elapsed');
    } else {
      pp('\n\n$xz Fucking bag is null! 🍎🍎🍎🍎🍎🍎');
      return DataBag(
          photos: [],
          videos: [],
          fieldMonitorSchedules: [],
          projectPositions: [],
          projects: [],
          audios: [],
          date: DateTime.now().toIso8601String(),
          users: [],
          projectPolygons: [],
          settings: [],
          activityModels: []);
    }
    return null;
  }

  Future<DataBag?> retry(
      {required int? numberOfDays,
      required String? organizationId,
      required String? projectId,
      required String? userId,
      required int activityStreamHours}) async {
    pp('$xx retrying the call after an error, will kick off after 5 seconds  ...');
    await Future.delayed(const Duration(seconds: 5));
    DataBag? bag;
    bag = await _performWork(
        organizationId: organizationId,
        bag: bag,
        projectId: projectId,
        userId: userId,
        activityStreamHours: activityStreamHours);
    return bag;
  }

  Future<DataBag?> _performWork(
      {String? organizationId,
      DataBag? bag,
      String? projectId,
      String? userId,
      required int activityStreamHours}) async {
    if (organizationId != null) {
      bag = await _startOrganizationDataRefresh(
          organizationId: organizationId,
          directoryPath: directory.path,
          activityStreamHours: activityStreamHours);
    }
    if (projectId != null) {
      bag = await _startProjectRefresh(
          projectId: projectId,
          directoryPath: directory.path,
          activityStreamHours: activityStreamHours);
    }
    if (userId != null) {
      bag = await _startUserDataRefresh(
          userId: userId,
          directoryPath: directory.path,
          activityStreamHours: activityStreamHours);
    }
    return bag;
  }

  Future _setUp() async {
    url = getUrl();
    try {
      token = (await appAuth.getAuthToken())!;
      pp('$xx 🍎🍎🍎token: \n$token 🍎🍎🍎\n');
      startDate = DateTime.now()
          .toUtc()
          .subtract(Duration(days: numberOfDays))
          .toIso8601String();
      endDate = DateTime.now().toUtc().toIso8601String();
      pp('$xx 🍎🍎🍎 check dates:startDate: $startDate endDate: $endDate 🍎🍎🍎');
      user = await prefsOGx.getUser();
      if (user == null) {
        throw Exception('User is null');
      }
      _check();
    } catch (e) {
      pp('$mm $e');
      final gex = GeoException(
          message: 'Unable to obtain Firebase token',
          translationKey: 'networkProblem',
          errorType: GeoException.socketException,
          url: url);
      errorHandler.handleError(exception: gex);
    }
  }

  Future<List<Project>> _startProjectsRefresh(
      {required String organizationId}) async {
    pp('$xx .......  _startProjectRefresh in an isolate ...');
    var list = await Isolate.run(() async => await getAllOrganizationProjects(
          token: token,
          mUrl: url,
          organizationId: organizationId,
        )).catchError((onError) {
      pp('$xx ${E.redDot}${E.redDot}${E.redDot}${E.redDot} $onError');
    });
    pp('$xz projects found: ${list.length}');
    await cacheManager.addProjects(projects: list);

    return list;
  }

  Future<List<User>> _startUsersRefresh(
      {required String organizationId}) async {
    pp('$xx .......  _startUsersRefresh in an isolate ...');
    var list = await Isolate.run(() async => await getUsers(
          token: token,
          mUrl: url,
          organizationId: organizationId,
        )).catchError((onError) {
      pp('$xx ${E.redDot}${E.redDot}${E.redDot}${E.redDot} $onError');
    });
    pp('$xz _startUsersRefresh: 🥬 users found: ${list.length}');
    await cacheManager.addUsers(users: list);
    return list;
  }

  Future<List<Country>> _startCountryRefresh() async {
    pp('$xx .......  _startCountryRefresh in an isolate ...');
    var list = await Isolate.run(() async => await getCountries(
          token: token,
          mUrl: url,
        ));
    pp('$xz countries found: ${list.length}');
    for (var element in list) {
      await cacheManager.addCountry(country: element);
    }

    return list;
  }

  Future<DataBag> _startOrganizationDataRefresh(
      {required String organizationId,
      required String directoryPath,
      required int activityStreamHours}) async {
    pp('$xx .......  startOrganizationRefresh in an isolate ...');
    late DataBag bag;
    try {
      bag = await Isolate.run(() async =>
          await refreshOrganizationDataInIsolate(
              token: token,
              directoryPath: directoryPath,
              organizationId: organizationId,
              startDate: startDate,
              activityStreamHours: activityStreamHours,
              endDate: endDate,
              url: url)).catchError((onError) {
        pp('$xx ${E.redDot}${E.redDot}${E.redDot}${E.redDot} $onError - return null for dataBag ${E.redDot}${E.redDot}');
        return DataBag(
            photos: [],
            videos: [],
            fieldMonitorSchedules: [],
            projectPositions: [],
            projects: [],
            audios: [],
            date: 'date',
            users: [],
            projectPolygons: [],
            settings: [],
            activityModels: []);
      });
    } on StateError catch (e, s) {
      pp('$xx ${E.redDot}${E.redDot} Isolate StateError, e: $e'); // In a bad state!
      pp('$xx ${E.redDot}${E.redDot} Isolate StateError, s: $s'); // In a bad state!
    }

    pp('$xx startOrganizationRefresh: isolate function completed, dataBag delivered; '
        'will be cached and sent to streams ...');
    if (!bag.isEmpty()) {
      _sendOrganizationDataToStreams(bag);
      _cacheTheData(bag);
      pp('$xx startOrganizationRefresh: isolate function completed, dataBag cached.\n');
    } else {
      pp('$xx Yo! this bag be null ... someone not behaving!');
    }
    return bag;
  }

  Future<DataBag?> _startProjectRefresh(
      {required String projectId,
      required String directoryPath,
      required int activityStreamHours}) async {
    pp('$xx .......  startProjectRefresh in an isolate ...');
    await _setUp();
    DataBag? bag;

    bag = await Isolate.run(() async => await refreshProjectDataInIsolate(
        token: token,
        directoryPath: directoryPath,
        projectId: projectId,
        startDate: startDate,
        activityStreamHours: activityStreamHours,
        endDate: endDate,
        url: url));
    pp('$xx startProjectRefresh: isolate function completed, dataBag delivered; '
        'will be cached and sent to streams ...');
    if (bag != null) {
      _sendProjectDataToStreams(bag);
      _cacheTheData(bag);
      pp('$xx startProjectRefresh: isolate function completed, dataBag cached.\n');
    }
    return bag;
  }

  Future<DataBag?> _startUserDataRefresh(
      {required String userId,
      required String directoryPath,
      required int activityStreamHours}) async {
    pp('$xx .......  startUserRefresh in an isolate ...');
    await _setUp();
    DataBag? bag;

    bag = await Isolate.run(() async => await refreshUserDataInIsolate(
        token: token,
        directoryPath: directoryPath,
        userId: userId,
        startDate: startDate,
        activityStreamHours: activityStreamHours,
        endDate: endDate,
        url: url));
    pp('$xx startUserRefresh: isolate function completed, dataBag delivered; '
        'will be cached and sent to streams ...');
    if (bag != null) {
      _sendUserDataToStreams(bag);
      _cacheTheData(bag);
      pp('$xx startUserRefresh: isolate function completed, dataBag cached.\n');
    } else {
      pp('$xx bag is null. Fuck!!');
    }
    return bag;
  }

  void _check() {
    if (user == null) {
      throw Exception('User is null. What the FUCK!! 🍎🍎🍎🍎');
    } else {
      pp('$xx user is OK!!!! ${user!.name} - ${user!.organizationId} ');
    }
    if (url.isEmpty) {
      throw Exception('url is null. What the FUCK!! 🍎🍎🍎🍎');
    } else {
      pp('$xx url is OK!!!! $url');
    }
    if (token.isEmpty) {
      throw Exception('token is null. What the FUCK!! 🍎🍎🍎🍎');
    } else {
      pp('$xx token is OK!!!!');
    }
    if (user!.organizationId == null) {
      throw Exception('organizationId is null. What the FUCK!! 🍎🍎🍎🍎');
    } else {
      pp('$xx organizationId is OK!!!!');
    }
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
    await cacheManager.deleteActivityModels();
    await cacheManager.addActivityModels(activities: bag.activityModels!);

    bag.settings!.sort((a, b) => DateTime.parse(b.created!)
        .millisecondsSinceEpoch
        .compareTo(DateTime.parse(a.created!).millisecondsSinceEpoch));
    if (bag.settings!.isNotEmpty) {
      await cacheManager.addSettings(settings: bag.settings!.first);
    }
    await cacheManager.addFieldMonitorSchedules(
        schedules: bag.fieldMonitorSchedules!);

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

//
//
//
/// Isolate functions to get organization data from the cloud...
Future<DataBag> refreshOrganizationDataInIsolate(
    {required String token,
    required String organizationId,
    required String startDate,
    required String endDate,
    required String url,
    required String directoryPath,
    required int activityStreamHours}) async {
  pp('$xz ............ refreshOrganizationDataInIsolate starting .... '
      'calling getOrganizationDataZippedFile, activityStreamHours: $activityStreamHours');
  DataBag? bag;

  try {
    bag = await getOrganizationDataZippedFile(
        url: url,
        directoryPath: directoryPath,
        organizationId: organizationId,
        startDate: startDate,
        endDate: endDate,
        activityStreamHours: activityStreamHours,
        token: token);
  } catch (e) {
    pp('$mm We have an issue here. $e');
  }
  if (bag == null) {
    pp('$xz Bag not returned from getOrganizationDataZippedFile ');
    throw GeoException(
        message: 'Problem with http call: $e',
        url: url,
        translationKey: 'serverProblem',
        errorType: GeoException.socketException);
  }
  pp('$xz ............ refreshOrganizationDataInIsolate ended. returning bag');
  return bag;
}

Future<DataBag?> refreshProjectDataInIsolate(
    {required String token,
    required String projectId,
    required String startDate,
    required String endDate,
    required String url,
    required String directoryPath,
    required int activityStreamHours}) async {
  pp('$xz refreshProjectDataInIsolate starting ....');
  DataBag? bag;

  bag = await getProjectDataZippedFile(
      url: url,
      directoryPath: directoryPath,
      projectId: projectId,
      startDate: startDate,
      endDate: endDate,
      activityStreamHours: activityStreamHours,
      token: token);

  return bag;
}

Future<DataBag?> refreshUserDataInIsolate(
    {required String token,
    required String userId,
    required String startDate,
    required String endDate,
    required String url,
    required String directoryPath,
    required int activityStreamHours}) async {
  pp('$xz refreshUserDataInIsolate starting ....');
  DataBag? bag;

  bag = await getUserDataZippedFile(
      url: url,
      directoryPath: directoryPath,
      userId: userId,
      startDate: startDate,
      activityStreamHours: activityStreamHours,
      endDate: endDate,
      token: token);

  return bag;
}

Future<DataBag?> getOrganizationDataZippedFile(
    {required String organizationId,
    required String startDate,
    required String endDate,
    required String token,
    required String url,
    required String directoryPath,
    required int activityStreamHours}) async {
  pp('$xz getOrganizationDataZippedFile  🔆🔆🔆 organizationId : 💙  $organizationId  💙');
  var start = DateTime.now();
  var mUrl =
      '${url}getOrganizationDataZippedFile?organizationId=$organizationId&startDate=$startDate&endDate=$endDate&activityStreamHours=$activityStreamHours';

  var bag =
      await _getDataBag(mUrl: mUrl, token: token, directoryPath: directoryPath);
  if (bag == null) {
    pp('$xz This is a problem, Boss! - null bag!');
  }
  var end = DateTime.now();
  pp('$xz getOrganizationDataZippedFile: ${end.difference(start).inSeconds} seconds elapsed');
  return bag;
}

Future<DataBag?> getProjectDataZippedFile(
    {required String projectId,
    required String startDate,
    required String endDate,
    required String token,
    required String url,
    required String directoryPath,
    required int activityStreamHours}) async {
  pp('$xz getProjectDataZippedFile  🔆🔆🔆 projectId : 💙  $projectId  💙');
  final start = DateTime.now();
  ;
  var mUrl =
      '${url}getProjectDataZippedFile?projectId=$projectId&startDate=$startDate&endDate=$endDate&activityStreamHours=$activityStreamHours';

  var bag =
      await _getDataBag(mUrl: mUrl, token: token, directoryPath: directoryPath);
  final end = DateTime.now();
  pp('$xz getProjectDataZippedFile: ${end.difference(start).inSeconds} seconds elapsed');

  return bag;
}

Future<DataBag?> getUserDataZippedFile(
    {required String userId,
    required String startDate,
    required String endDate,
    required String token,
    required String url,
    required String directoryPath,
    required int activityStreamHours}) async {
  pp('$xz getUserDataZippedFile  🔆🔆🔆 orgId : 💙  $userId  💙');
  final start = DateTime.now();
  var mUrl =
      '${url}getUserDataZippedFile?userId=$userId&startDate=$startDate&endDate=$endDate&activityStreamHours=$activityStreamHours';

  var bag =
      await _getDataBag(mUrl: mUrl, token: token, directoryPath: directoryPath);
  var end = DateTime.now();
  pp('$xz getUserDataZippedFile: ${end.difference(start).inSeconds} seconds elapsed');

  return bag;
}

Future<List<Project>> getAllOrganizationProjects(
    {required String organizationId,
    required String mUrl,
    required String token}) async {
  final client = http.Client();
  var start = DateTime.now();

  var list = <Project>[];
  Map<String, String> headers = {
    'Content-type': 'application/json',
    'Accept': '*/*',
    'Content-Encoding': 'application/json',
    'Authorization': 'Bearer $token'
  };

  mUrl = '${mUrl}getAllOrganizationProjects?organizationId=$organizationId';
  var uri = Uri.parse(mUrl);

  http.Response httpResponse = await client
      .get(
        uri,
        headers: headers,
      )
      .timeout(const Duration(seconds: 120));
  pp('$xz getAllOrganizationProjects: RESPONSE: .... : 💙 statusCode: 👌👌👌 '
      '${httpResponse.statusCode} 👌👌👌  for $mUrl');
  var end = DateTime.now();
  pp('$xz getAllOrganizationProjects: elapsed time: ${end.difference(start).inSeconds} seconds');
  if (httpResponse.statusCode == 200) {
    List mList = jsonDecode(httpResponse.body);
    for (var value in mList) {
      list.add(Project.fromJson(value));
    }
    return list;
  } else {
    pp('$xz Bad status; ${httpResponse.statusCode} ${httpResponse.body}');
    return [];
  }
}

Future<List<User>> getUsers(
    {required String organizationId,
    required String mUrl,
    required String token}) async {
  final client = http.Client();
  var start = DateTime.now();

  var list = <User>[];
  Map<String, String> headers = {
    'Content-type': 'application/json',
    'Accept': '*/*',
    'Content-Encoding': 'application/json',
    'Authorization': 'Bearer $token'
  };
  try {
    mUrl = '${mUrl}getAllOrganizationUsers?organizationId=$organizationId';
    var uri = Uri.parse(mUrl);

    http.Response httpResponse = await client
        .get(
          uri,
          headers: headers,
        )
        .timeout(const Duration(seconds: 120));
    pp('$xz getUsers: RESPONSE: .... : 💙 statusCode: 👌👌👌 '
        '${httpResponse.statusCode} 👌👌👌  for $mUrl');
    var end = DateTime.now();
    pp('$xz getUsers: elapsed time: ${end.difference(start).inSeconds} seconds');
    if (httpResponse.statusCode == 200) {
      List mList = jsonDecode(httpResponse.body);
      for (var value in mList) {
        list.add(User.fromJson(value));
      }
      return list;
    } else {
      pp('$xz getUsers: Bad status; ${httpResponse.statusCode} ${httpResponse.body}');
      return [];
    }
  } on SocketException {
    pp('$xz No Internet connection, really means that server cannot be reached 😑');
    throw GeoException(
        message: 'No Internet connection',
        url: mUrl,
        translationKey: 'networkProblem',
        errorType: GeoException.socketException);
  } on HttpException {
    pp("$xz HttpException occurred 😱");
    throw GeoException(
        message: 'Server not around',
        url: mUrl,
        translationKey: 'serverProblem',
        errorType: GeoException.httpException);
  } on FormatException {
    pp("$xz Bad response format 👎");
    throw GeoException(
        message: 'Bad response format',
        url: mUrl,
        translationKey: 'serverProblem',
        errorType: GeoException.formatException);
  } on TimeoutException {
    pp("$xz GET Request has timed out in $timeOutInSeconds seconds 👎");
    throw GeoException(
        message: 'Request timed out',
        url: mUrl,
        translationKey: 'networkProblem',
        errorType: GeoException.timeoutException);
  }

  return [];
}

Future<List<Country>> getCountries(
    {required String mUrl, required String token}) async {
  final client = http.Client();
  var start = DateTime.now();

  var list = <Country>[];
  Map<String, String> headers = {
    'Content-type': 'application/json',
    'Accept': '*/*',
    'Content-Encoding': 'application/json',
    'Authorization': 'Bearer $token'
  };
  try {
    mUrl = '${mUrl}getCountries';
    var uri = Uri.parse(mUrl);

    http.Response httpResponse = await client
        .get(
          uri,
          headers: headers,
        )
        .timeout(const Duration(seconds: 120));
    pp('$xz getCountries: RESPONSE: .... : 💙 statusCode: 👌👌👌 '
        '${httpResponse.statusCode} 👌👌👌  for $mUrl');
    var end = DateTime.now();
    pp('$xz getCountries: elapsed time: ${end.difference(start).inSeconds} seconds');
    if (httpResponse.statusCode == 200) {
      List mList = jsonDecode(httpResponse.body);
      for (var value in mList) {
        list.add(Country.fromJson(value));
      }
      return list;
    } else {
      pp('$xz getCountries: Bad status; ${httpResponse.statusCode} ${httpResponse.body}');
      return [];
    }
  } on SocketException {
    pp('$xz No Internet connection, really means that server cannot be reached 😑');
    throw GeoException(
        message: 'No Internet connection',
        url: mUrl,
        translationKey: 'networkProblem',
        errorType: GeoException.socketException);
  } on HttpException {
    pp("$xz HttpException occurred 😱");
    throw GeoException(
        message: 'Server not around',
        url: mUrl,
        translationKey: 'serverProblem',
        errorType: GeoException.httpException);
  } on FormatException {
    pp("$xz Bad response format 👎");
    throw GeoException(
        message: 'Bad response format',
        url: mUrl,
        translationKey: 'serverProblem',
        errorType: GeoException.formatException);
  } on TimeoutException {
    pp("$xz GET Request has timed out in $timeOutInSeconds seconds 👎");
    throw GeoException(
        message: 'Request timed out',
        url: mUrl,
        translationKey: 'networkProblem',
        errorType: GeoException.timeoutException);
  }

  return [];
}

Future<DataBag?> _getDataBag(
    {required String mUrl,
    required String token,
    required String directoryPath}) async {
  pp('$xz _getDataBag: 🔆🔆🔆 get zipped data ...');

  start = DateTime.now();
  DataBag? dataBag;

  http.Response response = await _sendRequestToBackend(mUrl, token);
  pp('$xz _getDataBag: 🔆🔆🔆 get zipped data, response: ${response.contentLength} bytes ...');

  File zipFile =
      File('$directoryPath/zip${DateTime.now().millisecondsSinceEpoch}.zip');
  zipFile.writeAsBytesSync(response.bodyBytes);

  pp('$xz _getDataBag: 🔆🔆🔆 handle file inside zip: ${await zipFile.length()}');

  //create zip archive
  final inputStream = InputFileStream(zipFile.path);
  final archive = ZipDecoder().decodeBuffer(inputStream);

  // pp('$xz _getDataBag: 🔆🔆🔆 handle file inside zip archive');
  for (var file in archive.files) {
    if (file.isFile) {
      var fileName = '$directoryPath/${file.name}';
      // pp('$xz _getDataBag: file from inside archive ... ${file.size} bytes 🔵 isCompressed: ${file.isCompressed} 🔵 zipped file name: ${file.name}');
      var outFile = File(fileName);
      outFile = await outFile.create(recursive: true);
      await outFile.writeAsBytes(file.content);
      // pp('$xz _getDataBag: file after decompress ... ${await outFile.length()} bytes  🍎 path: ${outFile.path} 🍎');

      if (outFile.existsSync()) {
        // pp('$xz decompressed file exists and has length of 🍎 ${await outFile.length()} bytes');
        var m = outFile.readAsStringSync(encoding: utf8);
        var mJson = json.decode(m);
        dataBag = DataBag.fromJson(mJson);
        _printDataBag(dataBag);
        var end = DateTime.now();
        var ms = end.difference(start).inSeconds;
        pp('$xz getOrganizationDataZippedFile 🍎🍎🍎🍎 work is done!, elapsed seconds: 🍎$ms 🍎\n\n');
      } else {
        pp('$xz ERROR: could not find file');
      }
    }
  }
  if (dataBag == null) {
    pp('$xz _getDataBag: dataBag is null');
    final sett = await prefsOGx.getSettings();
    final serverProblem =
        await translator.translate('serverProblem', sett.locale!);
    throw serverProblem;
  }
  return dataBag;
}

late DateTime start;
const timeOutInSeconds = 120;

Future<http.Response> _sendRequestToBackend(String mUrl, String token) async {
  pp('$xz _sendRequestToBackend call:  🔆 🔆 🔆 calling : 💙  $mUrl  💙');
  var start = DateTime.now();

  Map<String, String> headers = {
    'Content-type': 'application/json',
    'Accept': '*/*',
    'Content-Encoding': 'gzip',
    'Accept-Encoding': 'gzip, deflate',
    'Authorization': 'Bearer $token'
  };
  pp('$xz _sendRequestToBackend call:  🔆 🔆 🔆 '
      'just about to call http client ....');
  try {
    final client = http.Client();
    var uri = Uri.parse(mUrl);
    http.Response httpResponse = await client
        .get(
          uri,
          headers: headers,
        )
        .timeout(const Duration(seconds: 120));

    pp('$xz _sendRequestToBackend: RESPONSE: .... : 💙 statusCode: 👌👌👌 '
        '${httpResponse.statusCode} 👌👌👌  for $mUrl');
    var end = DateTime.now();
    pp('$xz _sendRequestToBackend: RESPONSE: 🔆 elapsed time for backend http request: '
        '${end.difference(start).inSeconds} seconds 🔆');

    if (httpResponse.statusCode != 200) {
      var msg =
          '$xz 😡😡😡😡 The response is not 200; it is ${httpResponse.statusCode}, '
          'NOT GOOD, throwing up !! 😡 ${httpResponse.body}';
      pp(msg);
      pp('$xz Bad status code ... 😑');
      final gex = GeoException(
          message: 'Bad status code: ${httpResponse.statusCode}',
          url: mUrl,
          translationKey: 'serverProblem',
          errorType: GeoException.socketException);
      throw gex;
    } else {
      pp('$xz status is 200, 🍎 Return the httpResponse: '
          '${httpResponse.contentLength} bytes  🍎');
      return httpResponse;
    }
  } on SocketException {
    pp('$xz SocketException: means that server cannot be reached 😑');
    final gex = GeoException(
        message: 'Sever unreachable',
        url: mUrl,
        translationKey: 'serverProblem',
        errorType: GeoException.socketException);
    throw gex;
  } on HttpException {
    pp("$xz HttpException occurred 😱");
    final gex = GeoException(
        message: 'Server not around',
        url: mUrl,
        translationKey: 'serverProblem',
        errorType: GeoException.httpException);
    throw gex;
  } on FormatException {
    pp("$xz Bad response format 👎");
    final gex = GeoException(
        message: 'Bad response format',
        url: mUrl,
        translationKey: 'serverProblem',
        errorType: GeoException.formatException);
    throw gex;
  } on TimeoutException {
    pp("$xz GET Request has timed out in $timeOutInSeconds seconds 👎");
    final gex = GeoException(
        message: 'Request timed out',
        url: mUrl,
        translationKey: 'networkProblem',
        errorType: GeoException.timeoutException);
    throw gex;
  }
}

void _printDataBag(DataBag bag) {
  final projects = bag.projects!.length;
  final users = bag.users!.length;
  final positions = bag.projectPositions!.length;
  final polygons = bag.projectPolygons!.length;
  final photos = bag.photos!.length;
  final videos = bag.videos!.length;
  final audios = bag.audios!.length;
  final schedules = bag.fieldMonitorSchedules!.length;

  // pp('$xz projects: $projects');
  // pp('$xz users: $users');
  // pp('$xz positions: $positions');
  // pp('$xz polygons: $polygons');
  // pp('$xz photos: $photos');
  // pp('$xz videos: $videos');
  // pp('$xz audios: $audios');
  // pp('$xz schedules: $schedules');
  // pp('$xz data from backend listed above: 🔵🔵🔵 ${bag.date}');
}

const xz = '🌼🌼🌼🌼🌼🌼🌼🌼 DataHandler Isolate ';

onError() {
  pp('http threw onError');
  throw Exception('dunno!');
}
