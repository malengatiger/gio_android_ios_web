import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:geo_monitor/library/api/data_api_og.dart';
import 'package:geo_monitor/library/api/prefs_og.dart';
import 'package:geo_monitor/library/bloc/geo_exception.dart';
import 'package:geo_monitor/library/bloc/organization_bloc.dart';
import 'package:geo_monitor/library/bloc/photo_for_upload.dart';
import 'package:geo_monitor/library/bloc/video_for_upload.dart';
import 'package:geo_monitor/library/errors/error_handler.dart';

import '../../device_location/device_location_bloc.dart';
import '../../l10n/translation_handler.dart';
import '../auth/app_auth.dart';
import '../cache_manager.dart';
import '../data/audio.dart';
import '../data/photo.dart';
import '../data/user.dart';
import '../data/video.dart';
import '../functions.dart';
import 'audio_for_upload.dart';
import 'isolate_functions.dart';

late GeoUploader geoUploader;

Random rand = Random(DateTime.now().millisecondsSinceEpoch);
const photoStorageName = 'geoPhotos3';
const videoStorageName = 'geoVideos3';
const audioStorageName = 'geoAudios3';
User? user;

/// Manages the uploading of media files to Cloud Storage using isolates
class GeoUploader {
  static const xx = '🤞🏾🤞🏾🤞🏾🤞🏾🤞🏾🤞🏾GeoUploader: 🤞🏾🤞🏾🤞🏾🤞🏾';
  int retryCount = 0;
  static const maxRetries = 2;
  final ErrorHandler errorHandler;
  final CacheManager cacheManager;
  final DataApiDog dataApiDog;

  GeoUploader(this.errorHandler, this.cacheManager, this.dataApiDog);

  Future manageMediaUploads() async {
    pp('$xx ............ manageMediaUploads: starting ... 🔵🔵🔵');
    try {
      await uploadCachedPhotos();
      await uploadCachedAudios();
      await uploadCachedVideos();
      await uploadErrors();
      pp('$xx manageMediaUploads: 🥬🥬🥬🥬🥬🥬 '
          'completed and uploads done if needed. 🥬🥬🥬 '
          'should be Okey Dokey!');
    } catch (e) {
      pp('$xx Something went horribly wrong with media upload: $e');
      if (e is GeoException) {
        errorHandler.handleError(exception: e);
      }
      await _retryUploads();
    }
  }


  Future<int> _retryUploads() async {
    await Future.delayed(const Duration(seconds: 5));
    await uploadCachedPhotos();
    await uploadCachedAudios();
    await uploadCachedVideos();

    pp('$xx manageMediaUploads: RETRY seems to have worked !!! 🥬🥬🥬🥬🥬🥬 '
        'completed and uploads done if needed. 🥬🥬🥬 '
        'should be Okey Dokey!');
    return 0;
  }

  Future uploadCachedPhotos() async {
    pp('$xx ................... checking for photo uploads ...');
    final photos = await cacheManager.getPhotosForUpload();
    if (photos.isEmpty) {
      return;
    }
    pp('$xx ... ${photos.length} photosForUpload found. 🔵 🔵 🔵 Will upload now ...');
    int cnt = 0;
    for (var p in photos) {
      var result = await _startPhotoUpload(p);
      if (result != null) {
        await cacheManager.removeUploadedPhoto(photo: p);
        cnt++;
      }
    }

    pp('$xx ... $cnt photos uploaded');
    final mPhotos = await cacheManager.getPhotosForUpload();
    pp('$xx ... ${mPhotos.length} photosForUpload found after uploads.  🔴 If greater than zero, something not cool!');
  }

  Future uploadCachedVideos() async {
    pp('$xx ... checking for video uploads ...');
    final videos = await cacheManager.getVideosForUpload();
    if (videos.isEmpty) {
      return;
    }
    pp('$xx ... ${videos.length} videosForUpload found. 🔵 🔵 🔵 Will upload now ...');
    int cnt = 0;
    final sett = await cacheManager.getSettings();
    final videoArrived =
        await translator.translate('videoArrived', sett.locale!);
    final msg =
    await translator.translate('messageFromGeo', sett.locale!);
    final messageFromGeo = msg.replaceAll('\$geo', 'Gio');

    for (var p in videos) {
      var result = await _startVideoUpload(
          videoForUploading: p,
          videoArrived: videoArrived,
          messageFromGeo: messageFromGeo);
      if (result != null) {
        await cacheManager.removeUploadedVideo(video: p);
        cnt++;
      }
    }

    pp('$xx ... $cnt videos uploaded');
    final mVideos = await cacheManager.getVideosForUpload();
    pp('$xx ... ${mVideos.length} videosForUpload found after uploads.  🔴 If greater than zero, something not cool!');
  }

  Future uploadCachedAudios() async {
    pp('$xx ... checking for audio uploads ...');
    final audios = await cacheManager.getAudioForUpload();
    if (audios.isEmpty) {
      return;
    }
    pp('$xx ... ${audios.length} audiosForUpload found. 🔵 🔵 🔵 Will upload now ...');
    int cnt = 0;
    final sett = await cacheManager.getSettings();
    final audioArrived =
        await translator.translate('audioArrived', sett.locale!);
    final msg =
    await translator.translate('messageFromGeo', sett.locale!);
    final messageFromGeo = msg.replaceAll('\$geo', 'Gio');

    for (var p in audios) {
      var result = await _startAudioUpload(
          audioForUploading: p,
          messageFromGeo: messageFromGeo,
          audioArrived: audioArrived);
      if (result != null) {
        await cacheManager.removeUploadedAudio(audio: p);
        cnt++;
      }
    }

    pp('$xx ... $cnt audios uploaded');
    final mAudios = await cacheManager.getAudioForUpload();
    pp('$xx ... ${mAudios.length} audiosForUpload found after uploads.  🔴 If greater than zero, something not cool!');
  }

  Future<Photo?> _startPhotoUpload(PhotoForUpload photoForUploading) async {
    pp('$xx ... _startPhotoUpload ..... run isolate');
    user = await prefsOGx.getUser();
    try {
      String? url = getUrl();
      var token = await appAuth.getAuthToken();
      if (token != null) {
        // pp('$xx http POST call: 😡😡😡 Firebase Auth Token: 💙️ Token is GOOD! 💙\n$token ');
      }

      String path = photoForUploading.filePath!;
      var height = 0, width = 0;
      var file = File(path);
      if (!file.existsSync()) {
        if (photoForUploading.fileBytes != null) {
          file = File.fromRawPath(photoForUploading.fileBytes!);
          photoForUploading.filePath = file.path;
          var tFile = File.fromRawPath(photoForUploading.thumbnailBytes!);
          photoForUploading.thumbnailPath = tFile.path;
        } else {
          pp('$xx File does not exist. 🔴🔴🔴 Deplaning ...');
          await cacheManager.removeUploadedPhoto(photo: photoForUploading);
          return null;
        }
      }
      decodeImageFromList(file.readAsBytesSync(), (image) {
        height = image.height;
        width = image.width;
      });
      var distance = await locationBloc.getDistanceFromCurrentPosition(
          latitude: photoForUploading.position!.coordinates[1],
          longitude: photoForUploading.position!.coordinates[0]);

      if (user == null) {
        pp('🔴🔴🔴🔴🔴🔴🔴🔴 user is null. WTF? 🔴🔴');
        final sett = await prefsOGx.getSettings();
        final serverProblem =
            await translator.translate('serverProblem', sett.locale!);
        throw serverProblem;
      } else {
        pp('$xx 🍐🍐🍐🍐🍐🍐The user is OK');
      }

      final sett = await cacheManager.getSettings();
      final photoArrived =
          await translator.translate('photoArrived', sett.locale!);
      final msg =
          await translator.translate('messageFromGeo', sett.locale!);
      final messageFromGeo = msg.replaceAll('\$geo', 'Gio');

      var mJson = json.encode(photoForUploading.toJson());

      var photo = await Isolate.run(() async => await uploadPhotoFile(
          objectName: 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
          url: url!,
          token: token!,
          height: height,
          width: width,
          mJson: mJson,
          photoArrived: photoArrived,
          messageFromGeo: messageFromGeo,
          distance: distance));

      if (photo != null) {
        await cacheManager.addPhoto(photo: photo);
        await cacheManager.removeUploadedPhoto(photo: photoForUploading);
      }

      return photo;
    } on StateError catch (e) {
      pp(e.message); // In a bad state!
    } on FormatException catch (e) {
      pp(e.message);
    }
    return null;
  }

  Future<Video?> _startVideoUpload({
    required VideoForUpload videoForUploading,
    required String videoArrived,
    required String messageFromGeo,
  }) async {
    user = await prefsOGx.getUser();
    try {
      String? url = getUrl();
      var token = await appAuth.getAuthToken();
      if (token != null) {
        pp('$xx 😡😡😡 Firebase Auth Token: 💙️ Token is GOOD! 💙 url: $url');
      }

      var mFile = File(videoForUploading.filePath!);

      if (!mFile.existsSync()) {
        if (videoForUploading.fileBytes != null) {
          mFile = File.fromRawPath(videoForUploading.fileBytes!);
          videoForUploading.filePath = mFile.path;
          var tFile = File.fromRawPath(videoForUploading.thumbnailBytes!);
          videoForUploading.thumbnailPath = tFile.path;
        } else {
          pp('$xx File does not exist. 🔴🔴🔴 Deplaning ...');
          await cacheManager.removeUploadedVideo(video: videoForUploading);
          return null;
        }
      }
      final bytes = await mFile.readAsBytes();
      final size = getFileSizeInMB(bytes: bytes.length, decimals: 2);

      var height = 0, width = 0;
      var distance = await locationBloc.getDistanceFromCurrentPosition(
          latitude: videoForUploading.position!.coordinates[1],
          longitude: videoForUploading.position!.coordinates[0]);

      if (user == null) {
        pp('🔴🔴🔴🔴🔴🔴🔴🔴 user is null. WTF? 🔴🔴');
        throw Exception('Fuck it! - User is NULL!!');
      } else {
        pp('$xx 🍐🍐🍐🍐🍐🍐The user is OK');
      }

      videoForUploading.fileBytes = null;
      videoForUploading.thumbnailBytes = null;

      var mJson = json.encode(videoForUploading.toJson());

      var vid = await Isolate.run(() async => await uploadVideoFile(
          objectName: 'video${DateTime.now().millisecondsSinceEpoch}.mp4',
          url: url!,
          token: token!,
          size: size,
          mJson: mJson,
          videoArrived: videoArrived,
          messageFromGeo: messageFromGeo,
          distance: distance));

      if (vid != null) {
        await cacheManager.addVideo(video: vid);
        await cacheManager.removeUploadedVideo(video: videoForUploading);
      }

      return vid;
    } on StateError catch (e) {
      pp(e.message); // In a bad state!
    } on FormatException catch (e) {
      pp(e.message);
    }
    return null;
  }

  Future<List<User>> startUserBatchUpload(
      {required String organizationId, required File file}) async {
    String? url = getUrl();
    var token = await appAuth.getAuthToken();
    final sett = await prefsOGx.getSettings();
    final tt = await translator.translate('messageFromGeo', sett.locale!);
    final tm = await translator.translate('memberAddedChanged', sett.locale!);
    var users = await Isolate.run(() async => await uploadUserFile(
        organizationId: organizationId,
        url: url!,
        token: token!,
        translatedTitle: tt,
        translatedMessage: tm,
        file: file));

    if (users.isNotEmpty) {
      await cacheManager.addUsers(users: users);
      organizationBloc.userController.sink.add(users);
    }

    return users;
  }

  Future<Audio?> _startAudioUpload({
    required AudioForUpload audioForUploading,
    required String audioArrived,
    required String messageFromGeo,
  }) async {
    user = await prefsOGx.getUser();
    try {
      String? url = getUrl();
      var token = await appAuth.getAuthToken();
      if (token != null) {
        pp('$xx 😡😡😡 Firebase Auth Token: 💙️ Token is GOOD! 💙 ');
      }

      var mFile = File(audioForUploading.filePath!);
      if (!mFile.existsSync()) {
        if (audioForUploading.fileBytes != null) {
          mFile = File.fromRawPath(audioForUploading.fileBytes!);
          audioForUploading.filePath = mFile.path;
        } else {
          pp('$xx File does not exist. 🔴🔴🔴 Deplaning ...');
          return null;
        }
      }

      var height = 0, width = 0;

      var distance = await locationBloc.getDistanceFromCurrentPosition(
          latitude: audioForUploading.position!.coordinates[1],
          longitude: audioForUploading.position!.coordinates[0]);

      if (user == null) {
        pp('🔴🔴🔴🔴🔴🔴🔴🔴 user is null. WTF? 🔴🔴');
        throw Exception('Fuck it! - User is NULL!!');
      } else {
        pp('$xx 🍐🍐🍐🍐🍐🍐The user is OK, distance: $distance metres');
      }

      var mJson = json.encode(audioForUploading.toJson());

      var audio = await Isolate.run(() async => await uploadAudioFile(
          objectName: 'audio${DateTime.now().millisecondsSinceEpoch}.mp3',
          url: url!,
          token: token!,
          height: height,
          width: width,
          mJson: mJson,
          audioArrived: audioArrived,
          messageFromGeo: messageFromGeo,
          distance: distance));

      if (audio != null) {
        await cacheManager.addAudio(audio: audio);
        await cacheManager.removeUploadedAudio(audio: audioForUploading);
      }

      return audio;
    } on StateError catch (e) {
      pp(e.message); // In a bad state!
    } on FormatException catch (e) {
      pp(e.message);
    }
    return null;
  }

Future uploadErrors() async {
  pp('$xx ....... uploadErrors starting ... ');

  final list = await cacheManager.getAppErrors();
  pp('$xx ....... uploadErrors ... will upload a possible list of'
      ' ${list.length} Some may have been previously uploaded');
  int cnt = 0;
  for (var value in list) {
    if (value.uploadedDate == null) {
      await dataApiDog.addAppError(value);
      value.uploadedDate = DateTime.now().toUtc().toIso8601String();
      await cacheManager.addAppError(appError: value);
      cnt++;
    }
  }

  pp('$xx uploadErrors completed. uploaded $cnt errors from cache');
}
}
