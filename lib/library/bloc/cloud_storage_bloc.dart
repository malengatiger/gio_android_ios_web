import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:geo_monitor/library/api/data_api_og.dart';
import 'package:geo_monitor/library/bloc/organization_bloc.dart';
import 'package:geo_monitor/library/bloc/photo_for_upload.dart';
import 'package:geo_monitor/library/bloc/video_for_upload.dart';
import 'package:geo_monitor/library/cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../device_location/device_location_bloc.dart';
import '../../l10n/translation_handler.dart';
import '../api/prefs_og.dart';
import '../data/audio.dart';
import '../data/photo.dart';
import '../data/user.dart';
import '../data/video.dart';
import '../functions.dart';
import 'audio_for_upload.dart';
import 'geo_exception.dart';

final CloudStorageBloc cloudStorageBloc = CloudStorageBloc();

class CloudStorageBloc {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  Random rand = Random(DateTime.now().millisecondsSinceEpoch);
  static const mm = '☕️☕️☕️☕️☕️☕️ CloudStorageBloc: 💚 ';

  bool busy = false;
  User? _user;

  final photoStorageName = 'geoPhotos3';
  final videoStorageName = 'geoVideos3';
  final audioStorageName = 'geoAudios3';

  final StreamController<Photo> _photoStreamController =
      StreamController.broadcast();
  final StreamController<Video> _videoStreamController =
      StreamController.broadcast();
  final StreamController<Video> _audioStreamController =
      StreamController.broadcast();
  final StreamController<String> _errorStreamController =
      StreamController.broadcast();

  Stream<Photo> get photoStream => _photoStreamController.stream;
  Stream<Video> get videoStream => _videoStreamController.stream;
  Stream<Video> get audioStream => _audioStreamController.stream;

  Stream<String> get errorStream => _errorStreamController.stream;

  AudioPlayer audioPlayer = AudioPlayer();

  Future uploadEverything() async {
    await uploadPhotos();
    await uploadAudios();
    await uploadVideos();
  }
  Future<int> uploadAudios() async {
    final list = await cacheManager.getAudioForUpload();
    int cnt = 0;
    for (var audio in list) {
      await uploadAudio(audioForUpload: audio);
      cnt++;
    }
    pp("$mm audios uploaded: $cnt");

    return cnt;
  }
  Future<int> uploadAudio({
    required AudioForUpload audioForUpload,
  }) async {
    pp('\n\n\n$mm️ uploadAudio ☕️☕️☕️☕️☕️☕️☕️️ ....');

    String url = 'unknown';
    UploadTask? uploadTask;
    var file = File(audioForUpload.filePath!);
    try {
      var fileName =
          'audio@${DateTime.now().toUtc().microsecondsSinceEpoch}.m4a';
      var firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child(audioStorageName)
          .child(fileName);
      uploadTask = firebaseStorageRef.putFile(file);
      _reportProgress(uploadTask);
      var taskSnapshot = await uploadTask.whenComplete(() {});
      url = await taskSnapshot.ref.getDownloadURL();
      pp('$mm file url is available, meaning that upload is complete: \n$url');
      _printSnapshot(taskSnapshot);
    } catch (e) {
      pp('\n$mm 🔴🔴🔴 failed audio cached in hive after upload or database failure 🔴🔴🔴');
      return uploadError;
    }
    var user = await prefsOGx.getUser();
    var distance = 0.0;
    if (user != null) {
      if (audioForUpload.position != null) {
        distance = await locationBloc.getDistanceFromCurrentPosition(
            latitude: audioForUpload.position!.coordinates[1],
            longitude: audioForUpload.position!.coordinates[0]);
      } else {
        distance = 0.0;
      }
      pp('$mm adding audio ..... 😡😡 distance: '
          '${distance.toStringAsFixed(2)} metres 😡😡');

      var dur = await audioPlayer.setUrl(url);
      final sett = await cacheManager.getSettings();
      final audioArrived =
          await translator.translate('audioArrived', sett.locale!);
      final messageFromGeo = await getFCMMessage('messageFromGeo');

      Audio audio = Audio(
          url: url,
          userUrl: user.imageUrl,
          created: DateTime.now().toUtc().toIso8601String(),
          userId: user.userId,
          userName: user.name,
          translatedTitle: messageFromGeo,
          translatedMessage: audioArrived,
          projectPosition: audioForUpload.position,
          distanceFromProjectPosition: distance,
          projectId: audioForUpload.project!.projectId!!,
          audioId: const Uuid().v4(),
          organizationId: audioForUpload.project!.organizationId,
          projectName: audioForUpload.project!.name,
          durationInSeconds: dur!.inSeconds);

      try {
        var result = await dataApiDog.addAudio(audio);
        await cacheManager.removeUploadedAudio(audio: audioForUpload);
        await organizationBloc.addAudioToStream(result);
      } catch (e) {
        pp(e);
        // listener.onError('Audio database write failed: $e');
        pp('\n$mm 🔴🔴🔴 failed audio cached in hive after upload or database failure 🔴🔴🔴');
        return uploadError;
      }
    }

    return uploadFinished;
  }

  Future<int> uploadPhotos() async {
    final list = await cacheManager.getPhotosForUpload();
    int cnt = 0;
    for (var photo in list) {
      await uploadPhoto(photoForUpload: photo);
      cnt++;
    }
    pp("$mm photos uploaded: $cnt");
    return cnt;
  }
  Future<int> uploadPhoto({
    required PhotoForUpload photoForUpload,
  }) async {
    pp('\n\n\n$mm️ uploadPhoto ☕️☕️☕️☕️☕️☕️☕️️ ... ');

    var url = 'unknown';
    var thumbUrl = 'unknown';
    late UploadTask uploadTask;
    late TaskSnapshot taskSnapshot;
    var file = File(photoForUpload.filePath!);
    try {
      pp('$mm️ uploadPhoto ☕️☕️☕️☕️☕️☕️☕️ file path: \n${file.path}');
      //upload main file
      var fileName =
          'photo@${DateTime.now().toUtc().microsecondsSinceEpoch}.${'jpg'}';
      var firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child(photoStorageName)
          .child(fileName);
      uploadTask = firebaseStorageRef.putFile(file);
      _reportProgress(uploadTask);
      taskSnapshot = await uploadTask.whenComplete(() {});
      url = await taskSnapshot.ref.getDownloadURL();
      pp('$mm file url is available, meaning that upload is complete: \n$url');
      _printSnapshot(taskSnapshot);
      // upload thumbnail here
      final thumbName =
          'thumbnail@${DateTime.now().toUtc().microsecondsSinceEpoch}.${'jpg'}';
      final firebaseStorageRef2 = FirebaseStorage.instance
          .ref()
          .child(photoStorageName)
          .child(thumbName);

      final thumbnailFile = File(photoForUpload.thumbnailPath!);
      final thumbUploadTask = firebaseStorageRef2.putFile(thumbnailFile);
      final thumbTaskSnapshot = await thumbUploadTask.whenComplete(() {});
      thumbUrl = await thumbTaskSnapshot.ref.getDownloadURL();
      pp('$mm thumbnail file url is available, meaning that upload is complete: \n$thumbUrl');
      _printSnapshot(thumbTaskSnapshot);
    } catch (e) {
      // listener.onError('File upload failed: $e');
      return uploadError;
    }

    //write to db
    pp('\n$mm adding photo data to the database ...o');
    Photo? photo;
    try {
      var distance = await locationBloc.getDistanceFromCurrentPosition(
          latitude: photoForUpload.position!.coordinates[1],
          longitude: photoForUpload.position!.coordinates[0]);

      var height = 0, width = 0;
      decodeImageFromList(file.readAsBytesSync(), (image) {
        height = image.height;
        width = image.width;
      });
      pp('$mm the famous photo ========> 🌀 height: $height 🌀 width: $width');

      pp('$mm adding photo ..... 😡😡 distance: '
          '${distance.toStringAsFixed(2)} metres 😡😡');
      var user = await prefsOGx.getUser();
      final sett = await cacheManager.getSettings();
      final photoArrived =
          await translator.translate('photoArrived', sett.locale!);
      final messageFromGeo = await getFCMMessage('messageFromGeo');

      photo = Photo(
          url: url,
          caption: 'tbd',
          created: DateTime.now().toUtc().toIso8601String(),
          userId: _user!.userId,
          userName: _user!.name,
          translatedMessage: photoArrived,
          translatedTitle: messageFromGeo,
          projectPosition: photoForUpload.position,
          distanceFromProjectPosition: distance,
          projectId: photoForUpload.project!.projectId!,
          thumbnailUrl: thumbUrl,
          projectName: photoForUpload.project!.name,
          organizationId: _user!.organizationId,
          height: height,
          width: width,
          projectPositionId: photoForUpload.projectPositionId,
          projectPolygonId: photoForUpload.projectPolygonId,
          photoId: const Uuid().v4(),
          landscape: width > height ? 0 : 1,
          userUrl: user!.imageUrl);

      await dataApiDog.addPhoto(photo);
      await cacheManager.removeUploadedPhoto(photo: photoForUpload);
      pp('\n$mm upload process completed, tell the faithful listener!.');

      // listener.onFileUploadComplete(
      //     url, taskSnapshot.totalBytes, taskSnapshot.bytesTransferred);
      return uploadFinished;
    } catch (e) {
      pp('\n\n$mm 👿👿👿👿 Photo write to database failed, We may have a database problem: 🔴🔴🔴 $e');
      // listener.onError('We have a database problem $e');
      return uploadError;
    }
  }

  Future<int> uploadVideos() async {
    final list = await cacheManager.getVideosForUpload();
    int cnt = 0;
    for (var video in list) {
      await uploadVideo(videoForUpload: video);
      cnt++;
    }
    pp("$mm videos uploaded: $cnt");
    return cnt;
  }
  Future<int> uploadVideo({
    required VideoForUpload videoForUpload,
  }) async {
    pp('\n\n\n$mm️ uploadVideo ☕️☕️☕️☕️☕️☕️☕️️ ');
    var file = File(videoForUpload.filePath!);
    var url = 'unknown';
    var thumbUrl = 'unknown';
    late UploadTask uploadTask;
    late TaskSnapshot taskSnapshot;
    try {
      pp('$mm️ uploadVideo ☕️☕️☕️☕️☕️☕️☕️file path: \n${file.path}');
      //upload main file
      var fileName =
          'video@${DateTime.now().toUtc().microsecondsSinceEpoch}.${'mp4'}';
      var firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child(videoStorageName)
          .child(fileName);
      uploadTask = firebaseStorageRef.putFile(file);
      _reportProgress(uploadTask);
      taskSnapshot = await uploadTask.whenComplete(() {});
      url = await taskSnapshot.ref.getDownloadURL();
      pp('$mm file url is available, meaning that upload is complete: \n$url');
      _printSnapshot(taskSnapshot);
      // upload thumbnail here
      final thumbName =
          'thumbnail@${DateTime.now().toUtc().microsecondsSinceEpoch}.${'jpg'}';
      final firebaseStorageRef2 = FirebaseStorage.instance
          .ref()
          .child(videoStorageName)
          .child(thumbName);
      var thumbnailFile = File(videoForUpload.thumbnailPath!);
      final thumbUploadTask = firebaseStorageRef2.putFile(thumbnailFile);
      final thumbTaskSnapshot = await thumbUploadTask.whenComplete(() {});
      thumbUrl = await thumbTaskSnapshot.ref.getDownloadURL();
      pp('$mm thumbnail file url is available, meaning that upload is complete: \n$thumbUrl');
      _printSnapshot(thumbTaskSnapshot);
    } catch (e) {
      pp(e);
      return uploadError;
    }
    //write to db
    pp('\n$mm adding video data to the database ... ');
    Video? video;
    try {
      var distance = await locationBloc.getDistanceFromCurrentPosition(
          latitude: videoForUpload.position!.coordinates[1],
          longitude: videoForUpload.position!.coordinates[0]);

      pp('$mm adding video ..... 😡😡 distance: '
          '${distance.toStringAsFixed(2)} metres 😡😡');
      var u = const Uuid();
      final messageTitle = await getFCMMessageTitle();
      final videoArrived = await getFCMMessage('videoArrived');
      video = Video(
          url: url,
          caption: 'tbd',
          created: DateTime.now().toUtc().toIso8601String(),
          userId: _user!.userId,
          userName: _user!.name,
          translatedTitle: messageTitle,
          translatedMessage: videoArrived,
          projectPosition: videoForUpload.position,
          distanceFromProjectPosition: distance,
          projectId: videoForUpload.project!.projectId!,
          thumbnailUrl: thumbUrl,
          projectName: videoForUpload.project!.name,
          projectPositionId: videoForUpload.projectPositionId,
          projectPolygonId: videoForUpload.projectPolygonId,
          organizationId: _user!.organizationId,
          videoId: u.v4(),
          durationInSeconds: null,
          userUrl: _user!.imageUrl,
          size: 0.0);

      await dataApiDog.addVideo(video);
      await cacheManager.removeUploadedVideo(video: videoForUpload);
      pp('$mm video upload process completed, tell the faithful listener!.\n');

      return uploadFinished;
    } catch (e) {
      pp('\n\n$mm 👿👿👿👿 Video write to database failed, We may have a database problem: 🔴🔴🔴 $e');
      return uploadError;
    }
  }

  void _printSnapshot(TaskSnapshot taskSnapshot) {
    var totalByteCount = taskSnapshot.totalBytes;
    var bytesTransferred = taskSnapshot.bytesTransferred;
    var bt = '${(bytesTransferred / 1024).toStringAsFixed(2)} KB';
    var tot = '${(totalByteCount / 1024).toStringAsFixed(2)} KB';
    pp('$mm uploadTask: 💚💚 '
        'photo or video upload complete '
        ' 🧩 $bt of $tot 🧩 transferred.'
        ' date: ${DateTime.now().toIso8601String()}\n');
  }

  void _reportProgress(UploadTask uploadTask) {
    uploadTask.snapshotEvents.listen((event) {
      var totalByteCount = event.totalBytes;
      var bytesTransferred = event.bytesTransferred;
      var bt = '${(bytesTransferred / 1024).toStringAsFixed(2)} KB';
      var tot = '${(totalByteCount / 1024).toStringAsFixed(2)} KB';
      pp('️$mm _reportProgress:  💚 progress ******* 🧩 $bt KB of $tot KB 🧩 transferred');
      // listener.onFileProgress(event.totalBytes, event.bytesTransferred);
    });
  }

  void thumbnailProgress(UploadTask uploadTask) {
    uploadTask.snapshotEvents.listen((event) {
      var totalByteCount = event.totalBytes;
      var bytesTransferred = event.bytesTransferred;
      var bt = '${(bytesTransferred / 1024).toStringAsFixed(2)} KB';
      var tot = '${(totalByteCount / 1024).toStringAsFixed(2)} KB';
      pp('$mm️ .uploadThumbnail:  🥦 progress ******* 🍓 $bt KB of $tot KB 🍓 transferred');
    });
  }

  static const xz = '🌿🌿🌿🌿🌿🌿🌿 CloudStorageBloc: ';
  Future<File> downloadFile(String mUrl) async {
    pp('$xz : downloadFile: 😡😡😡 $mUrl ....');

    try {
      final http.Response response =
          await http.get(Uri.parse(mUrl)).catchError((e) {
        pp('😡😡😡 Download failed: 😡😡😡 $e');
        throw Exception('😡😡😡 Download failed: $e');
      });

      pp('$xz : downloadFile: OK?? 💜💜💜💜'
          '  statusCode: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Directory directory = await getApplicationDocumentsDirectory();
        var type = 'jpg';
        if (mUrl.contains('mp4')) {
          type = 'mp4';
        }
        final File mFile = File(
            '${directory.path}/download${DateTime.now().millisecondsSinceEpoch}.$type');
        pp('$xz : downloadFile: 💜  .... new file: ${mFile.path}');
        mFile.writeAsBytesSync(response.bodyBytes);
        var len = await mFile.length();
        pp('$xz : downloadFile: 💜  .... file downloaded length: 😡 '
            '${(len / 1024).toStringAsFixed(1)} KB - path: ${mFile.path}');
        return mFile;
      } else {
        pp('$xz : downloadFile: Download failed: 😡😡😡 statusCode ${response.statusCode} 😡 ${response.body} 😡');
        throw Exception('Download failed: statusCode: ${response.statusCode}');
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
  }

  static const timeOutInSeconds = 120;
  // ignore: missing_return
  Future<int> deleteFolder(String folderName) async {
    pp('.deleteFolder ######## deleting $folderName');
    var task = _firebaseStorage.ref().child(folderName).delete();
    await task.then((f) {
      pp('.deleteFolder $folderName deleted from FirebaseStorage');
      return 0;
    }).catchError((e) {
      pp('.deleteFolder ERROR $e');
      return 1;
    });
    return 0;
  }

  // ignore: missing_return
  Future<int> deleteFile(String folderName, String name) async {
    pp('.deleteFile ######## deleting $folderName : $name');
    var task = _firebaseStorage.ref().child(folderName).child(name).delete();
    task.then((f) {
      pp('.deleteFile $folderName : $name deleted from FirebaseStorage');
      return 0;
    }).catchError((e) {
      pp('.deleteFile ERROR $e');
      return 1;
    });
    return 0;
  }

  CloudStorageBloc() {
    pp('🍇 🍇 🍇 🍇 🍇 StorageBloc constructor 🍇 🍇 🍇 🍇 🍇');
    getUser();
  }
  Future? getUser() async {
    _user = await prefsOGx.getUser();
    return _user;
  }
}

const uploadBusy = 201;
const uploadFinished = 200;
const uploadError = 500;

final CloudStorageIsolate cloudStorageIsolate = CloudStorageIsolate();

///control cloudStorageBloc inside Isolate
class CloudStorageIsolate {
  static const xz = '🌿🌿🌿🌿🌿🌿🌿 CloudStorageIsolate: ';
  Future startVideoUpload(VideoForUpload videoForUpload) async {
    pp('$xz starting Isolate to run cloudStorageBloc ........');
    return await flutterCompute(_uploadVideo, videoForUpload);
  }

  Future startAudioUpload(AudioForUpload audioForUpload) async {
    pp('$xz starting Isolate to run cloudStorageBloc ........');
    return await flutterCompute(_uploadAudio, audioForUpload);
  }

  Future startPhotoUpload(PhotoForUpload photoForUpload) async {
    pp('$xz starting Isolate to run cloudStorageBloc ........');
    return await FlutterIsolate.spawn(_uploadPhoto, photoForUpload.toJson());
  }
}

///Cloud Storage Isolate functions
@pragma('vm:entry-point')
Future _uploadVideo(VideoForUpload videoForUpload) async {
  pp('_heavyStuff _uploadVideo: 🌿🌿🌿 starting Isolate to run cloudStorageBloc ........');
  cloudStorageBloc.uploadVideo(videoForUpload: videoForUpload);
}

@pragma('vm:entry-point')
Future _uploadAudio(AudioForUpload audioForUpload) async {
  pp('_heavyStuff _uploadAudio: 🌿🌿🌿 starting Isolate to run cloudStorageBloc ........');
  cloudStorageBloc.uploadAudio(audioForUpload: audioForUpload);
}

@pragma('vm:entry-point')
Future _uploadPhoto(Map photoForUploadMap) async {
  pp('_heavyStuff _uploadPhoto: 🌿🌿🌿 starting Isolate to run cloudStorageBloc ........');
  final photoForUpload = PhotoForUpload.fromJson(photoForUploadMap);
  cloudStorageBloc.uploadPhoto(photoForUpload: photoForUpload);
}
