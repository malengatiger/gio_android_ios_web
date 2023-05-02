import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:geo_monitor/library/api/data_api.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../auth/app_auth.dart';
import '../cache_manager.dart';
import '../data/data_bag.dart';
import '../functions.dart';
import 'geo_exception.dart';

final ZipBloc zipBloc = ZipBloc();

class ZipBloc {
  static const xz = '🌎🌎🌎🌎🌎🌎ZipBloc: ';
  static final client = http.Client();
  static int start = 0;

  Future<DataBag?> getUserDataZippedFile(String userId, String startDate, String endDate) async {
    pp('\n\n$xz getUserDataZippedFile  🔆🔆🔆 userId : 💙  $userId  💙');
    start = DateTime.now().millisecondsSinceEpoch;
    var url = await DataAPI.getUrl();
    var mUrl = '${url!}getUserData?userId=$userId&startDate=$startDate&endDate=$endDate';

    var bag = await _getDataBag(mUrl);
    await _cacheTheData(bag);
    return bag;
  }

  Future<DataBag?> getProjectDataZippedFile(String projectId,String startDate, String endDate) async {
    pp('\n\n$xz getProjectDataZippedFile  🔆🔆🔆 projectId : 💙  $projectId  💙');
    start = DateTime.now().millisecondsSinceEpoch;
    var url = await DataAPI.getUrl();
    var mUrl = '${url!}getProjectDataZippedFile?projectId=$projectId&startDate=$startDate&endDate=$endDate';

    var bag = await _getDataBag(mUrl);
    await _cacheTheData(bag);
    return bag;
  }

  Future<DataBag?> getOrganizationDataZippedFile(String organizationId, String startDate, String endDate) async {
    pp('\n\n$xz getOrganizationDataZippedFile  🔆🔆🔆 orgId : 💙  $organizationId  💙');
    start = DateTime.now().millisecondsSinceEpoch;
    var url = await DataAPI.getUrl();
    var mUrl =
        '${url!}getOrganizationDataZippedFile?organizationId=$organizationId&startDate=$startDate&endDate=$endDate';

    var bag = await _getDataBag(mUrl);
    await _cacheTheData(bag);
    return bag;
  }

  Future<void> _cacheTheData(DataBag? bag) async {
    pp('\n$xz Data returned from server, adding to Hive cache ...');

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
    pp('\n$xz Org Data saved in Hive cache ...');
  }

  Future<DataBag?> _getDataBag(String mUrl) async {
    http.Response response = await _sendRequestToBackend(mUrl);
    var dir = await getApplicationDocumentsDirectory();
    File zipFile =
        File('${dir.path}/zip${DateTime.now().millisecondsSinceEpoch}.zip');
    zipFile.writeAsBytesSync(response.bodyBytes);

    //create zip archive
    final inputStream = InputFileStream(zipFile.path);
    final archive = ZipDecoder().decodeBuffer(inputStream);

    DataBag? dataBag;
    //handle file inside zip archive
    for (var file in archive.files) {
      if (file.isFile) {
        var fileName = '${dir.path}/${file.name}';
        pp('$xz file from inside archive ... ${file.size} bytes 🔵 isCompressed: ${file.isCompressed} 🔵 zipped file name: ${file.name}');
        var outFile = File(fileName);
        outFile = await outFile.create(recursive: true);
        await outFile.writeAsBytes(file.content);
        pp('$xz file after decompress ... ${await outFile.length()} bytes  🍎 path: ${outFile.path} 🍎');

        if (outFile.existsSync()) {
          pp('$xz decompressed file exists and has length of 🍎 ${await outFile.length()} bytes');
          var m = outFile.readAsStringSync(encoding: utf8);
          var mJson = json.decode(m);
          dataBag = DataBag.fromJson(mJson);
          printDataBag(dataBag);

          var end = DateTime.now().millisecondsSinceEpoch;
          var ms = (end - start) / 1000;
          pp('$xz getOrganizationDataZippedFile 🍎🍎🍎🍎 work is done!, elapsed seconds: $ms\n\n');
        }
      }
    }

    return dataBag;
  }

  static Map<String, String> headers = {
    'Content-type': 'application/zip',
    'Accept': '*/*',
    'Content-Encoding': 'gzip',
    'Accept-Encoding': 'gzip, deflate'
  };
  static Future<http.Response> _sendRequestToBackend(String mUrl) async {
    pp('$xz http GET call:  🔆 🔆 🔆 calling : 💙  $mUrl  💙');
    var start = DateTime.now();
    var token = await appAuth.getAuthToken();

    headers['Authorization'] = 'Bearer $token';

    try {
      http.Response resp = await client
          .get(
            Uri.parse(mUrl),
            headers: headers,
          )
          .timeout(const Duration(seconds: 120));
      pp('$xz http GET call RESPONSE: .... : 💙 statusCode: 👌👌👌 ${resp.statusCode} 👌👌👌 💙 for $mUrl');
      // pp(resp);
      var end = DateTime.now();
      pp('$xz http GET call: 🔆 elapsed time for http: ${end.difference(start).inSeconds} seconds 🔆 \n\n');

      if (resp.statusCode != 200) {
        var msg =
            '😡 😡 The response is not 200; it is ${resp.statusCode}, NOT GOOD, throwing up !! 🥪 🥙 🌮  😡 ${resp.body}';
        pp(msg);
        throw HttpException(msg);
      }
      return resp;
    } on SocketException {
      pp('$xz No Internet connection, really means that server cannot be reached 😑');
      throw GeoException(message: 'No Internet connection',
          url: mUrl,
          translationKey: 'networkProblem', errorType: GeoException.socketException);

    } on HttpException {
      pp("$xz HttpException occurred 😱");
      throw GeoException(message: 'Server not around',
          url: mUrl,
          translationKey: 'serverProblem', errorType: GeoException.httpException);
    } on FormatException {
      pp("$xz Bad response format 👎");
      throw GeoException(message: 'Bad response format',
          url: mUrl,
          translationKey: 'serverProblem', errorType: GeoException.formatException);

    } on TimeoutException {
      pp("$xz GET Request has timed out in $timeOutInSeconds seconds 👎");
      throw GeoException(message: 'Request timed out',
          url: mUrl,
          translationKey: 'networkProblem', errorType: GeoException.timeoutException);

    }
  }
  static const timeOutInSeconds = 120;
}

void printDataBag(DataBag bag) {
  final projects = bag.projects!.length;
  final users = bag.users!.length;
  final positions = bag.projectPositions!.length;
  final polygons = bag.projectPolygons!.length;
  final photos = bag.photos!.length;
  final videos = bag.videos!.length;
  final audios = bag.audios!.length;
  final schedules = bag.fieldMonitorSchedules!.length;

  const xz = '👌👌👌 DataBag print 👌';
  pp('$xz projects: $projects');
  pp('$xz users: $users');
  pp('$xz positions: $positions');
  pp('$xz polygons: $polygons');
  pp('$xz photos: $photos');
  pp('$xz videos: $videos');
  pp('$xz audios: $audios');
  pp('$xz schedules: $schedules');
  pp('$xz data from backend listed above: 🔵🔵🔵 ${bag.date}');
}
