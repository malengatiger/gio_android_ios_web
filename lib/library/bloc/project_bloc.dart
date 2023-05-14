import 'dart:async';

import 'package:geo_monitor/library/data/activity_model.dart';
import 'package:geo_monitor/library/data/settings_model.dart';

import '../../device_location/device_location_bloc.dart';
import '../api/data_api_og.dart';
import '../api/prefs_og.dart';
import '../cache_manager.dart';
import '../data/audio.dart';
import '../data/community.dart';
import '../data/country.dart';
import '../data/data_bag.dart';
import '../data/field_monitor_schedule.dart';
import '../data/monitor_report.dart';
import '../data/photo.dart';
import '../data/project.dart';
import '../data/project_polygon.dart';
import '../data/project_position.dart';
import '../data/questionnaire.dart';
import '../data/user.dart';
import '../data/video.dart';
import '../functions.dart';
import 'data_refresher.dart';
import 'isolate_handler.dart';

late ProjectBloc projectBloc;

class ProjectBloc {
  final DataApiDog dataApiDog;
  final CacheManager cacheManager;
  final IsolateDataHandler isolateHandler;

  ProjectBloc(this.dataApiDog, this.cacheManager, this.isolateHandler) {
    pp('$mm ProjectBloc constructed');
  }
  final mm = '💛️💛️💛️💛️💛️💛️ '
      'ProjectBloc';
  final StreamController<DataBag> dataBagController =
      StreamController.broadcast();
  final StreamController<List<MonitorReport>> _reportController =
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

  final StreamController<List<Photo>> _projectPhotoController =
      StreamController.broadcast();
  final StreamController<List<Video>> _projectVideoController =
      StreamController.broadcast();
  final StreamController<List<Audio>> _projectAudioController =
      StreamController.broadcast();

  final StreamController<List<ProjectPosition>> _projPositionsController =
      StreamController.broadcast();
  final StreamController<List<ProjectPolygon>> _polygonController =
      StreamController.broadcast();
  final StreamController<List<ProjectPosition>> _projectPositionsController =
      StreamController.broadcast();
  final StreamController<List<FieldMonitorSchedule>>
      _fieldMonitorScheduleController = StreamController.broadcast();
  final StreamController<List<Country>> _countryController =
      StreamController.broadcast();

  final StreamController<Questionnaire> _activeQuestionnaireController =
      StreamController.broadcast();
  final StreamController<List<ActivityModel>> activityController =
      StreamController.broadcast();

  Stream<DataBag> get dataBagStream => dataBagController.stream;

  Stream<List<ActivityModel>> get activityStream => activityController.stream;

  Stream<List<Audio>> get audioStream => _projectAudioController.stream;

  Stream<List<MonitorReport>> get reportStream => _reportController.stream;

  Stream<List<Community>> get communityStream => _communityController.stream;

  Stream<List<Questionnaire>> get questionnaireStream =>
      _questController.stream;

  Stream<List<Project>> get projectStream => _projController.stream;

  Stream<List<ProjectPosition>> get projectPositionsStream =>
      _projPositionsController.stream;

  Stream<List<ProjectPolygon>> get projectPolygonsStream =>
      _polygonController.stream;

  Stream get countryStream => _countryController.stream;

  Stream<List<User>> get usersStream => _userController.stream;

  Stream get activeQuestionnaireStream => _activeQuestionnaireController.stream;

  Stream<List<FieldMonitorSchedule>> get fieldMonitorScheduleStream =>
      _fieldMonitorScheduleController.stream;

  Stream<List<Photo>> get photoStream => _photoController.stream;

  Stream<List<Video>> get videoStream => _videoController.stream;

  Future<List<ActivityModel>> getProjectActivity(
      {required String projectId,
      required int hours,
      required bool forceRefresh}) async {
    try {
      var activities =
          await cacheManager.getProjectActivitiesWithinHours(projectId, hours);

      if (activities.isEmpty || forceRefresh) {
        activities = await dataApiDog.getProjectActivity(projectId, hours);
      }
      activityController.sink.add(activities);
      pp('$mm 💜💜💜💜 getProjectActivity found: 💜 ${activities.length} activities ; organizationId: $projectId 💜');
      return activities;
    } catch (e) {
      pp('$mm $e');
      rethrow;
    }
  }

  //
  Future<List<ProjectPosition>> getProjectPositions(
      {required String projectId,
      required bool forceRefresh,
      required String startDate,
      required String endDate}) async {
    var projectPositions = await cacheManager.getProjectPositions(projectId);
    pp('$mm getProjectPositions found ${projectPositions.length} positions in local cache ');

    if (projectPositions.isEmpty || forceRefresh) {
      projectPositions =
          await dataApiDog.getProjectPositions(projectId, startDate, endDate);
      pp('$mm getProjectPositions found ${projectPositions.length} positions from remote database ');
      await cacheManager.addProjectPositions(positions: projectPositions);
    }
    _projPositionsController.sink.add(projectPositions);
    pp('$mm getProjectPositions found: 💜 ${projectPositions.length} projectPositions from local or remote db ');
    return projectPositions;
  }

  Future<List<ProjectPolygon>> getProjectPolygons(
      {required String projectId, required bool forceRefresh}) async {
    var projectPolygons =
        await cacheManager.getProjectPolygons(projectId: projectId);
    pp('$mm getProjectPolygons found ${projectPolygons.length} polygons in local cache ');

    if (projectPolygons.isEmpty || forceRefresh) {
      var map = await getStartEndDates();
      final startDate = map['startDate'];
      final endDate = map['endDate'];
      projectPolygons =
          await dataApiDog.getProjectPolygons(projectId, startDate!, endDate!);
      pp('$mm getProjectPolygons found ${projectPolygons.length} polygons from remote database ');
      await cacheManager.addProjectPolygons(polygons: projectPolygons);
    }
    _polygonController.sink.add(projectPolygons);
    pp('$mm getProjectPolygons found: 💜 ${projectPolygons.length} projectPolygons from local or remote db ');
    return projectPolygons;
  }

  Future<List<Photo>> getPhotos(
      {required String projectId,
      required bool forceRefresh,
      required String startDate,
      required String endDate}) async {
    List<Photo> photos = await cacheManager.getProjectPhotos(
        projectId: projectId, startDate: startDate, endDate: endDate);
    if (photos.isEmpty || forceRefresh) {
      photos = await dataApiDog.getProjectPhotos(
          projectId: projectId, startDate: startDate, endDate: endDate);
      await cacheManager.addPhotos(photos: photos);
    }
    photos.sort((a, b) => b.created!.compareTo(a.created!));
    _projectPhotoController.sink.add(photos);
    pp('$mm getPhotos found: 💜 ${photos.length} photos ');

    return photos;
  }

  Future<List<FieldMonitorSchedule>> getProjectFieldMonitorSchedules(
      {required String projectId, required bool forceRefresh}) async {
    var schedules = await cacheManager.getProjectMonitorSchedules(projectId);

    if (schedules.isEmpty || forceRefresh) {
      schedules = await dataApiDog.getProjectFieldMonitorSchedules(projectId);
      await cacheManager.addFieldMonitorSchedules(schedules: schedules);
    }

    _fieldMonitorScheduleController.sink.add(schedules);
    pp('🔵 🔵 🔵  MonitorBloc: getProjectFieldMonitorSchedules found: 💜 ${schedules.length} schedules ');

    return schedules;
  }

  Future<List<FieldMonitorSchedule>> getMonitorFieldMonitorSchedules(
      {required String userId, required bool forceRefresh}) async {
    var schedules = await cacheManager.getFieldMonitorSchedules(userId);

    if (schedules.isEmpty || forceRefresh) {
      schedules = await dataApiDog.getMonitorFieldMonitorSchedules(userId);
      await cacheManager.addFieldMonitorSchedules(schedules: schedules);
    }
    schedules.sort((a, b) => b.date!.compareTo(a.date!));
    _fieldMonitorScheduleController.sink.add(schedules);
    pp('🔵 🔵 🔵  MonitorBloc: getMonitorFieldMonitorSchedules found: 💜 ${schedules.length} schedules ');

    return schedules;
  }

  Future<List<Video>> getProjectVideos(
      {required String projectId,
      required bool forceRefresh,
      required String startDate,
      required String endDate}) async {
    List<Video> videos = await cacheManager.getProjectVideos(
        projectId: projectId, startDate: startDate, endDate: endDate);

    if (videos.isEmpty || forceRefresh) {
      videos = await dataApiDog.getProjectVideos(projectId, startDate, endDate);
    }
    videos.sort((a, b) => b.created!.compareTo(a.created!));
    _projectVideoController.sink.add(videos);
    pp('$mm getProjectVideos found: 💜 ${videos.length} videos ');

    return videos;
  }

  Future<List<Audio>> getProjectAudios(
      {required String projectId,
      required bool forceRefresh,
      required String startDate,
      required String endDate}) async {
    List<Audio> audios = await cacheManager.getProjectAudios(
        projectId: projectId, startDate: startDate, endDate: endDate);

    if (audios.isEmpty || forceRefresh) {
      audios = await dataApiDog.getProjectAudios(projectId, startDate, endDate);
    }
    audios.sort((a, b) => b.created!.compareTo(a.created!));

    _projectAudioController.sink.add(audios);
    pp('$mm getProjectAudios found: 💜 ${audios.length} audios ');

    return audios;
  }

  Future<DataBag> getProjectData(
      {required String projectId,
      required bool forceRefresh,
      required String startDate,
      required String endDate}) async {

    DataBag dataBag =
        await getCachedProjectData(projectId, startDate, endDate);

    if (forceRefresh) {
       isolateHandler.getProjectData(projectId);
    }

    return dataBag;
  }

  Future<DataBag> getCachedProjectData(
      String projectId, String startDate, String endDate) async {
    List<Video> videos = await cacheManager.getProjectVideos(
        projectId: projectId, startDate: startDate, endDate: endDate);
    List<Audio> audios = await cacheManager.getProjectAudios(
        projectId: projectId, startDate: startDate, endDate: endDate);
    List<Photo> photos = await cacheManager.getProjectPhotos(
        projectId: projectId, startDate: startDate, endDate: endDate);
    List<ProjectPosition> positions =
        await cacheManager.getProjectPositions(projectId);
    List<ProjectPolygon> polygons =
        await cacheManager.getProjectPolygons(projectId: projectId);
    List<SettingsModel> settings =
        await cacheManager.getProjectSettings(projectId);

    DataBag dataBag = DataBag(
        photos: photos,
        videos: videos,
        fieldMonitorSchedules: [],
        projectPositions: positions,
        projects: [],
        audios: audios,
        date: DateTime.now().toUtc().toIso8601String(),
        users: [],
        activityModels: [],
        projectPolygons: polygons,
        settings: settings);
    return dataBag;
  }

  Future updateProject(Project project) async {
    final m = await dataApiDog.updateProject(project);
    return m;
  }

  Future addProject(Project project) async {
    final m = await dataApiDog.addProject(project);
    return m;
  }

  Future<DataBag> refreshProjectData(
      {required String projectId,
      required bool forceRefresh,
      required String startDate,
      required String endDate}) async {
    pp('$mm refreshing project data ... photos, videos and schedules '
        '... forceRefresh: $forceRefresh');
    var bag = await _loadBag(
        projectId: projectId, startDate: startDate, endDate: endDate);

    if (forceRefresh) {
      bag = await dataApiDog.getProjectData(projectId, startDate, endDate);
    }
    _putBagContentsToStreams(bag);
    return bag;
  }

  Future<DataBag> _loadBag(
      {required String projectId,
      required String startDate,
      required String endDate}) async {
    var positions = await cacheManager.getProjectPositions(projectId);
    var polygons = await cacheManager.getProjectPolygons(projectId: projectId);
    var photos = await cacheManager.getProjectPhotos(
        projectId: projectId, startDate: startDate, endDate: endDate);
    var videos = await cacheManager.getProjectVideos(
        projectId: projectId, startDate: startDate, endDate: endDate);
    var audios = await cacheManager.getProjectAudios(
        projectId: projectId, startDate: startDate, endDate: endDate);
    var schedules = await cacheManager.getProjectMonitorSchedules(projectId);

    var bag = DataBag(
        photos: photos,
        videos: videos,
        fieldMonitorSchedules: schedules,
        projectPositions: positions,
        projects: [],
        audios: audios,
        date: DateTime.now().toUtc().toIso8601String(),
        users: [],
        projectPolygons: polygons,
        settings: [],
        activityModels: []);
    pp('$mm project data bag loaded: ... photos: ${photos.length}, videos: ${videos.length} and audios: ${audios.length} ...');
    return bag;
  }

  void _putBagContentsToStreams(DataBag bag) {
    pp('$mm _processBag: send data to project streams ...');
    if (bag.photos != null) {
      if (bag.photos!.isNotEmpty) {
        bag.photos?.sort((a, b) => b.created!.compareTo(a.created!));
        _photoController.sink.add(bag.photos!);
      }
    }
    if (bag.videos != null) {
      if (bag.videos!.isNotEmpty) {
        bag.videos?.sort((a, b) => b.created!.compareTo(a.created!));
        _videoController.sink.add(bag.videos!);
      }
    }
    if (bag.audios != null) {
      if (bag.audios!.isNotEmpty) {
        bag.audios?.sort((a, b) => b.created!.compareTo(a.created!));
        _audioController.sink.add(bag.audios!);
      }
    }

    if (bag.projectPositions != null) {
      if (bag.projectPositions!.isNotEmpty) {
        _projectPositionsController.sink.add(bag.projectPositions!);
      }
    }
  }

  Future<List<Project>> getProjectsWithinRadius(
      {double radiusInKM = 100.5, bool checkUserOrg = true}) async {
    var user = await prefsOGx.getUser();
    var pos = await locationBloc.getLocation();
    try {
      if (pos != null) {
        pp('$mm current location: 💜 latitude: ${pos.latitude} longitude: ${pos.longitude}');
      } else {
        return [];
      }
    } catch (e) {
      pp('MonitorBloc: Location is fucked!');
      rethrow;
    }
    var projects = await dataApiDog.findProjectsByLocation(
        organizationId: user!.organizationId!,
        latitude: pos.latitude!,
        longitude: pos.longitude!,
        radiusInKM: radiusInKM);

    List<Project> userProjects = [];

    pp('$mm Projects within radius of  🍏 $radiusInKM  🍏 kilometres; '
        'found: 💜 ${projects.length} projects');
    for (var project in projects) {
      pp('$mm 😡 ALL PROJECT found in radius: ${project.name} 🍏 ${project.organizationName}  🍏 ${project.organizationId}');
      if (project.organizationId == user!.organizationId) {
        userProjects.add(project);
      }
    }

    pp('$mm User Org Projects within radius of $radiusInKM kilometres; '
        'found: 💜 ${userProjects.length} projects in organization, filtered out non-org projects found in radius');

    if (checkUserOrg) {
      return userProjects;
    } else {
      return projects;
    }
  }
}
