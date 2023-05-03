import 'dart:async';

import 'package:geo_monitor/library/bloc/isolate_handler.dart';
import 'package:geo_monitor/library/bloc/organization_bloc.dart';
import 'package:geo_monitor/library/bloc/zip_bloc.dart';
import 'package:geo_monitor/library/data/data_bag.dart';

import '../api/data_api_og.dart';
import '../cache_manager.dart';
import '../data/activity_model.dart';
import '../data/audio.dart';
import '../data/community.dart';
import '../data/field_monitor_schedule.dart';
import '../data/photo.dart';
import '../data/project.dart';
import '../data/project_position.dart';
import '../data/questionnaire.dart';
import '../data/user.dart';
import '../data/video.dart';
import '../functions.dart';
import 'data_refresher.dart';

late UserBloc userBloc;

class UserBloc {
  final DataApiDog dataApiDog;
  final CacheManager cacheManager;
  final IsolateDataHandler isolateDataHandler;
  UserBloc(this.dataApiDog, this.cacheManager, this.isolateDataHandler) {
    pp('UserBloc constructed');
  }

  User? _user;

  User get user => _user!;
  final StreamController<DataBag> dataBagController =
      StreamController.broadcast();
  final StreamController<List<Community>> _reportController =
  StreamController.broadcast();
  final StreamController<List<User>> _userController =
      StreamController.broadcast();
  final StreamController<List<Community>> _communityController =
      StreamController.broadcast();
  final StreamController<List<Questionnaire>> _questController =
      StreamController.broadcast();
  final StreamController<List<Project>> _projController =
      StreamController.broadcast();
  final StreamController<List<Photo>> _photoController =
      StreamController.broadcast();
  final StreamController<List<Video>> _videoController =
      StreamController.broadcast();
  final StreamController<List<Audio>> _audioController =
      StreamController.broadcast();

  final StreamController<List<ProjectPosition>> _projPositionsController =
      StreamController.broadcast();
  final StreamController<List<FieldMonitorSchedule>>
      _fieldMonitorScheduleController = StreamController.broadcast();

  final StreamController<List<ActivityModel>> activityController =
      StreamController.broadcast();

  Stream<List<ActivityModel>> get activityStream => activityController.stream;

  Stream get dataBagStream => dataBagController.stream;

  Stream get audioStream => _audioController.stream;

  Stream get reportStream => _reportController.stream;

  Stream get settlementStream => _communityController.stream;

  Stream get questionnaireStream => _questController.stream;

  Stream get fieldMonitorScheduleStream =>
      _fieldMonitorScheduleController.stream;

  Stream<List<Photo>> get photoStream => _photoController.stream;

  Stream<List<Video>> get videoStream => _videoController.stream;

  static const mm = '💜💜💜 UserBloc 💜: ';

  Future<List<ActivityModel>> getUserActivity(
      {required String userId,
      required int hours,
      required bool forceRefresh}) async {
    try {
      var activities =
          await cacheManager.getUserActivitiesWithinHours(userId, hours);

      if (activities.isEmpty || forceRefresh) {
        activities = await dataApiDog.getUserActivity(userId, hours);
      }
      activityController.sink.add(activities);
      pp('$mm 💜💜💜💜 getUserActivity found: 💜 ${activities.length} activities ; organizationId: $userId 💜');
      return activities;
    } catch (e) {
      pp('$mm $e');
      rethrow;
    }
  }

  Future<List<Photo>> getPhotos(
      {required String userId, required bool forceRefresh}) async {
    // var android = UniversalPlatform.isAndroid;
    var photos = await cacheManager.getUserPhotos(userId);

    if (photos.isEmpty || forceRefresh) {
      photos = await dataApiDog.getUserProjectPhotos(userId);
    }
    _photoController.sink.add(photos);
    pp('$mm getUserProjectPhotos found: 💜 ${photos.length} photos ');
    return photos;
  }

  Future<List<Video>> getVideos(
      {required String userId, required bool forceRefresh}) async {
    // var android = UniversalPlatform.isAndroid;
    var videos = await cacheManager.getUserVideos(userId);

    if (videos.isEmpty || forceRefresh) {
      videos = await dataApiDog.getUserProjectVideos(userId);
    }
    _videoController.sink.add(videos);
    pp('$mm getUserProjectVideos found: 💜 ${videos.length} videos ');
    return videos;
  }

  Future<List<Audio>> getAudios(
      {required String userId, required bool forceRefresh}) async {
    // var android = UniversalPlatform.isAndroid;
    var audios = await cacheManager.getUserAudios(userId);

    if (audios.isEmpty || forceRefresh) {
      audios = await dataApiDog.getUserProjectAudios(userId);
    }
    _audioController.sink.add(audios);
    pp('$mm getAudios found: 💜 ${audios.length} audios ');
    return audios;
  }

  Future<List<FieldMonitorSchedule>> getFieldMonitorSchedules(
      {required String userId, required bool forceRefresh}) async {
    // var android = UniversalPlatform.isAndroid;
    var schedules = await cacheManager.getProjectMonitorSchedules(userId);

    if (schedules.isEmpty || forceRefresh) {
      schedules = await dataApiDog.getUserFieldMonitorSchedules(userId);
    }
    _fieldMonitorScheduleController.sink.add(schedules);
    pp('$mm getFieldMonitorSchedules found: 💜 ${schedules.length} schedules ');
    return schedules;
  }

  Future<DataBag> getUserData(
      {required String userId, required bool forceRefresh,required String startDate, required String endDate}) async {
    pp('$mm refreshUserData ... forceRefresh: $forceRefresh');
    final sDate = DateTime.parse(startDate);
    final eDate = DateTime.parse(endDate);
    final numberOfDays = eDate.difference(sDate).inDays;
    //todo - for monitor, only their projects must show
    DataBag? bag = await cacheManager.getUserData(userId: userId);
    if (forceRefresh || bag.isEmpty()) {
      dataHandler.getOrganizationData();

    }
    pp('$mm filter bag by the dates ....');
    var mBag = filterBagContentsByDate(bag: bag!,  startDate: startDate, endDate: endDate);
    dataBagController.sink.add(mBag);
    pp('$mm filtered bag ....');
    printDataBag(mBag);
    return mBag;
  }

  close() {
    _communityController.close();
    _questController.close();
    _projController.close();
    _userController.close();

    _reportController.close();
    _projPositionsController.close();

    _videoController.close();
    _photoController.close();
    _fieldMonitorScheduleController.close();
  }
}
