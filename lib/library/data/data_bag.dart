import 'package:geo_monitor/library/data/activity_model.dart';
import 'package:geo_monitor/library/data/project_polygon.dart';
import 'package:geo_monitor/library/data/settings_model.dart';
import 'package:hive/hive.dart';

import '../functions.dart';
import 'audio.dart';
import 'user.dart';
import 'field_monitor_schedule.dart';
import 'photo.dart';
import 'project.dart';
import 'project_position.dart';
import 'video.dart';

part 'data_bag.g.dart';

@HiveType(typeId: 18)
class DataBag {
  @HiveField(0)
  List<Photo>? photos;
  @HiveField(1)
  List<Video>? videos;
  @HiveField(2)
  List<FieldMonitorSchedule>? fieldMonitorSchedules;
  @HiveField(3)
  List<ProjectPosition>? projectPositions;
  @HiveField(4)
  List<Project>? projects;
  @HiveField(5)
  String? date;
  @HiveField(6)
  List<User>? users;
  @HiveField(7)
  List<ProjectPolygon>? projectPolygons;
  @HiveField(8)
  @HiveField(8)
  List<Audio>? audios;
  @HiveField(9)
  List<SettingsModel>? settings;
  @HiveField(10)
  List<ActivityModel>? activityModels;


  DataBag({
    required this.photos,
    required this.videos,
    required this.fieldMonitorSchedules,
    required this.projectPositions,
    required this.projects,
    required this.audios,
    required this.date, required this.users,
    required this.activityModels,
    required this.projectPolygons, required this.settings,
  });

  DataBag.fromJson(Map data) {
    date = data['date'];
    activityModels = [];
    if (data['activityModels'] != null) {
      List m = data['activityModels'];
      for (var element in m) {
        var pos = ActivityModel.fromJson(element);
        activityModels?.add(pos);
      }
    }
    users = [];
    if (data['users'] != null) {
      List m = data['users'];
      for (var element in m) {
        var pos = User.fromJson(element);
        users?.add(pos);
      }
    }
    settings = [];
    if (data['settings'] != null) {
      List m = data['settings'];
      for (var element in m) {
        var pos = SettingsModel.fromJson(element);
        settings?.add(pos);
      }
    }
    audios = [];
    if (data['audios'] != null) {
      List m = data['audios'];
      for (var element in m) {
        var pos = Audio.fromJson(element);
        audios?.add(pos);
      }
    }
    projectPolygons = [];
    if (data['projectPolygons'] != null) {
      List m = data['projectPolygons'];
      for (var element in m) {
        var pos = ProjectPolygon.fromJson(element);
        projectPolygons?.add(pos);
      }
    }
    projectPositions = [];
    if (data['projectPositions'] != null) {
      List m = data['projectPositions'];
      for (var element in m) {
        var pos = ProjectPosition.fromJson(element);
        projectPositions?.add(pos);
      }
    }
    projects = [];
    if (data['projects'] != null) {
      List m = data['projects'];
      for (var element in m) {
        var project = Project.fromJson(element);
        projects?.add(project);
      }
    }
    photos = [];
    if (data['photos'] != null) {
      List m = data['photos'];
      for (var element in m) {
        var photo = Photo.fromJson(element);
        photos?.add(photo);
      }
    }
    videos = [];
    if (data['videos'] != null) {
      List m = data['videos'];
      for (var element in m) {
        var video = Video.fromJson(element);
        videos?.add(video);
      }
    }
    fieldMonitorSchedules = [];
    if (data['fieldMonitorSchedules'] != null) {
      List m = data['fieldMonitorSchedules'];
      for (var element in m) {
        var schedule = FieldMonitorSchedule.fromJson(element);
        fieldMonitorSchedules?.add(schedule);
      }
    }
  }
  Map<String, dynamic> toJson() {
    List mEvents = [];
    if (activityModels != null) {
      for (var r in activityModels!) {
        mEvents.add(r.toJson());
      }
    }
    List mSettings = [];
    if (settings != null) {
      for (var r in settings!) {
        mSettings.add(r.toJson());
      }
    }
    List mPhotos = [];
    if (photos != null) {
      for (var r in photos!) {
        mPhotos.add(r.toJson());
      }
    }
    List mAudios = [];
    if (audios != null) {
      for (var r in audios!) {
        mAudios.add(r.toJson());
      }
    }
    List mVideos = [];
    if (videos != null) {
      for (var r in videos!) {
        mVideos.add(r.toJson());
      }
    }
    List mSchedules = [];
    if (fieldMonitorSchedules != null) {
      for (var r in fieldMonitorSchedules!) {
        mSchedules.add(r.toJson());
      }
    }
    List mProjects = [];
    if (projects != null) {
      for (var r in projects!) {
        mProjects.add(r.toJson());
      }
    }
    List mPositions = [];
    if (projectPositions != null) {
      for (var r in projectPositions!) {
        mPositions.add(r.toJson());
      }
    }
    List mPolygons = [];
    if (projectPolygons != null) {
      for (var r in projectPolygons!) {
        mPolygons.add(r.toJson());
      }
    }
    List mUsers = [];
    if (users != null) {
      for (var r in users!) {
        mUsers.add(r.toJson());
      }
    }

    Map<String, dynamic> map = {
      'photos': mPhotos,
      'videos': mVideos,
      'fieldMonitorSchedules': mSchedules,
      'projectPositions': mPositions,
      'projectPolygons': mPolygons,
      'projects': mProjects,
      'users': mUsers,
      'audios': mAudios,
      'settings': mSettings,
      'date': date,
      'activityModels': mEvents,
    };
    return map;
  }
  bool isEmpty() {
    int count = 0;
    if (users!.isNotEmpty) {
     count++;
    }
    if (projects!.isNotEmpty) {
     count++;
    }
    if (projectPositions!.isNotEmpty) {
     count++;
    }
    if (projectPolygons!.isNotEmpty) {
     count++;
    }
    if (photos!.isNotEmpty) {
     count++;
    }
    if (videos!.isNotEmpty) {
     count++;
    }
    if (fieldMonitorSchedules!.isNotEmpty) {
     count++;
    }
    if (count == 0) {
      pp('💙💙💙 DataBag is empty, barren and no can do, Boss!');
      return true;
    }

    return false;
  }



}
